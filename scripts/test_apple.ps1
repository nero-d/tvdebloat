Add-Type -AssemblyName System.Drawing

function Create-SquirclePath($x, $y, $w, $h, $r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc(($x + $w - $d), $y, $d, $d, 270, 90)
    $path.AddArc(($x + $w - $d), ($y + $h - $d), $d, $d, 0, 90)
    $path.AddArc($x, ($y + $h - $d), $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

$W = 640; $H = 360
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($b)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# Frosted Base
$cardPath = Create-SquirclePath 0 0 $W $H 32
$smokyBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.PointF(0, 0)),
    (New-Object System.Drawing.PointF(0, $H)),
    [System.Drawing.Color]::FromArgb(115, 14, 16, 22),
    [System.Drawing.Color]::FromArgb(75, 10, 11, 15)
)
$g.FillPath($smokyBrush, $cardPath)
$smokyBrush.Dispose()

$frostedSheen = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.PointF(0, 0)),
    (New-Object System.Drawing.PointF(0, $H)),
    [System.Drawing.Color]::FromArgb(48, 255, 255, 255),
    [System.Drawing.Color]::FromArgb(18, 255, 255, 255)
)
$g.FillPath($frostedSheen, $cardPath)
$frostedSheen.Dispose()

# Ambient glow
$cx = 158; $cy = 180
$glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse(($cx - 100), ($cy - 100), 200, 200)
$pgb = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
$pgb.CenterColor = [System.Drawing.Color]::FromArgb(90, 200, 215, 230)
$pgb.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 200, 215, 230))
$g.FillPath($pgb, $glowPath)
$pgb.Dispose(); $glowPath.Dispose()

# Squircle emblem with official Apple icon
$sqX = $cx - 74; $sqY = $cy - 74; $sqSize = 148
$appleSquircle = Create-SquirclePath $sqX $sqY $sqSize $sqSize 38

# Save state and clip to squircle
$state = $g.Save()
$g.SetClip($appleSquircle)
$officialIcon = [System.Drawing.Image]::FromFile("C:\Users\sanik\tv_debloat\res\mipmap-xxxhdpi-v4\appletv_icon.png")
$g.DrawImage($officialIcon, $sqX, $sqY, $sqSize, $sqSize)
$officialIcon.Dispose()
$g.Restore($state)

# Squircle subtle rim border
$sqPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 255, 255, 255), 1.5)
$g.DrawPath($sqPen, $appleSquircle)
$sqPen.Dispose(); $appleSquircle.Dispose()

# Outer glass border & top specular
$glassBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(58, 255, 255, 255), 1.5)
$g.DrawPath($glassBorder, $cardPath)
$glassBorder.Dispose()

$g.DrawLine(
    (New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(90, 255, 255, 255), 1.5)),
    32, 1, ($W - 32), 1
)
$cardPath.Dispose()

# Text
$pfc = New-Object System.Drawing.Text.PrivateFontCollection
$pfc.AddFontFile("C:\Users\sanik\tv_debloat\launcher\res\font\outfit_regular.ttf")
$outfitBold = $pfc.Families[0]
$fontTitle = New-Object System.Drawing.Font($outfitBold, 29, [System.Drawing.FontStyle]::Bold)
$fontSub = New-Object System.Drawing.Font($outfitBold, 10.5, [System.Drawing.FontStyle]::Bold)

$textX = 264; $titleY = 144; $subY = 196
$shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(160, 0, 0, 0))
$g.DrawString("Apple TV+", $fontTitle, $shadowBrush, ($textX + 2), ($titleY + 2))
$g.DrawString("Apple TV+", $fontTitle, [System.Drawing.Brushes]::White, $textX, $titleY)

$subBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 205, 215, 225))
$g.DrawString("ORIGINALS & 4K HDR CINEMA", $fontSub, $shadowBrush, ($textX + 1), ($subY + 1))
$g.DrawString("ORIGINALS & 4K HDR CINEMA", $fontSub, $subBrush, $textX, $subY)

$g.Dispose()
$b.Save("C:\Users\sanik\tv_debloat\test_apple_banner.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()
Write-Host "Generated test Apple TV banner!"
