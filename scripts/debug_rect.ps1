Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile("C:\Users\sanik\tv_debloat\crop_netflix_focused.png")
$g = [System.Drawing.Graphics]::FromImage($bmp)
$pen = New-Object System.Drawing.Pen([System.Drawing.Color]::Yellow, 2)
# Draw the box from (73, 138) to (387, 266)
$g.DrawRectangle($pen, 73, 138, (387 - 73), (266 - 138))
$pen.Dispose()
$g.Dispose()
$bmp.Save("C:\Users\sanik\tv_debloat\debug_rect.png")
$bmp.Dispose()
Write-Host "Saved debug_rect.png"
