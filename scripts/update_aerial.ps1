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

function Draw-TileBase($g, $bgColor1, $bgColor2, $glowColor, $glowRect) {
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Point(0, 0)),
        (New-Object System.Drawing.Point($W, $H)),
        $bgColor1, $bgColor2
    )
    $g.FillRectangle($bgBrush, 0, 0, $W, $H)
    $bgBrush.Dispose()

    if ($glowColor -and $glowRect) {
        $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
        $gp.AddEllipse($glowRect)
        $pbr = New-Object System.Drawing.Drawing2D.PathGradientBrush($gp)
        $pbr.CenterColor = $glowColor
        $pbr.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
        $g.FillEllipse($pbr, $glowRect)
        $pbr.Dispose()
        $gp.Dispose()
    }

    $topPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(35, 255, 255, 255), 1.0)
    $g.DrawLine($topPen, 0, 0, $W, 0)
    $topPen.Dispose()

    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(20, 255, 255, 255), 1.0)
    $g.DrawRectangle($borderPen, 0, 0, $W - 1, $H - 1)
    $borderPen.Dispose()
}

$tFont = New-Object System.Drawing.Font($fontFam, 34, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$sFont = New-Object System.Drawing.Font($fontFam, 13, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$bmp5 = New-Object System.Drawing.Bitmap($W, $H)
$g5 = Init-Graphics $bmp5
Draw-TileBase $g5 ([System.Drawing.Color]::FromArgb(255, 14, 18, 34)) `
                 ([System.Drawing.Color]::FromArgb(255, 7, 9, 18)) `
                 ([System.Drawing.Color]::FromArgb(85, 94, 92, 230)) `
                 (New-Object System.Drawing.Rectangle(45, 35, 250, 250))

$cx = 170
$cy = 180
$aerialTile = New-Object System.Drawing.Rectangle(($cx - 56), ($cy - 56), 112, 112)
$aerialTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(85, 28, 36, 70))
$aerialTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(140, 94, 92, 230), 2.0)
Fill-RoundRect $g5 $aerialTileBrush $aerialTile 26
Draw-RoundRect $g5 $aerialTilePen $aerialTile 26
$aerialTileBrush.Dispose()
$aerialTilePen.Dispose()

# Glowing celestial moon
$moonBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 100, 210, 255))
$g5.FillEllipse($moonBrush, ($cx + 12), ($cy - 30), 16, 16)
$moonBrush.Dispose()

# Left Mountain peak (White)
$mtn1 = New-Object System.Drawing.Drawing2D.GraphicsPath
$mtn1.AddLine(($cx - 36), ($cy + 24), ($cx - 10), ($cy - 16))
$mtn1.AddLine(($cx - 10), ($cy - 16), ($cx + 16), ($cy + 24))
$mtn1.CloseFigure()
$mtn1Brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$g5.FillPath($mtn1Brush, $mtn1)
$mtn1Brush.Dispose()
$mtn1.Dispose()

# Right Mountain peak (Lavender / Indigo tint)
$mtn2 = New-Object System.Drawing.Drawing2D.GraphicsPath
$mtn2.AddLine(($cx - 6), ($cy + 24), ($cx + 14), ($cy - 6))
$mtn2.AddLine(($cx + 14), ($cy - 6), ($cx + 36), ($cy + 24))
$mtn2.CloseFigure()
$mtn2Brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 160, 175, 255))
$g5.FillPath($mtn2Brush, $mtn2)
$mtn2Brush.Dispose()
$mtn2.Dispose()

# Base horizon line
$basePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 3.5)
$basePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$basePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g5.DrawLine($basePen, ($cx - 38), ($cy + 24), ($cx + 38), ($cy + 24))
$basePen.Dispose()

# Typography
$g5.DrawString("Aerial Views", $tFont, [System.Drawing.Brushes]::White, 275, 136)
$indigoBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 140, 165, 255))
$g5.DrawString("4K AERIAL SCREENSAVERS", $sFont, $indigoBrush, 278, 190)
$indigoBrush.Dispose()
$g5.Dispose()
$bmp5.Save("$outDir\banner_aerialviews.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp5.Dispose()

Write-Host "Updated Aerial Views with SF Symbols Mountain!"
