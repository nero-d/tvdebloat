Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile("C:\Users\sanik\tv_debloat\screen_grid_restored.png")
$bmp = New-Object System.Drawing.Bitmap($img)

# Find tile bounds for Apple TV (Tile 0) and Xstream Play (Tile 1)
# Grid starts around Y = 750
# Tile 0 is around X = 100 to 500
# Tile 1 is around X = 500 to 900
Write-Host "Screen: $($bmp.Width) x $($bmp.Height)"

# Let's inspect the entire row around Y = 800
for ($x = 0; $x -lt 1920; $x += 10) {
    $c = $bmp.GetPixel($x, 800)
    # Write-Host "$x: R=$($c.R)"
}

$bmp.Dispose()
$img.Dispose()
