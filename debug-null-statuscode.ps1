# Status Code Null Debug Script
# This script helps diagnose why frontend gets statuscode null

Write-Host "=== Status Code Null Debug Script ===" -ForegroundColor Green
Write-Host ""

# Test 1: Check if backend is accessible from frontend perspective
Write-Host "Test 1: Testing backend accessibility..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5192/swagger" -Method Get -ErrorAction Stop
    Write-Host "✓ Backend is accessible on localhost:5192" -ForegroundColor Green
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "✗ Backend not accessible on localhost:5192" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Check if API endpoint is accessible
Write-Host ""
Write-Host "Test 2: Testing API endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5192/api/Users/SignUp" -Method Get -ErrorAction Stop
    Write-Host "✗ GET request succeeded (should return 405)" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 405) {
        Write-Host "✓ API endpoint exists (GET returns 405 as expected)" -ForegroundColor Green
    } else {
        Write-Host "✗ Unexpected error: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

# Test 3: Test POST request (this should work)
Write-Host ""
Write-Host "Test 3: Testing POST request..." -ForegroundColor Yellow
try {
    $body = @{
        username = "testuser_$(Get-Date -Format 'yyyyMMddHHmmss')"
        password = "testpass123"
        name = "Test User"
        guardianKey = "testguardian"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "http://localhost:5192/api/Users/SignUp" -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
    Write-Host "✓ POST request successful" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Green
} catch {
    Write-Host "✗ POST request failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

# Test 4: Check if frontend can reach backend from container perspective
Write-Host ""
Write-Host "Test 4: Testing container-to-container communication..." -ForegroundColor Yellow
try {
    $response = docker exec vta-frontend-build curl -s -o /dev/null -w "%{http_code}" http://vta-backend-build:8080/swagger
    if ($response -eq "200") {
        Write-Host "✓ Frontend container can reach backend container" -ForegroundColor Green
    } else {
        Write-Host "✗ Frontend container cannot reach backend container (HTTP $response)" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Could not test container communication" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Check CORS configuration
Write-Host ""
Write-Host "Test 5: Testing CORS..." -ForegroundColor Yellow
try {
    $headers = @{
        'Origin' = 'http://localhost:8080'
        'Access-Control-Request-Method' = 'POST'
        'Access-Control-Request-Headers' = 'Content-Type'
    }
    
    $response = Invoke-WebRequest -Uri "http://localhost:5192/api/Users/SignUp" -Method Options -Headers $headers -ErrorAction Stop
    Write-Host "✓ CORS preflight successful" -ForegroundColor Green
    Write-Host "CORS Headers: $($response.Headers['Access-Control-Allow-Origin'])" -ForegroundColor Green
} catch {
    Write-Host "✗ CORS preflight failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Check container status
Write-Host ""
Write-Host "Test 6: Checking container status..." -ForegroundColor Yellow
$containers = docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host $containers -ForegroundColor Cyan

# Test 7: Check backend logs for requests
Write-Host ""
Write-Host "Test 7: Checking recent backend logs..." -ForegroundColor Yellow
try {
    $logs = docker logs vta-backend-build --tail 10 2>&1
    Write-Host "Recent backend logs:" -ForegroundColor Cyan
    Write-Host $logs -ForegroundColor White
} catch {
    Write-Host "Could not retrieve backend logs" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Debug Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Common causes of 'statuscode null':" -ForegroundColor Yellow
Write-Host "1. Frontend calling wrong URL" -ForegroundColor White
Write-Host "2. Backend not running" -ForegroundColor White
Write-Host "3. Network connectivity issues" -ForegroundColor White
Write-Host "4. CORS blocking the request" -ForegroundColor White
Write-Host "5. Frontend running in different network" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Check browser developer tools Network tab" -ForegroundColor White
Write-Host "2. Verify frontend is calling http://localhost:5192/api/Users/SignUp" -ForegroundColor White
Write-Host "3. Check if backend container is running: docker ps" -ForegroundColor White
Write-Host "4. Check backend logs: docker logs vta-backend-build" -ForegroundColor White
