import AppKit

func renderedAverage(_ image: NSImage) -> (red: Double, green: Double, blue: Double) {
    let width = 32
    let height = 32
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width,
        pixelsHigh: height,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else { fatalError("无法创建位图") }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: width, height: height).fill()
    image.draw(in: NSRect(x: 4, y: 4, width: 24, height: 24))
    NSGraphicsContext.restoreGraphicsState()

    var red = 0.0
    var green = 0.0
    var blue = 0.0
    var count = 0.0
    for y in 0..<height {
        for x in 0..<width {
            guard let color = bitmap.colorAt(x: x, y: y), color.alphaComponent > 0.1 else {
                continue
            }
            red += color.redComponent
            green += color.greenComponent
            blue += color.blueComponent
            count += 1
        }
    }
    precondition(count > 0, "图标没有可见像素")
    return (red / count, green / count, blue / count)
}

@main
struct MenuIconTests {
    static func main() {
        guard
            let light = MenuIconFactory.make(variant: .light),
            let dark = MenuIconFactory.make(variant: .dark)
        else { fatalError("无法生成菜单图标") }

        precondition(!light.isTemplate && !dark.isTemplate, "菜单图标不能是模板图标")
        let blackPixels = renderedAverage(light)
        let whitePixels = renderedAverage(dark)
        precondition(blackPixels.red < 0.1 && blackPixels.green < 0.1 && blackPixels.blue < 0.1, "浅色模式图标并非黑色")
        precondition(whitePixels.red > 0.9 && whitePixels.green > 0.9 && whitePixels.blue > 0.9, "深色模式图标并非白色")

        print("测试通过：浅色模式为黑色图标，深色模式为白色图标，且均为非模板实色资源。")
    }
}
