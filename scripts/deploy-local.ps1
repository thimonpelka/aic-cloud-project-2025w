# ============================================================================
# scripts/deploy_local.ps1
# ============================================================================
Write-Host "Deploying to LocalStack..." -ForegroundColor Cyan

# --- Set LocalStack environment variables ---
$env:AWS_ENDPOINT_URL      = "http://localhost:4566"
$env:AWS_ENDPOINT_URL_S3   = "http://localhost:4566"
$env:AWS_ACCESS_KEY_ID     = "test"
$env:AWS_SECRET_ACCESS_KEY = "test"
$env:AWS_DEFAULT_REGION    = "eu-west-1"

# --- Check if LocalStack is running ---
try {
    $health = Invoke-RestMethod -Uri "http://localhost:4566/_localstack/health" -TimeoutSec 3 -ErrorAction Stop
    Write-Host "✅ LocalStack is running" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ LocalStack is not running!" -ForegroundColor Red
    exit 1
}

# --- Check if CDK is installed ---
if (-not (Get-Command "cdk" -ErrorAction SilentlyContinue)) {
    Write-Host "AWS CDK is not installed! Install with: npm install -g aws-cdk" -ForegroundColor Red
    exit 1
}

# --- Check if cdklocal is installed ---
if (-not (Get-Command "cdklocal" -ErrorAction SilentlyContinue)) {
    Write-Host "cdklocal is not installed. Installing..." -ForegroundColor Yellow
    npm install -g aws-cdk-local | Out-Null
}

# --- Bootstrap CDK (only needed once) ---
Write-Host "Bootstrapping CDK for LocalStack..." -ForegroundColor Cyan
$bootstrapOutput = cdklocal bootstrap 2>&1
if ($bootstrapOutput -notmatch "Stack already exists") {
    Write-Host $bootstrapOutput
}
Write-Host ""

# --- Synthesize the stack ---
Write-Host "Synthesizing CDK stack..." -ForegroundColor Cyan
$cdkSynth = cdk synth --context local=true 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ CDK synthesis failed!" -ForegroundColor Red
    Write-Host $cdkSynth
    exit 1
}
Write-Host "Stack synthesized successfully" -ForegroundColor Green
Write-Host ""

# --- Deploy the stack ---
Write-Host "🏗️  Deploying stack to LocalStack..." -ForegroundColor Cyan
cdklocal deploy --context local=true --require-approval never
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Deployment successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Stack Outputs:" -ForegroundColor Cyan
    cdklocal outputs --context local=true
    Write-Host ""
    Write-Host "Useful commands:" -ForegroundColor Cyan
    Write-Host "  - List tables: awslocal dynamodb list-tables"
    Write-Host "  - List functions: awslocal lambda list-functions"
    Write-Host "  - View logs: docker-compose logs -f"
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ Deployment failed!" -ForegroundColor Red
    exit 1
}
