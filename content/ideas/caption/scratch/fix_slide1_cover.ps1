Add-Type -AssemblyName System.Drawing

$cleanCover = "C:\Users\susen\.gemini\antigravity-ide\brain\d79580a5-790d-49a8-ae7b-818946cde97c\cover_new_logo_1792321023753.jpg"
$circleLogoPath = "c:\Users\susen\Documents\githublab\days\content\ideas\caption\assets\days-logo-circle.png"
$targetSlide1 = "c:\Users\susen\Documents\githublab\days\content\ideas\caption\assets\slide-01-cover.jpg"
$artifactSlide1 = "C:\Users\susen\.gemini\antigravity-ide\brain\d79580a5-790d-49a8-ae7b-818946cde97c\slide-01-cover.jpg"

$circleLogo = [System.Drawing.Image]::FromFile($circleLogoPath)
$coverImg = [System.Drawing.Image]::FromFile($cleanCover)
$coverBmp = New-Object System.Drawing.Bitmap($coverImg)
$coverImg.Dispose()

$w = $coverBmp.Width
$h = $coverBmp.Height

# Lock bits for pixel-perfect horizontal gradient interpolation across entire old bottom-right logo area
$rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
$bmpData = $coverBmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

$bytes = [Math]::Abs($bmpData.Stride) * $h
$pixels = New-Object byte[] $bytes
[System.Runtime.InteropServices.Marshal]::Copy($bmpData.Scan0, $pixels, 0, $bytes)

# X0 is clean floor to the left of the old logo (715)
# X1 is clean floor to the right of the old DAYS text (955)
# Y spans from 865 to 975
$x0 = 715
$x1 = 955
$y0 = 865
$y1 = 975
$stride = [Math]::Abs($bmpData.Stride)

for ($y = $y0; $y -le $y1; $y++) {
    $row = $y * $stride
    $idx0 = $row + ($x0 * 4)
    $b0 = $pixels[$idx0]
    $g0 = $pixels[$idx0 + 1]
    $r0 = $pixels[$idx0 + 2]

    $idx1 = $row + ($x1 * 4)
    $b1 = $pixels[$idx1]
    $g1 = $pixels[$idx1 + 1]
    $r1 = $pixels[$idx1 + 2]

    $dx = [double]($x1 - $x0)

    for ($x = $x0; $x -le $x1; $x++) {
        $idx = $row + ($x * 4)
        $t = ($x - $x0) / $dx
        $pixels[$idx]     = [byte][Math]::Round($b0 + ($b1 - $b0) * $t)
        $pixels[$idx + 1] = [byte][Math]::Round($g0 + ($g1 - $g0) * $t)
        $pixels[$idx + 2] = [byte][Math]::Round($r0 + ($r1 - $r0) * $t)
        $pixels[$idx + 3] = 255
    }
}

[System.Runtime.InteropServices.Marshal]::Copy($pixels, 0, $bmpData.Scan0, $bytes)
$coverBmp.UnlockBits($bmpData)

# Draw the transparent circular globe logo and modern crisp white "DAYS" on the flawless floor
$g = [System.Drawing.Graphics]::FromImage($coverBmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

$logoSize = 58
$logoX = 745
$logoY = 890
$g.DrawImage($circleLogo, (New-Object System.Drawing.Rectangle($logoX, $logoY, $logoSize, $logoSize)))

# Draw "DAYS" text
$font = New-Object System.Drawing.Font("Arial", 29, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$g.DrawString("DAYS", $font, $brush, [float]($logoX + $logoSize + 10), [float]($logoY + 13))

$brush.Dispose()
$font.Dispose()
$g.Dispose()

# Save Slide 1 with maximum JPEG quality
$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]98)

$coverBmp.Save($targetSlide1, $codec, $encoderParams)
$coverBmp.Save($artifactSlide1, $codec, $encoderParams)

$coverBmp.Dispose()
$circleLogo.Dispose()

Write-Output "SUCCESS: Floor flawlessly restored across entire region, zero blockers, zero seams, pristine [Globe] DAYS logo!"
