import AppKit

enum MenuIconFactory {
    enum Variant: String {
        case light
        case dark

        var color: NSColor {
            switch self {
            case .light: return .black
            case .dark: return .white
            }
        }
    }

    static func currentVariant() -> Variant {
        let appearance = NSAppearance.currentDrawing()
        return appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? .dark
            : .light
    }

    static func make(variant: Variant) -> NSImage? {
        let size = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        let color = NSImage.SymbolConfiguration(paletteColors: [variant.color])

        guard let image = NSImage(
            systemSymbolName: "doc.badge.plus",
            accessibilityDescription: "新建文本文档"
        )?.withSymbolConfiguration(size.applying(color))?.copy() as? NSImage else {
            return nil
        }

        // Finder 对模板图标的自动反色并不稳定。保留符号中已经写入的
        // 黑色或白色，让深浅模式各自使用真正独立的实色版本。
        image.isTemplate = false
        return image
    }
}
