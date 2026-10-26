Add-Type -AssemblyName System.Drawing

$wall = [System.Drawing.Bitmap]::FromFile("C:\Users\sanik\tv_debloat\launcher\res\drawable-nodpi\wallpaper_mojave.jpg")
$banner = [System.Drawing.Bitmap]::FromFile("C:\Users\sanik\tv_debloat\launcher\res\drawable-nodpi\test_frosted.png")

$preview = New-Object System.Drawing.Bitmap(640, 360)
$g = [System.Drawing.Graphics]::FromImage($preview)

# Draw dark section of wallpaper
$srcRect = New-Object System.Drawing.Rectangle(400, 400, 640, 360)
$destRect = New-Object System.Drawing.Rectangle(0, 0, 640, 360)
$g.DrawImage($wall, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

# Draw the frosted banner on top!
$g.DrawImage($banner, 0, 0, 640, 360)

$g.Dispose()
$wall.Dispose()
$banner.Dispose()

$preview.Save("C:\Users\sanik\tv_debloat\launcher\res\drawable-nodpi\preview_frosted_on_wallpaper.png", [System.Drawing.Imaging.ImageFormat]::Png)
$preview.Dispose()
Write-Host "Created preview_frosted_on_wallpaper.png"
