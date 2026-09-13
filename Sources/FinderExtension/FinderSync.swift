import AppKit
import FinderSync
import os

@objc(FinderSync)
final class FinderSync: FIFinderSync {
    private let logger = Logger(
        subsystem: "com.zhangshao.NewText.FinderExtension",
        category: "FinderSync"
    )

    override init() {
        super.init()

        // 监视文件系统根目录，使访达、桌面以及外接卷的
        // 窗口背景都能显示同一个右键命令。扩展不申请徽章，
        // 因此闲置时不会遍历文件或占用额外资源。
        FIFinderSyncController.default().directoryURLs = [
            URL(fileURLWithPath: "/", isDirectory: true)
        ]
        logger.notice("Finder extension initialized")
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        guard menuKind == .contextualMenuForContainer else {
            return nil
        }

        let menu = NSMenu(title: "")
        let item = NSMenuItem(
            title: "新建文本文档",
            action: #selector(createTextDocument(_:)),
            keyEquivalent: ""
        )
        item.target = self
        let iconVariant = MenuIconFactory.currentVariant()
        item.image = MenuIconFactory.make(variant: iconVariant)
        let iconColor = iconVariant == .dark ? "white" : "black"
        logger.notice(
            "Menu icon selected: \(iconVariant.rawValue, privacy: .public) / \(iconColor, privacy: .public)"
        )
        menu.addItem(item)
        return menu
    }

    @objc func createTextDocument(_ sender: Any?) {
        logger.notice("Create text command invoked")

        guard let targetURL = FIFinderSyncController.default().targetedURL() else {
            logger.error("Finder did not provide a targeted URL")
            presentFailure("无法识别当前文件夹。")
            return
        }

        logger.notice("Target URL: \(targetURL.path, privacy: .public)")
        let didStartSecurityScope = targetURL.startAccessingSecurityScopedResource()
        defer {
            if didStartSecurityScope {
                targetURL.stopAccessingSecurityScopedResource()
            }
        }

        let directoryURL: URL
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(
            atPath: targetURL.path,
            isDirectory: &isDirectory
        ), isDirectory.boolValue {
            directoryURL = targetURL
        } else {
            directoryURL = targetURL.deletingLastPathComponent()
        }

        do {
            let documentURL = try NewTextFileCreator.create(in: directoryURL)
            logger.notice("Created document: \(documentURL.path, privacy: .public)")
            PreferredEditor.open(documentURL)
        } catch {
            logger.error("Creation failed: \(error.localizedDescription, privacy: .public)")
            presentFailure(error.localizedDescription)
        }
    }

    private func presentFailure(_ detail: String) {
        NSSound.beep()

        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "无法新建文本"
        alert.informativeText = detail
        alert.addButton(withTitle: "好")
        alert.runModal()
    }
}
