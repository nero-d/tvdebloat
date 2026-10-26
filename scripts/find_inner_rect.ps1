Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile("C:\Users\sanik\tv_debloat\crop_netflix_focused.png")

# Find the bounding box of that inner rectangle:
# Look for the top line, bottom line, left line, right line
# Look at scanline Y = 138 (between top of rectangle and top of N icon)
for ($x = 0; $x -lt $bmp.Width; $x += 5) {
    $c = $bmp.GetPixel($x, 140)
    # Write-Host "$x: $($c.R),$($c.G),$($c.B)"
}

# Scan vertically at X = 240 (above "Netflix" text)
for ($y = 80; $y -lt 160; $y++) {
    $c1 = $bmp.GetPixel(240, $y)
    $c2 = $bmp.GetPixel(240, $y+1)
    $diff = [Math]::Abs($c2.R - $c1.R) + [Math]::Abs($c2.G - $c1.G) + [Math]::Abs($c2.B - $c1.B)
    if ($diff -gt 20) {
        Write-Host ("Sharp line at Y={0}: {1},{2},{3} -> {4},{5},{6}" -f $y, $c1.R, $c1.G, $c1.B, $c2.R, $c2.G, $c2.B)
    }
}

# Scan horizontally at Y = 160
for ($x = 40; $x -lt 120; $x++) {
    $c1 = $bmp.GetPixel($x, 160)
    $c2 = $bmp.GetPixel($x+1, 160)
    $diff = [Math]::Abs($c2.R - $c1.R) + [Math]::Abs($c2.G - $c1.G) + [Math]::Abs($c2.B - $c1.B)
    if ($diff -gt 20) {
        Write-Host ("Sharp line at X={0}: {1},{2},{3} -> {4},{5},{6}" -f $x, $c1.R, $c1.G, $c1.B, $c2.R, $c2.G, $c2.B)
    }
}

$bmp.Dispose()
