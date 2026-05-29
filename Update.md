# Update

## 2026-05-30

本次记录对应 `1286495 fix some issues and bugs` 与 `ab9dd4a docs: clarify subtitle model downloads`。

### 已完成

- `fix:` 抖音弹幕表情改为按 `rtfContent.piecesList` 富文本片段解析，聊天区按文字和图片顺序显示，不再只把图片追加到消息末尾。
- `fix:` 抖音表情图片无法解析成 URL 时保留文字占位，减少表情消息内容丢失；不再把背景图、礼物图混成普通聊天表情。
- `update:` `LiveMessage` 增加有序富文本片段，旧的 `imageUrls` 仍保留，主 App 和 TV 端继续兼容旧渲染路径。
- `update:` 抖音账号登录入口改为优先调用系统浏览器打开抖音，登录后回 App 粘贴完整 Cookie；TV 端保持无浏览器方案，通过手机或电脑同步 Cookie。
- `fix:` Android 非全屏播放页恢复竖屏布局，适配 realme 侧边栏双击全屏后再次双击退出的场景。
- `fix:` PiP/小窗进入和返回时不再主动清空弹幕层，减少从小窗回全屏时弹幕像重新刷新的问题。
- `fix:` 播放页右上角更多菜单加入底部安全距离，避免底部菜单项被 Android 虚拟导航栏遮挡。
- `update:` 播放页“聊天 / SC 或头条 / 关注 / 设置”支持在主页设置里拖拽排序；不存在的页签不显示，存在的页签按保存顺序显示。
- `update:` B 站 SC / 虎牙头条支持按消失时间正序或倒序排序，播放器悬浮层和聊天区列表使用同一排序设置。
- `update:` 重复弹幕过滤支持主 App 全平台和 TV 端，默认关闭；同一用户在最近 N 条内发送相同内容时只显示一次，默认窗口为 10。
- `update:` TV 端弹幕设置新增重复过滤开关和过滤窗口选项。
- `update:` 实时字幕模型路径选择改为优先选择模型文件夹，适配一个模型由多个文件组成的情况。
- `update:` 实时字幕模型说明补充百度网盘镜像：`https://pan.baidu.com/s/17ToLCOaK71zkl1s6c8ZKpg?pwd=6699`，提取码 `6699`。
- `update:` README 写清楚三个字幕模型档位需要下载哪些文件、不需要下载哪些文件，以及“选一个档位，把该档位所有文件放同一个文件夹，再在 App 里选择这个文件夹”的使用方式。
- `chore:` 本地模型缓存目录为 `C:\softwares\dart_simple_live\models`，仓库 `.gitignore` 已忽略 `models/`，避免大模型进入 git。

### 字幕模型下载说明

- 甜点级（先试这个）：下载 `encoder-epoch-99-avg-1.int8.onnx`、`decoder-epoch-99-avg-1.int8.onnx`、`joiner-epoch-99-avg-1.int8.onnx`、`tokens.txt`、`bpe.model`、`bpe.vocab`。
- 中级（中文直播优先）：下载 `model.int8.onnx`、`tokens.txt`、`config.yaml`、`am.mvn`。
- 高级（高性能桌面）：下载 `large-v3-encoder.int8.onnx`、`large-v3-decoder.int8.onnx`、`large-v3-tokens.txt`。
- 不需要下载 `.weights`、无 `int8` 的 `.onnx`、`test_wavs` 测试音频。

### 已验证

- 主 App：`flutter analyze` 通过，`No issues found`。
- TV App：`flutter analyze` 通过，`No issues found`。
- Core：`dart analyze` 仅剩既有 info 级风格提示，无新增 error/warning。
- `models/` 已确认被 `.gitignore` 命中，不会提交本地模型文件。

### 待真实设备继续验证

- 抖音表情在不同直播间、不同表情类型下的实际显示效果，尤其 TV 端。
- Android realme 侧边栏全屏/退出全屏后的竖屏布局恢复。
- 小窗回全屏时弹幕层是否仍有设备差异。
- 重复弹幕过滤在高弹幕量房间下的误过滤情况。
- 字幕模型导入后真实识别效果和不同平台文件夹选择兼容性。

## 2026-05-29

### v1.12.4 / tv_1.7.5 发布重点

- `update:` 关注页支持按开播状态或平台分组，特别关注星标持久化并在全部列表和所属分组置顶。
- `update:` 特别关注支持移动端开播提醒；桌面端和 TV 端暂不做通知。
- `fix:` 主 App / TV App 版本号、更新 JSON 和本地 release tag 统一到 `v1.12.4` / `tv_1.7.5`。
- `fix:` WebDAV 和局域网同步恢复失败时不再一直转圈，连接失败会收起 loading 并给出明确原因。
- `update:` 抖音房间名 / 主播名搜索接入账号 Cookie；TV 端通过手机或电脑端同步 Cookie。
- `update:` 播放器新增当前房间临时静音、房间内一次性定时关闭、Android 退后台自动小窗开关。
- `fix:` 手动刷新直播间时同步刷新视频、弹幕、SC/头条和贡献榜；全平台热度增加 10 秒详情刷新兜底。
- `fix:` 虎牙头条 pid 候选和日志增强，SC/头条按结束时间排序。
- `fix:` 修复播放器浮层多条 SC 倒计时卡 1 秒不消失的问题。
- `update:` 弹幕表情支持 B 站和抖音消息里的图片字段，主 App 聊天区、播放器浮层和 TV 播放器弹幕均可显示。
- `update:` 实时字幕设置补到直播间设置和右上角更多菜单，并提供高级 / 中级 / 甜点级模型推荐入口。
- `fix:` 其他设置里的同步服务地址在窄屏上改为短标签显示，完整地址保留在说明和编辑弹窗中。
