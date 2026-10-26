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

# Standard layout constants matching the existing design language
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
# 1. XSTREAM PLAY (banner_xstream.png)
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

# Precision Airtel Ribbon Swirl
# Draw sculpted flowing loops
$airtelPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 237, 28, 36), 11.0)
$airtelPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$airtelPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

$airtelPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$pts = @(
    (New-Object System.Drawing.Point(($cx + 34), ($cy - 12))),
    (New-Object System.Drawing.Point(($cx + 10), ($cy - 36))),
    (New-Object System.Drawing.Point(($cx - 28), ($cy - 20))),
    (New-Object System.Drawing.Point(($cx - 32), ($cy + 14))),
    (New-Object System.Drawing.Point(($cx - 6), ($cy + 36))),
    (New-Object System.Drawing.Point(($cx + 20), ($cy + 22))),
    (New-Object System.Drawing.Point(($cx + 6), ($cy + 2))),
    (New-Object System.Drawing.Point(($cx - 10), ($cy + 10)))
)
$airtelPath.AddCurve($pts)
$g1.DrawPath($airtelPen, $airtelPath)
$airtelPen.Dispose()
$airtelPath.Dispose()

# Typography
$g1.DrawString("Xstream Play", $tFontMed, [System.Drawing.Brushes]::White, $textX, 132)
$xsSubBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 80, 95))
$g1.DrawString("MOVIES  •  SHOWS  •  LIVE TV", $sFont, $xsSubBrush, ($textX + 4), 195)
$xsSubBrush.Dispose()
$g1.Dispose()
$bmp1.Save("$outDir\banner_xstream.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp1.Dispose()
Write-Host "Created banner_xstream.png"

# ==========================================
# 2. CRICFY TV (banner_cricfy.png)
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

# Cricfy Sports Ball & Antenna Emblem
# Cricket ball seam + TV display
$ballPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 4.5)
$g2.DrawEllipse($ballPen, ($cx - 34), ($cy - 24), 68, 68)
$ballPen.Dispose()

# Curved seam lines in vivid orange
$seamPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 120, 20), 4.0)
$seamPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$seamPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g2.DrawArc($seamPen, ($cx - 48), ($cy - 24), 68, 68, -45, 90)
$g2.DrawArc($seamPen, ($cx - 20), ($cy - 24), 68, 68, 135, 90)
$seamPen.Dispose()

# Left and Right TV Antennas
$antPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 4.0)
$antPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$antPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g2.DrawLine($antPen, ($cx - 14), ($cy - 22), ($cx - 32), ($cy - 46))
$g2.DrawLine($antPen, ($cx + 14), ($cy - 22), ($cx + 32), ($cy - 46))
$antPen.Dispose()

# Ball tips on antennas
$g2.FillEllipse([System.Drawing.Brushes]::White, ($cx - 37), ($cy - 51), 10, 10)
$g2.FillEllipse([System.Drawing.Brushes]::White, ($cx + 27), ($cy - 51), 10, 10)

# Typography
$g2.DrawString("Cricfy TV", $tFont, [System.Drawing.Brushes]::White, $textX, 130)
$cfSubBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 140, 30))
$g2.DrawString("FREE LIVE CRICKET & SPORTS", $sFont, $cfSubBrush, ($textX + 4), 195)
$cfSubBrush.Dispose()
$g2.Dispose()
$bmp2.Save("$outDir\banner_cricfy.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp2.Dispose()
Write-Host "Created banner_cricfy.png"

# ==========================================
# 3. ZEE5 (banner_zee5.png)
# ==========================================
$bmp3 = New-Object System.Drawing.Bitmap($W, $H)
$g3 = Init-Graphics $bmp3
Draw-TileBase $g3 ([System.Drawing.Color]::FromArgb(255, 22, 17, 34)) `
                 ([System.Drawing.Color]::FromArgb(255, 11, 8, 18)) `
                 ([System.Drawing.Color]::FromArgb(95, 138, 43, 226))

$zTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(95, 48, 32, 80))
$zTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, 162, 90, 245), 2.5)
Fill-RoundRect $g3 $zTileBrush $tileRect $tileR
Draw-RoundRect $g3 $zTilePen $tileRect $tileR
$zTileBrush.Dispose()
$zTilePen.Dispose()

# Sculpted Z5 Monogram
$zFont = New-Object System.Drawing.Font($fontFam, 68, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$zBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(($cx - 45), ($cy - 45))),
    (New-Object System.Drawing.Point(($cx + 45), ($cy + 45))),
    [System.Drawing.Color]::FromArgb(255, 255, 255, 255),
    [System.Drawing.Color]::FromArgb(255, 190, 150, 255)
)
$g3.DrawString("Z5", $zFont, $zBrush, ($cx - 48), ($cy - 48))
$zBrush.Dispose()
$zFont.Dispose()

