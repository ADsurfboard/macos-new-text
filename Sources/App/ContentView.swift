import SwiftUI

struct ContentView: View {
    @StateObject private var model = AppModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            header
            statusCard
            workflow
            actions
        }
        .padding(28)
        .frame(width: 540)
        .background {
            LinearGradient(
                colors: [
                    Color.accentColor.opacity(0.09),
                    Color.clear,
                    Color.cyan.opacity(0.045)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                model.refresh()
            }
        }
    }

    private var header: some View {
        HStack(spacing: 18) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 34, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.tint)
                .frame(width: 72, height: 72)
                .glassEffect(.regular.tint(Color.accentColor.opacity(0.14)), in: .rect(cornerRadius: 22))

            VStack(alignment: .leading, spacing: 5) {
                Text("右键新建文本")
                    .font(.title2.weight(.semibold))
                Text("为访达补上 Windows 式的新建文本体验")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var statusCard: some View {
        VStack(spacing: 0) {
            statusRow(
                symbol: model.extensionEnabled ? "checkmark.circle.fill" : "exclamationmark.circle.fill",
                color: model.extensionEnabled ? .green : .orange,
                title: model.extensionEnabled ? "扩展已启用" : "等待启用",
                detail: model.statusDetail
            )

            Divider().padding(.leading, 46)

            statusRow(
                symbol: "chevron.left.forwardslash.chevron.right",
                color: .accentColor,
                title: "默认编辑器",
                detail: model.editorName
            )
        }
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.primary.opacity(0.07))
        }
    }

    private var workflow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("使用方法")
                .font(.headline)

            HStack(spacing: 12) {
                step(number: "1", text: "在访达或桌面空白处右键")
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                step(number: "2", text: "选择“新建文本文档”")
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                step(number: "3", text: "自动用 VS Code 打开")
            }
        }
    }

    private var actions: some View {
        HStack(spacing: 10) {
            Button {
                model.openExtensionSettings()
            } label: {
                Label(
                    model.extensionEnabled ? "管理扩展" : "打开扩展设置",
                    systemImage: "puzzlepiece.extension"
                )
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)

            Button {
                model.reloadFinder()
            } label: {
                Label("重新加载访达", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.glass)
            .controlSize(.large)

            Spacer()
        }
    }

    private func statusRow(
        symbol: String,
        color: Color,
        title: String,
        detail: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(color)
                .font(.title3)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                Text(detail)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 13)
    }

    private func step(number: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(number)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Color.accentColor, in: Circle())
            Text(text)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

