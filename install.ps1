# Claude Code starter: rules, official plugins, documentation server.
$ErrorActionPreference = "Continue"
$base = "https://raw.githubusercontent.com/tybbuisness/claude-starter/main"
$dir = Join-Path $HOME ".claude"
$file = Join-Path $dir "CLAUDE.md"

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "[STOP] 'claude' not found. Install Claude Code first." -ForegroundColor Red
    return
}

New-Item -Force -ItemType Directory $dir | Out-Null
if (Test-Path $file) {
    $backup = "$file.bak-" + (Get-Date -Format "yyyyMMdd-HHmmss")
    Copy-Item $file $backup
    Write-Host "[OK] Previous rules saved: $backup"
}
try {
    Invoke-WebRequest -UseBasicParsing "$base/CLAUDE.md" -OutFile $file -ErrorAction Stop
    Write-Host "[OK] Rules installed: $file" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Rules download: $_" -ForegroundColor Red
}

claude plugin marketplace add anthropics/claude-plugins-official
foreach ($p in "superpowers", "frontend-design", "skill-creator") {
    claude plugin install "$p@claude-plugins-official"
    if ($LASTEXITCODE -eq 0) { Write-Host "[OK] Plugin $p" -ForegroundColor Green }
    else { Write-Host "[FAIL] Plugin $p" -ForegroundColor Red }
}

claude mcp add --scope user --transport http context7 https://mcp.context7.com/mcp
if ($LASTEXITCODE -eq 0) { Write-Host "[OK] Context7" -ForegroundColor Green }
else { Write-Host "[WARN] Context7 not added (it may already exist)" -ForegroundColor Yellow }

Write-Host ""
Write-Host "Finished. Close Claude Code, then run: claude" -ForegroundColor Green
