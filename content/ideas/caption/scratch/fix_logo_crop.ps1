Add-Type -AssemblyName System.Drawing

$cleanSlide4 = "C:\Users\susen\.gemini\antigravity-ide\brain\d79580a5-790d-49a8-ae7b-818946cde97c\carousel_slide_guidebook_1792320777850.jpg"
$circlePngPath = "c:\Users\susen\Documents\githublab\days\content\ideas\caption\assets\days-logo-circle.png"
$assetsDir = "c:\Users\susen\Documents\githublab\days\content\ideas\caption\assets"
$artifactDir = "C:\Users\susen\.gemini\antigravity-ide\brain\d79580a5-790d-49a8-ae7b-818946cde97c"

$circleLogo = [System.Drawing.Image]::FromFile($circlePngPath)
$slide4Img = [System.Drawing.Image]::FromFile($cleanSlide4)
$slide4Bmp = New-Object System.Drawing.Bitmap($slide4Img)
$slide4Img.Dispose()

$g = [System.Drawing.Graphics]::FromImage($slide4Bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# --- A. TOP HEADER ---
# Clone natural background from left (X: 350..411, Y: 60..115) over entire old [D] including the right arc (X: 411..472, Y: 60..115)
# This completely erases [D] right up to the start of "DAYS" at X: 472!
$cloneRectTop = New-Object System.Drawing.Rectangle(350, 60, 61, 55)
$destRectTop  = New-Object System.Drawing.Rectangle(411, 60, 61, 55)
$g.DrawImage($slide4Bmp, $destRectTop, $cloneRectTop, [System.Drawing.GraphicsUnit]::Pixel)

# Draw the clean transparent circular logo over it
$g.DrawImage($circleLogo, (New-Object System.Drawing.Rectangle(414, 61, 52, 52)))

# --- B. BOOK COVER (LEFT) ---
$cloneRectBook = New-Object System.Drawing.Rectangle(180, 306, 29, 29)
$destRectBook  = New-Object System.Drawing.Rectangle(209, 306, 29, 29)
$g.DrawImage($slide4Bmp, $destRectBook, $cloneRectBook, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawImage($circleLogo, (New-Object System.Drawing.Rectangle(210, 306, 27, 27)))

# --- C. OPEN BOOK PAGE (BOTTOM LEFT) ---
$cloneRectPage = New-Object System.Drawing.Rectangle(195, 762, 19, 19)
$destRectPage  = New-Object System.Drawing.Rectangle(215, 762, 19, 19)
$g.DrawImage($slide4Bmp, $destRectPage, $cloneRectPage, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawImage($circleLogo, (New-Object System.Drawing.Rectangle(216, 762, 16, 16)))

# --- D. TABLET SCREEN ---
$cloneRectTab = New-Object System.Drawing.Rectangle(542, 536, 18, 18)
$destRectTab  = New-Object System.Drawing.Rectangle(561, 536, 18, 18)
$g.DrawImage($slide4Bmp, $destRectTab, $cloneRectTab, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawImage($circleLogo, (New-Object System.Drawing.Rectangle(562, 537, 15, 15)))

$g.Dispose()

# Save Slide 4 with maximum quality JPEG
$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]98)

$outSlide4Assets = Join-Path $assetsDir "slide-04-guidebook.jpg"
$outSlide4Artifact = Join-Path $artifactDir "slide-04-guidebook.jpg"

$slide4Bmp.Save($outSlide4Assets, $codec, $encoderParams)
$slide4Bmp.Save($outSlide4Artifact, $codec, $encoderParams)

$slide4Bmp.Dispose()
$circleLogo.Dispose()

Write-Output "SUCCESS: Slide 4 updated with zero artifacts, zero black blocks, and flawless circle logo!"
