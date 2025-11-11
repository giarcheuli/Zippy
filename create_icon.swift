import AppKit
import Foundation

let sizes: [(Int, Int)] = [(16, 1), (16, 2), (32, 1), (32, 2), (128, 1), (128, 2), (256, 1), (256, 2), (512, 1), (512, 2)]
let outputDir = "Sources/Resources/Assets.xcassets/AppIcon.appiconset"

for (baseSize, scale) in sizes {
    let size = CGFloat(baseSize * scale)
    let image = NSImage(size: NSSize(width: size, height: size))
    
    image.lockFocus()
    
    // Orange background with rounded corners
    let bgColor = NSColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0)
    bgColor.setFill()
    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let path = NSBezierPath(roundedRect: rect, xRadius: size * 0.2, yRadius: size * 0.2)
    path.fill()
    
    // White "Z" text
    let fontSize = size * 0.6
    let font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white
    ]
    let text = "Z" as NSString
    let textSize = text.size(withAttributes: attrs)
    let textRect = NSRect(
        x: (size - textSize.width) / 2,
        y: (size - textSize.height) / 2,
        width: textSize.width,
        height: textSize.height
    )
    text.draw(in: textRect, withAttributes: attrs)
    
    image.unlockFocus()
    
    // Save as PNG
    let filename = scale > 1 ? "icon_\(baseSize)x\(baseSize)@\(scale)x.png" : "icon_\(baseSize)x\(baseSize).png"
    let filepath = "\(outputDir)/\(filename)"
    
    if let tiffData = image.tiffRepresentation,
       let bitmapImage = NSBitmapImageRep(data: tiffData),
       let pngData = bitmapImage.representation(using: .png, properties: [:]) {
        try? pngData.write(to: URL(fileURLWithPath: filepath))
    }
}

print("Icons created successfully!")
