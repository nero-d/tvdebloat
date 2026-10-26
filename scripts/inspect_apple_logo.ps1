Add-Type -AssemblyName System.Drawing
$b = [System.Drawing.Image]::FromFile("C:\Users\sanik\tv_debloat\res\mipmap-xxxhdpi-v4\appletv_icon.png")
$bmp = New-Object System.Drawing.Bitmap($b)
$pixel00 = $bmp.GetPixel(0, 0)
Write-Host "Pixel (0,0) Alpha: $($pixel00.A), R: $($pixel00.R), G: $($pixel00.G), B: $($pixel00.B)"
Write-Host "Dimensions: $($b.Width) x $($b.Height)"
$b.Dispose()
$bmp.Dispose()
