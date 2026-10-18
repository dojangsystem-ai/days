Add-Type -AssemblyName System.Drawing

$logoPath = "C:\Users\susen\.gemini\antigravity-ide\brain\d79580a5-790d-49a8-ae7b-818946cde97c\.user_uploaded\media_1792328155066.jpg"
$img = [System.Drawing.Image]::FromFile($logoPath)
$bmp = New-Object System.Drawing.Bitmap($img)
$img.Dispose()

$w = $bmp.Width
$h = $bmp.Height
Write-Output "Image size: ${w}x${h}"

$midY = [int]($h / 2)
$firstX = -1
$lastX = -1

for ($x = 0; $x -lt $w; $x++) {
    $c = $bmp.GetPixel($x, $midY)
    if ($c.R -gt 20 -or $c.G -gt 20 -or $c.B -gt 40) {
        $firstX = $x
        break
    }
}

for ($x = $w - 1; $x -ge 0; $x--) {
    $c = $bmp.GetPixel($x, $midY)
    if ($c.R -gt 20 -or $c.G -gt 20 -or $c.B -gt 40) {
        $lastX = $x
        break
    }
}

$midX = [int]($w / 2)
$firstY = -1
$lastY = -1

for ($y = 0; $y -lt $h; $y++) {
    $c = $bmp.GetPixel($midX, $y)
    if ($c.R -gt 20 -or $c.G -gt 20 -or $c.B -gt 40) {
        $firstY = $y
        break
    }
}

for ($y = $h - 1; $y -ge 0; $y--) {
    $c = $bmp.GetPixel($midX, $y)
    if ($c.R -gt 20 -or $c.G -gt 20 -or $c.B -gt 40) {
        $lastY = $y
        break
    }
}

Write-Output "Horizontal bounds at midY: $firstX to $lastX (Width: $($lastX - $firstX))"
Write-Output "Vertical bounds at midX: $firstY to $lastY (Height: $($lastY - $firstY))"

$bmp.Dispose()
