Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile("C:\Users\sanik\tv_debloat\crop_focused.png")

# Let's find the white outer border of the focused tile!
# Look for bright white pixels (stroke is #60FFFFFF)
Write-Host "Finding outer border..."
$outerMinX = 999; $outerMaxX = 0; $outerMinY = 999; $outerMaxY = 0

for ($y = 0; $y -lt $bmp.Height; $y++) {
    for ($x = 0; $x -lt $bmp.Width; $x++) {
        $c = $bmp.GetPixel($x, $y)
        # Check for white border
        if ($c.R -gt 150 -and $c.G -gt 150 -and $c.B -gt 150 -and $y -lt 90) {
            if ($x -lt $outerMinX) { $outerMinX = $x }
            if ($x -gt $outerMaxX) { $outerMaxX = $x }
            if ($y -lt $outerMinY) { $outerMinY = $y }
            if ($y -gt $outerMaxY) { $outerMaxY = $y }
        }
    }
}
Write-Host "Outer top border: X=$outerMinX to $outerMaxX, Y=$outerMinY to $outerMaxY (Width=$($outerMaxX - $outerMinX))"

# Let's find the inner rectangle lines:
# In crop_focused, look around Y = 80 to 220, X = 40 to 420
# Let's save a thresholded edge map image so we can look at it directly!
$edgeBmp = New-Object System.Drawing.Bitmap($bmp.Width, $bmp.Height)
for ($y = 1; $y -lt $bmp.Height - 1; $y++) {
    for ($x = 1; $x -lt $bmp.Width - 1; $x++) {
        $c = $bmp.GetPixel($x, $y)
        $cr = $bmp.GetPixel($x+1, $y)
        $cd = $bmp.GetPixel($x, $y+1)
        $diff = [Math]::Abs($cr.R - $c.R) + [Math]::Abs($cd.R - $c.R)
        if ($diff -gt 15) {
            $edgeBmp.SetPixel($x, $y, [System.Drawing.Color]::White)
        } else {
            $edgeBmp.SetPixel($x, $y, [System.Drawing.Color]::Black)
        }
    }
}
$edgeBmp.Save("C:\Users\sanik\tv_debloat\edges_focused.png")
$edgeBmp.Dispose()
$bmp.Dispose()
Write-Host "Saved edges_focused.png"
