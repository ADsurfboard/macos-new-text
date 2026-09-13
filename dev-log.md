# 开发日志

## 2026-09-13

- 创建 SwiftUI 宿主应用和 Finder Sync 扩展，安装到 `~/Applications/新建文本.app`。
- 实现 Finder/桌面背景右键“新建文本文档”、同名递增、VS Code 优先打开和文本编辑回退。
- 修复沙盒目录写入和 PlugInKit 重复注册；单元测试、签名校验和 Finder 端到端测试通过。
- v1.0.5 尝试使用模板图标自动适配明暗；用户实测 Finder 深色菜单仍绘制为黑色，下一版改用显式黑/白非模板图像。
- v1.0.6 已改为两套显式实色图标：深色模式白色、浅色模式黑色；新增像素级自动测试，确认两套资源均为非模板图像，并确认系统只注册一份 build 7 扩展。
- 项目已由 `ADsurfboard` 账户公开发布至 GitHub：`ADsurfboard/macos-new-text`，采用 MIT 许可证；首次提交为 `0cb9c81`。
