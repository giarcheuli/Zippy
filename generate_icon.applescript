#!/usr/bin/osascript

-- Generate Zippy app icon using SF Symbols
on run
    set sizes to {16, 32, 64, 128, 256, 512, 1024}
    set baseDir to (do shell script "dirname " & quoted form of POSIX path of ((path to me as text)))
    set iconsetPath to baseDir & "/Sources/Resources/Assets.xcassets/AppIcon.appiconset"
    
    repeat with iconSize in sizes
        set scale1Path to iconsetPath & "/icon_" & iconSize & "x" & iconSize & ".png"
        
        -- Create icon using sips and SF Symbols
        do shell script "python3 << 'EOF'
import os
from PIL import Image, ImageDraw, ImageFont

size = " & iconSize & "
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Draw a zipper icon background
bg_color = (255, 149, 0)  # Orange
draw.rounded_rectangle([(size*0.1, size*0.1), (size*0.9, size*0.9)], 
                       radius=size*0.2, fill=bg_color)

# Add 'Z' text
font_size = int(size * 0.6)
try:
    font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', font_size)
except:
    font = ImageFont.load_default()

text = 'Z'
bbox = draw.textbbox((0, 0), text, font=font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]
x = (size - text_width) / 2
y = (size - text_height) / 2 - bbox[1]

draw.text((x, y), text, fill='white', font=font)

img.save('" & scale1Path & "')
EOF"
    end repeat
    
    return "Icon generated!"
end run
