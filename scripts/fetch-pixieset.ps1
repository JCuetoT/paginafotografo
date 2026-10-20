# Descarga las fotos desde Pixieset a las carpetas del sitio.
# Uso: powershell -ExecutionPolicy Bypass -File scripts/fetch-pixieset.ps1
#
# Cada linea es: destino|url_de_la_foto_en_pixieset
# El script lee el og:image de la pagina y pide la variante -xxlarge (1600 px).

param([string]$Only = "")

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"

$map = @'
images/sesiones/bodas/cover.jpg|https://morningstar87.pixieset.com/bodas/?pid=12556051435&id=33&h=MjMyMjk3MDYzMQ
images/sesiones/bodas/foto-2.jpg|https://morningstar87.pixieset.com/bodas/?pid=12556072811&id=41&h=MjAxMzU3NDY5Ng
images/sesiones/bodas/foto-3.jpg|https://morningstar87.pixieset.com/bodas/?pid=13787406892&id=47&h=MzQ4MDA5NzY2Nw
images/sesiones/bodas/foto-4.jpg|https://morningstar87.pixieset.com/bodas/?pid=13787406893&id=51&h=MTkzMjE1MDMxNg
images/sesiones/bodas/foto-5.jpg|https://morningstar87.pixieset.com/bodas/?pid=13787407801&id=53&h=MjE3Njg0ODQy
images/sesiones/bodas/foto-6.jpg|https://morningstar87.pixieset.com/bodas/?pid=12554468983&id=0&h=89de2df33f751b005afa83c00e4c7e92
images/sesiones/bodas/foto-7.jpg|https://morningstar87.pixieset.com/bodas/?pid=12555858284&id=4&h=MjU4MDEyMjExNQ
images/sesiones/bodas/foto-8.jpg|https://morningstar87.pixieset.com/bodas/?pid=12555857996&id=3&h=MzE2MzkwNTUzNw
images/sesiones/bodas/foto-9.jpg|https://morningstar87.pixieset.com/bodas/?pid=12556022025&id=19&h=MTExMjMwODc1MA
images/sesiones/bodas/foto-10.jpg|https://morningstar87.pixieset.com/bodas/?pid=12556013911&id=16&h=Mjg1MTA2NzM3NQ
images/sesiones/bodas/foto-11.jpg|https://morningstar87.pixieset.com/bodas/?pid=12556033863&id=23&h=MjE2MjQxMDE2
images/sesiones/eventos-sociales/cover.jpg|https://morningstar87.pixieset.com/quinceaeros/?pid=12557701985&id=82&h=NDE2OTY0OTI2MQ
images/sesiones/eventos-sociales/foto-2.jpg|https://morningstar87.pixieset.com/quinceaeros/?pid=12557498044&id=56&h=Mjg5OTgzNjQ4MA
images/sesiones/eventos-sociales/foto-3.jpg|https://morningstar87.pixieset.com/quinceaeros/?pid=12557472542&id=42&h=ODk1MzkzNDYz
images/sesiones/eventos-sociales/foto-4.jpg|https://morningstar87.pixieset.com/quinceaeros/?pid=12557431433&id=33&h=MTkyNTY3MTIx
images/sesiones/eventos-sociales/foto-5.jpg|https://morningstar87.pixieset.com/quinceaeros/?pid=14742614537&id=21&h=MzQ1NTk0ODQ3OQ
images/sesiones/eventos-sociales/foto-6.jpg|https://morningstar87.pixieset.com/quinceaeros/?pid=14742599775&id=16&h=NTQzODk1MDkz
images/sesiones/eventos-sociales/foto-7.jpg|https://morningstar87.pixieset.com/quinceaeros/?pid=19545462964&id=14&h=NDA1Njk2MDA2Ng
images/sesiones/eventos-musicales/cover.jpg|https://morningstar87.pixieset.com/diseogrfico/?pid=12563647261&id=5&h=MzUxNDE1NDM0NA
images/sesiones/eventos-musicales/foto-2.jpg|https://morningstar87.pixieset.com/diseogrfico/?pid=12563653987&id=6&h=MjQ1NTMyOTUyOA
images/sesiones/eventos-musicales/foto-3.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19544685808&id=0&h=MjIyNDAwNzI5
images/sesiones/diseno-grafico/cover.jpg|https://morningstar87.pixieset.com/diseogrfico/?pid=12559803108&id=11&h=MzIyMjk0MTkxNQ
images/sesiones/diseno-grafico/foto-2.jpg|https://morningstar87.pixieset.com/diseogrfico/?pid=12559987776&id=8&h=MTk3MDc3ODEwNQ
images/sesiones/diseno-grafico/foto-3.jpg|https://morningstar87.pixieset.com/diseogrfico/?pid=12559871300&id=9&h=NjY1MDg1OTg
images/sesiones/diseno-grafico/foto-4.jpg|https://morningstar87.pixieset.com/diseogrfico/?pid=12559818490&id=4&h=MTI3OTg3OTcwNw
images/sesiones/diseno-grafico/foto-5.jpg|https://morningstar87.pixieset.com/diseogrfico/?pid=12559874535&id=7&h=ODU5ODIyNDM2
images/sesiones/diseno-grafico/foto-6.jpg|https://morningstar87.pixieset.com/diseogrfico/?pid=12559840848&id=18&h=NDUwNTkyMTc0
images/sesiones/diseno-grafico/foto-7.jpg|https://morningstar87.pixieset.com/diseogrfico/?pid=12559841022&id=16&h=Mzc4MDM5MzczOQ
images/sesiones/diseno-grafico/foto-8.jpg|https://morningstar87.pixieset.com/diseogrfico/?pid=12559987637&id=32&h=OTg3NDc4MDY2
images/sesiones/logos/logo-1.png|https://morningstar87.pixieset.com/diseogrfico/logos/?pid=12559792444&id=1&h=MzgwODM1OTM1Ng
images/sesiones/logos/logo-2.png|https://morningstar87.pixieset.com/diseogrfico/logos/?pid=12559997978&id=7&h=MTcyMTcwMjQ4MQ
images/sesiones/logos/logo-3.png|https://morningstar87.pixieset.com/diseogrfico/logos/?pid=12559928695&id=8&h=MjE4MjExOTE4MA
images/sesiones/logos/logo-4.png|https://morningstar87.pixieset.com/diseogrfico/logos/?pid=12559924694&id=11&h=NDM5MTUzNDA1
images/sesiones/logos/logo-5.png|https://morningstar87.pixieset.com/diseogrfico/logos/?pid=12559753968&id=0&h=Mzk1MTY1ODE4Mg
images/sesiones/logos/logo-6.png|https://morningstar87.pixieset.com/diseogrfico/logos/?pid=12559998015&id=5&h=MTk1OTg4MDg4MA
images/sesiones/logos/logo-7.png|https://morningstar87.pixieset.com/diseogrfico/logos/?pid=12559998016&id=12&h=MzA5MTAxOTM0Ng
images/sesiones/logos/logo-8.png|https://morningstar87.pixieset.com/diseogrfico/logos/?pid=12559872182&id=2&h=MTg3NTI0NDk1Nw
images/sesiones/logos/logo-9.png|https://morningstar87.pixieset.com/diseogrfico/logos/?pid=12559997910&id=4&h=MjMwMTQ3MzcyOQ
images/sesiones/logos/logo-10.png|https://morningstar87.pixieset.com/diseogrfico/logos/?pid=12563227569&id=18&h=MjM3NzI5NDg2Ng
images/sesiones/corporativos/cover.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19544886088&id=5&h=MjgzNzIyNjQzNA
images/sesiones/corporativos/foto-2.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19544846668&id=9&h=MTA3ODQ2MjIyMQ
images/sesiones/corporativos/foto-3.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19544264672&id=6&h=OTA5MjU3ODg3
images/sesiones/corporativos/foto-4.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19544532076&id=7&h=MjA2ODI1NzE4Ng
images/sesiones/corporativos/foto-5.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19543669541&id=11&h=MzM3NzM0NTEyNQ
images/sesiones/corporativos/foto-6.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19543669540&id=14&h=MzAwMjk1MzAzMw
images/sesiones/corporativos/foto-7.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19545316056&id=16&h=MTUwMTc1MzA2
images/sesiones/corporativos/foto-8.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19543509412&id=22&h=MzIxMjcxMDE0Mw
images/sesiones/corporativos/foto-9.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19543516355&id=23&h=MTk1OTI2NDE3Ng
images/sesiones/corporativos/foto-10.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19543528311&id=24&h=Mzc2NzQ1NjM5MQ
images/sesiones/corporativos/foto-11.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19544264671&id=29&h=Mzg2OTAyMTc0Ng
images/sesiones/corporativos/foto-12.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19543626298&id=28&h=OTc3NzQwMTQw
images/sesiones/corporativos/foto-13.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19544341107&id=31&h=MTg2MDMzNjM2
images/sesiones/corporativos/foto-14.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19543502950&id=21&h=MzU3MTA3MTg3Nw
images/sesiones/corporativos/foto-15.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19543595958&id=15&h=MzgwMzUwNzQ1NA
images/sesiones/corporativos/foto-16.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19543673121&id=12&h=Mjk1NDIxNDgyNA
images/sesiones/corporativos/foto-17.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19544462430&id=17&h=Mjg3ODg3NDI5OA
images/sesiones/corporativos/foto-18.jpg|https://morningstar87.pixieset.com/cubrimientodeeventos/?pid=19545356128&id=3&h=ODI5NTE5MTU0
'@

