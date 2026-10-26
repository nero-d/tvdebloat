Add-Type -AssemblyName System.Drawing

$pfc = New-Object System.Drawing.Text.PrivateFontCollection
$pfc.AddFontFile("C:\Users\sanik\tv_debloat\launcher\res\font\outfit_regular.ttf")
$fontFam = $pfc.Families[0]

$W = 640
$H = 360
$bmp = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# 1. Clear with fully transparent
$g.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))

# 2. Frosted Glass Base (Semi-transparent white/gray glass matching pill_bg: #24FFFFFF to #15FFFFFF)
$glassBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(0, 0)),
    (New-Object System.Drawing.Point(0, $H)),
    [System.Drawing.Color]::FromArgb(48, 255, 255, 255),
    [System.Drawing.Color]::FromArgb(18, 255, 255, 255)
)
$g.FillRectangle($glassBrush, 0, 0, $W, $H)
$glassBrush.Dispose()

# 3. Soft brand radial glow through the glass (e.g. AirDrop Cyan/Blue)
$gp = New-Object System.Drawing.Drawing2D.GraphicsPath
$glowRect = New-Object System.Drawing.Rectangle(10, 10, 320, 320)
$gp.AddEllipse($glowRect)
$pbr = New-Object System.Drawing.Drawing2D.PathGradientBrush($gp)
$pbr.CenterColor = [System.Drawing.Color]::FromArgb(90, 0, 122, 255)
$pbr.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
$g.FillEllipse($pbr, $glowRect)
$pbr.Dispose()
$gp.Dispose()

# 4. Top specular highlight line (Apple glass rim)
$shinePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(90, 255, 255, 255), 1.5)
$g.DrawLine($shinePen, 0, 1, $W, 1)
$shinePen.Dispose()

# 5. Delicate outer glass border (matching pill_stroke: #3AFFFFFF)
$borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 255, 255, 255), 1.5)
$g.DrawRectangle($borderPen, 0, 0, $W - 1, $H - 1)
$borderPen.Dispose()

# 6. Squircle Emblem (Denser frosted glass pill with brand border)
$cx = 158
$cy = 180
$tileSz = 148
$tileR = 34
$tileRect = New-Object System.Drawing.Rectangle(($cx - $tileSz/2), ($cy - $tileSz/2), $tileSz, $tileSz)

function Fill-RoundRect($g, $brush, $rect, $radius) {
    $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
    $gp.AddArc($rect.X, $rect.Y, $radius * 2, $radius * 2, 180, 90)
    $gp.AddArc($rect.Right - $radius * 2, $rect.Y, $radius * 2, $radius * 2, 270, 90)
    $gp.AddArc($rect.Right - $radius * 2, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 0, 90)
    $gp.AddArc($rect.X, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 90, 90)
    $gp.CloseFigure()
    $g.FillPath($brush, $gp)
    $gp.Dispose()
}

function Draw-RoundRect($g, $pen, $rect, $radius) {
    $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
    $gp.AddArc($rect.X, $rect.Y, $radius * 2, $radius * 2, 180, 90)
    $gp.AddArc($rect.Right - $radius * 2, $rect.Y, $radius * 2, $radius * 2, 270, 90)
    $gp.AddArc($rect.Right - $radius * 2, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 0, 90)
    $gp.AddArc($rect.X, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 90, 90)
    $gp.CloseFigure()
    $g.DrawPath($pen, $gp)
    $gp.Dispose()
}

$emblemBg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point($tileRect.X, $tileRect.Y)),
    (New-Object System.Drawing.Point($tileRect.X, $tileRect.Bottom)),
    [System.Drawing.Color]::FromArgb(85, 255, 255, 255),
    [System.Drawing.Color]::FromArgb(35, 255, 255, 255)
)
$emblemPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(180, 0, 140, 255), 2.5)
Fill-RoundRect $g $emblemBg $tileRect $tileR
Draw-RoundRect $g $emblemPen $tileRect $tileR
$emblemBg.Dispose()
$emblemPen.Dispose()

# AirDrop concentric rings inside tile
for ($i = 2; $i -ge 1; $i--) {
    $rad = $i * 26
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 0, 140, 255), 5.0)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawArc($pen, ($cx - $rad), ($cy - $rad + 8), ($rad * 2), ($rad * 2), 140, 260)
    $pen.Dispose()
}

$nodeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$g.FillEllipse($nodeBrush, ($cx - 10), ($cy - 2), 20, 20)
$nodeBrush.Dispose()

# Upward sharing beam
$arrowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$arrowPath.AddLine($cx, ($cy - 50), ($cx - 16), ($cy - 30))
$arrowPath.AddLine(($cx - 16), ($cy - 30), ($cx - 7), ($cy - 30))
$arrowPath.AddLine(($cx - 7), ($cy - 30), ($cx - 7), ($cy - 6))
$arrowPath.AddLine(($cx + 7), ($cy - 6), ($cx + 7), ($cy - 30))
$arrowPath.AddLine(($cx + 7), ($cy - 30), ($cx + 16), ($cy - 30))
$arrowPath.CloseFigure()
$arrowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$g.FillPath($arrowBrush, $arrowPath)
$arrowBrush.Dispose()
$arrowPath.Dispose()

# Typography
$textX = 265
$tFont = New-Object System.Drawing.Font($fontFam, 44, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$sFont = New-Object System.Drawing.Font($fontFam, 16, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

# Text shadow for legibility over any wallpaper
$shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120, 0, 0, 0))
$g.DrawString("Send Files", $tFont, $shadowBrush, ($textX + 2), 132)
$g.DrawString("Send Files", $tFont, [System.Drawing.Brushes]::White, $textX, 130)

$sBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 100, 210, 255))
$g.DrawString("TO TV  •  FAST TRANSFER", $sFont, $sBrush, ($textX + 4), 195)
$sBrush.Dispose()
$shadowBrush.Dispose()

$g.Dispose()
$bmp.Save("C:\Users\sanik\tv_debloat\launcher\res\drawable-nodpi\test_frosted.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "Created test_frosted.png"
