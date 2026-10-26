Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile("C:\Users\sanik\tv_debloat\screen_clean_grid2.png")
$rect = New-Object System.Drawing.Rectangle(100, 720, 480, 280)
$bmp = New-Object System.Drawing.Bitmap($rect.Width, $rect.Height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, $bmp.Width, $bmp.Height)), $rect, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
$bmp.Save("C:\Users\sanik\tv_debloat\crop_clean_apple.png")
$bmp.Dispose()
$img.Dispose()
Write-Host "Cropped clean Apple TV"
