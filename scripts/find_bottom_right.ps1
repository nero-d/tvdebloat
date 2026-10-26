Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile("C:\Users\sanik\tv_debloat\crop_netflix_focused.png")

# Scan vertically from Y = 200 to 280 at X = 240 (below "Netflix" text)
for ($y = 200; $y -lt 270; $y++) {
    $c1 = $bmp.GetPixel(240, $y)
    $c2 = $bmp.GetPixel(240, $y+1)
    $diff = [Math]::Abs($c2.R - $c1.R) + [Math]::Abs($c2.G - $c1.G) + [Math]::Abs($c2.B - $c1.B)
    if ($diff -gt 15) {
        Write-Host ("Bottom edge at Y={0}: {1},{2},{3} -> {4},{5},{6}" -f $y, $c1.R, $c1.G, $c1.B, $c2.R, $c2.G, $c2.B)
    }
}

# Scan horizontally from X = 300 to 450 at Y = 160 (right of "Netflix" text)
for ($x = 300; $x -lt 450; $x++) {
    $c1 = $bmp.GetPixel($x, 160)
    $c2 = $bmp.GetPixel($x+1, 160)
    $diff = [Math]::Abs($c2.R - $c1.R) + [Math]::Abs($c2.G - $c1.G) + [Math]::Abs($c2.B - $c1.B)
    if ($diff -gt 15) {
        Write-Host ("Right edge at X={0}: {1},{2},{3} -> {4},{5},{6}" -f $x, $c1.R, $c1.G, $c1.B, $c2.R, $c2.G, $c2.B)
    }
}

$bmp.Dispose()
