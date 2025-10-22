# Build script for VTA Docker images
# Kun til brug af udviklingsteamet

Write-Host "Bygger VTA Docker images..." -ForegroundColor Green

# Byg backend image
Write-Host "Bygger backend image..." -ForegroundColor Yellow
docker build -t vta-backend:latest -f ./Backend/VTA.API/Dockerfile .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Fejl ved bygning af backend image" -ForegroundColor Red
    exit 1
}

# Byg frontend image
Write-Host "Bygger frontend image..." -ForegroundColor Yellow
docker build -t vta-frontend:latest ./Frontend/vta_app

if ($LASTEXITCODE -ne 0) {
    Write-Host "Fejl ved bygning af frontend image" -ForegroundColor Red
    exit 1
}

Write-Host "Alle images bygget succesfuldt!" -ForegroundColor Green
Write-Host ""
Write-Host "Images tilgængelige:" -ForegroundColor Cyan
Write-Host "  - vta-backend:latest" -ForegroundColor White
Write-Host "  - vta-frontend:latest" -ForegroundColor White
Write-Host ""
Write-Host "For at teste images lokalt:" -ForegroundColor Yellow
Write-Host "  docker-compose -f docker-compose.build.yml up -d" -ForegroundColor White
Write-Host ""
Write-Host "For at pushe til registry:" -ForegroundColor Yellow
Write-Host "  docker tag vta-backend:latest <registry>/vta-backend:latest" -ForegroundColor White
Write-Host "  docker tag vta-frontend:latest <registry>/vta-frontend:latest" -ForegroundColor White
Write-Host "  docker push <registry>/vta-backend:latest" -ForegroundColor White
Write-Host "  docker push <registry>/vta-frontend:latest" -ForegroundColor White
