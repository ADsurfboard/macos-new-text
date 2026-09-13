# 新建文本 for macOS

一个原生 Finder Sync 扩展：在访达窗口或桌面空白处右键，选择“新建文本文档”，即可创建空白 `.txt` 文件。

## 使用效果

- 文件名默认为 `新建文本文档.txt`。
- 右键菜单内置黑、白两套实色图标：浅色模式使用黑色，深色模式使用白色。
- 同名时依次创建 `新建文本文档 (2).txt`、`新建文本文档 (3).txt` 等，不会覆盖现有文件。
- 创建后优先用 `/Applications/Visual Studio Code.app` 打开。
- 支持 VS Code 正式版与 Insiders 版；未安装、无法启动或打开失败时，自动回退到系统“文本编辑”。
- 仅针对本次新建的文件选择编辑器，不会篡改全局 `.txt` 默认打开方式。
- 扩展保留 App Sandbox，只为个人目录与外接卷声明本地读写例外。实现不含网络请求、文件遍历或常驻同步，只在您点击右键命令时向 Finder 给出的目录创建一个空文件。

## 安装

```bash
./Scripts/install.sh
```

应用会安装到 `~/Applications/新建文本.app`。如系统仍显示“等待启用”，在应用内点击“打开扩展设置”，启用“新建文本”的访达扩展。这是 macOS 对 Finder 扩展的一次性安全确认。

## 卸载

```bash
./Scripts/uninstall.sh
```

卸载脚本会停用扩展，并将应用移入废纸篓，便于恢复。

## 开发

要求 macOS 26 或更高版本，以及系统自带的 Xcode Command Line Tools。

```bash
./Scripts/test.sh
./Scripts/build.sh
```

项目使用 SwiftUI、AppKit 和 FinderSync，不依赖第三方包。构建产物位于 `build/.products/新建文本.app`；隐藏产物目录可避免 macOS 把开发副本再注册为第二个 Finder 扩展。

## 许可证

[MIT](LICENSE)
