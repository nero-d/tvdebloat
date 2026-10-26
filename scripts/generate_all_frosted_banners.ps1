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

# The unified Frosted Glass Base - matching pill_bg.xml (#24FFFFFF)
function Draw-FrostedBase($g, $glowColor) {
    $g.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))

    # Smoky frosted underlay for rich contrast
    $darkBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Point(0, 0)),
        (New-Object System.Drawing.Point(0, $H)),
        [System.Drawing.Color]::FromArgb(115, 14, 16, 22),
        [System.Drawing.Color]::FromArgb(75, 10, 11, 15)
    )
    $g.FillRectangle($darkBrush, 0, 0, $W, $H)
    $darkBrush.Dispose()

    # Translucent Frosted Glass Sheen (matches pill_bg: #24FFFFFF)
    $glassBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Point(0, 0)),
        (New-Object System.Drawing.Point(0, $H)),
        [System.Drawing.Color]::FromArgb(48, 255, 255, 255),
        [System.Drawing.Color]::FromArgb(18, 255, 255, 255)
    )
    $g.FillRectangle($glassBrush, 0, 0, $W, $H)
    $glassBrush.Dispose()

    # Soft Brand Halo Aura through the frosted glass
    if ($glowColor) {
        $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
        $glowRect = New-Object System.Drawing.Rectangle(10, 10, 320, 320)
        $gp.AddEllipse($glowRect)
        $pbr = New-Object System.Drawing.Drawing2D.PathGradientBrush($gp)
        $pbr.CenterColor = $glowColor
        $pbr.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
        $g.FillEllipse($pbr, $glowRect)
        $pbr.Dispose()
        $gp.Dispose()
    }

    # Top specular rim highlight
    $shinePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(90, 255, 255, 255), 1.5)
    $g.DrawLine($shinePen, 0, 1, $W, 1)
    $shinePen.Dispose()

    # Translucent glass border (matches pill_stroke: #3AFFFFFF)
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(58, 255, 255, 255), 1.5)
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
$tFontCompact = New-Object System.Drawing.Font($fontFam, 34, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$sFont = New-Object System.Drawing.Font($fontFam, 15, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

function Draw-TileSquircle($g, $brushColor, $strokeColor) {
    $brush = New-Object System.Drawing.SolidBrush($brushColor)
    $pen = New-Object System.Drawing.Pen($strokeColor, 2.5)
    Fill-RoundRect $g $brush $tileRect $tileR
    Draw-RoundRect $g $pen $tileRect $tileR
    $brush.Dispose()
    $pen.Dispose()
}

function Draw-TileText($g, $title, $sub, $subColor, $isMed = $false, $isCompact = $false) {
    $f = if ($isCompact) { $tFontCompact } elseif ($isMed) { $tFontMed } else { $tFont }
    $yOff = if ($isCompact) { 136 } elseif ($isMed) { 132 } else { 130 }
    
    # Soft text drop shadow
    $sh = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120, 0, 0, 0))
    $g.DrawString($title, $f, $sh, ($textX + 2), ($yOff + 2))
    $sh.Dispose()

    # Crisp white title
    $g.DrawString($title, $f, [System.Drawing.Brushes]::White, $textX, $yOff)

    # Radiant brand subtitle
    $sb = New-Object System.Drawing.SolidBrush($subColor)
    $g.DrawString($sub, $sFont, $sb, ($textX + 4), 195)
    $sb.Dispose()
}

