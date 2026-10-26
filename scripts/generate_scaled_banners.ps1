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

# Typography scale: Bold 46px title, 16px subtitle
$tFont = New-Object System.Drawing.Font($fontFam, 44, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$tFontCompact = New-Object System.Drawing.Font($fontFam, 36, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$sFont = New-Object System.Drawing.Font($fontFam, 16, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

# Common geometry: Squircle 150x150, centered at X=160, Y=180
$cx = 158
$cy = 180
$tileSz = 148
$tileR = 34
$tileRect = New-Object System.Drawing.Rectangle(($cx - $tileSz/2), ($cy - $tileSz/2), $tileSz, $tileSz)
$textX = 265

# ==========================================
# 1. SEND FILES TO TV (banner_sftv.png)
# ==========================================
$bmp1 = New-Object System.Drawing.Bitmap($W, $H)
$g1 = Init-Graphics $bmp1
Draw-TileBase $g1 ([System.Drawing.Color]::FromArgb(255, 17, 22, 34)) `
                 ([System.Drawing.Color]::FromArgb(255, 9, 11, 18)) `
                 ([System.Drawing.Color]::FromArgb(90, 0, 122, 255))

$sftvBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(95, 20, 48, 86))
$sftvPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, 0, 140, 255), 2.5)
Fill-RoundRect $g1 $sftvBrush $tileRect $tileR
Draw-RoundRect $g1 $sftvPen $tileRect $tileR
$sftvBrush.Dispose()
$sftvPen.Dispose()

# AirDrop concentric rings
for ($i = 2; $i -ge 1; $i--) {
    $rad = $i * 26
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 0, 140, 255), 5.0)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g1.DrawArc($pen, ($cx - $rad), ($cy - $rad + 8), ($rad * 2), ($rad * 2), 140, 260)
    $pen.Dispose()
}

$nodeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$g1.FillEllipse($nodeBrush, ($cx - 10), ($cy - 2), 20, 20)
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
$g1.FillPath($arrowBrush, $arrowPath)
$arrowBrush.Dispose()
$arrowPath.Dispose()

# Typography
$g1.DrawString("Send Files", $tFont, [System.Drawing.Brushes]::White, $textX, 130)
$sBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 60, 170, 255))
$g1.DrawString("TO TV  •  FAST TRANSFER", $sFont, $sBrush, ($textX + 4), 195)
$sBrush.Dispose()
$g1.Dispose()
$bmp1.Save("$outDir\banner_sftv.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp1.Dispose()

# ==========================================
# 2. DOWNLOADER (banner_downloader.png)
# ==========================================
$bmp2 = New-Object System.Drawing.Bitmap($W, $H)
$g2 = Init-Graphics $bmp2
Draw-TileBase $g2 ([System.Drawing.Color]::FromArgb(255, 28, 29, 36)) `
                 ([System.Drawing.Color]::FromArgb(255, 14, 15, 18)) `
                 ([System.Drawing.Color]::FromArgb(85, 255, 159, 10))

$dlTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(90, 52, 54, 66))
$dlTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(150, 255, 159, 10), 2.5)
Fill-RoundRect $g2 $dlTileBrush $tileRect $tileR
Draw-RoundRect $g2 $dlTilePen $tileRect $tileR
$dlTileBrush.Dispose()
$dlTilePen.Dispose()

# Downloader Arrow & Cradle
$dlArrow = New-Object System.Drawing.Drawing2D.GraphicsPath
$dlArrow.AddLine($cx, ($cy + 20), ($cx - 24), ($cy - 8))
$dlArrow.AddLine(($cx - 24), ($cy - 8), ($cx - 10), ($cy - 8))
$dlArrow.AddLine(($cx - 10), ($cy - 8), ($cx - 10), ($cy - 40))
$dlArrow.AddLine(($cx + 10), ($cy - 40), ($cx + 10), ($cy - 8))
$dlArrow.AddLine(($cx + 10), ($cy - 8), ($cx + 24), ($cy - 8))
$dlArrow.CloseFigure()
$dlBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$g2.FillPath($dlBrush, $dlArrow)
$dlBrush.Dispose()
$dlArrow.Dispose()

# Amber cradle tray
$cradlePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 159, 10), 6.0)
$cradlePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$cradlePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$cradlePath = New-Object System.Drawing.Drawing2D.GraphicsPath
$cradlePath.AddLine(($cx - 32), ($cy + 28), ($cx - 32), ($cy + 40))
$cradlePath.AddLine(($cx - 32), ($cy + 40), ($cx + 32), ($cy + 40))
$cradlePath.AddLine(($cx + 32), ($cy + 40), ($cx + 32), ($cy + 28))
$g2.DrawPath($cradlePen, $cradlePath)
$cradlePen.Dispose()
$cradlePath.Dispose()

