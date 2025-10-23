# VTA Local Development Environment Setup Script (PowerShell)
# This script sets up the database environment for the VTA project
# Backend and Frontend run locally for optimal hot reload functionality

Write-Host "Setting up VTA Local Development Environment..." -ForegroundColor Green

# Check if Docker is installed and running
try {
    $dockerVersion = docker --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not found"
    }
    Write-Host " Docker is installed and running" -ForegroundColor Green
}
catch {
    Write-Host "Docker is not installed or not running. Please install Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Check if Docker Compose is available
try {
    $composeVersion = docker-compose --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        $composeVersion = docker compose version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Docker Compose not found"
        }
    }
    Write-Host " Docker Compose is available" -ForegroundColor Green
}
catch {
    Write-Host " Docker Compose is not available. Please install Docker Compose." -ForegroundColor Red
    exit 1
}

# Create environment file if it doesn't exist
if (-not (Test-Path ".env.local")) {
    Write-Host "Creating .env.local from template..." -ForegroundColor Yellow
    Copy-Item "env.local" ".env.local"
    Write-Host "Created .env.local - you can edit it if needed" -ForegroundColor Green
}
else {
    Write-Host ".env.local already exists" -ForegroundColor Green
}

# Stop any existing containers
Write-Host "Stopping any existing containers..." -ForegroundColor Yellow
try {
    docker-compose -f docker-compose.local.yml down 2>$null
}
catch {
    # Ignore errors if no containers are running
}

# Start database services
Write-Host "Starting database services..." -ForegroundColor Yellow
docker-compose -f docker-compose.local.yml up -d

# Wait for services to be healthy
Write-Host "Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check database health
Write-Host "Checking database health..." -ForegroundColor Yellow

# Check MySQL
try {
    docker exec vta-mysql-local mysqladmin ping -h localhost -u root -prootpassword 2>$null
    Write-Host " MySQL is healthy" -ForegroundColor Green
}
catch {
    Write-Host "MySQL is not responding" -ForegroundColor Red
}

# Check phpMyAdmin
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081" -UseBasicParsing -TimeoutSec 5
    Write-Host "phpMyAdmin is accessible" -ForegroundColor Green
}
catch {
    Write-Host "phpMyAdmin might still be starting up" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Database setup complete! Now start your backend and frontend locally:" -ForegroundColor Green
Write-Host ""
Write-Host "Database services available at:" -ForegroundColor Cyan
Write-Host "   • phpMyAdmin:   http://localhost:8081" -ForegroundColor White
Write-Host "   • MySQL:        localhost:3306" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "   1. Start Backend:  cd Backend/VTA.API && dotnet run" -ForegroundColor White
Write-Host "   2. Start Frontend: cd Frontend/vta_app && flutter run -d web-server --web-port 8080" -ForegroundColor White
Write-Host ""
Write-Host "Management commands:" -ForegroundColor Cyan
Write-Host "   • Stop database:  docker-compose -f docker-compose.local.yml down" -ForegroundColor White
Write-Host "   • View logs:      docker-compose -f docker-compose.local.yml logs -f" -ForegroundColor White
Write-Host "   • Restart:        docker-compose -f docker-compose.local.yml up -d" -ForegroundColor White
Write-Host ""
Write-Host "Database credentials:" -ForegroundColor Cyan
Write-Host "   • Root user:    root / rootpassword" -ForegroundColor White
Write-Host "   • App user:     vta_user / vta_password" -ForegroundColor White
Write-Host "   • Database:     vta_local" -ForegroundColor White
Write-Host ""
Write-Host "Happy coding with hot reload!" -ForegroundColor Green