# ----------------------------------------------------
# 1. NETFLIX
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 229, 9, 20))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(235, 255, 255, 255)) ([System.Drawing.Color]::FromArgb(200, 229, 9, 20))
$nBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 229, 9, 20))
$nFont = New-Object System.Drawing.Font($fontFam, 95, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString("N", $nFont, $nBrush, ($cx - 36), ($cy - 65))
$nFont.Dispose()
$nBrush.Dispose()
Draw-TileText $g "Netflix" "POPULAR MOVIES & SERIES" ([System.Drawing.Color]::FromArgb(255, 240, 70, 80))
$g.Dispose()
$b.Save("$outDir\banner_netflix.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 2. PRIME VIDEO
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 0, 168, 225))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(220, 0, 168, 225)) ([System.Drawing.Color]::FromArgb(200, 255, 255, 255))
$pFont = New-Object System.Drawing.Font($fontFam, 38, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString("prime", $pFont, [System.Drawing.Brushes]::White, ($cx - 48), ($cy - 34))
$pFont.Dispose()
$smilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 153, 0), 4.5)
$smilePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$smilePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawArc($smilePen, ($cx - 40), ($cy + 6), 80, 28, 15, 150)
$smilePen.Dispose()
Draw-TileText $g "Prime Video" "AMAZON ORIGINALS & MOVIES" ([System.Drawing.Color]::FromArgb(255, 50, 195, 255))
$g.Dispose()
$b.Save("$outDir\banner_prime.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 3. JIOHOTSTAR
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 31, 128, 224))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(180, 20, 48, 86)) ([System.Drawing.Color]::FromArgb(180, 31, 128, 224))
$starPath = New-Object System.Drawing.Drawing2D.GraphicsPath
for ($a = 0; $a -lt 360; $a += 45) {
    $radM = $a * [Math]::PI / 180
    $radm = ($a + 22.5) * [Math]::PI / 180
    $ro = if ($a % 90 -eq 0) { 48 } else { 24 }
    $starPath.AddLine((New-Object System.Drawing.PointF(($cx + [Math]::Cos($radM)*$ro), ($cy + [Math]::Sin($radM)*$ro))),
                      (New-Object System.Drawing.PointF(($cx + [Math]::Cos($radm)*8), ($cy + [Math]::Sin($radm)*8))))
}
$starPath.CloseFigure()
$starBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$g.FillPath($starBrush, $starPath)
$starBrush.Dispose()
$starPath.Dispose()
$g.FillEllipse([System.Drawing.Brushes]::White, ($cx - 5), ($cy - 5), 10, 10)
Draw-TileText $g "JioHotstar" "MOVIES, SHOWS & LIVE SPORTS" ([System.Drawing.Color]::FromArgb(255, 75, 185, 255))
$g.Dispose()
$b.Save("$outDir\banner_hotstar.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 4. YOUTUBE
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 255, 0, 0))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(235, 255, 255, 255)) ([System.Drawing.Color]::FromArgb(180, 255, 0, 0))
$ytPill = New-Object System.Drawing.Rectangle(($cx - 44), ($cy - 30), 88, 60)
$ytBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 0, 0))
Fill-RoundRect $g $ytBrush $ytPill 16
$ytBrush.Dispose()
$ytTri = New-Object System.Drawing.Drawing2D.GraphicsPath
$ytTri.AddPolygon(@(
    (New-Object System.Drawing.PointF(($cx - 10), ($cy - 16))),
    (New-Object System.Drawing.PointF(($cx + 18), $cy)),
    (New-Object System.Drawing.PointF(($cx - 10), ($cy + 16)))
))
$g.FillPath([System.Drawing.Brushes]::White, $ytTri)
$ytTri.Dispose()
Draw-TileText $g "YouTube" "VIDEOS, MUSIC & STREAMS" ([System.Drawing.Color]::FromArgb(255, 255, 75, 75))
$g.Dispose()
$b.Save("$outDir\banner_youtube.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 5. APPLE TV
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 180, 190, 205))

# Draw official Apple TV icon inside squircle
$gp = New-Object System.Drawing.Drawing2D.GraphicsPath
$gp.AddArc($tileRect.X, $tileRect.Y, $tileR * 2, $tileR * 2, 180, 90)
$gp.AddArc($tileRect.Right - $tileR * 2, $tileRect.Y, $tileR * 2, $tileR * 2, 270, 90)
$gp.AddArc($tileRect.Right - $tileR * 2, $tileRect.Bottom - $tileR * 2, $tileR * 2, $tileR * 2, 0, 90)
$gp.AddArc($tileRect.X, $tileRect.Bottom - $tileR * 2, $tileR * 2, $tileR * 2, 90, 90)
$gp.CloseFigure()
$state = $g.Save()
$g.SetClip($gp)
$officialAppleIcon = [System.Drawing.Image]::FromFile("C:\Users\sanik\tv_debloat\assets\appletv_icon.png")
$g.DrawImage($officialAppleIcon, $tileRect.X, $tileRect.Y, $tileRect.Width, $tileRect.Height)
$officialAppleIcon.Dispose()
$g.Restore($state)
$pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(80, 255, 255, 255), 2.0)
$g.DrawPath($pen, $gp)
$pen.Dispose()
$gp.Dispose()