# Typography
$g2.DrawString("Downloader", $tFont, [System.Drawing.Brushes]::White, $textX, 130)
$amberBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 165, 30))
$g2.DrawString("BROWSER & TV FILES", $sFont, $amberBrush, ($textX + 4), 195)
$amberBrush.Dispose()
$g2.Dispose()
$bmp2.Save("$outDir\banner_downloader.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp2.Dispose()

# ==========================================
# 3. T-SOLO (banner_tsolo.png)
# ==========================================
$bmp3 = New-Object System.Drawing.Bitmap($W, $H)
$g3 = Init-Graphics $bmp3
Draw-TileBase $g3 ([System.Drawing.Color]::FromArgb(255, 30, 15, 48)) `
                 ([System.Drawing.Color]::FromArgb(255, 13, 6, 21)) `
                 ([System.Drawing.Color]::FromArgb(95, 191, 90, 242))

$tsoloTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(95, 62, 30, 96))
$tsoloTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(150, 191, 90, 242), 2.5)
Fill-RoundRect $g3 $tsoloTileBrush $tileRect $tileR
Draw-RoundRect $g3 $tsoloTilePen $tileRect $tileR
$tsoloTileBrush.Dispose()
$tsoloTilePen.Dispose()

# Apple Music 8th Note
$noteBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(($cx - 40), ($cy - 40))),
    (New-Object System.Drawing.Point(($cx + 40), ($cy + 40))),
    [System.Drawing.Color]::FromArgb(255, 255, 65, 130),
    [System.Drawing.Color]::FromArgb(255, 191, 90, 242)
)

# Left note head
$g3.TranslateTransform(($cx - 20), ($cy + 24))
$g3.RotateTransform(-25)
$g3.FillEllipse($noteBrush, -16, -11, 32, 22)
$g3.ResetTransform()

# Right note head
$g3.TranslateTransform(($cx + 20), ($cy + 14))
$g3.RotateTransform(-25)
$g3.FillEllipse($noteBrush, -16, -11, 32, 22)
$g3.ResetTransform()

# Stems and connecting beam
$stemPen = New-Object System.Drawing.Pen($noteBrush, 7.5)
$stemPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$g3.DrawLine($stemPen, ($cx - 9), ($cy + 20), ($cx - 9), ($cy - 28))
$g3.DrawLine($stemPen, ($cx + 31), ($cy + 10), ($cx + 31), ($cy - 38))

# Top connecting beam
$beamPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$beamPath.AddLine(($cx - 10), ($cy - 22), ($cx + 33), ($cy - 32))
$beamPath.AddLine(($cx + 33), ($cy - 41), ($cx - 10), ($cy - 31))
$beamPath.CloseFigure()
$g3.FillPath($noteBrush, $beamPath)
$beamPath.Dispose()
$stemPen.Dispose()
$noteBrush.Dispose()

# Typography
$g3.DrawString("T-Solo", $tFont, [System.Drawing.Brushes]::White, $textX, 130)
$purpBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 215, 130, 255))
$g3.DrawString("AUDIO & SOUND TUNER", $sFont, $purpBrush, ($textX + 4), 195)
$purpBrush.Dispose()
$g3.Dispose()
$bmp3.Save("$outDir\banner_tsolo.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp3.Dispose()

# ==========================================
# 4. WEB VIDEO CASTER (banner_wvc.png)
# ==========================================
$bmp4 = New-Object System.Drawing.Bitmap($W, $H)
$g4 = Init-Graphics $bmp4
Draw-TileBase $g4 ([System.Drawing.Color]::FromArgb(255, 26, 25, 30)) `
                 ([System.Drawing.Color]::FromArgb(255, 13, 13, 16)) `
                 ([System.Drawing.Color]::FromArgb(85, 255, 149, 0))

$wvcTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(90, 56, 48, 40))
$wvcTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(150, 255, 149, 0), 2.5)
Fill-RoundRect $g4 $wvcTileBrush $tileRect $tileR
Draw-RoundRect $g4 $wvcTilePen $tileRect $tileR
$wvcTileBrush.Dispose()
$wvcTilePen.Dispose()

# Apple AirPlay Display Frame
$tvFramePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 5.5)
$tvFrameRect = New-Object System.Drawing.Rectangle(($cx - 46), ($cy - 44), 92, 62)
Draw-RoundRect $g4 $tvFramePen $tvFrameRect 10
$tvFramePen.Dispose()

# AirPlay Beaming Triangle
$triPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$triPath.AddLine($cx, ($cy + 8), ($cx - 20), ($cy + 36))
$triPath.AddLine(($cx - 20), ($cy + 36), ($cx + 20), ($cy + 36))
$triPath.CloseFigure()
$triBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 149, 0))
$g4.FillPath($triBrush, $triPath)
$triBrush.Dispose()
$triPath.Dispose()