# Typography
$g3.DrawString("ZEE5", $tFont, [System.Drawing.Brushes]::White, $textX, 130)
$zSubBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 180, 130, 255))
$g3.DrawString("ORIGINALS & BLOCKBUSTERS", $sFont, $zSubBrush, ($textX + 4), 195)
$zSubBrush.Dispose()
$g3.Dispose()
$bmp3.Save("$outDir\banner_zee5.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp3.Dispose()
Write-Host "Created banner_zee5.png"

# ==========================================
# 4. GOOGLE PLAY STORE (banner_playstore.png)
# ==========================================
$bmp4 = New-Object System.Drawing.Bitmap($W, $H)
$g4 = Init-Graphics $bmp4
Draw-TileBase $g4 ([System.Drawing.Color]::FromArgb(255, 14, 25, 20)) `
                 ([System.Drawing.Color]::FromArgb(255, 7, 13, 10)) `
                 ([System.Drawing.Color]::FromArgb(95, 0, 200, 83))

$psTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(95, 20, 56, 42))
$psTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, 0, 200, 83), 2.5)
Fill-RoundRect $g4 $psTileBrush $tileRect $tileR
Draw-RoundRect $g4 $psTilePen $tileRect $tileR
$psTileBrush.Dispose()
$psTilePen.Dispose()

# 4-Facet Google Play Triangle
# Outer boundary points of triangle
$pTop = New-Object System.Drawing.PointF(($cx - 28), ($cy - 44))
$pBtm = New-Object System.Drawing.PointF(($cx - 28), ($cy + 44))
$pTip = New-Object System.Drawing.PointF(($cx + 42), $cy)
$pCtr = New-Object System.Drawing.PointF(($cx + 2), $cy)

# Facet 1: Blue (Left vertical spine)
$fBlue = New-Object System.Drawing.Drawing2D.GraphicsPath
$fBlue.AddPolygon(@($pTop, $pBtm, $pCtr))
$bBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 134, 248))
$g4.FillPath($bBrush, $fBlue)
$bBrush.Dispose()
$fBlue.Dispose()

# Facet 2: Green (Top slope)
$fGreen = New-Object System.Drawing.Drawing2D.GraphicsPath
$fGreen.AddPolygon(@($pTop, $pTip, $pCtr))
$gBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 200, 83))
$g4.FillPath($gBrush, $fGreen)
$gBrush.Dispose()
$fGreen.Dispose()

# Facet 3: Red (Bottom slope)
$fRed = New-Object System.Drawing.Drawing2D.GraphicsPath
$fRed.AddPolygon(@($pBtm, $pTip, $pCtr))
$rBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 61, 0))
$g4.FillPath($rBrush, $fRed)
$rBrush.Dispose()
$fRed.Dispose()

# Facet 4: Yellow tip triangle
$fYellow = New-Object System.Drawing.Drawing2D.GraphicsPath
$fYellow.AddPolygon(@(
    (New-Object System.Drawing.PointF(($cx + 18), ($cy - 16))),
    $pTip,
    (New-Object System.Drawing.PointF(($cx + 18), ($cy + 16)))
))
$yBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 212, 0))
$g4.FillPath($yBrush, $fYellow)
$yBrush.Dispose()
$fYellow.Dispose()

# Typography
$g4.DrawString("Play Store", $tFont, [System.Drawing.Brushes]::White, $textX, 130)
$psSubBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 230, 118))
$g4.DrawString("APPS, GAMES & TV TOOLS", $sFont, $psSubBrush, ($textX + 4), 195)
$psSubBrush.Dispose()
$g4.Dispose()
$bmp4.Save("$outDir\banner_playstore.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp4.Dispose()
Write-Host "Created banner_playstore.png"

# ==========================================
# 5. JIOHOTSTAR (banner_hotstar.png)
# ==========================================
$bmp5 = New-Object System.Drawing.Bitmap($W, $H)
$g5 = Init-Graphics $bmp5
Draw-TileBase $g5 ([System.Drawing.Color]::FromArgb(255, 14, 23, 38)) `
                 ([System.Drawing.Color]::FromArgb(255, 7, 12, 20)) `
                 ([System.Drawing.Color]::FromArgb(95, 31, 128, 224))

$hsTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(95, 20, 48, 86))
$hsTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, 31, 128, 224), 2.5)
Fill-RoundRect $g5 $hsTileBrush $tileRect $tileR
Draw-RoundRect $g5 $hsTilePen $tileRect $tileR
$hsTileBrush.Dispose()
$hsTilePen.Dispose()

# Hotstar 8-pointed starburst spark
$starPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$rOutMajor = 48
$rOutMinor = 24
$rIn = 8

