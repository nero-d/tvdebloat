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

# ==========================================
# 1. SEND FILES TO TV (banner_sftv.png) - With Matching Squircle
# ==========================================
$bmp1 = New-Object System.Drawing.Bitmap($W, $H)
$g1 = Init-Graphics $bmp1
Draw-TileBase $g1 ([System.Drawing.Color]::FromArgb(255, 16, 21, 32)) `
                 ([System.Drawing.Color]::FromArgb(255, 9, 11, 18)) `
                 ([System.Drawing.Color]::FromArgb(75, 0, 122, 255)) `
                 (New-Object System.Drawing.Rectangle(45, 35, 250, 250))

$cx = 170
$cy = 180
$sftvTile = New-Object System.Drawing.Rectangle(($cx - 56), ($cy - 56), 112, 112)
$sftvTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(85, 20, 42, 75))
$sftvTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(140, 0, 140, 255), 2.0)
Fill-RoundRect $g1 $sftvTileBrush $sftvTile 26
Draw-RoundRect $g1 $sftvTilePen $sftvTile 26
$sftvTileBrush.Dispose()
$sftvTilePen.Dispose()

# AirDrop concentric rings inside tile
for ($i = 2; $i -ge 1; $i--) {
    $rad = $i * 18
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 0, 140, 255), 3.8)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g1.DrawArc($pen, ($cx - $rad), ($cy - $rad + 6), ($rad * 2), ($rad * 2), 140, 260)
    $pen.Dispose()
}

# Glowing core node
$nodeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$g1.FillEllipse($nodeBrush, ($cx - 7), ($cy - 1), 14, 14)
$nodeBrush.Dispose()

# Upward sharing beam
$arrowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$arrowPath.AddLine($cx, ($cy - 38), ($cx - 12), ($cy - 22))
$arrowPath.AddLine(($cx - 12), ($cy - 22), ($cx - 5), ($cy - 22))
$arrowPath.AddLine(($cx - 5), ($cy - 22), ($cx - 5), ($cy - 4))
$arrowPath.AddLine(($cx + 5), ($cy - 4), ($cx + 5), ($cy - 22))
$arrowPath.AddLine(($cx + 5), ($cy - 22), ($cx + 12), ($cy - 22))
$arrowPath.CloseFigure()
$arrowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$g1.FillPath($arrowBrush, $arrowPath)
$arrowBrush.Dispose()
$arrowPath.Dispose()

# Typography
$g1.DrawString("Send Files", $tFont, [System.Drawing.Brushes]::White, 275, 136)
$sBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 60, 165, 255))
$g1.DrawString("TO TV  •  AIRDROP TRANSFER", $sFont, $sBrush, 278, 190)
$sBrush.Dispose()
$g1.Dispose()
$bmp1.Save("$outDir\banner_sftv.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp1.Dispose()

# ==========================================
# 4. WEB VIDEO CASTER (banner_wvc.png) - With Full Name
# ==========================================
$bmp4 = New-Object System.Drawing.Bitmap($W, $H)
$g4 = Init-Graphics $bmp4
Draw-TileBase $g4 ([System.Drawing.Color]::FromArgb(255, 25, 24, 28)) `
                 ([System.Drawing.Color]::FromArgb(255, 13, 13, 16)) `
                 ([System.Drawing.Color]::FromArgb(65, 255, 149, 0)) `
                 (New-Object System.Drawing.Rectangle(45, 35, 250, 250))

$cx = 165
$cy = 180
$wvcTile = New-Object System.Drawing.Rectangle(($cx - 56), ($cy - 56), 112, 112)
$wvcTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80, 48, 42, 36))
$wvcTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, 255, 149, 0), 2.0)
Fill-RoundRect $g4 $wvcTileBrush $wvcTile 26
Draw-RoundRect $g4 $wvcTilePen $wvcTile 26
$wvcTileBrush.Dispose()
$wvcTilePen.Dispose()

# Apple AirPlay / Cast Display Bezel
$tvFramePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 4.5)
$tvFrameRect = New-Object System.Drawing.Rectangle(($cx - 36), ($cy - 34), 72, 48)
Draw-RoundRect $g4 $tvFramePen $tvFrameRect 8
$tvFramePen.Dispose()

# AirPlay Beaming Triangle
$triPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$triPath.AddLine($cx, ($cy + 6), ($cx - 16), ($cy + 28))
$triPath.AddLine(($cx - 16), ($cy + 28), ($cx + 16), ($cy + 28))
$triPath.CloseFigure()
$triBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 149, 0))
$g4.FillPath($triBrush, $triPath)
$triBrush.Dispose()
$triPath.Dispose()

# Typography (Full Name)
$wvcFont = New-Object System.Drawing.Font($fontFam, 30, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g4.DrawString("Web Video Caster", $wvcFont, [System.Drawing.Brushes]::White, 260, 138)
$orangeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 165, 30))
$g4.DrawString("AIRPLAY & WEB RECEIVER", $sFont, $orangeBrush, 263, 190)
$orangeBrush.Dispose()
$wvcFont.Dispose()
$g4.Dispose()
$bmp4.Save("$outDir\banner_wvc.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp4.Dispose()

# ==========================================
# 5. AERIAL VIEWS (banner_aerialviews.png) - Enhanced Celestial Globe
# ==========================================
$bmp5 = New-Object System.Drawing.Bitmap($W, $H)
$g5 = Init-Graphics $bmp5
Draw-TileBase $g5 ([System.Drawing.Color]::FromArgb(255, 15, 19, 36)) `
                 ([System.Drawing.Color]::FromArgb(255, 8, 10, 20)) `
                 ([System.Drawing.Color]::FromArgb(75, 94, 92, 230)) `
                 (New-Object System.Drawing.Rectangle(45, 35, 250, 250))

$cx = 170
$cy = 180
$aerialTile = New-Object System.Drawing.Rectangle(($cx - 56), ($cy - 56), 112, 112)
$aerialTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80, 28, 34, 65))
$aerialTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(130, 94, 92, 230), 2.0)
Fill-RoundRect $g5 $aerialTileBrush $aerialTile 26
Draw-RoundRect $g5 $aerialTilePen $aerialTile 26
$aerialTileBrush.Dispose()
$aerialTilePen.Dispose()

# Outer celestial circle
$globePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 4.0)
$g5.DrawEllipse($globePen, ($cx - 28), ($cy - 28), 56, 56)
$globePen.Dispose()

# Equator and meridian latitude arcs
$equatorPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 100, 210, 255), 2.8)
$g5.DrawEllipse($equatorPen, ($cx - 28), ($cy - 12), 56, 24)
$equatorPen.Dispose()

$meridianPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, 94, 92, 230), 2.5)
$g5.DrawLine($meridianPen, $cx, ($cy - 28), $cx, ($cy + 28))
$meridianPen.Dispose()

# Glowing atmospheric rim ring
$ringPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 100, 210, 255), 3.2)
$ringPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$ringPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g5.DrawArc($ringPen, ($cx - 36), ($cy - 20), 72, 40, 15, 150)
$ringPen.Dispose()

# Typography
$g5.DrawString("Aerial Views", $tFont, [System.Drawing.Brushes]::White, 275, 136)
$indigoBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 130, 155, 255))
$g5.DrawString("4K AERIAL SCREENSAVERS", $sFont, $indigoBrush, 278, 190)
$indigoBrush.Dispose()
$g5.Dispose()
$bmp5.Save("$outDir\banner_aerialviews.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp5.Dispose()

Write-Host "Updated banner_sftv, banner_wvc, and banner_aerialviews!"