Draw-TileText $g "Apple TV+" "ORIGINALS & 4K HDR CINEMA" ([System.Drawing.Color]::FromArgb(255, 205, 215, 225))
$g.Dispose()
$b.Save("$outDir\banner_appletv.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 6. XSTREAM PLAY
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 237, 28, 36))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(180, 60, 20, 26)) ([System.Drawing.Color]::FromArgb(180, 237, 28, 36))
$swirlPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$swirlPath.AddBezier(($cx + 34), ($cy - 10), ($cx + 30), ($cy - 36), ($cx - 26), ($cy - 40), ($cx - 36), ($cy - 12))
$swirlPath.AddBezier(($cx - 36), ($cy - 12), ($cx - 44), ($cy + 16), ($cx - 16), ($cy + 42), ($cx + 12), ($cy + 36))
$swirlPath.AddBezier(($cx + 12), ($cy + 36), ($cx + 32), ($cy + 30), ($cx + 34), ($cy + 10), ($cx + 18), ($cy + 2))
$swirlPath.AddBezier(($cx + 18), ($cy + 2), ($cx + 6), ($cy - 4), ($cx - 6), ($cy + 8), ($cx + 2), ($cy + 18))
$swirlPath.AddBezier(($cx + 2), ($cy + 18), ($cx + 14), ($cy + 24), ($cx + 14), ($cy + 22), ($cx + 4), ($cy + 24))
$swirlPath.AddBezier(($cx + 4), ($cy + 24), ($cx - 12), ($cy + 24), ($cx - 24), ($cy + 10), ($cx - 20), ($cy - 6))
$swirlPath.AddBezier(($cx - 20), ($cy - 6), ($cx - 16), ($cy - 20), ($cx + 10), ($cy - 20), ($cx + 34), ($cy - 10))
$swirlPath.CloseFigure()
$swirlBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 237, 28, 36))
$g.FillPath($swirlBrush, $swirlPath)
$swirlBrush.Dispose()
$swirlPath.Dispose()
Draw-TileText $g "Xstream Play" "MOVIES, SHOWS & LIVE TV" ([System.Drawing.Color]::FromArgb(255, 255, 75, 90)) $true
$g.Dispose()
$b.Save("$outDir\banner_xstream.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 7. ZEE5
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 138, 43, 226))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(180, 48, 28, 76)) ([System.Drawing.Color]::FromArgb(180, 162, 90, 245))
$zFont = New-Object System.Drawing.Font($fontFam, 68, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString("Z5", $zFont, [System.Drawing.Brushes]::White, ($cx - 48), ($cy - 48))
$zFont.Dispose()
Draw-TileText $g "ZEE5" "ORIGINALS & BLOCKBUSTERS" ([System.Drawing.Color]::FromArgb(255, 185, 135, 255))
$g.Dispose()
$b.Save("$outDir\banner_zee5.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 8. CRICFY TV
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 255, 109, 0))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(180, 56, 32, 16)) ([System.Drawing.Color]::FromArgb(180, 255, 109, 0))
$tvBodyPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 4.5)
$tvBodyRect = New-Object System.Drawing.Rectangle(($cx - 44), ($cy - 20), 88, 56)
Draw-RoundRect $g $tvBodyPen $tvBodyRect 10
$tvBodyPen.Dispose()
$screenBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 109, 0))
$screenRect = New-Object System.Drawing.Rectangle(($cx - 36), ($cy - 12), 48, 40)
Fill-RoundRect $g $screenBrush $screenRect 6
$screenBrush.Dispose()
$g.FillEllipse([System.Drawing.Brushes]::White, ($cx + 20), ($cy - 10), 10, 10)
$g.FillEllipse([System.Drawing.Brushes]::White, ($cx + 20), ($cy + 6), 10, 10)
$speakerPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 255, 255, 255), 2.5)
$g.DrawLine($speakerPen, ($cx + 18), ($cy + 22), ($cx + 32), ($cy + 22))
$speakerPen.Dispose()
$antPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 4.0)
$antPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$antPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($antPen, ($cx - 10), ($cy - 20), ($cx - 30), ($cy - 48))
$g.DrawLine($antPen, ($cx + 10), ($cy - 20), ($cx + 30), ($cy - 48))
$antPen.Dispose()
$g.FillEllipse([System.Drawing.Brushes]::White, ($cx - 35), ($cy - 53), 10, 10)
$g.FillEllipse([System.Drawing.Brushes]::White, ($cx + 25), ($cy - 53), 10, 10)
$legPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 255, 255, 255), 3.5)
$legPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$legPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($legPen, ($cx - 28), ($cy + 36), ($cx - 38), ($cy + 48))
$g.DrawLine($legPen, ($cx + 28), ($cy + 36), ($cx + 38), ($cy + 48))
$legPen.Dispose()
Draw-TileText $g "Cricfy TV" "FREE LIVE CRICKET & SPORTS" ([System.Drawing.Color]::FromArgb(255, 255, 140, 30))
$g.Dispose()
$b.Save("$outDir\banner_cricfy.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 9. AERIAL VIEWS
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 94, 92, 230))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(180, 28, 36, 70)) ([System.Drawing.Color]::FromArgb(180, 94, 92, 230))
$moonBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 100, 215, 255))
$g.FillEllipse($moonBrush, ($cx + 16), ($cy - 40), 22, 22)
$moonBrush.Dispose()
$mtn1 = New-Object System.Drawing.Drawing2D.GraphicsPath
$mtn1.AddLine(($cx - 48), ($cy + 34), ($cx - 14), ($cy - 22))
$mtn1.AddLine(($cx - 14), ($cy - 22), ($cx + 22), ($cy + 34))
$mtn1.CloseFigure()
$g.FillPath([System.Drawing.Brushes]::White, $mtn1)
$mtn1.Dispose()
$mtn2 = New-Object System.Drawing.Drawing2D.GraphicsPath
$mtn2.AddLine(($cx - 8), ($cy + 34), ($cx + 20), ($cy - 8))
$mtn2.AddLine(($cx + 20), ($cy - 8), ($cx + 48), ($cy + 34))
$mtn2.CloseFigure()
$mtn2Brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, 165, 180, 255))
$g.FillPath($mtn2Brush, $mtn2)
$mtn2Brush.Dispose()
$mtn2.Dispose()
$basePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 4.5)
$basePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$basePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($basePen, ($cx - 50), ($cy + 34), ($cx + 50), ($cy + 34))
$basePen.Dispose()
Draw-TileText $g "Aerial Views" "4K AERIAL SCREENSAVERS" ([System.Drawing.Color]::FromArgb(255, 140, 165, 255))
$g.Dispose()
$b.Save("$outDir\banner_aerialviews.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 10. AERIAL DREAM
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 0, 122, 255))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(180, 20, 48, 86)) ([System.Drawing.Color]::FromArgb(180, 0, 140, 255))
$airpPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 0, 140, 255), 4.0)
$g.DrawEllipse($airpPen, ($cx - 38), ($cy - 38), 76, 76)
$airpPen.Dispose()
$planePath = New-Object System.Drawing.Drawing2D.GraphicsPath
$planePath.AddLine($cx, ($cy - 28), ($cx + 6), ($cy - 8))
$planePath.AddLine(($cx + 6), ($cy - 8), ($cx + 30), ($cy - 4))
$planePath.AddLine(($cx + 30), ($cy - 4), ($cx + 6), ($cy + 10))
$planePath.AddLine(($cx + 6), ($cy + 10), ($cx + 14), ($cy + 24))
$planePath.AddLine(($cx + 14), ($cy + 24), ($cx + 4), ($cy + 22))
$planePath.AddLine(($cx + 4), ($cy + 22), $cx, ($cy + 28))
$planePath.AddLine($cx, ($cy + 28), ($cx - 4), ($cy + 22))
$planePath.AddLine(($cx - 4), ($cy + 22), ($cx - 14), ($cy + 24))
$planePath.AddLine(($cx - 14), ($cy + 24), ($cx - 6), ($cy + 10))
$planePath.AddLine(($cx - 6), ($cy + 10), ($cx - 30), ($cy - 4))
$planePath.AddLine(($cx - 30), ($cy - 4), ($cx - 6), ($cy - 8))
$planePath.CloseFigure()
$g.FillPath([System.Drawing.Brushes]::White, $planePath)
$planePath.Dispose()
Draw-TileText $g "Aerial Dream" "DAYDREAM SCREENSAVERS" ([System.Drawing.Color]::FromArgb(255, 80, 175, 255))
$g.Dispose()
$b.Save("$outDir\banner_aerialdream.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 11. PLAY STORE
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 0, 200, 83))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(180, 18, 54, 40)) ([System.Drawing.Color]::FromArgb(180, 0, 200, 83))
$pTop = New-Object System.Drawing.PointF(($cx - 28), ($cy - 44))
$pBtm = New-Object System.Drawing.PointF(($cx - 28), ($cy + 44))
$pTip = New-Object System.Drawing.PointF(($cx + 42), $cy)
$pCtr = New-Object System.Drawing.PointF(($cx + 2), $cy)
$fBlue = New-Object System.Drawing.Drawing2D.GraphicsPath; $fBlue.AddPolygon(@($pTop, $pBtm, $pCtr))
$bBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 134, 248)); $g.FillPath($bBrush, $fBlue); $bBrush.Dispose(); $fBlue.Dispose()
$fGreen = New-Object System.Drawing.Drawing2D.GraphicsPath; $fGreen.AddPolygon(@($pTop, $pTip, $pCtr))
$gBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 200, 83)); $g.FillPath($gBrush, $fGreen); $gBrush.Dispose(); $fGreen.Dispose()
$fRed = New-Object System.Drawing.Drawing2D.GraphicsPath; $fRed.AddPolygon(@($pBtm, $pTip, $pCtr))
$rBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 61, 0)); $g.FillPath($rBrush, $fRed); $rBrush.Dispose(); $fRed.Dispose()
$fYellow = New-Object System.Drawing.Drawing2D.GraphicsPath; $fYellow.AddPolygon(@((New-Object System.Drawing.PointF(($cx + 18), ($cy - 16))), $pTip, (New-Object System.Drawing.PointF(($cx + 18), ($cy + 16)))))
$yBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 212, 0)); $g.FillPath($yBrush, $fYellow); $yBrush.Dispose(); $fYellow.Dispose()
Draw-TileText $g "Play Store" "APPS, GAMES & TV TOOLS" ([System.Drawing.Color]::FromArgb(255, 0, 230, 118))
$g.Dispose()
$b.Save("$outDir\banner_playstore.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 12. LIVE TV
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 255, 55, 95))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(180, 58, 22, 30)) ([System.Drawing.Color]::FromArgb(180, 255, 55, 95))
$displayPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 5.5)
$displayRect = New-Object System.Drawing.Rectangle(($cx - 46), ($cy - 34), 92, 58)
Draw-RoundRect $g $displayPen $displayRect 8
$displayPen.Dispose()
$standPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 255, 255, 255), 4.5)
$standPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$standPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($standPen, ($cx - 20), ($cy + 35), ($cx + 20), ($cy + 35))
$standPen.Dispose()
$liveBadgeRect = New-Object System.Drawing.Rectangle(($cx - 30), ($cy - 24), 60, 22)
$liveBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 55, 95))
Fill-RoundRect $g $liveBrush $liveBadgeRect 6
$liveBrush.Dispose()
$liveFont = New-Object System.Drawing.Font($fontFam, 13, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString("LIVE", $liveFont, [System.Drawing.Brushes]::White, ($cx - 15), ($cy - 22))
$liveFont.Dispose()
Draw-TileText $g "Live TV" "CHANNELS & HDMI INPUTS" ([System.Drawing.Color]::FromArgb(255, 255, 90, 120))
$g.Dispose()
$b.Save("$outDir\banner_tcltv.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 13. T-SOLO
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 191, 90, 242))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(180, 54, 25, 78)) ([System.Drawing.Color]::FromArgb(180, 191, 90, 242))
$noteBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Point(($cx - 40), ($cy - 40))), (New-Object System.Drawing.Point(($cx + 40), ($cy + 40))), [System.Drawing.Color]::FromArgb(255, 255, 65, 130), [System.Drawing.Color]::FromArgb(255, 191, 90, 242))
$g.TranslateTransform(($cx - 20), ($cy + 24)); $g.RotateTransform(-25); $g.FillEllipse($noteBrush, -16, -11, 32, 22); $g.ResetTransform()
$g.TranslateTransform(($cx + 20), ($cy + 14)); $g.RotateTransform(-25); $g.FillEllipse($noteBrush, -16, -11, 32, 22); $g.ResetTransform()
$stemPen = New-Object System.Drawing.Pen($noteBrush, 7.5); $stemPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($stemPen, ($cx - 9), ($cy + 20), ($cx - 9), ($cy - 28))
$g.DrawLine($stemPen, ($cx + 31), ($cy + 10), ($cx + 31), ($cy - 38))
$beamPath = New-Object System.Drawing.Drawing2D.GraphicsPath; $beamPath.AddLine(($cx - 10), ($cy - 22), ($cx + 33), ($cy - 32)); $beamPath.AddLine(($cx + 33), ($cy - 41), ($cx - 10), ($cy - 31)); $beamPath.CloseFigure()
$g.FillPath($noteBrush, $beamPath); $beamPath.Dispose(); $stemPen.Dispose(); $noteBrush.Dispose()
Draw-TileText $g "T-Solo" "AUDIO & SOUND TUNER" ([System.Drawing.Color]::FromArgb(255, 215, 130, 255))
$g.Dispose()
$b.Save("$outDir\banner_tsolo.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 14. DOWNLOADER
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 255, 159, 10))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(180, 52, 44, 30)) ([System.Drawing.Color]::FromArgb(180, 255, 159, 10))
$dlArrow = New-Object System.Drawing.Drawing2D.GraphicsPath
$dlArrow.AddLine($cx, ($cy + 20), ($cx - 24), ($cy - 8))
$dlArrow.AddLine(($cx - 24), ($cy - 8), ($cx - 10), ($cy - 8))
$dlArrow.AddLine(($cx - 10), ($cy - 8), ($cx - 10), ($cy - 40))
$dlArrow.AddLine(($cx + 10), ($cy - 40), ($cx + 10), ($cy - 8))
$dlArrow.AddLine(($cx + 10), ($cy - 8), ($cx + 24), ($cy - 8))
$dlArrow.CloseFigure()
$g.FillPath([System.Drawing.Brushes]::White, $dlArrow)
$dlArrow.Dispose()
$cradlePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 159, 10), 6.0)
$cradlePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round; $cradlePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$cradlePath = New-Object System.Drawing.Drawing2D.GraphicsPath
$cradlePath.AddLine(($cx - 32), ($cy + 28), ($cx - 32), ($cy + 40)); $cradlePath.AddLine(($cx - 32), ($cy + 40), ($cx + 32), ($cy + 40)); $cradlePath.AddLine(($cx + 32), ($cy + 40), ($cx + 32), ($cy + 28))
$g.DrawPath($cradlePen, $cradlePath); $cradlePen.Dispose(); $cradlePath.Dispose()
Draw-TileText $g "Downloader" "BROWSER & TV FILES" ([System.Drawing.Color]::FromArgb(255, 255, 165, 30))
$g.Dispose()
$b.Save("$outDir\banner_downloader.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 15. GALLERY
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 0, 122, 255))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(180, 20, 48, 86)) ([System.Drawing.Color]::FromArgb(180, 0, 140, 255))
for ($i = 0; $i -lt 6; $i++) {
    $angle = $i * 60
    $g.TranslateTransform($cx, $cy)
    $g.RotateTransform($angle)
    $petalBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 255, 255, 255))
    $g.FillEllipse($petalBrush, -9, -38, 18, 32)
    $petalBrush.Dispose()
    $g.ResetTransform()
}
$g.FillEllipse([System.Drawing.Brushes]::White, ($cx - 10), ($cy - 10), 20, 20)
Draw-TileText $g "Gallery" "PHOTOS & PERSONAL MEDIA" ([System.Drawing.Color]::FromArgb(255, 80, 175, 255))
$g.Dispose()
$b.Save("$outDir\banner_gallery.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 16. MEDIA PLAYER
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 33, 150, 243))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(180, 20, 42, 75)) ([System.Drawing.Color]::FromArgb(180, 33, 150, 243))
$filmRect = New-Object System.Drawing.Rectangle(($cx - 44), ($cy - 30), 88, 60)
$filmPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 4.5)
Draw-RoundRect $g $filmPen $filmRect 8
$filmPen.Dispose()
for ($x = ($cx - 36); $x -le ($cx + 32); $x += 16) {
    $g.FillRectangle([System.Drawing.Brushes]::White, $x, ($cy - 26), 8, 8)
    $g.FillRectangle([System.Drawing.Brushes]::White, $x, ($cy + 18), 8, 8)
}
$triPlay = New-Object System.Drawing.Drawing2D.GraphicsPath
$triPlay.AddPolygon(@((New-Object System.Drawing.PointF(($cx - 8), ($cy - 10))), (New-Object System.Drawing.PointF(($cx + 12), $cy)), (New-Object System.Drawing.PointF(($cx - 8), ($cy + 10)))))
$g.FillPath([System.Drawing.Brushes]::White, $triPlay)
$triPlay.Dispose()
Draw-TileText $g "Media Player" "USB & LOCAL STORAGE" ([System.Drawing.Color]::FromArgb(255, 75, 185, 255))
$g.Dispose()
$b.Save("$outDir\banner_mediaplayer.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 17. MX PLAYER
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 33, 150, 243))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(180, 20, 42, 75)) ([System.Drawing.Color]::FromArgb(180, 33, 150, 243))
$mxPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 4.5)
$g.DrawEllipse($mxPen, ($cx - 38), ($cy - 38), 76, 76)
$mxPen.Dispose()
$mxTri = New-Object System.Drawing.Drawing2D.GraphicsPath
$mxTri.AddPolygon(@((New-Object System.Drawing.PointF(($cx - 10), ($cy - 20))), (New-Object System.Drawing.PointF(($cx + 20), $cy)), (New-Object System.Drawing.PointF(($cx - 10), ($cy + 20)))))
$g.FillPath([System.Drawing.Brushes]::White, $mxTri)
$mxTri.Dispose()
Draw-TileText $g "MX Player" "4K HARDWARE ACCELERATION" ([System.Drawing.Color]::FromArgb(255, 75, 185, 255))
$g.Dispose()
$b.Save("$outDir\banner_mxplayer.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 18. STREMIO
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 124, 82, 149))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(180, 52, 34, 76)) ([System.Drawing.Color]::FromArgb(180, 155, 81, 224))
$dTop = New-Object System.Drawing.PointF($cx, ($cy - 44)); $dBtm = New-Object System.Drawing.PointF($cx, ($cy + 44))
$dLeft = New-Object System.Drawing.PointF(($cx - 40), $cy); $dRight = New-Object System.Drawing.PointF(($cx + 44), $cy)
$p1 = New-Object System.Drawing.Drawing2D.GraphicsPath; $p1.AddPolygon(@($dLeft, $dTop, (New-Object System.Drawing.PointF($cx, $cy))))
$b1 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 75, 50, 170)); $g.FillPath($b1, $p1); $b1.Dispose(); $p1.Dispose()
$p2 = New-Object System.Drawing.Drawing2D.GraphicsPath; $p2.AddPolygon(@($dLeft, $dBtm, (New-Object System.Drawing.PointF($cx, $cy))))
$b2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 160, 255)); $g.FillPath($b2, $p2); $b2.Dispose(); $p2.Dispose()
$p3 = New-Object System.Drawing.Drawing2D.GraphicsPath; $p3.AddPolygon(@($dTop, $dRight, $dBtm, (New-Object System.Drawing.PointF($cx, $cy))))
$b3 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 175, 82, 222)); $g.FillPath($b3, $p3); $b3.Dispose(); $p3.Dispose()
$triPlay = New-Object System.Drawing.Drawing2D.GraphicsPath
$triPlay.AddPolygon(@((New-Object System.Drawing.PointF(($cx - 10), ($cy - 18))), (New-Object System.Drawing.PointF(($cx + 18), $cy)), (New-Object System.Drawing.PointF(($cx - 10), ($cy + 18)))))
$g.FillPath([System.Drawing.Brushes]::White, $triPlay); $triPlay.Dispose()
Draw-TileText $g "Stremio" "FREEDOM OF STREAMING" ([System.Drawing.Color]::FromArgb(255, 190, 140, 255))
$g.Dispose()
$b.Save("$outDir\banner_stremio.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 19. SEND FILES TO TV
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 0, 122, 255))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(180, 20, 48, 86)) ([System.Drawing.Color]::FromArgb(180, 0, 140, 255))
for ($i = 2; $i -ge 1; $i--) {
    $rad = $i * 26
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 0, 140, 255), 5.0)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round; $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawArc($pen, ($cx - $rad), ($cy - $rad + 8), ($rad * 2), ($rad * 2), 140, 260); $pen.Dispose()
}
$g.FillEllipse([System.Drawing.Brushes]::White, ($cx - 10), ($cy - 2), 20, 20)
$arrowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$arrowPath.AddLine($cx, ($cy - 50), ($cx - 16), ($cy - 30)); $arrowPath.AddLine(($cx - 16), ($cy - 30), ($cx - 7), ($cy - 30))
$arrowPath.AddLine(($cx - 7), ($cy - 30), ($cx - 7), ($cy - 6)); $arrowPath.AddLine(($cx + 7), ($cy - 6), ($cx + 7), ($cy - 30))
$arrowPath.AddLine(($cx + 7), ($cy - 30), ($cx + 16), ($cy - 30)); $arrowPath.CloseFigure()
$g.FillPath([System.Drawing.Brushes]::White, $arrowPath); $arrowPath.Dispose()
Draw-TileText $g "Send Files" "FAST LOCAL WI-FI TRANSFER" ([System.Drawing.Color]::FromArgb(255, 80, 185, 255))
$g.Dispose()
$b.Save("$outDir\banner_sftv.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

# ----------------------------------------------------
# 20. WEB VIDEO CASTER
# ----------------------------------------------------
$b = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = Init-Graphics $b
Draw-FrostedBase $g ([System.Drawing.Color]::FromArgb(90, 255, 149, 0))
Draw-TileSquircle $g ([System.Drawing.Color]::FromArgb(180, 56, 44, 28)) ([System.Drawing.Color]::FromArgb(180, 255, 149, 0))
$tvFramePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 5.5)
$tvFrameRect = New-Object System.Drawing.Rectangle(($cx - 46), ($cy - 44), 92, 62)
Draw-RoundRect $g $tvFramePen $tvFrameRect 10
$tvFramePen.Dispose()
$triPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$triPath.AddLine($cx, ($cy + 8), ($cx - 20), ($cy + 36)); $triPath.AddLine(($cx - 20), ($cy + 36), ($cx + 20), ($cy + 36)); $triPath.CloseFigure()
$triBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 149, 0))
$g.FillPath($triBrush, $triPath); $triBrush.Dispose(); $triPath.Dispose()
Draw-TileText $g "Web Video Caster" "AIRPLAY & WEB RECEIVER" ([System.Drawing.Color]::FromArgb(255, 255, 165, 30)) $false $true
$g.Dispose()
$b.Save("$outDir\banner_wvc.png", [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

Write-Host "Successfully generated all 20 Frosted Glass tvOS banners!"
