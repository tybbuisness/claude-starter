# Claude Code starter: rules, second brain, Vinted photo skill, official plugins.
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

function Get-StarterFile($relative, $destination, $keepExisting) {
    if ($keepExisting -and (Test-Path $destination)) { Write-Host "[KEEP] $destination"; return }
    New-Item -Force -ItemType Directory (Split-Path $destination) | Out-Null
    try {
        Invoke-WebRequest -UseBasicParsing "$base/$relative" -OutFile $destination -ErrorAction Stop
        Write-Host "[OK] $destination" -ForegroundColor Green
    } catch {
        Write-Host "[FAIL] $relative : $_" -ForegroundColor Red
    }
}

# Second brain: never overwrites what already exists.
$brain = Join-Path $HOME "second-brain"
foreach ($f in "profil.md", "regles.md", ".gitignore") { Get-StarterFile "second-brain/$f" (Join-Path $brain $f) $true }
New-Item -Force -ItemType Directory (Join-Path $brain "projets") | Out-Null
if ((Get-Command git -ErrorAction SilentlyContinue) -and -not (Test-Path (Join-Path $brain ".git"))) {
    git -C $brain init -q
    Write-Host "[OK] Git repository in $brain" -ForegroundColor Green
}

# Vinted photos skill.
$skill = Join-Path (Join-Path $dir "skills") "vinted-photos"
foreach ($f in "SKILL.md", "generer.ps1") { Get-StarterFile "skills/vinted-photos/$f" (Join-Path $skill $f) $false }

# ArgoLink key: hidden while typing, stored for this Windows user only.
if (-not [Environment]::GetEnvironmentVariable("ARGOLINK_API_KEY", "User")) {
    $secure = Read-Host "ArgoLink API key (hidden, press Enter to skip)" -AsSecureString
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    if ($plain) {
        [Environment]::SetEnvironmentVariable("ARGOLINK_API_KEY", $plain, "User")
        Write-Host "[OK] ArgoLink key saved" -ForegroundColor Green
    } else {
        Write-Host "[WARN] No ArgoLink key: the photo skill will not work yet" -ForegroundColor Yellow
    }
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
