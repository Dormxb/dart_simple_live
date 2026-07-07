const fs = require("fs");

const marker = "<!-- dart-simple-live-discussion-poll-chart -->";
const owner = process.env.REPO_OWNER;
const repo = process.env.REPO_NAME;
const discussionNumber = Number(process.env.DISCUSSION_NUMBER || "68");
const token = process.env.GITHUB_TOKEN;
const outputPath = process.env.OUTPUT_PATH || "poll-comment.md";
const dryRun = process.env.DRY_RUN === "true";

if (!owner || !repo || !discussionNumber || !token) {
  throw new Error("Missing REPO_OWNER, REPO_NAME, DISCUSSION_NUMBER, or GITHUB_TOKEN.");
}

async function graphql(query, variables) {
  const response = await fetch("https://api.github.com/graphql", {
    method: "POST",
    headers: {
      "authorization": `Bearer ${token}`,
      "content-type": "application/json",
      "user-agent": "dart-simple-live-poll-chart",
    },
    body: JSON.stringify({ query, variables }),
  });

  const payload = await response.json();
  if (!response.ok || payload.errors) {
    throw new Error(JSON.stringify(payload.errors || payload, null, 2));
  }
  return payload.data;
}

function percent(count, total) {
  if (total === 0) return "0.0";
  return ((count / total) * 100).toFixed(1);
}

function buildContent(discussion) {
  const poll = discussion.poll;
  if (!poll) {
    throw new Error(`Discussion #${discussionNumber} does not have a poll.`);
  }

  const total = poll.totalVoteCount;
  const rows = poll.options.nodes
    .map((item) => {
      const rate = percent(item.totalVoteCount, total);
      return `| ${item.option} | ${item.totalVoteCount} | ${rate}% |`;
    })
    .join("\n");

  return `${marker}
## 投票实时统计

**${poll.question}**

| 选项 | 票数 | 占比 |
|---|---:|---:|
${rows}
| **合计** | **${total}** | **100%** |`;
}

function buildBody(discussion) {
  const content = buildContent(discussion);
  const updatedAt = new Date().toISOString().replace("T", " ").replace(/\.\d{3}Z$/, " UTC");

  return `${content}

更新时间：${updatedAt}

> 此评论由 GitHub Actions 自动更新。`;
}

function hasCurrentPollContent(commentBody, content) {
  return typeof commentBody === "string" && commentBody.includes(content);
}

function isPermissionError(error) {
  const message = error instanceof Error ? error.message : String(error);
  return message.includes("FORBIDDEN") || message.includes("Resource not accessible by integration");
}

function pickLatestManagedComment(comments) {
  return comments
    .filter((comment) => comment.body.includes(marker))
    .sort((left, right) => new Date(right.createdAt).getTime() - new Date(left.createdAt).getTime());
}

const query = `
query($owner:String!, $repo:String!, $number:Int!) {
  repository(owner:$owner, name:$repo) {
    discussion(number:$number) {
      id
      title
      poll {
        question
        totalVoteCount
        options(first: 50) {
          nodes {
            option
            totalVoteCount
          }
        }
      }
      comments(last: 100) {
        nodes {
          id
          body
          createdAt
          viewerCanUpdate
        }
      }
    }
  }
}`;

const addMutation = `
mutation($discussionId:ID!, $body:String!) {
  addDiscussionComment(input:{discussionId:$discussionId, body:$body}) {
    comment { id }
  }
}`;

const updateMutation = `
mutation($commentId:ID!, $body:String!) {
  updateDiscussionComment(input:{commentId:$commentId, body:$body}) {
    comment { id }
  }
}`;

(async () => {
  const data = await graphql(query, { owner, repo, number: discussionNumber });
  const discussion = data.repository.discussion;
  if (!discussion) {
    throw new Error(`Discussion #${discussionNumber} was not found.`);
  }

  const content = buildContent(discussion);
  const body = buildBody(discussion);
  fs.writeFileSync(outputPath, `${body}\n`, "utf8");

  if (dryRun) {
    console.log(body);
    console.log("Dry run enabled; skipped creating or updating the discussion comment.");
    return;
  }

  const managedComments = pickLatestManagedComment(discussion.comments.nodes);
  const editable = managedComments.find((comment) => comment.viewerCanUpdate);
  const current = editable || managedComments[0];

  if (!current) {
    const result = await graphql(addMutation, { discussionId: discussion.id, body });
    console.log(`Created poll chart comment: ${result.addDiscussionComment.comment.id}`);
    return;
  }

  if (current.viewerCanUpdate) {
    try {
      await graphql(updateMutation, { commentId: current.id, body });
      console.log(`Updated poll chart comment: ${current.id}`);
      return;
    } catch (error) {
      if (!isPermissionError(error)) {
        throw error;
      }
      console.warn(`Unable to update managed comment ${current.id}; falling back to add a new comment.`);
    }
  } else if (hasCurrentPollContent(current.body, content)) {
    console.log(`Managed comment ${current.id} already has the latest poll data; skipped timestamp-only refresh.`);
    return;
  } else {
    console.warn(`Managed comment ${current.id} is not editable by the current token; creating a new comment instead.`);
  }

  try {
    const result = await graphql(addMutation, { discussionId: discussion.id, body });
    console.log(`Created poll chart comment: ${result.addDiscussionComment.comment.id}`);
  } catch (error) {
    if (isPermissionError(error) && hasCurrentPollContent(current.body, content)) {
      console.log(`Managed comment ${current.id} already has the latest poll data; skipped after add permission failure.`);
      return;
    }
    throw error;
  }
})();
