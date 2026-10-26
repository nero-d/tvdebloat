Add-Type -AssemblyName System.Drawing

function Create-AirDropBanner {
    param([string]$outputPath)
    
    $width = 640
    $height = 360
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    # 1. Background gradient (deep obsidian navy)
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Point(0, 0)),
        (New-Object System.Drawing.Point($width, $height)),
        [System.Drawing.Color]::FromArgb(255, 18, 22, 32),
        [System.Drawing.Color]::FromArgb(255, 10, 12, 18)
    )
    $g.FillRectangle($bgBrush, 0, 0, $width, $height)
    $bgBrush.Dispose()

    # 2. Soft radial blue glow behind icon
    $glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $glowPath.AddEllipse(50, 40, 260, 260)
    $pbr = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
    $pbr.CenterColor = [System.Drawing.Color]::FromArgb(70, 0, 122, 255)
    $pbr.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 10, 12, 18))
    $g.FillEllipse($pbr, 50, 40, 260, 260)
    $pbr.Dispose()
    $glowPath.Dispose()

    # 3. AirDrop Radar Rings
    $cx = 175
    $cy = 180

    # Outer Arc 3
    $pen3 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(140, 0, 122, 255), 4.5)
    $g.DrawArc($pen3, ($cx - 72), ($cy - 72), 144, 144, 135, 270)
    $pen3.Dispose()

    # Middle Arc 2
    $pen2 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(190, 40, 160, 255), 4.5)
    $g.DrawArc($pen2, ($cx - 48), ($cy - 48), 96, 96, 135, 270)
    $pen2.Dispose()

    # Inner Arc 1
    $pen1 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(240, 90, 195, 255), 4.5)
    $g.DrawArc($pen1, ($cx - 26), ($cy - 26), 52, 52, 135, 270)
    $pen1.Dispose()

    # Center glowing node
    $nodeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
    $g.FillEllipse($nodeBrush, ($cx - 8), ($cy - 8), 16, 16)
    $nodeBrush.Dispose()

    # AirDrop pulse dot
    $dotPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 0, 122, 255), 2.5)
    $g.DrawEllipse($dotPen, ($cx - 12), ($cy - 12), 24, 24)
    $dotPen.Dispose()

    # Upward share beam / arrow from center
    $arrowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
    $arrowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    # Arrow head
    $arrowPath.AddLine($cx, ($cy - 105), ($cx - 16), ($cy - 85))
    $arrowPath.AddLine(($cx - 16), ($cy - 85), ($cx - 6), ($cy - 85))
    $arrowPath.AddLine(($cx - 6), ($cy - 85), ($cx - 6), ($cy - 50))
    $arrowPath.AddLine(($cx + 6), ($cy - 50), ($cx + 6), ($cy - 85))
    $arrowPath.AddLine(($cx + 6), ($cy - 85), ($cx + 16), ($cy - 85))
    $arrowPath.CloseFigure()
    $g.FillPath($arrowBrush, $arrowPath)
    $arrowPath.Dispose()
    $arrowBrush.Dispose()

    # Load Outfit Font
    $pfc = New-Object System.Drawing.Text.PrivateFontCollection
    $pfc.AddFontFile("C:\Users\sanik\tv_debloat\launcher\res\font\outfit_regular.ttf")
    $fontFam = $pfc.Families[0]

    # Title: Send Files
    $titleFont = New-Object System.Drawing.Font($fontFam, 35, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 245, 247, 250))
    $g.DrawString("Send Files", $titleFont, $titleBrush, 280, 136)

    # Subtitle: TO TV • AIRDROP
    $subFont = New-Object System.Drawing.Font($fontFam, 14, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    $subBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 140, 255))
    $g.DrawString("TO TV  •  FAST TRANSFER", $subFont, $subBrush, 283, 190)

    # Clean border highlight (subtle 1px ceramic border)
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(35, 255, 255, 255), 1.0)
    $g.DrawRectangle($borderPen, 0, 0, $width - 1, $height - 1)
    $borderPen.Dispose()

    $g.Dispose()
    $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Created AirDrop banner: $outputPath"
}

Create-AirDropBanner "C:\Users\sanik\tv_debloat\launcher\res\drawable-nodpi\test_banner_sftv.png"
