Add-Type -AssemblyName System.Drawing
$b = [System.Drawing.Bitmap]::FromFile("C:\Users\sanik\tv_debloat\launcher\res\drawable-nodpi\banner_netflix.png")
Write-Host "banner_netflix: $($b.Width) x $($b.Height)"

# In banner_netflix (640x360):
# If on screen the card is 386x212, and the box is 314x128...
# In 640x360 coordinates:
# 314 * (640 / 386) = 520
# 128 * (360 / 212) = 217
# Let's check banner_netflix pixels along Y = 70 to 120 and X = 50 to 120
for ($y = 40; $y -lt 120; $y += 5) {
    $c = $b.GetPixel(300, $y)
    Write-Host ("Y={0:D3}: A={1,3}, R={2,3}, G={3,3}, B={4,3}" -f $y, $c.A, $c.R, $c.G, $c.B)
}
$b.Dispose()
