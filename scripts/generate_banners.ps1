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

function Draw-TileBase($g, $bgColor1, $bgColor2, $glowColor, $glowRect) {
    # Gradient BG
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Point(0, 0)),
        (New-Object System.Drawing.Point($W, $H)),
        $bgColor1, $bgColor2
    )
    $g.FillRectangle($bgBrush, 0, 0, $W, $H)
    $bgBrush.Dispose()

    # Soft radial glow
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

    # Subtle top highlight (Apple glass rim)
    $topPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(35, 255, 255, 255), 1.0)
    $g.DrawLine($topPen, 0, 0, $W, 0)
    $topPen.Dispose()

    # Subtle border
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(20, 255, 255, 255), 1.0)
    $g.DrawRectangle($borderPen, 0, 0, $W - 1, $H - 1)
    $borderPen.Dispose()
}

# ==========================================
# 1. SEND FILES TO TV (banner_sftv.png)
# ==========================================
$bmp1 = New-Object System.Drawing.Bitmap($W, $H)
$g1 = Init-Graphics $bmp1
Draw-TileBase $g1 ([System.Drawing.Color]::FromArgb(255, 16, 20, 29)) `
                 ([System.Drawing.Color]::FromArgb(255, 9, 11, 16)) `
                 ([System.Drawing.Color]::FromArgb(65, 0, 122, 255)) `
                 (New-Object System.Drawing.Rectangle(40, 30, 260, 260))

$cx = 170
$cy = 180

# Radar arcs with rounded caps
for ($i = 3; $i -ge 1; $i--) {
    $rad = $i * 25
    $alpha = 110 + ($i * 45)
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb($alpha, 0, 122, 255), 5.0)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g1.DrawArc($pen, ($cx - $rad), ($cy - $rad), ($rad * 2), ($rad * 2), 140, 260)
    $pen.Dispose()
}

# Glowing core beacon
$nodeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$g1.FillEllipse($nodeBrush, ($cx - 9), ($cy - 9), 18, 18)
$nodeBrush.Dispose()

# Upward sharing beam
$arrowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$arrowPath.AddLine($cx, ($cy - 108), ($cx - 17), ($cy - 87))
$arrowPath.AddLine(($cx - 17), ($cy - 87), ($cx - 7), ($cy - 87))
$arrowPath.AddLine(($cx - 7), ($cy - 87), ($cx - 7), ($cy - 52))
$arrowPath.AddLine(($cx + 7), ($cy - 52), ($cx + 7), ($cy - 87))
$arrowPath.AddLine(($cx + 7), ($cy - 87), ($cx + 17), ($cy - 87))
$arrowPath.CloseFigure()
$arrowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$g1.FillPath($arrowBrush, $arrowPath)
$arrowBrush.Dispose()
$arrowPath.Dispose()

# Typography
$tFont = New-Object System.Drawing.Font($fontFam, 34, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g1.DrawString("Send Files", $tFont, [System.Drawing.Brushes]::White, 275, 136)
$sFont = New-Object System.Drawing.Font($fontFam, 13, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$sBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 58, 160, 255))
$g1.DrawString("TO TV  •  AIRDROP TRANSFER", $sFont, $sBrush, 278, 190)
$sBrush.Dispose()
$g1.Dispose()
$bmp1.Save("$outDir\banner_sftv.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp1.Dispose()
Write-Host "Created banner_sftv.png"

# ==========================================
# 2. DOWNLOADER (banner_downloader.png)
# ==========================================
$bmp2 = New-Object System.Drawing.Bitmap($W, $H)
$g2 = Init-Graphics $bmp2
Draw-TileBase $g2 ([System.Drawing.Color]::FromArgb(255, 26, 27, 34)) `
                 ([System.Drawing.Color]::FromArgb(255, 14, 15, 18)) `
                 ([System.Drawing.Color]::FromArgb(60, 255, 159, 10)) `
                 (New-Object System.Drawing.Rectangle(45, 35, 250, 250))

# Sleek rounded badge for download glyph
$cx = 170
$cy = 180
$badgeRect = New-Object System.Drawing.Rectangle(($cx - 56), ($cy - 56), 112, 112)
$badgeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80, 45, 47, 56))
$badgePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, 255, 159, 10), 2.0)

# Rounded rectangle function
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

Fill-RoundRect $g2 $badgeBrush $badgeRect 26
Draw-RoundRect $g2 $badgePen $badgeRect 26
$badgeBrush.Dispose()
$badgePen.Dispose()

# Downloader Arrow & Cradle
$dlArrow = New-Object System.Drawing.Drawing2D.GraphicsPath
# Arrow pointing down
$dlArrow.AddLine($cx, ($cy + 16), ($cx - 18), ($cy - 6))
$dlArrow.AddLine(($cx - 18), ($cy - 6), ($cx - 7), ($cy - 6))
$dlArrow.AddLine(($cx - 7), ($cy - 6), ($cx - 7), ($cy - 30))
$dlArrow.AddLine(($cx + 7), ($cy - 30), ($cx + 7), ($cy - 6))
$dlArrow.AddLine(($cx + 7), ($cy - 6), ($cx + 18), ($cy - 6))
$dlArrow.CloseFigure()
$dlBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$g2.FillPath($dlBrush, $dlArrow)
$dlBrush.Dispose()
$dlArrow.Dispose()

