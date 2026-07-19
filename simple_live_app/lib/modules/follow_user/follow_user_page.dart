import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/app/platform_utils.dart';
import 'package:simple_live_app/app/utils.dart';
import 'package:simple_live_app/models/db/follow_user.dart';
import 'package:simple_live_app/models/db/follow_user_tag.dart';
import 'package:simple_live_app/modules/follow_user/follow_user_controller.dart';
import 'package:simple_live_app/services/current_room_service.dart';
import 'package:simple_live_app/services/follow_service.dart';
import 'package:simple_live_app/widgets/filter_button.dart';
import 'package:simple_live_app/widgets/follow_user_item.dart';
import 'package:simple_live_app/widgets/page_grid_view.dart';

class FollowUserPage extends GetView<FollowUserController> {
  const FollowUserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.batchManageMode.value
            ? "已选 ${controller.selectedBatchKeys.length} 项"
            : "关注用户")),
        actions: [
          Obx(
            () => controller.batchManageMode.value
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: () =>
                            controller.batchSetSpecialFollow(true),
                        icon: const Icon(Icons.star),
                        label: const Text("特别关注"),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            controller.batchSetSpecialFollow(false),
                        icon: const Icon(Icons.star_border),
                        label: const Text("取消特别关注"),
                      ),
                      IconButton(
                        tooltip: "取消",
                        onPressed: controller.toggleBatchManageMode,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
          IconButton(
            tooltip: "批量管理",
            onPressed: controller.toggleBatchManageMode,
            icon: const Icon(Icons.checklist),
          ),
          IconButton(
            tooltip: "搜索主播",
            onPressed: () => _showSearchDialog(context),
            icon: Obx(
              () => Icon(
                controller.searchKeyword.value.isEmpty
                    ? Icons.search
                    : Icons.manage_search,
              ),
            ),
          ),
          IconButton(
            tooltip: "显示与筛选",
            onPressed: () => _showDisplaySheet(context),
            icon: const Icon(Icons.tune),
          ),
          Obx(
            () => Visibility(
              visible: controller.paginationEnabled.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: "上一页",
                    onPressed: controller.currentDisplayPage.value > 1
                        ? controller.goToPreviousPage
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    "${controller.currentDisplayPage.value}/${controller.totalDisplayPages.value}",
                  ),
                  IconButton(
                    tooltip: "下一页",
                    onPressed: controller.currentDisplayPage.value <
                            controller.totalDisplayPages.value
                        ? controller.goToNextPage
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                  IconButton(
                    tooltip: "刷新当前页",
                    onPressed: controller.refreshCurrentPageStatus,
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    tooltip: "刷新全部",
                    onPressed: controller.refreshAllStatus,
                    icon: const Icon(Icons.sync),
                  ),
                ],
              ),
            ),
          ),
          if (PlatformUtils.supportsInlineMultiRoom) ...[
            Obx(
              () => TextButton.icon(
                onPressed: controller.multiSelectMode.value
                    ? controller.openSelectedMultiRooms
                    : controller.toggleMultiSelectMode,
                icon: Icon(
                  controller.multiSelectMode.value
                      ? Icons.grid_view
                      : Icons.grid_view_outlined,
                ),
                label: Text(
                  controller.multiSelectMode.value
                      ? "开始同屏(${controller.selectedMultiRoomKeys.length})"
                      : "多开同屏",
                ),
              ),
            ),
            Obx(
              () => Visibility(
                visible: controller.multiSelectMode.value,
                child: IconButton(
                  tooltip: "取消多选",
                  onPressed: controller.toggleMultiSelectMode,
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ],
          PopupMenuButton(
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Remix.save_2_line),
                      AppStyle.hGap12,
                      Text("导出文件")
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Remix.folder_open_line),
                      AppStyle.hGap12,
                      Text("导入文件")
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Remix.text),
                      AppStyle.hGap12,
                      Text("导出文本"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Remix.file_text_line),
                      AppStyle.hGap12,
                      Text("导入文本"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Remix.price_tag_line),
                      AppStyle.hGap12,
                      Text("标签管理"),
                    ],
                  ),
                ),
              ];
            },
            onSelected: (value) {
              if (value == 0) {
                FollowService.instance.exportFile();
              } else if (value == 1) {
                FollowService.instance.inputFile();
              } else if (value == 2) {
                FollowService.instance.exportText();
              } else if (value == 3) {
                FollowService.instance.inputText();
              } else if (value == 4) {
                showTagsManager();
              }
            },
          ),
                  ],
                ),
              ),
        ],
        leading: Obx(
          () => FollowService.instance.updating.value
              ? const IconButton(
                  onPressed: null,
                  icon: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  onPressed: () {
                    controller.refreshData();
                  },
                  icon: const Icon(Icons.refresh),
                ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(
                () => _buildRefreshProgress(context),
              ),
              Expanded(
                child: Obx(
                  () {
                    final layout = _resolveLayoutSpec(context);
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragEnd: (details) {
                        if (!controller.paginationEnabled.value) {
                          return;
                        }
                        final velocity = details.primaryVelocity ?? 0;
                        if (velocity < -260) {
                          controller.goToNextPage();
                        } else if (velocity > 260) {
                          controller.goToPreviousPage();
                        }
                      },
                      child: PageGridView(
                        padding: const EdgeInsets.only(bottom: 96.0, left: 8, right: 8, top: 8),
                        crossAxisSpacing: layout.crossAxisSpacing,
                        mainAxisSpacing: layout.mainAxisSpacing,
                        mainAxisExtent: layout.mainAxisExtent,
                        childAspectRatio: layout.childAspectRatio,
                        useFixedGrid: true,
                        crossAxisCount: layout.crossAxisCount,
                        pageController: controller,
                        firstRefresh: false,
                        showPCRefreshButton: false,
                        itemBuilder: (_, i) {
                          final item = controller.list[i];
                          final isCurrent = "${item.siteId}_${item.roomId}" ==
                              CurrentRoomService.instance.currentKey;
                          return Obx(
                            () => FollowUserItem(
                              item: item,
                              style: layout.itemStyle,
                              showLiveCover: AppSettingsController
                                  .instance.followShowLiveCover.value,
                              batchSelected: controller.selectedBatchKeys
                                  .contains(item.id),
                              onBatchTap: () =>
                                  controller.toggleBatchItem(item),
                            onSpecialTap: () {
                              controller.toggleSpecialFollow(item);
                            },
                            onRemove: () {
                              controller.removeItem(item);
                            },
                            onTap: () {
                              if (controller.batchManageMode.value) {
                                controller.toggleBatchItem(item);
                                return;
                              }
                              if (PlatformUtils.supportsInlineMultiRoom &&
                                  controller.multiSelectMode.value) {
                                controller.toggleMultiRoomItem(item);
                                return;
                              }
                              controller.openFollowRoom(item);
                            },
                            onLongPress: () {
                              setFollowTagDialog(item);
                            },
                            playing: controller.isSelectedForMultiRoom(item) ||
                                isCurrent,
                          ),
                        );
                      },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Obx(
            () => controller.paginationEnabled.value
                ? Positioned(
                    left: 16,
                    right: 16,
                    bottom: Platform.isAndroid || Platform.isIOS ? 12 : 18,
                    child: _buildFloatingPaginationBar(context),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  _FollowLayoutSpec _resolveLayoutSpec(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final style = AppSettingsController.instance.followDisplayStyle.value;
    final showLiveCover =
        AppSettingsController.instance.followShowLiveCover.value;
    final mobile = PlatformUtils.isMobileApp;
    if (style == "compact") {
      return _FollowLayoutSpec(
        itemStyle: FollowUserItemStyle.compactList,
        crossAxisCount: mobile ? 1 : (width >= 1440 ? 2 : 1),
        mainAxisExtent:
            showLiveCover ? (mobile ? 112 : 118) : (mobile ? 70 : 78),
        childAspectRatio: 3.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: showLiveCover ? 10 : 8,
      );
    }
    if (style == "card") {
      final crossAxisCount = mobile
          ? (width >= 720 ? 3 : 2)
          : (width >= 1680 ? 4 : (width >= 1220 ? 3 : 2));
      final availableWidth = width - 16 - (crossAxisCount - 1) * 16;
      final cardWidth = availableWidth / crossAxisCount;
      final coverHeight = cardWidth * 9 / 16;
      final cardExtent = showLiveCover
          ? coverHeight + 56
          : (mobile ? 178.0 : 190.0);
      return _FollowLayoutSpec(
        itemStyle: FollowUserItemStyle.card,
        crossAxisCount: crossAxisCount,
        mainAxisExtent: cardExtent,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      );
    }
    return _FollowLayoutSpec(
      itemStyle: FollowUserItemStyle.defaultList,
      crossAxisCount: mobile ? 1 : (width >= 1520 ? 2 : 1),
      mainAxisExtent: showLiveCover ? (mobile ? 132 : 138) : (mobile ? 82 : 92),
      childAspectRatio: 3.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: showLiveCover ? 10 : 8,
    );
  }

  Future<void> _showSearchDialog(BuildContext context) async {
    final textController = TextEditingController(
      text: controller.searchKeyword.value,
    );
    await Get.dialog(
      AlertDialog(
        title: const Text("搜索主播"),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "只按主播名字本地搜索",
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: () {
                textController.clear();
              },
              icon: const Icon(Icons.clear),
            ),
          ),
          onSubmitted: (value) {
            controller.setSearchKeyword(value);
            Get.back();
          },
        ),
        actions: [
          if (controller.searchKeyword.value.isNotEmpty)
            TextButton(
              onPressed: () {
                controller.clearSearchKeyword();
                Get.back();
              },
              child: const Text("清空"),
            ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("取消"),
          ),
          FilledButton(
            onPressed: () {
              controller.setSearchKeyword(textController.text);
              Get.back();
            },
            child: const Text("搜索"),
          ),
        ],
      ),
    );
  }

  void _showDisplaySheet(BuildContext context) {
    final theme = Theme.of(context);
    Utils.showBottomSheet(
      title: "显示与筛选",
      child: Obx(
        () {
          final settings = AppSettingsController.instance;
          final isStatusMode =
              controller.groupMode.value == FollowGroupMode.liveStatus;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 分组方式 ──
              Padding(
                padding: AppStyle.edgeInsetsH8.copyWith(top: 8),
                child: Text("分组方式",
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: AppStyle.edgeInsetsH8,
                child: SegmentedButton<FollowGroupMode>(
                  segments: const [
                    ButtonSegment(
                        value: FollowGroupMode.liveStatus,
                        label: Text("按状态"),
                        icon: Icon(Icons.circle, size: 16)),
                    ButtonSegment(
                        value: FollowGroupMode.platform,
                        label: Text("按平台"),
                        icon: Icon(Icons.language, size: 16)),
                  ],
                  selected: {controller.groupMode.value},
                  onSelectionChanged: (v) => controller.setGroupMode(v.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor:
                        theme.colorScheme.primaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ── 分组选项 ──
              Padding(
                padding: AppStyle.edgeInsetsH8,
                child: Text(
                    isStatusMode ? "直播状态" : "直播平台",
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: AppStyle.edgeInsetsH8,
                child: Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.groupOptions.map((option) {
                      return ChoiceChip(
                        label: Text(option.title),
                        selected:
                            controller.selectedGroupId.value == option.id,
                        selectedColor: theme.colorScheme.primary,
                        onSelected: (_) {
                          controller.setGroupOption(option);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              AppStyle.divider,
              // ── 自动刷新 ──
              SwitchListTile(
                contentPadding: AppStyle.edgeInsetsH8,
                title: const Text("进入关注页后自动刷新"),
                value: settings.followRefreshOnEnter.value,
                onChanged: (value) async {
                  if (value) {
                    final confirmed = await Utils.showAlertDialog(
                      "开启后，每次进入关注页都会先显示本地列表，再异步发起一次全量刷新。关注过多时，极其容易触发抖音限制。",
                      title: "风险提示",
                      confirm: "继续开启",
                    );
                    if (!confirmed) return;
                  }
                  controller.setRefreshOnEnter(value);
                },
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloatingPaginationBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        child: Material(
          elevation: 8,
          color: Theme.of(context).colorScheme.surface.withAlpha(242),
          borderRadius: AppStyle.radius8,
          child: Padding(
            padding: AppStyle.edgeInsetsH12.add(AppStyle.edgeInsetsV4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: "上一页",
                  onPressed: controller.currentDisplayPage.value > 1
                      ? controller.goToPreviousPage
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  "${controller.currentDisplayPage.value}/${controller.totalDisplayPages.value}",
                ),
                IconButton(
                  tooltip: "下一页",
                  onPressed: controller.currentDisplayPage.value <
                          controller.totalDisplayPages.value
                      ? controller.goToNextPage
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
                AppStyle.hGap8,
                TextButton.icon(
                  onPressed: controller.refreshCurrentPageStatus,
                  icon: const Icon(Icons.refresh),
                  label: const Text("当前页"),
                ),
                AppStyle.hGap4,
                TextButton.icon(
                  onPressed: controller.refreshAllStatus,
                  icon: const Icon(Icons.sync),
                  label: const Text("全部"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshProgress(BuildContext context) {
    final progress = FollowService.instance.refreshProgress.value;
    if (!progress.active) {
      return const SizedBox.shrink();
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: AppStyle.edgeInsetsH8.copyWith(top: 4, bottom: 4),
      child: Material(
        color: colorScheme.surfaceContainerHighest.withAlpha(
          progress.automatic ? 180 : 220,
        ),
        borderRadius: AppStyle.radius8,
        child: Padding(
          padding: AppStyle.edgeInsetsA12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      progress.stage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text("${progress.resolvedCount}/${progress.total}"),
                ],
              ),
              if (progress.detail.isNotEmpty) ...[
                AppStyle.vGap4,
                Text(
                  progress.detail,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              AppStyle.vGap8,
              LinearProgressIndicator(
                value: progress.total > 0 ? progress.percent : null,
                minHeight: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setFollowTagDialog(FollowUser item) {
    List<FollowUserTag> copiedList = [
      controller.tagList.first,
      ...controller.tagList.skip(3),
    ];
    Rx<FollowUserTag> checkTag = copiedList
        .firstWhere(
          (tag) => tag.tag == item.tag,
          orElse: () => copiedList.first,
        )
        .obs;
    final ScrollController scrollController = ScrollController();
    Get.dialog(
      AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '设置标签',
                  style: TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    controller.setItemTag(item, checkTag.value);
                    Get.back();
                  },
                ),
              ],
            ),
            const Divider(),
            Obx(
              () {
                int selectedIndex = copiedList.indexOf(checkTag.value);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (selectedIndex >= 0) {
                    scrollController.animateTo(
                      selectedIndex * 60.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                });
                return SizedBox(
                  height: 300,
                  width: 300,
                  child: RadioGroup(
                    groupValue: checkTag.value,
                    onChanged: (value) {
                      checkTag.value = value!;
                    },
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: copiedList.length,
                      itemBuilder: (context, index) {
                        var tagItem = copiedList[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: RadioListTile<FollowUserTag>(
                            title: Text(tagItem.tag),
                            value: tagItem,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void showTagsManager() {
    Utils.showBottomSheet(
      title: '标签管理',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppStyle.divider,
          ListTile(
            title: const Text("添加标签"),
            leading: const Icon(Icons.add),
            onTap: () {
              editTagDialog("添加标签");
            },
          ),
          AppStyle.divider,
          Expanded(
            child: Obx(
              () => ReorderableListView.builder(
                itemCount: controller.userTagList.length,
                itemBuilder: (context, index) {
                  FollowUserTag item = controller.userTagList[index];
                  return ListTile(
                    key: ValueKey(item.id),
                    title: GestureDetector(
                      child: Text(item.tag),
                      onLongPress: () {
                        editTagDialog("修改标签", followUserTag: item);
                      },
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        controller.removeTag(item);
                      },
                    ),
                  );
                },
                onReorder: (int oldIndex, int newIndex) {
                  controller.updateTagOrder(oldIndex, newIndex);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void editTagDialog(String title, {FollowUserTag? followUserTag}) {
    final TextEditingController tagEditController =
        TextEditingController(text: followUserTag?.tag);
    bool upMode = title == "添加标签";
    Get.dialog(
      AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        content: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 18)),
              TextField(
                controller: tagEditController,
                minLines: 1,
                maxLines: 1,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding: AppStyle.edgeInsetsA12,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.withAlpha(51),
                    ),
                  ),
                ),
                onSubmitted: (_) {
                  upMode
                      ? controller.addTag(tagEditController.text)
                      : controller.updateTagName(
                          followUserTag!,
                          tagEditController.text,
                        );
                  Get.back();
                },
              ),
              Container(
                margin: AppStyle.edgeInsetsB4,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text('否'),
                    ),
                    TextButton(
                      onPressed: () {
                        upMode
                            ? controller.addTag(tagEditController.text)
                            : controller.updateTagName(
                                followUserTag!,
                                tagEditController.text,
                              );
                        Get.back();
                      },
                      child: const Text('是'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowLayoutSpec {
  final FollowUserItemStyle itemStyle;
  final int crossAxisCount;
  final double mainAxisExtent;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const _FollowLayoutSpec({
    required this.itemStyle,
    required this.crossAxisCount,
    required this.mainAxisExtent,
    required this.childAspectRatio,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
  });
}

