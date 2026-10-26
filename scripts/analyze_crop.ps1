Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile("C:\Users\sanik\tv_debloat\crop_focused.png")

# Let's inspect horizontal scanline across the middle of crop_focused.png
# and vertical scanline
Write-Host "Width: $($bmp.Width), Height: $($bmp.Height)"

# Sample horizontal line at Y = 140 (middle)
# and vertical line at X = 240 (middle)
# Look for sharp brightness changes
for ($x = 20; $x -lt $bmp.Width - 20; $x += 5) {
    $c = $bmp.GetPixel($x, 140)
    # Write-Host "$x : R=$($c.R), G=$($c.G), B=$($c.B)"
}

# Check the bounds of the inner rectangle:
# Top edge: look down from Y = 20 to 100 at X = 240
for ($y = 20; $y -lt 120; $y++) {
    $c1 = $bmp.GetPixel(240, $y)
    $c2 = $bmp.GetPixel(240, $y+1)
    $diff = [Math]::Abs($c2.R - $c1.R) + [Math]::Abs($c2.G - $c1.G) + [Math]::Abs($c2.B - $c1.B)
    if ($diff -gt 15) {
        Write-Host "Horizontal edge at Y = $y (diff=$diff) Color: $($c1.R),$($c1.G),$($c1.B) -> $($c2.R),$($c2.G),$($c2.B)"
    }
}

# Left edge: look right from X = 20 to 120 at Y = 140
for ($x = 20; $x -lt 120; $x++) {
    $c1 = $bmp.GetPixel($x, 140)
    $c2 = $bmp.GetPixel($x+1, 140)
    $diff = [Math]::Abs($c2.R - $c1.R) + [Math]::Abs($c2.G - $c1.G) + [Math]::Abs($c2.B - $c1.B)
    if ($diff -gt 15) {
        Write-Host "Vertical edge at X = $x (diff=$diff) Color: $($c1.R),$($c1.G),$($c1.B) -> $($c2.R),$($c2.G),$($c2.B)"
    }
}

$bmp.Dispose()
