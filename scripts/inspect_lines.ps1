Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile("C:\Users\sanik\tv_debloat\crop_focused.png")

# Let's inspect along a vertical line X = 200 from Y = 30 to Y = 260
Write-Host "Vertical line at X=200:"
for ($y = 35; $y -lt 110; $y += 2) {
    $c = $bmp.GetPixel(200, $y)
    Write-Host ("Y={0:D3}: R={1,3}, G={2,3}, B={3,3}" -f $y, $c.R, $c.G, $c.B)
}

Write-Host "`nHorizontal line at Y=140:"
for ($x = 25; $x -lt 120; $x += 2) {
    $c = $bmp.GetPixel($x, 140)
    Write-Host ("X={0:D3}: R={1,3}, G={2,3}, B={3,3}" -f $x, $c.R, $c.G, $c.B)
}

$bmp.Dispose()
