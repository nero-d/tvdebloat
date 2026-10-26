Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile("C:\Users\sanik\tv_debloat\screen_grid_restored.png")

# Tile 0 (Apple TV - Focused)
# In 1920x1080 screen:
# Let's crop around Tile 0 (X: ~100 to 550, Y: ~700 to 1050)
$rectFocused = New-Object System.Drawing.Rectangle(100, 720, 480, 280)
$bmpFocused = New-Object System.Drawing.Bitmap($rectFocused.Width, $rectFocused.Height)
$g1 = [System.Drawing.Graphics]::FromImage($bmpFocused)
$g1.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, $bmpFocused.Width, $bmpFocused.Height)), $rectFocused, [System.Drawing.GraphicsUnit]::Pixel)
$g1.Dispose()
$bmpFocused.Save("C:\Users\sanik\tv_debloat\crop_focused.png")
$bmpFocused.Dispose()

# Tile 1 (Xstream Play - Unfocused)
$rectUnfocused = New-Object System.Drawing.Rectangle(550, 720, 480, 280)
$bmpUnfocused = New-Object System.Drawing.Bitmap($rectUnfocused.Width, $rectUnfocused.Height)
$g2 = [System.Drawing.Graphics]::FromImage($bmpUnfocused)
$g2.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, $bmpUnfocused.Width, $bmpUnfocused.Height)), $rectUnfocused, [System.Drawing.GraphicsUnit]::Pixel)
$g2.Dispose()
$bmpUnfocused.Save("C:\Users\sanik\tv_debloat\crop_unfocused.png")
$bmpUnfocused.Dispose()

$img.Dispose()
Write-Host "Cropped both!"