# Amber cradle tray below arrow
$cradlePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 159, 10), 4.5)
$cradlePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$cradlePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$cradlePath = New-Object System.Drawing.Drawing2D.GraphicsPath
$cradlePath.AddLine(($cx - 24), ($cy + 22), ($cx - 24), ($cy + 30))
$cradlePath.AddLine(($cx - 24), ($cy + 30), ($cx + 24), ($cy + 30))
$cradlePath.AddLine(($cx + 24), ($cy + 30), ($cx + 24), ($cy + 22))
$g2.DrawPath($cradlePen, $cradlePath)
$cradlePen.Dispose()
$cradlePath.Dispose()

# Typography
$g2.DrawString("Downloader", $tFont, [System.Drawing.Brushes]::White, 275, 136)
$amberBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 165, 30))
$g2.DrawString("BROWSER & TV FILES", $sFont, $amberBrush, 278, 190)
$amberBrush.Dispose()
$g2.Dispose()
$bmp2.Save("$outDir\banner_downloader.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp2.Dispose()
Write-Host "Created banner_downloader.png"

# ==========================================
# 3. T-SOLO AUDIO (banner_tsolo.png)
# ==========================================
$bmp3 = New-Object System.Drawing.Bitmap($W, $H)
$g3 = Init-Graphics $bmp3
Draw-TileBase $g3 ([System.Drawing.Color]::FromArgb(255, 28, 14, 45)) `
                 ([System.Drawing.Color]::FromArgb(255, 13, 6, 21)) `
                 ([System.Drawing.Color]::FromArgb(75, 191, 90, 242)) `
                 (New-Object System.Drawing.Rectangle(45, 35, 250, 250))

$cx = 170
$cy = 180
# Frosted violet tile
$noteTile = New-Object System.Drawing.Rectangle(($cx - 56), ($cy - 56), 112, 112)
$noteTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(90, 55, 25, 85))
$noteTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(140, 191, 90, 242), 2.0)
Fill-RoundRect $g3 $noteTileBrush $noteTile 26
Draw-RoundRect $g3 $noteTilePen $noteTile 26
$noteTileBrush.Dispose()
$noteTilePen.Dispose()

# Sculpted Apple Music 8th Note
$noteBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(($cx - 30), ($cy - 30))),
    (New-Object System.Drawing.Point(($cx + 30), ($cy + 30))),
    [System.Drawing.Color]::FromArgb(255, 255, 60, 120),
    [System.Drawing.Color]::FromArgb(255, 191, 90, 242)
)

# Left note head (angled ellipse)
$g3.TranslateTransform(($cx - 16), ($cy + 18))
$g3.RotateTransform(-25)
$g3.FillEllipse($noteBrush, -13, -9, 26, 18)
$g3.ResetTransform()

# Right note head (angled ellipse)
$g3.TranslateTransform(($cx + 16), ($cy + 10))
$g3.RotateTransform(-25)
$g3.FillEllipse($noteBrush, -13, -9, 26, 18)
$g3.ResetTransform()

# Stems and connecting beam
$stemPen = New-Object System.Drawing.Pen($noteBrush, 6.0)
$stemPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$g3.DrawLine($stemPen, ($cx - 7), ($cy + 15), ($cx - 7), ($cy - 22))
$g3.DrawLine($stemPen, ($cx + 25), ($cy + 7), ($cx + 25), ($cy - 30))

# Thick connecting beam at top
$beamPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$beamPath.AddLine(($cx - 8), ($cy - 16), ($cx + 27), ($cy - 24))
$beamPath.AddLine(($cx + 27), ($cy - 31), ($cx - 8), ($cy - 23))
$beamPath.CloseFigure()
$g3.FillPath($noteBrush, $beamPath)
$beamPath.Dispose()
$stemPen.Dispose()
$noteBrush.Dispose()

# Typography
$g3.DrawString("T-Solo", $tFont, [System.Drawing.Brushes]::White, 275, 136)
$purpBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 205, 120, 255))
$g3.DrawString("AUDIO & SOUND TUNER", $sFont, $purpBrush, 278, 190)
$purpBrush.Dispose()
$g3.Dispose()
$bmp3.Save("$outDir\banner_tsolo.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp3.Dispose()
Write-Host "Created banner_tsolo.png"

# ==========================================
# 4. WEB VIDEO CASTER (banner_wvc.png)
# ==========================================
$bmp4 = New-Object System.Drawing.Bitmap($W, $H)
$g4 = Init-Graphics $bmp4
Draw-TileBase $g4 ([System.Drawing.Color]::FromArgb(255, 25, 24, 28)) `
                 ([System.Drawing.Color]::FromArgb(255, 13, 13, 16)) `
                 ([System.Drawing.Color]::FromArgb(65, 255, 149, 0)) `
                 (New-Object System.Drawing.Rectangle(45, 35, 250, 250))

$cx = 170
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

# AirPlay Beaming Triangle / Cast Waves
$triPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$triPath.AddLine($cx, ($cy + 6), ($cx - 16), ($cy + 28))
$triPath.AddLine(($cx - 16), ($cy + 28), ($cx + 16), ($cy + 28))
$triPath.CloseFigure()
$triBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 149, 0))
$g4.FillPath($triBrush, $triPath)
$triBrush.Dispose()
$triPath.Dispose()

