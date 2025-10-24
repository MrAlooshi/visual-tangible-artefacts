# VTA Development Environment Setup Script (PowerShell)
# This script sets up the complete VTA development environment using Docker

Write-Host "Setting up VTA Development Environment..." -ForegroundColor Green

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
    docker-compose -f docker-compose.build.yml down 2>$null
}
catch {
    # Ignore errors if no containers are running
}

# Start all services
Write-Host "Starting all services..." -ForegroundColor Yellow
docker-compose -f docker-compose.build.yml up --build -d

# Wait for services to be healthy
Write-Host "Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check database health
Write-Host "Checking database health..." -ForegroundColor Yellow

# Check MySQL
try {
    docker exec vta-mysql mysqladmin ping -h localhost -u root -proot_password 2>$null
    Write-Host " MySQL is healthy" -ForegroundColor Green
}
catch {
    Write-Host "MySQL is not responding" -ForegroundColor Red
}

# Check Backend
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5192/swagger" -UseBasicParsing -TimeoutSec 5
    Write-Host "Backend is accessible" -ForegroundColor Green
}
catch {
    Write-Host "Backend might still be starting up" -ForegroundColor Yellow
}

# Check Frontend
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing -TimeoutSec 5
    Write-Host "Frontend is accessible" -ForegroundColor Green
}
catch {
    Write-Host "Frontend might still be starting up" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Development environment setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Services available at:" -ForegroundColor Cyan
Write-Host "   • Frontend:     http://localhost:8080" -ForegroundColor White
Write-Host "   • Backend API:  http://localhost:5192" -ForegroundColor White
Write-Host "   • Swagger UI:   http://localhost:5192/swagger" -ForegroundColor White
Write-Host "   • MySQL:        localhost:3306" -ForegroundColor White
Write-Host ""
Write-Host "Management commands:" -ForegroundColor Cyan
Write-Host "   • Stop all:      docker-compose -f docker-compose.build.yml down" -ForegroundColor White
Write-Host "   • View logs:     docker-compose -f docker-compose.build.yml logs -f" -ForegroundColor White
Write-Host "   • Restart:       docker-compose -f docker-compose.build.yml up --build -d" -ForegroundColor White
Write-Host ""
Write-Host "Database credentials:" -ForegroundColor Cyan
Write-Host "   • Root user:    root / root_password" -ForegroundColor White
Write-Host "   • App user:     vta_user / vta_password" -ForegroundColor White
Write-Host "   • Database:     vta_dev" -ForegroundColor White
Write-Host ""
Write-Host "Happy coding!" -ForegroundColor Green
