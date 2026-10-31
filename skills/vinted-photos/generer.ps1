param(
  [Parameter(Mandatory)][string[]]$Images,
  [Parameter(Mandatory)][string]$PromptFile,
  [Parameter(Mandatory)][string]$Out,
  [string]$AspectRatio = "3:4",
  [string]$Resolution = "2K",
  [string]$Model = "gpt-image-2.5-sunburst"
)
$key = $env:ARGOLINK_API_KEY
if (-not $key) { $key = [Environment]::GetEnvironmentVariable("ARGOLINK_API_KEY", "User") }
if (-not $key) { Write-Error "ARGOLINK_API_KEY is missing"; exit 1 }

$tmp = [IO.Path]::GetTempFileName()
$curlArgs = @("--max-time", "600", "-sS", "-o", $tmp, "-w", "%{http_code}",
  "https://argolink.io/v1/images/edits",
  "-H", "Authorization: Bearer $key",
  "-F", "model=$Model", "-F", "aspect_ratio=$AspectRatio", "-F", "resolution=$Resolution", "-F", "prompt=<$PromptFile")
foreach ($i in $Images) { $curlArgs += @("-F", "image[]=@$i") }

$code = & curl.exe @curlArgs
$body = Get-Content $tmp -Raw
Remove-Item $tmp
if ($code -ne "200") { Write-Error "ArgoLink HTTP ${code}: $body"; exit 1 }

$b64 = [regex]::Match($body, '"b64_json"\s*:\s*"([^"]+)"')
$url = [regex]::Match($body, '"url"\s*:\s*"([^"]+)"')
$target = Join-Path (Get-Location) $Out
if ($b64.Success) {
  [IO.File]::WriteAllBytes($target, [Convert]::FromBase64String($b64.Groups[1].Value))
} elseif ($url.Success) {
  & curl.exe --max-time 120 -sS -o $target $url.Groups[1].Value.Replace('\/', '/')
} else {
  Write-Error "No image in response: $body"; exit 1
}
if (-not (Test-Path $target) -or (Get-Item $target).Length -lt 1000) { Write-Error "Image file is invalid: $target"; exit 1 }
Write-Host "OK $target"
