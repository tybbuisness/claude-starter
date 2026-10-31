param(
  [Parameter(Mandatory)][string[]]$Images,
  [Parameter(Mandatory)][string]$PromptFile,
  [string]$OutDir = ".",
  [string]$Size = "2160x2880",
  [string]$Model = "gpt-image-2.5-sunburst"
)
$key = $env:ARGOLINK_API_KEY
if (-not $key) { $key = [Environment]::GetEnvironmentVariable("ARGOLINK_API_KEY", "User") }
if (-not $key) { Write-Error "ARGOLINK_API_KEY is missing"; exit 1 }

New-Item -Force -ItemType Directory $OutDir | Out-Null
$OutDir = (Resolve-Path $OutDir).Path
$grid = Join-Path $OutDir "grille.png"

$tmp = [IO.Path]::GetTempFileName()
$curlArgs = @("--max-time", "600", "-sS", "-o", $tmp, "-w", "%{http_code}",
  "https://argolink.io/v1/images/edits",
  "-H", "Authorization: Bearer $key",
  "-F", "model=$Model", "-F", "size=$Size", "-F", "prompt=<$PromptFile")
foreach ($i in $Images) { $curlArgs += @("-F", "image[]=@$i") }

$code = & curl.exe @curlArgs
$body = Get-Content $tmp -Raw
Remove-Item $tmp
if ($code -ne "200") { Write-Error "ArgoLink HTTP ${code}: $body"; exit 1 }

$b64 = [regex]::Match($body, '"b64_json"\s*:\s*"([^"]+)"')
$url = [regex]::Match($body, '"url"\s*:\s*"([^"]+)"')
if ($b64.Success) {
  [IO.File]::WriteAllBytes($grid, [Convert]::FromBase64String($b64.Groups[1].Value))
} elseif ($url.Success) {
  & curl.exe --max-time 120 -sS -o $grid $url.Groups[1].Value.Replace('\/', '/')
} else {
  Write-Error "No image in response: $body"; exit 1
}
if (-not (Test-Path $grid) -or (Get-Item $grid).Length -lt 1000) { Write-Error "Grid file is invalid: $grid"; exit 1 }

# Cut the 2x2 grid into 4 separate photos.
Add-Type -AssemblyName System.Drawing
$source = [System.Drawing.Image]::FromFile($grid)
$w = [int][math]::Floor($source.Width / 2)
$h = [int][math]::Floor($source.Height / 2)
$n = 1
foreach ($y in 0, 1) {
  foreach ($x in 0, 1) {
    $photo = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($photo)
    $to = New-Object System.Drawing.Rectangle 0, 0, $w, $h
    $from = New-Object System.Drawing.Rectangle ($x * $w), ($y * $h), $w, $h
    $g.DrawImage($source, $to, $from, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()
    $path = Join-Path $OutDir "photo$n.jpg"
    $photo.Save($path, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $photo.Dispose()
    Write-Host "OK $path (${w}x${h})"
    $n++
  }
}
$source.Dispose()