# Typography
$g4.DrawString("Web Cast", $tFont, [System.Drawing.Brushes]::White, 275, 136)
$orangeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 165, 30))
$g4.DrawString("AIRPLAY & WEB RECEIVER", $sFont, $orangeBrush, 278, 190)
$orangeBrush.Dispose()
$g4.Dispose()
$bmp4.Save("$outDir\banner_wvc.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp4.Dispose()
Write-Host "Created banner_wvc.png"

# ==========================================
# 5. AERIAL VIEWS (banner_aerialviews.png)
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

# Precision tvOS Aerial Orbit / Aperture
$globePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 4.0)
$g5.DrawEllipse($globePen, ($cx - 28), ($cy - 28), 56, 56)
$globePen.Dispose()

# Glowing atmospheric celestial ring
$ringPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 100, 210, 255), 3.5)
$ringPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$ringPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g5.DrawArc($ringPen, ($cx - 36), ($cy - 18), 72, 36, 10, 160)
$ringPen.Dispose()

# Horizon latitude line
$latPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, 94, 92, 230), 2.5)
$g5.DrawArc($latPen, ($cx - 28), ($cy - 12), 56, 24, 0, 180)
$latPen.Dispose()

# Typography
$g5.DrawString("Aerial Views", $tFont, [System.Drawing.Brushes]::White, 275, 136)
$indigoBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 130, 155, 255))
$g5.DrawString("4K AERIAL SCREENSAVERS", $sFont, $indigoBrush, 278, 190)
$indigoBrush.Dispose()
$g5.Dispose()
$bmp5.Save("$outDir\banner_aerialviews.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp5.Dispose()
Write-Host "Created banner_aerialviews.png"

# ==========================================
# 6. LIVE TV (banner_tcltv.png)
# ==========================================
$bmp6 = New-Object System.Drawing.Bitmap($W, $H)
$g6 = Init-Graphics $bmp6
Draw-TileBase $g6 ([System.Drawing.Color]::FromArgb(255, 28, 14, 18)) `
                 ([System.Drawing.Color]::FromArgb(255, 13, 6, 8)) `
                 ([System.Drawing.Color]::FromArgb(75, 255, 55, 95)) `
                 (New-Object System.Drawing.Rectangle(45, 35, 250, 250))

$cx = 170
$cy = 180
$tvTile = New-Object System.Drawing.Rectangle(($cx - 56), ($cy - 56), 112, 112)
$tvTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(85, 55, 25, 32))
$tvTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(130, 255, 55, 95), 2.0)
Fill-RoundRect $g6 $tvTileBrush $tvTile 26
Draw-RoundRect $g6 $tvTilePen $tvTile 26
$tvTileBrush.Dispose()
$tvTilePen.Dispose()

# Minimalist modern TV Display
$displayPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 4.5)
$displayRect = New-Object System.Drawing.Rectangle(($cx - 36), ($cy - 26), 72, 44)
Draw-RoundRect $g6 $displayPen $displayRect 6
$displayPen.Dispose()

# TV Stand
$standPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 255, 255, 255), 3.5)
$standPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$standPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g6.DrawLine($standPen, ($cx - 16), ($cy + 26), ($cx + 16), ($cy + 26))
$standPen.Dispose()

# Glowing LIVE pill badge in top right of display
$liveBadgeRect = New-Object System.Drawing.Rectangle(($cx - 24), ($cy - 18), 48, 16)
$liveBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 55, 95))
Fill-RoundRect $g6 $liveBrush $liveBadgeRect 4
$liveBrush.Dispose()

$liveFont = New-Object System.Drawing.Font($fontFam, 10, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g6.DrawString("LIVE", $liveFont, [System.Drawing.Brushes]::White, ($cx - 12), ($cy - 16))

# Typography
$g6.DrawString("Live TV", $tFont, [System.Drawing.Brushes]::White, 275, 136)
$redBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 80, 110))
$g6.DrawString("CHANNELS & HDMI INPUTS", $sFont, $redBrush, 278, 190)
$redBrush.Dispose()
$g6.Dispose()
$bmp6.Save("$outDir\banner_tcltv.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp6.Dispose()
Write-Host "Created banner_tcltv.png"

Write-Host "All 6 banners generated successfully!"
