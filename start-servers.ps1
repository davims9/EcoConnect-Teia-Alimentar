$root = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Iniciando servidores ===" -ForegroundColor Cyan
Write-Host ""

# Start Flutter web server on port 5174
$flutterDir = Join-Path $root "web\public\flutter-app"
Write-Host "[1/2] Servindo Flutter em http://localhost:5174" -ForegroundColor Yellow
$job1 = Start-Job -ScriptBlock { param($d) Set-Location $d; npx http-server -p 5174 -c-1 --cors --silent } -ArgumentList $flutterDir

# Start Svelte server on port 5173
$svelteDir = Join-Path $root "web\dist"
Write-Host "[2/2] Servindo Svelte em http://localhost:5173" -ForegroundColor Yellow
$job2 = Start-Job -ScriptBlock { param($d) Set-Location $d; npx http-server -p 5173 -c-1 --cors --silent } -ArgumentList $svelteDir

Start-Sleep 3

Write-Host ""
Write-Host "=== Servidores rodando ===" -ForegroundColor Green
Write-Host "Pagina Svelte: http://localhost:5173" -ForegroundColor Green
Write-Host "Flutter direto: http://localhost:5174" -ForegroundColor Green
Write-Host ""
Write-Host "Pressione Enter para parar os servidores..."
Read-Host | Out-Null

Stop-Job $job1; Stop-Job $job2
Remove-Job $job1; Remove-Job $job2
Write-Host "Servidores parados." -ForegroundColor Red
