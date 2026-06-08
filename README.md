# 童言童语 Kids Quotes

记录孩子成长过程中说过的有趣话语，支持多人对话、导出分享卡片。

## 功能进度

### v1 — 初始版本
- [x] 宝宝档案（姓名、生日、emoji 头像）
- [x] 对话记录（多轮对话、角色切换、发生场景）
- [x] 自动计算宝宝年龄快照
- [x] 按月份筛选查看
- [x] 导出分享卡片（4 套渐变主题）
- [x] SQLite 本地持久化

### v2 — 体验优化（2026-06-08）
- [x] **emoji 多选扩充**：4 分类 / 32 个预设（宝宝、家人、动物、可爱）+ 自定义输入框
- [x] **编辑已录入对话**：点击气泡弹出编辑弹窗，可修改内容及类型
- [x] **心理活动 vs 说出的话**：输入栏一键切换，气泡/卡片视觉区分（斜体 + 括号 + 不同底色）
- [x] **分享内容自定义**：可独立隐藏日期、场景
- [x] **导出白角修复**：圆角卡片浮在白底上，PNG 无透明角
- [x] **主题扩充至 9 套**：新增樱粉、奶茶、珊瑚、星空（深色）、柠黄
- [x] **数据库迁移**：turns 表新增 is_inner_thought 列（v1 → v2 自动升级）

## 技术栈

- Flutter 3.x / Dart
- sqflite（本地数据库）
- share_plus（系统分享）
- intl（日期格式化）

## 构建说明

> 项目位于 exFAT 外置盘时，macOS 会生成 `._*` 元数据文件干扰 Gradle。
> 请先将项目复制到本地再构建：
>
> ```bash
> rsync -a --exclude='build/' --exclude='.dart_tool/' /path/to/kids_quotes/ ~/Desktop/kids_quotes_build/
> cd ~/Desktop/kids_quotes_build
> flutter pub get && flutter build apk --release
> ```
