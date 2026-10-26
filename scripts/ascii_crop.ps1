Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile("C:\Users\sanik\tv_debloat\crop_focused.png")

# Let's inspect rows around Y = 30 to 70 and columns around X = 20 to 60
# to find the exact coordinates of the outer shape and inner shape
for ($y = 20; $y -lt 260; $y += 10) {
    $line = ""
    for ($x = 20; $x -lt 460; $x += 10) {
        $c = $bmp.GetPixel($x, $y)
        # B = background, O = outer highlight, I = inner card, S = squircle
        if ($c.R -gt 130 -and $c.G -gt 130 -and $c.B -gt 130) {
            $line += "#"
        } elseif ($c.R -gt 90) {
            $line += "+"
        } elseif ($c.R -gt 60) {
            $line += "."
        } else {
            $line += " "
        }
    }
    Write-Host ("{0:D3}: {1}" -f $y, $line)
}

$bmp.Dispose()