$lines = $map -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
if ($Only -ne "") { $lines = $lines | Where-Object { $_ -like "*$Only*" } }

$ok = 0; $fail = 0
foreach ($line in $lines) {
  $dest, $url = $line -split '\|', 2
  $out = Join-Path $root $dest
  try {
    $page = Invoke-WebRequest -Uri $url -UseBasicParsing -Headers @{ "User-Agent" = $ua }
    $m = [regex]::Match($page.Content, 'og:image"\s+name=""\s+content="([^"]+)"')
    if (-not $m.Success) { $m = [regex]::Match($page.Content, 'og:image"\s+content="([^"]+)"') }
    if (-not $m.Success) { throw "sin og:image" }
    $img = $m.Groups[1].Value -replace '-large\.', '-xxlarge.'
    $dir = Split-Path -Parent $out
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Invoke-WebRequest -Uri $img -OutFile $out -UseBasicParsing -Headers @{ "User-Agent" = $ua }
    $kb = [math]::Round((Get-Item $out).Length / 1KB)
    Write-Host "OK   $dest  ($kb KB)"
    $ok++
  } catch {
    Write-Host "FAIL $dest  -> $($_.Exception.Message)"
    $fail++
  }
}
Write-Host ""
Write-Host "Descargadas: $ok   Fallidas: $fail"
