# Test Sign-Up Endpoint Script
# This script tests the sign-up endpoint to verify it's working correctly

Write-Host "=== Testing Sign-Up Endpoint ===" -ForegroundColor Green
Write-Host ""

# Test data
$testUser = @{
    username    = "testuser_$(Get-Date -Format 'yyyyMMddHHmmss')"
    password    = "testpassword123"
    name        = "Test User"
    guardianKey = "testguardian"
} | ConvertTo-Json

$headers = @{
    'Content-Type' = 'application/json'
}

# Test the endpoint
Write-Host "Testing sign-up endpoint: http://localhost:5192/api/Users/SignUp" -ForegroundColor Yellow
Write-Host "Test data: $testUser" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5192/api/Users/SignUp" -Method Post -Body $testUser -Headers $headers -ErrorAction Stop
    
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
        Write-Host "405 Method Not Allowed - This suggests:" -ForegroundColor Yellow
        Write-Host "1. The endpoint doesn't exist" -ForegroundColor Yellow
        Write-Host "2. Wrong HTTP method (should be POST)" -ForegroundColor Yellow
        Write-Host "3. Route configuration issue" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Check if:" -ForegroundColor Yellow
        Write-Host "- Backend is running on port 5192" -ForegroundColor Yellow
        Write-Host "- The SignUp method name matches the route" -ForegroundColor Yellow
        Write-Host "- The controller is properly configured" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Green
