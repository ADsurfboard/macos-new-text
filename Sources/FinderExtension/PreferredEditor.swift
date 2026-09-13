import AppKit
import os

enum PreferredEditor {
    private static let logger = Logger(
        subsystem: "com.zhangshao.NewText.FinderExtension",
        category: "Editor"
    )

    private static let preferredVisualStudioCodePath =
        "/Applications/Visual Studio Code.app"

    private static let visualStudioCodeBundleIdentifiers = [
        "com.microsoft.VSCode",
        "com.microsoft.VSCodeInsiders"
    ]

    private static let visualStudioCodePaths = [
        "~/Applications/Visual Studio Code.app",
        "/Applications/Visual Studio Code - Insiders.app",
        "~/Applications/Visual Studio Code - Insiders.app"
    ]

    static func open(_ documentURL: URL) {
        guard let editorURL = visualStudioCodeURL() else {
            logger.notice("VS Code not found; falling back to TextEdit")
            openWithTextEdit(documentURL)
            return
        }

        logger.notice("Opening with VS Code: \(editorURL.path, privacy: .public)")

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        configuration.addsToRecentItems = true

        NSWorkspace.shared.open(
            [documentURL],
            withApplicationAt: editorURL,
            configuration: configuration
        ) { _, error in
            if error != nil {
                logger.error("VS Code open failed; falling back to TextEdit")
                openWithTextEdit(documentURL)
            }
        }
    }

    static func visualStudioCodeURL() -> URL? {
        let preferredURL = URL(
            fileURLWithPath: preferredVisualStudioCodePath,
            isDirectory: true
        )
        if FileManager.default.fileExists(atPath: preferredURL.path) {
            return preferredURL
        }

        for bundleIdentifier in visualStudioCodeBundleIdentifiers {
            if let url = NSWorkspace.shared.urlForApplication(
                withBundleIdentifier: bundleIdentifier
            ) {
                return url
            }
        }

        for rawPath in visualStudioCodePaths {
            let expandedPath = NSString(string: rawPath).expandingTildeInPath
            let url = URL(fileURLWithPath: expandedPath, isDirectory: true)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }

        return nil
    }

    private static func openWithTextEdit(_ documentURL: URL) {
        let textEditURL = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: "com.apple.TextEdit"
        ) ?? URL(fileURLWithPath: "/System/Applications/TextEdit.app", isDirectory: true)

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        configuration.addsToRecentItems = true

        NSWorkspace.shared.open(
            [documentURL],
            withApplicationAt: textEditURL,
            configuration: configuration
        ) { _, error in
            if error != nil {
                logger.error("TextEdit open failed; asking Launch Services for the default app")
                NSWorkspace.shared.open(documentURL)
            }
        }
    }
}
