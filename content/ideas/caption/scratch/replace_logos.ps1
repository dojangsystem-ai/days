Add-Type -AssemblyName System.Drawing

$logoPath = "C:\Users\susen\.gemini\antigravity-ide\brain\d79580a5-790d-49a8-ae7b-818946cde97c\.user_uploaded\media_1792328155066.jpg"
$assetsDir = "c:\Users\susen\Documents\githublab\days\content\ideas\caption\assets"
$coverGenerated = "C:\Users\susen\.gemini\antigravity-ide\brain\d79580a5-790d-49a8-ae7b-818946cde97c\cover_new_logo_1792321023753.jpg"

if (-not (Test-Path $logoPath)) {
    Write-Error "Logo master not found at $logoPath"
    exit 1
}

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

# ==========================================
# 1. UPDATE SLIDE 1 (COVER)
# ==========================================
Write-Output "Processing Slide 1 (Cover)..."
$slide1Path = Join-Path $assetsDir "slide-01-cover.jpg"
$baseCover = if (Test-Path $coverGenerated) { $coverGenerated } else { $slide1Path }
$img1 = [System.Drawing.Image]::FromFile($baseCover)
$bmp1 = New-Object System.Drawing.Bitmap($img1)
$img1.Dispose()
$g1 = [System.Drawing.Graphics]::FromImage($bmp1)
$g1.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# Cover bottom right old logo DAYS [gold kicking figure]
$brush1 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 17, 19, 23))
$g1.FillRectangle($brush1, 720, 870, 240, 95)
$brush1.Dispose()

$logo1 = Get-CircularLogo -src $rawLogo -size 110
$g1.DrawImage($logo1, 790, 860)
$logo1.Dispose()
$g1.Dispose()

$temp1 = Join-Path $assetsDir "slide-01-cover_temp.jpg"
$bmp1.Save($temp1, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$bmp1.Dispose()
Move-Item -Path $temp1 -Destination $slide1Path -Force
Write-Output "Slide 1 updated successfully!"

# ==========================================
# 2. UPDATE SLIDE 4 (GUIDEBOOK)
# ==========================================
Write-Output "Processing Slide 4 (Guidebook)..."
$slide4Path = Join-Path $assetsDir "slide-04-guidebook.jpg"
if (Test-Path $slide4Path) {
    $img4 = [System.Drawing.Image]::FromFile($slide4Path)
    $bmp4 = New-Object System.Drawing.Bitmap($img4)
    $img4.Dispose()
    $g4 = [System.Drawing.Graphics]::FromImage($bmp4)
    $g4.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

    # Erase top center old [D] DAYS logo
    $brush4 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 13, 16, 22))
    $g4.FillRectangle($brush4, 300, 115, 340, 120)
    $brush4.Dispose()

    # Draw new circular globe logo at top center
    $logo4Top = Get-CircularLogo -src $rawLogo -size 120
    $g4.DrawImage($logo4Top, 452, 115)
    $logo4Top.Dispose()

    # Erase and replace on the guidebook book cover (left)
    $brushBook = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 12, 28, 34))
    $g4.FillRectangle($brushBook, 200, 290, 120, 45)
    $brushBook.Dispose()

    $logo4Book = Get-CircularLogo -src $rawLogo -size 45
    $g4.DrawImage($logo4Book, 238, 290)
    $logo4Book.Dispose()

    $g4.Dispose()
    $temp4 = Join-Path $assetsDir "slide-04-guidebook_temp.jpg"
    $bmp4.Save($temp4, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $bmp4.Dispose()
    Move-Item -Path $temp4 -Destination $slide4Path -Force
    Write-Output "Slide 4 updated successfully!"
}

# ==========================================
# 3. UPDATE SLIDE 3 (SOLUTION)
# ==========================================
Write-Output "Processing Slide 3 (Solution)..."
$slide3Path = Join-Path $assetsDir "slide-03-solution.jpg"
if (Test-Path $slide3Path) {
    $img3 = [System.Drawing.Image]::FromFile($slide3Path)
    $bmp3 = New-Object System.Drawing.Bitmap($img3)
    $img3.Dispose()
    $g3 = [System.Drawing.Graphics]::FromImage($bmp3)
    $g3.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

    # Erase bottom right logo
    $brush3 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 10, 15, 20))
    $g3.FillRectangle($brush3, 830, 910, 160, 65)
    $brush3.Dispose()

    $logo3 = Get-CircularLogo -src $rawLogo -size 75
    $g3.DrawImage($logo3, 875, 905)
    $logo3.Dispose()

    $g3.Dispose()
    $temp3 = Join-Path $assetsDir "slide-03-solution_temp.jpg"
    $bmp3.Save($temp3, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $bmp3.Dispose()
    Move-Item -Path $temp3 -Destination $slide3Path -Force
    Write-Output "Slide 3 updated successfully!"
}

# ==========================================
# 4. UPDATE SLIDE 5 (CTA)
# ==========================================
Write-Output "Processing Slide 5 (CTA)..."
$slide5Path = Join-Path $assetsDir "slide-05-cta.jpg"
if (Test-Path $slide5Path) {
    $img5 = [System.Drawing.Image]::FromFile($slide5Path)
    $bmp5 = New-Object System.Drawing.Bitmap($img5)
    $img5.Dispose()
    $g5 = [System.Drawing.Graphics]::FromImage($bmp5)
    $g5.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

    # Erase phone screen top logo
    $brush5 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 18, 22, 28))
    $g5.FillRectangle($brush5, 485, 305, 120, 45)
    $brush5.Dispose()

    $logo5 = Get-CircularLogo -src $rawLogo -size 45
    $g5.DrawImage($logo5, 522, 305)
    $logo5.Dispose()

    $g5.Dispose()
    $temp5 = Join-Path $assetsDir "slide-05-cta_temp.jpg"
    $bmp5.Save($temp5, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $bmp5.Dispose()
    Move-Item -Path $temp5 -Destination $slide5Path -Force
    Write-Output "Slide 5 updated successfully!"
}

# Copy master logo to assets/days-logo.jpg for permanent project asset
Copy-Item -Path $logoPath -Destination (Join-Path $assetsDir "days-logo.jpg") -Force
Write-Output "Master logo copied to assets/days-logo.jpg successfully!"

$rawLogo.Dispose()
Write-Output "ALL CAROUSEL SLIDES UPDATED WITH OFFICIAL DAYS GLOBE LOGO!"
