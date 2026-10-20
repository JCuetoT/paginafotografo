# Genera placeholders fotográficos oscuros (gradiente + glow + viñeta) en images/
# ponytail: PS 5.1 falla al resolver Graphics::FromImage dentro de funciones nombradas -> loop inline
Add-Type -AssemblyName System.Drawing

$outDir = Join-Path $PSScriptRoot "..\images"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

$aspects = @(
  @{ W = 1200; H = 1500 },
  @{ W = 1600; H = 1200 },
  @{ W = 1400; H = 1400 },
  @{ W = 1600; H = 1000 },
  @{ W = 1200; H = 1600 }
)

$cats = @(
  @{ Folder = 'sesiones\bodas';              R = 190; G = 140; B = 95;  Top = '#241d16' },
  @{ Folder = 'sesiones\eventos-sociales';   R = 150; G = 140; B = 125; Top = '#201e1a' },
  @{ Folder = 'sesiones\eventos-musicales';  R = 110; G = 95;  B = 150; Top = '#1c1822' },
  @{ Folder = 'sesiones\artistas';           R = 110; G = 125; B = 145; Top = '#171b20' },
  @{ Folder = 'sesiones\diseno-grafico';     R = 140; G = 140; B = 145; Top = '#1b1b1d' },
  @{ Folder = 'sesiones\branding';           R = 165; G = 145; B = 110; Top = '#201c16' }
)

foreach ($cat in $cats) {
  New-Item -ItemType Directory -Path (Join-Path $outDir $cat.Folder) -Force | Out-Null
  for ($i = 1; $i -le 5; $i++) {
    $spec = $aspects[($i - 1) % 5]
    $glowX = 0.3 + (($i * 37) % 50) / 100
    $glowY = 0.25 + (($i * 29) % 45) / 100
    $alpha = 60 + (($i * 11) % 30)

    $bmp = [System.Drawing.Bitmap]::new($spec.W, $spec.H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $rect = [System.Drawing.Rectangle]::new(0, 0, $spec.W, $spec.H)

    $lin = [System.Drawing.Drawing2D.LinearGradientBrush]::new($rect, [System.Drawing.ColorTranslator]::FromHtml($cat.Top), [System.Drawing.ColorTranslator]::FromHtml('#0a0a0a'), 90)
    $g.FillRectangle($lin, $rect)

    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $path.AddEllipse(0, 0, $spec.W, $spec.H)
    $glow = [System.Drawing.Drawing2D.PathGradientBrush]::new($path)
    $glow.CenterPoint = [System.Drawing.PointF]::new($glowX, $glowY)
    $glow.CenterColor = [System.Drawing.Color]::FromArgb($alpha, $cat.R, $cat.G, $cat.B)
    $glow.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
    $g.FillEllipse($glow, 0, 0, $spec.W, $spec.H)

    $path2 = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $path2.AddEllipse(0, 0, $spec.W, $spec.H)
    $vig = [System.Drawing.Drawing2D.PathGradientBrush]::new($path2)
    $vig.CenterColor = [System.Drawing.Color]::FromArgb(0, 0, 0, 0)
    $vig.SurroundColors = @([System.Drawing.Color]::FromArgb(210, 0, 0, 0))
    $g.FillEllipse($vig, 0, 0, $spec.W, $spec.H)

    $name = if ($i -eq 1) { 'cover.jpg' } else { "foto-$i.jpg" }
    $out = Join-Path $outDir "$($cat.Folder)\$name"
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $params = [System.Drawing.Imaging.EncoderParameters]::new(1)
    $params.Param[0] = [System.Drawing.Imaging.EncoderParameter]::new([System.Drawing.Imaging.Encoder]::Quality, [long]88)
    $bmp.Save($out, $codec, $params)
    Write-Host "Generado: $out"

    $g.Dispose()
    $bmp.Dispose()
  }
}
Write-Host "OK"