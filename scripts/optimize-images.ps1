# Optimiza las imagenes de images/sesiones para web.
# JPG: lado mayor 1600 px, calidad 82. PNG: lado mayor 800 px, sin perder transparencia.
# Uso: powershell -ExecutionPolicy Bypass -File scripts/optimize-images.ps1

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$base = Join-Path $root "images\sesiones"

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$jpegParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$jpegParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]82)

function Resize-Image([string]$path, [int]$maxEdge, [bool]$isPng) {
  $src = [System.Drawing.Image]::FromFile($path)
  try {
    $scale = [Math]::Min(1.0, $maxEdge / [Math]::Max($src.Width, $src.Height))
    $w = [int][Math]::Round($src.Width * $scale)
    $h = [int][Math]::Round($src.Height * $scale)

    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.DrawImage($src, 0, 0, $w, $h)
    $g.Dispose()

    $tmp = "$path.tmp"
    if ($isPng) { $bmp.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png) }
    else { $bmp.Save($tmp, $codec, $jpegParams) }
    $bmp.Dispose()
  } finally { $src.Dispose() }

  Move-Item -Path $tmp -Destination $path -Force
}

$before = 0; $after = 0
$files = Get-ChildItem $base -Recurse -File -Include *.jpg,*.jpeg,*.png
foreach ($f in $files) {
  $before += $f.Length
  $isPng = $f.Extension -eq ".png"
  Resize-Image $f.FullName $(if ($isPng) { 800 } else { 1600 }) $isPng
  $after += (Get-Item $f.FullName).Length
  $kb = [math]::Round((Get-Item $f.FullName).Length / 1KB)
  Write-Host ("OK   {0,-52} {1,5} KB" -f $f.FullName.Replace($root + "\", ""), $kb)
}

Write-Host ""
Write-Host ("Total: {0} MB -> {1} MB" -f [math]::Round($before/1MB,1), [math]::Round($after/1MB,1))