# 8 points (angles 0, 45, 90, 135, 180, 225, 270, 315)
$ptsStar = @()
for ($a = 0; $a -lt 360; $a += 45) {
    $radMajor = $a * [Math]::PI / 180
    $radMinor = ($a + 22.5) * [Math]::PI / 180
    
    $ro = if ($a % 90 -eq 0) { $rOutMajor } else { $rOutMinor }
    
    $px1 = $cx + [Math]::Cos($radMajor) * $ro
    $py1 = $cy + [Math]::Sin($radMajor) * $ro
    $ptsStar += (New-Object System.Drawing.PointF($px1, $py1))
    
    $px2 = $cx + [Math]::Cos($radMinor) * $rIn
    $py2 = $cy + [Math]::Sin($radMinor) * $rIn
    $ptsStar += (New-Object System.Drawing.PointF($px2, $py2))
}
$starPath.AddPolygon($ptsStar)

$starBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(($cx - 40), ($cy - 40))),
    (New-Object System.Drawing.Point(($cx + 40), ($cy + 40))),
    [System.Drawing.Color]::FromArgb(255, 255, 255, 255),
    [System.Drawing.Color]::FromArgb(255, 90, 200, 255)
)
$g5.FillPath($starBrush, $starPath)
$starBrush.Dispose()
$starPath.Dispose()

# Center golden/white star spark
$g5.FillEllipse([System.Drawing.Brushes]::White, ($cx - 5), ($cy - 5), 10, 10)

# Typography
$g5.DrawString("JioHotstar", $tFont, [System.Drawing.Brushes]::White, $textX, 130)
$hsSubBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 90, 200, 255))
$g5.DrawString("MOVIES, SHOWS & LIVE CRICKET", $sFont, $hsSubBrush, ($textX + 4), 195)
$hsSubBrush.Dispose()
$g5.Dispose()
$bmp5.Save("$outDir\banner_hotstar.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp5.Dispose()
Write-Host "Created banner_hotstar.png"

# ==========================================
# 6. STREMIO (banner_stremio.png)
# ==========================================
$bmp6 = New-Object System.Drawing.Bitmap($W, $H)
$g6 = Init-Graphics $bmp6
Draw-TileBase $g6 ([System.Drawing.Color]::FromArgb(255, 24, 17, 36)) `
                 ([System.Drawing.Color]::FromArgb(255, 12, 8, 18)) `
                 ([System.Drawing.Color]::FromArgb(95, 124, 82, 149))

$stTileBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(95, 52, 34, 76))
$stTilePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, 155, 81, 224), 2.5)
Fill-RoundRect $g6 $stTileBrush $tileRect $tileR
Draw-RoundRect $g6 $stTilePen $tileRect $tileR
$stTileBrush.Dispose()
$stTilePen.Dispose()

# Stremio Play Diamond / Prism
# Draw 4 diamond facets
$dTop = New-Object System.Drawing.PointF($cx, ($cy - 44))
$dBtm = New-Object System.Drawing.PointF($cx, ($cy + 44))
$dLeft = New-Object System.Drawing.PointF(($cx - 40), $cy)
$dRight = New-Object System.Drawing.PointF(($cx + 44), $cy)

# Facet 1: Top-Left (Indigo)
$p1 = New-Object System.Drawing.Drawing2D.GraphicsPath
$p1.AddPolygon(@($dLeft, $dTop, (New-Object System.Drawing.PointF($cx, $cy))))
$b1 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 75, 50, 170))
$g6.FillPath($b1, $p1)
$b1.Dispose()
$p1.Dispose()

# Facet 2: Bottom-Left (Cyan-Blue)
$p2 = New-Object System.Drawing.Drawing2D.GraphicsPath
$p2.AddPolygon(@($dLeft, $dBtm, (New-Object System.Drawing.PointF($cx, $cy))))
$b2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 160, 255))
$g6.FillPath($b2, $p2)
$b2.Dispose()
$p2.Dispose()

# Facet 3: Right Play Point (Brilliant Violet-Magenta)
$p3 = New-Object System.Drawing.Drawing2D.GraphicsPath
$p3.AddPolygon(@($dTop, $dRight, $dBtm, (New-Object System.Drawing.PointF($cx, $cy))))
$b3 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 175, 82, 222))
$g6.FillPath($b3, $p3)
$b3.Dispose()
$p3.Dispose()

# Inner Play Triangle White Highlight
$triPlay = New-Object System.Drawing.Drawing2D.GraphicsPath
$triPlay.AddPolygon(@(
    (New-Object System.Drawing.PointF(($cx - 10), ($cy - 18))),
    (New-Object System.Drawing.PointF(($cx + 18), $cy)),
    (New-Object System.Drawing.PointF(($cx - 10), ($cy + 18)))
))
$g6.FillPath([System.Drawing.Brushes]::White, $triPlay)
$triPlay.Dispose()

# Typography
$g6.DrawString("Stremio", $tFont, [System.Drawing.Brushes]::White, $textX, 130)
$stSubBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 190, 140, 255))
$g6.DrawString("FREEDOM OF STREAMING", $sFont, $stSubBrush, ($textX + 4), 195)
$stSubBrush.Dispose()
$g6.Dispose()
$bmp6.Save("$outDir\banner_stremio.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp6.Dispose()
Write-Host "Created banner_stremio.png"

Write-Host "All 6 additional banners generated successfully!"
