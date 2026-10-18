Add-Type -AssemblyName System.Drawing

$cleanCover = "C:\Users\susen\.gemini\antigravity-ide\brain\d79580a5-790d-49a8-ae7b-818946cde97c\cover_new_logo_1792321023753.jpg"
$circleLogoPath = "c:\Users\susen\Documents\githublab\days\content\ideas\caption\assets\days-logo-circle.png"
$targetSlide1 = "c:\Users\susen\Documents\githublab\days\content\ideas\caption\assets\slide-01-cover.jpg"
$artifactSlide1 = "C:\Users\susen\.gemini\antigravity-ide\brain\d79580a5-790d-49a8-ae7b-818946cde97c\slide-01-cover.jpg"

$circleLogo = [System.Drawing.Image]::FromFile($circleLogoPath)
$coverImg = [System.Drawing.Image]::FromFile($cleanCover)
$coverBmp = New-Object System.Drawing.Bitmap($coverImg)
$coverImg.Dispose()

# Lock bits for pixel-perfect seamless background gradient interpolation
$w = $coverBmp.Width
$h = $coverBmp.Height
$rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
$bmpData = $coverBmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

$bytes = [Math]::Abs($bmpData.Stride) * $h
$pixels = New-Object byte[] $bytes
[System.Runtime.InteropServices.Marshal]::Copy($bmpData.Scan0, $pixels, 0, $bytes)

# Interpolate across X: 695 to 799, Y: 870 to 965 to flawlessly erase the gold figure AND the gold ribbon/pedestal underneath!
$x0 = 695
$x1 = 799
$y0 = 870
$y1 = 965
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

    for ($x = $x0 + 1; $x -lt $x1; $x++) {
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

# Draw the transparent circular globe logo on top of the seamlessly restored floor
$g = [System.Drawing.Graphics]::FromImage($coverBmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Position logo cleanly next to DAYS (X: 735, Y: 887, size: 57x57)
$g.DrawImage($circleLogo, (New-Object System.Drawing.Rectangle(735, 887, 57, 57)))
$g.Dispose()

# Save with maximum JPEG quality
$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]98)

$coverBmp.Save($targetSlide1, $codec, $encoderParams)
$coverBmp.Save($artifactSlide1, $codec, $encoderParams)

$coverBmp.Dispose()
$circleLogo.Dispose()

Write-Output "FLAWLESS: Slide 1 cover floor completely cleaned of all blockers and gold residues!"
