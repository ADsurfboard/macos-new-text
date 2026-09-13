import AppKit
import FinderSync
import Foundation

@MainActor
final class AppModel: ObservableObject {
    static let extensionBundleIdentifier = "com.zhangshao.NewText.FinderExtension"

    @Published private(set) var extensionEnabled = false
    @Published private(set) var editorName = "正在检测…"
    @Published private(set) var statusDetail = "正在读取系统状态"

    init() {
        refresh()
    }

    func refresh() {
        extensionEnabled = FIFinderSyncController.isExtensionEnabled
        statusDetail = extensionEnabled
            ? "访达和桌面右键菜单已生效"
            : "需要在系统设置中启用一次"
        editorName = detectedEditorName()
    }

    func openExtensionSettings() {
        FIFinderSyncController.showExtensionManagementInterface()
        scheduleRefresh()
    }

    func reloadFinder() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        process.arguments = ["Finder"]

        do {
            try process.run()
            process.waitUntilExit()
            statusDetail = "访达已重新加载"
        } catch {
            statusDetail = "无法重新加载访达：\(error.localizedDescription)"
        }

        scheduleRefresh()
    }

    private func scheduleRefresh() {
        Task {
            try? await Task.sleep(for: .seconds(1))
            refresh()
        }
    }

    private func detectedEditorName() -> String {
        let workspace = NSWorkspace.shared
        if FileManager.default.fileExists(
            atPath: "/Applications/Visual Studio Code.app"
        ) {
            return "Visual Studio Code"
        }
        if workspace.urlForApplication(withBundleIdentifier: "com.microsoft.VSCode") != nil {
            return "Visual Studio Code"
        }
        if workspace.urlForApplication(withBundleIdentifier: "com.microsoft.VSCodeInsiders") != nil {
            return "Visual Studio Code Insiders"
        }

        let commonPaths = [
            "/Applications/Visual Studio Code.app",
            NSString(string: "~/Applications/Visual Studio Code.app").expandingTildeInPath,
            "/Applications/Visual Studio Code - Insiders.app",
            NSString(string: "~/Applications/Visual Studio Code - Insiders.app").expandingTildeInPath
        ]
        if commonPaths.contains(where: { FileManager.default.fileExists(atPath: $0) }) {
            return "Visual Studio Code"
        }
        return "文本编辑（未检测到 VS Code）"
    }
}
