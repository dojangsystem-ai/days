Add-Type -AssemblyName System.Drawing

$cleanSource = "C:\Users\susen\.gemini\antigravity-ide\brain\d79580a5-790d-49a8-ae7b-818946cde97c\carousel_slide_guidebook_1792320777850.jpg"
$logoPath = "C:\Users\susen\.gemini\antigravity-ide\brain\d79580a5-790d-49a8-ae7b-818946cde97c\.user_uploaded\media_1792328155066.jpg"
$targetSlide4 = "c:\Users\susen\Documents\githublab\days\content\ideas\caption\assets\slide-04-guidebook.jpg"
$artifactSlide4 = "C:\Users\susen\.gemini\antigravity-ide\brain\d79580a5-790d-49a8-ae7b-818946cde97c\slide-04-guidebook.jpg"

$rawLogo = [System.Drawing.Image]::FromFile($logoPath)

function Get-CircularLogo {
    param(
        [System.Drawing.Image]$src,
        [int]$size
    )
    $bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse(0, 0, $size, $size)
    $g.SetClip($path)
    $g.DrawImage($src, 0, 0, $size, $size)
    $g.Dispose()
    $path.Dispose()
    return $bmp
}

$img = [System.Drawing.Image]::FromFile($cleanSource)
$bmp = New-Object System.Drawing.Bitmap($img)
$img.Dispose()

$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# 1. TOP HEADER: Completely erase old [D] icon including right cyan arc (X: 412..470, Y: 60..114)
$brushTop = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 11, 14, 20))
$g.FillRectangle($brushTop, 412, 60, 58, 54)
$brushTop.Dispose()

# Draw circular globe logo of size 54x54 nicely centered in that space
$logoTop = Get-CircularLogo -src $rawLogo -size 54
$g.DrawImage($logoTop, 412, 60)
$logoTop.Dispose()

# 2. BOOK COVER (LEFT): Erase old [D] and replace with crisp globe logo
$brushBook = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 12, 27, 34))
$g.FillRectangle($brushBook, 210, 305, 29, 29)
$brushBook.Dispose()

$logoBook = Get-CircularLogo -src $rawLogo -size 27
$g.DrawImage($logoBook, 211, 306)
$logoBook.Dispose()

# 3. OPEN BOOK PAGE (BOTTOM LEFT): Cover old [D] at Y: 766
$brushPage = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 14, 22, 28))
$g.FillRectangle($brushPage, 216, 762, 17, 16)
$brushPage.Dispose()

$logoPage = Get-CircularLogo -src $rawLogo -size 15
$g.DrawImage($logoPage, 217, 762)
$logoPage.Dispose()

# 4. TABLET SCREEN: Clean placement
$brushTab = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 23, 35, 45))
$g.FillRectangle($brushTab, 560, 536, 17, 16)
$brushTab.Dispose()

$logoTab = Get-CircularLogo -src $rawLogo -size 15
$g.DrawImage($logoTab, 561, 537)
$logoTab.Dispose()

$g.Dispose()

# Save with maximum JPEG quality
$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]98)

$bmp.Save($targetSlide4, $codec, $encoderParams)
$bmp.Save($artifactSlide4, $codec, $encoderParams)

$bmp.Dispose()
$rawLogo.Dispose()

Write-Output "PERFECT: All D logos in slide-04-guidebook.jpg replaced cleanly with DAYS globe logo!"
