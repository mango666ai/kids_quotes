# 童言童语 — 开发进度

## v1（初始版本）
- [x] 宝宝档案（姓名、生日、emoji 头像）
- [x] 多轮对话记录（多角色、发生场景）
- [x] 自动计算宝宝年龄快照
- [x] 按月份筛选查看
- [x] 导出分享卡片（4 套渐变主题）
- [x] SQLite 本地持久化

## v2（2026-06-08）
- [x] emoji 多选扩充：4 分类 / 32 个预设 + 自定义输入框
- [x] 点击对话气泡可编辑已录内容（内容 + 类型）
- [x] 心理活动 vs 说出的话：输入栏一键切换，气泡斜体+紫色底色，导出卡片括号+斜体
- [x] 分享页自定义：日期/场景可独立隐藏
- [x] 导出白角修复：圆角卡片浮在白底上，PNG 无透明角
- [x] 主题从 4 套扩充至 9 套（+樱粉/奶茶/珊瑚/星空/柠黄）
- [x] 数据库 v1→v2 自动迁移（turns 表新增 is_inner_thought 列）

## Backlog / 待做
- [ ] 搜索功能（按关键词搜对话内容）
- [ ] iCloud / 本地备份导出
- [ ] 首页卡片支持长按多选删除
- [ ] 分享卡片支持自定义字体

## 构建说明
项目在 exFAT 外置盘（SANDISK）上需先复制到本地再构建，否则 macOS `._*` 元数据文件会让 Gradle 报错：

```bash
rsync -a --exclude='build/' --exclude='.dart_tool/' \
  "/Volumes/SANDISK ELE/AICoding/project6_childquote/kids_quotes/" \
  ~/Desktop/kids_quotes_build/
cd ~/Desktop/kids_quotes_build
flutter pub get && flutter build apk --release
```
