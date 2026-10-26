Add-Type -AssemblyName System.Drawing
$b = [System.Drawing.Bitmap]::FromFile("C:\Users\sanik\tv_debloat\launcher\res\drawable-nodpi\banner_appletv.png")
Write-Host "banner_appletv size: $($b.Width) x $($b.Height)"

# Check pixel values across X at Y = 50, Y = 100, Y = 180, Y = 300
# Is there a rectangle in banner_appletv.png?
# Let's inspect along vertical line X = 50 from Y = 0 to 360
for ($y = 0; $y -lt 360; $y += 10) {
    $c = $b.GetPixel(50, $y)
    Write-Host ("Y={0:D3}: A={1}, R={2}, G={3}, B={4}" -f $y, $c.A, $c.R, $c.G, $c.B)
}
$b.Dispose()
