# Comprehensive Sign-Up Debug Script
# This script tests the sign-up endpoint and helps identify 405 errors

Write-Host "=== Sign-Up Endpoint Debug Script ===" -ForegroundColor Green
Write-Host ""

# Test data
$testUser = @{
    username    = "testuser_$(Get-Date -Format 'yyyyMMddHHmmss')"
    password    = "testpassword123"
    name        = "Test User"
    guardianKey = "testguardian"
}

$headers = @{
    'Content-Type' = 'application/json'
}

# Test 1: Check if backend is running
Write-Host "Test 1: Checking if backend is running..." -ForegroundColor Yellow
try {
    $healthCheck = Invoke-WebRequest -Uri "http://localhost:5192/swagger" -Method Get -ErrorAction Stop
    Write-Host "✓ Backend is responding" -ForegroundColor Green
}
catch {
    # Try a different endpoint
    try {
        $healthCheck = Invoke-WebRequest -Uri "http://localhost:5192" -Method Get -ErrorAction Stop
        Write-Host "✓ Backend is responding" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Backend is not responding on localhost:5192" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Solutions:" -ForegroundColor Yellow
        Write-Host "1. Run: docker-compose -f docker-compose.build.yml up -d" -ForegroundColor White
        Write-Host "2. Check: docker ps" -ForegroundColor White
        Write-Host "3. Verify backend is running on port 5192" -ForegroundColor White
        exit 1
    }
}

# Test 2: Check if the endpoint exists (GET should return 405)
Write-Host ""
Write-Host "Test 2: Checking endpoint existence..." -ForegroundColor Yellow
try {
    $getResponse = Invoke-WebRequest -Uri "http://localhost:5192/api/Users/SignUp" -Method Get -ErrorAction Stop
    Write-Host "✗ GET request succeeded (should have failed)" -ForegroundColor Red
}
catch {
    if ($_.Exception.Response.StatusCode -eq 405) {
        Write-Host "✓ Endpoint exists (GET returns 405 as expected)" -ForegroundColor Green
    }
    else {
        Write-Host "✗ Unexpected error: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

# Test 3: Test POST request
Write-Host ""
Write-Host "Test 3: Testing POST request..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5192/api/Users/SignUp" -Method Post -ContentType "application/json" -Body ($testUser | ConvertTo-Json) -ErrorAction Stop
    
    Write-Host "✓ Sign-up successful!" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Green
    
}
catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorMessage = $_.Exception.Message
    
    Write-Host "✗ Sign-up failed!" -ForegroundColor Red
    Write-Host "Status Code: $statusCode" -ForegroundColor Red
    Write-Host "Error: $errorMessage" -ForegroundColor Red
    
    if ($statusCode -eq 405) {
        Write-Host ""
        Write-Host "405 Method Not Allowed - Possible causes:" -ForegroundColor Yellow
        Write-Host "1. Wrong HTTP method (should be POST)" -ForegroundColor Yellow
        Write-Host "2. Endpoint doesn't exist" -ForegroundColor Yellow
        Write-Host "3. Route configuration issue" -ForegroundColor Yellow
        Write-Host "4. Frontend calling wrong URL" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Debug steps:" -ForegroundColor Yellow
        Write-Host "1. Check frontend is calling: http://localhost:5192/api/Users/SignUp" -ForegroundColor White
        Write-Host "2. Verify method is POST" -ForegroundColor White
        Write-Host "3. Check Content-Type is application/json" -ForegroundColor White
        Write-Host "4. Run: docker logs vta-backend" -ForegroundColor White
    }
    elseif ($statusCode -eq 400) {
        Write-Host ""
        Write-Host "400 Bad Request - Check request body format" -ForegroundColor Yellow
        Write-Host "Expected format: {\"username\":\"...\",\"password\":\"...\",\"name\":\"...\",\"guardianKey\":\"...\"}" -ForegroundColor White
    }
}

# Test 4: Check backend logs
Write-Host ""
Write-Host "Test 4: Checking recent backend logs..." -ForegroundColor Yellow
try {
    $logs = docker logs vta-backend --tail 10 2>&1
    Write-Host "Recent backend logs:" -ForegroundColor Cyan
    Write-Host $logs -ForegroundColor White
}
catch {
    Write-Host "Could not retrieve backend logs" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Debug Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "If you're still getting 405 errors:" -ForegroundColor Yellow
Write-Host "1. Make sure you're using the correct URL: http://localhost:5192/api/Users/SignUp" -ForegroundColor White
Write-Host "2. Ensure you're using POST method" -ForegroundColor White
Write-Host "3. Check Content-Type is application/json" -ForegroundColor White
Write-Host "4. Verify backend container is running: docker ps" -ForegroundColor White
Write-Host "5. Check backend logs: docker logs vta-backend" -ForegroundColor White
