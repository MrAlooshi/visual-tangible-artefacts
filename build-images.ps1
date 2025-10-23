# Build script for VTA Docker images
# Til brug af MrAliFar og CI/CD pipelines

Write-Host "Bygger VTA Docker images..." -ForegroundColor Green
Write-Host ""

# Byg backend image (dev)
Write-Host "Bygger backend image (dev)..." -ForegroundColor Yellow
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

Write-Host ""
Write-Host "Alle images bygget succesfuldt!" -ForegroundColor Green
Write-Host ""
Write-Host "Images tilgængelige:" -ForegroundColor Cyan
Write-Host "  - vta-backend:latest" -ForegroundColor White
Write-Host "  - vta-frontend:latest" -ForegroundColor White
Write-Host ""
Write-Host "For at teste images lokalt:" -ForegroundColor Yellow
Write-Host "  # Fuldt udviklingsmiljø (dev + test)" -ForegroundColor Gray
Write-Host "  docker-compose -f docker-compose.build.yml up --build -d" -ForegroundColor White
Write-Host ""
Write-Host "  # Kun test miljø" -ForegroundColor Gray
Write-Host "  docker-compose -f docker-compose.build.yml up --build -d backend-test mysql-test" -ForegroundColor White
Write-Host ""
Write-Host "  # Kun udviklingsmiljø" -ForegroundColor Gray
Write-Host "  docker-compose -f docker-compose.build.yml up --build -d mysql backend frontend" -ForegroundColor White
Write-Host ""
Write-Host "Tilgængelige services:" -ForegroundColor Cyan
Write-Host "  - Frontend: http://localhost:8080" -ForegroundColor White
Write-Host "  - Backend Dev: localhost:5192" -ForegroundColor White
Write-Host "  - Backend Test: localhost:5193" -ForegroundColor White
Write-Host "  - MySQL Dev: localhost:3306" -ForegroundColor White
Write-Host "  - MySQL Test: localhost:3307" -ForegroundColor White
Write-Host ""
Write-Host "For at pushe til registry:" -ForegroundColor Yellow
Write-Host "  docker tag vta-backend:latest <registry>/vta-backend:latest" -ForegroundColor White
Write-Host "  docker tag vta-frontend:latest <registry>/vta-frontend:latest" -ForegroundColor White
Write-Host "  docker push <registry>/vta-backend:latest" -ForegroundColor White
Write-Host "  docker push <registry>/vta-frontend:latest" -ForegroundColor White
Write-Host ""
Write-Host "For at teste API direkte:" -ForegroundColor Yellow
Write-Host "  # Test signup" -ForegroundColor Gray
Write-Host "  curl -X POST -H \"Content-Type: application/json\" -d '{\"username\":\"testuser\",\"password\":\"testpass\",\"name\":\"Test User\",\"guardianKey\":\"testkey\"}' http://localhost:5192/api/Users/SignUp" -ForegroundColor White
Write-Host ""
Write-Host "Se README-DOCKER.md for detaljeret dokumentation" -ForegroundColor Green