# Typography (Compact font 36px for 3 words)
$g4.DrawString("Web Video Caster", $tFontCompact, [System.Drawing.Brushes]::White, ($textX - 10), 134)
$orangeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 165, 30))
$g4.DrawString("AIRPLAY & WEB RECEIVER", $sFont, $orangeBrush, ($textX - 6), 195)
$orangeBrush.Dispose()
$g4.Dispose()
$bmp4.Save("$outDir\banner_wvc.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp4.Dispose()

# ==========================================
# 5. AERIAL VIEWS (banner_aerialviews.png)
# ==========================================
$bmp5 = New-Object System.Drawing.Bitmap($W, $H)
$g5 = Init-Graphics $bmp5
Draw-TileBase $g5 ([System.Drawing.Color]::FromArgb(255, 16, 20, 38)) `
                 ([System.Drawing.Color]::FromArgb(255, 8, 10, 20)) `
                 ([System.Drawing.Color]::FromArgb(95, 94, 92, 230))

$aerialTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(95, 32, 42, 82))
$aerialTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(150, 94, 92, 230), 2.5)
Fill-RoundRect $g5 $aerialTileBrush $tileRect $tileR
Draw-RoundRect $g5 $aerialTilePen $tileRect $tileR
$aerialTileBrush.Dispose()
$aerialTilePen.Dispose()

# Celestial Moon
$moonBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 100, 215, 255))
$g5.FillEllipse($moonBrush, ($cx + 16), ($cy - 40), 22, 22)
$moonBrush.Dispose()

# Left Mountain peak (White)
$mtn1 = New-Object System.Drawing.Drawing2D.GraphicsPath
$mtn1.AddLine(($cx - 48), ($cy + 34), ($cx - 14), ($cy - 22))
$mtn1.AddLine(($cx - 14), ($cy - 22), ($cx + 22), ($cy + 34))
$mtn1.CloseFigure()
$mtn1Brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$g5.FillPath($mtn1Brush, $mtn1)
$mtn1Brush.Dispose()
$mtn1.Dispose()

# Right Mountain peak (Lavender/Indigo)
$mtn2 = New-Object System.Drawing.Drawing2D.GraphicsPath
$mtn2.AddLine(($cx - 8), ($cy + 34), ($cx + 20), ($cy - 8))
$mtn2.AddLine(($cx + 20), ($cy - 8), ($cx + 48), ($cy + 34))
$mtn2.CloseFigure()
$mtn2Brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, 165, 180, 255))
$g5.FillPath($mtn2Brush, $mtn2)
$mtn2Brush.Dispose()
$mtn2.Dispose()

# Horizon baseline
$basePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 4.5)
$basePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$basePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g5.DrawLine($basePen, ($cx - 50), ($cy + 34), ($cx + 50), ($cy + 34))
$basePen.Dispose()

# Typography
$g5.DrawString("Aerial Views", $tFont, [System.Drawing.Brushes]::White, $textX, 130)
$indigoBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 150, 175, 255))
$g5.DrawString("4K AERIAL SCREENSAVERS", $sFont, $indigoBrush, ($textX + 4), 195)
$indigoBrush.Dispose()
$g5.Dispose()
$bmp5.Save("$outDir\banner_aerialviews.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp5.Dispose()

# ==========================================
# 6. LIVE TV (banner_tcltv.png)
# ==========================================
$bmp6 = New-Object System.Drawing.Bitmap($W, $H)
$g6 = Init-Graphics $bmp6
Draw-TileBase $g6 ([System.Drawing.Color]::FromArgb(255, 30, 14, 20)) `
                 ([System.Drawing.Color]::FromArgb(255, 13, 6, 8)) `
                 ([System.Drawing.Color]::FromArgb(95, 255, 55, 95))

$tvTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(95, 65, 28, 36))
$tvTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(150, 255, 55, 95), 2.5)
Fill-RoundRect $g6 $tvTileBrush $tileRect $tileR
Draw-RoundRect $g6 $tvTilePen $tileRect $tileR
$tvTileBrush.Dispose()
$tvTilePen.Dispose()

# Minimalist TV Display
$displayPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 5.5)
$displayRect = New-Object System.Drawing.Rectangle(($cx - 46), ($cy - 34), 92, 58)
Draw-RoundRect $g6 $displayPen $displayRect 8
$displayPen.Dispose()

# TV Stand
$standPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 255, 255, 255), 4.5)
$standPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$standPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g6.DrawLine($standPen, ($cx - 20), ($cy + 35), ($cx + 20), ($cy + 35))
$standPen.Dispose()

# Glowing LIVE pill badge
$liveBadgeRect = New-Object System.Drawing.Rectangle(($cx - 30), ($cy - 24), 60, 22)
$liveBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 55, 95))
Fill-RoundRect $g6 $liveBrush $liveBadgeRect 6
$liveBrush.Dispose()

$liveFont = New-Object System.Drawing.Font($fontFam, 13, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g6.DrawString("LIVE", $liveFont, [System.Drawing.Brushes]::White, ($cx - 15), ($cy - 22))

# Typography
$g6.DrawString("Live TV", $tFont, [System.Drawing.Brushes]::White, $textX, 130)
$redBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 90, 120))
$g6.DrawString("CHANNELS & HDMI INPUTS", $sFont, $redBrush, ($textX + 4), 195)
$redBrush.Dispose()
$g6.Dispose()
$bmp6.Save("$outDir\banner_tcltv.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp6.Dispose()

Write-Host "All 6 banners scaled up and rendered with high TV presence!"
