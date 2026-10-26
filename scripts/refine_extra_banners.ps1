Add-Type -AssemblyName System.Drawing

$pfc = New-Object System.Drawing.Text.PrivateFontCollection
$pfc.AddFontFile("C:\Users\sanik\tv_debloat\launcher\res\font\outfit_regular.ttf")
$fontFam = $pfc.Families[0]

$outDir = "C:\Users\sanik\tv_debloat\launcher\res\drawable-nodpi"
$W = 640
$H = 360

function Init-Graphics($bmp) {
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    return $g
}

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

function Draw-TileBase($g, $bgColor1, $bgColor2, $glowColor) {
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Point(0, 0)),
        (New-Object System.Drawing.Point($W, $H)),
        $bgColor1, $bgColor2
    )
    $g.FillRectangle($bgBrush, 0, 0, $W, $H)
    $bgBrush.Dispose()

    if ($glowColor) {
        $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
        $glowRect = New-Object System.Drawing.Rectangle(20, 10, 320, 320)
        $gp.AddEllipse($glowRect)
        $pbr = New-Object System.Drawing.Drawing2D.PathGradientBrush($gp)
        $pbr.CenterColor = $glowColor
        $pbr.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
        $g.FillEllipse($pbr, $glowRect)
        $pbr.Dispose()
        $gp.Dispose()
    }

    $topPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(40, 255, 255, 255), 1.0)
    $g.DrawLine($topPen, 0, 0, $W, 0)
    $topPen.Dispose()

    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(25, 255, 255, 255), 1.0)
    $g.DrawRectangle($borderPen, 0, 0, $W - 1, $H - 1)
    $borderPen.Dispose()
}

$cx = 158
$cy = 180
$tileSz = 148
$tileR = 34
$tileRect = New-Object System.Drawing.Rectangle(($cx - $tileSz/2), ($cy - $tileSz/2), $tileSz, $tileSz)
$textX = 265

$tFont = New-Object System.Drawing.Font($fontFam, 44, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$tFontMed = New-Object System.Drawing.Font($fontFam, 38, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$sFont = New-Object System.Drawing.Font($fontFam, 16, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

# ==========================================
# 1. REFINED XSTREAM PLAY (banner_xstream.png)
# ==========================================
$bmp1 = New-Object System.Drawing.Bitmap($W, $H)
$g1 = Init-Graphics $bmp1
Draw-TileBase $g1 ([System.Drawing.Color]::FromArgb(255, 30, 14, 18)) `
                 ([System.Drawing.Color]::FromArgb(255, 13, 6, 8)) `
                 ([System.Drawing.Color]::FromArgb(95, 237, 28, 36))

$xsTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(95, 65, 24, 30))
$xsTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, 237, 28, 36), 2.5)
Fill-RoundRect $g1 $xsTileBrush $tileRect $tileR
Draw-RoundRect $g1 $xsTilePen $tileRect $tileR
$xsTileBrush.Dispose()
$xsTilePen.Dispose()

# Authentic Filled Airtel Swirl
$swirlPath = New-Object System.Drawing.Drawing2D.GraphicsPath
# Outer curve
$swirlPath.AddBezier(($cx + 34), ($cy - 10), ($cx + 30), ($cy - 36), ($cx - 26), ($cy - 40), ($cx - 36), ($cy - 12))
$swirlPath.AddBezier(($cx - 36), ($cy - 12), ($cx - 44), ($cy + 16), ($cx - 16), ($cy + 42), ($cx + 12), ($cy + 36))
$swirlPath.AddBezier(($cx + 12), ($cy + 36), ($cx + 32), ($cy + 30), ($cx + 34), ($cy + 10), ($cx + 18), ($cy + 2))
$swirlPath.AddBezier(($cx + 18), ($cy + 2), ($cx + 6), ($cy - 4), ($cx - 6), ($cy + 8), ($cx + 2), ($cy + 18))
# Inner hole / contour
$swirlPath.AddBezier(($cx + 2), ($cy + 18), ($cx + 14), ($cy + 24), ($cx + 14), ($cy + 22), ($cx + 4), ($cy + 24))
$swirlPath.AddBezier(($cx + 4), ($cy + 24), ($cx - 12), ($cy + 24), ($cx - 24), ($cy + 10), ($cx - 20), ($cy - 6))
$swirlPath.AddBezier(($cx - 20), ($cy - 6), ($cx - 16), ($cy - 20), ($cx + 10), ($cy - 20), ($cx + 34), ($cy - 10))
$swirlPath.CloseFigure()

$swirlBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 237, 28, 36))
$g1.FillPath($swirlBrush, $swirlPath)
$swirlBrush.Dispose()
$swirlPath.Dispose()

# Typography
$g1.DrawString("Xstream Play", $tFontMed, [System.Drawing.Brushes]::White, $textX, 132)
$xsSubBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 80, 95))
$g1.DrawString("MOVIES  •  SHOWS  •  LIVE TV", $sFont, $xsSubBrush, ($textX + 4), 195)
$xsSubBrush.Dispose()
$g1.Dispose()
$bmp1.Save("$outDir\banner_xstream.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp1.Dispose()

# ==========================================
# 2. REFINED CRICFY TV (banner_cricfy.png)
# ==========================================
$bmp2 = New-Object System.Drawing.Bitmap($W, $H)
$g2 = Init-Graphics $bmp2
Draw-TileBase $g2 ([System.Drawing.Color]::FromArgb(255, 28, 20, 14)) `
                 ([System.Drawing.Color]::FromArgb(255, 14, 10, 7)) `
                 ([System.Drawing.Color]::FromArgb(95, 255, 109, 0))

$cfTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(95, 60, 36, 18))
$cfTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, 255, 109, 0), 2.5)
Fill-RoundRect $g2 $cfTileBrush $tileRect $tileR
Draw-RoundRect $g2 $cfTilePen $tileRect $tileR
$cfTileBrush.Dispose()
$cfTilePen.Dispose()

# Precision Retro Television in Squircle
# TV Body
$tvBodyPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 4.5)
$tvBodyRect = New-Object System.Drawing.Rectangle(($cx - 44), ($cy - 20), 88, 56)
Draw-RoundRect $g2 $tvBodyPen $tvBodyRect 10
$tvBodyPen.Dispose()

# TV Screen (glowing amber)
$screenBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 109, 0))
$screenRect = New-Object System.Drawing.Rectangle(($cx - 36), ($cy - 12), 48, 40)
Fill-RoundRect $g2 $screenBrush $screenRect 6
$screenBrush.Dispose()

# TV Controls / Dials on right side
$g2.FillEllipse([System.Drawing.Brushes]::White, ($cx + 20), ($cy - 10), 10, 10)
$g2.FillEllipse([System.Drawing.Brushes]::White, ($cx + 20), ($cy + 6), 10, 10)
$speakerPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 255, 255, 255), 2.5)
$g2.DrawLine($speakerPen, ($cx + 18), ($cy + 22), ($cx + 32), ($cy + 22))
$speakerPen.Dispose()

# V-Antennas
$antPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 4.0)
$antPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$antPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g2.DrawLine($antPen, ($cx - 10), ($cy - 20), ($cx - 30), ($cy - 48))
$g2.DrawLine($antPen, ($cx + 10), ($cy - 20), ($cx + 30), ($cy - 48))
$antPen.Dispose()
$g2.FillEllipse([System.Drawing.Brushes]::White, ($cx - 35), ($cy - 53), 10, 10)
$g2.FillEllipse([System.Drawing.Brushes]::White, ($cx + 25), ($cy - 53), 10, 10)

# TV Stand Legs
$legPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 255, 255, 255), 3.5)
$legPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$legPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g2.DrawLine($legPen, ($cx - 28), ($cy + 36), ($cx - 38), ($cy + 48))
$g2.DrawLine($legPen, ($cx + 28), ($cy + 36), ($cx + 38), ($cy + 48))
$legPen.Dispose()

# Typography
$g2.DrawString("Cricfy TV", $tFont, [System.Drawing.Brushes]::White, $textX, 130)
$cfSubBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 140, 30))
$g2.DrawString("FREE LIVE CRICKET & SPORTS", $sFont, $cfSubBrush, ($textX + 4), 195)
$cfSubBrush.Dispose()
$g2.Dispose()
$bmp2.Save("$outDir\banner_cricfy.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp2.Dispose()

Write-Host "Refined banner_xstream and banner_cricfy!"
