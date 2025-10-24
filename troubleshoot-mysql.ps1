# VTA MySQL Troubleshooting Script
# This script helps diagnose and fix common MySQL/Docker issues

Write-Host "=== VTA MySQL Troubleshooting Script ===" -ForegroundColor Green
Write-Host ""

# Function to check if Docker is running
function Test-DockerRunning {
    try {
        docker version | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to check MySQL container status
function Get-MySQLStatus {
    Write-Host "Checking MySQL container status..." -ForegroundColor Yellow
    
    $containers = docker ps -a --filter "name=vta-mysql" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    if ($containers -match "vta-mysql") {
        Write-Host $containers
        return $true
    }
    else {
        Write-Host "No MySQL container found!" -ForegroundColor Red
        return $false
    }
}

# Function to check MySQL logs
function Get-MySQLLogs {
    Write-Host "`nChecking MySQL logs (last 20 lines)..." -ForegroundColor Yellow
    docker logs --tail 20 vta-mysql
}

# Function to test MySQL connection
function Test-MySQLConnection {
    Write-Host "`nTesting MySQL connection..." -ForegroundColor Yellow
    
    try {
        $result = docker exec vta-mysql mysqladmin ping -h localhost -u root -prootpassword
        if ($result -match "alive") {
            Write-Host "✓ MySQL is responding to ping" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "✗ MySQL ping failed" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ Could not connect to MySQL container" -ForegroundColor Red
        return $false
    }
}

# Function to check database exists
function Test-DatabaseExists {
    Write-Host "`nChecking if vta_dev database exists..." -ForegroundColor Yellow
    
    try {
        $result = docker exec vta-mysql mysql -u root -prootpassword -e "SHOW DATABASES LIKE 'vta_dev';"
        if ($result -match "vta_dev") {
            Write-Host "✓ vta_dev database exists" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "✗ vta_dev database not found" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ Could not check database" -ForegroundColor Red
        return $false
    }
}

# Function to check tables exist
function Test-TablesExist {
    Write-Host "`nChecking if required tables exist..." -ForegroundColor Yellow
    
    try {
        $result = docker exec vta-mysql mysql -u root -prootpassword -e "USE vta_dev; SHOW TABLES;"
        if ($result -match "user" -and $result -match "category" -and $result -match "artefact") {
            Write-Host "✓ All required tables exist" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "✗ Some tables are missing" -ForegroundColor Red
            Write-Host "Found tables: $result" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "✗ Could not check tables" -ForegroundColor Red
        return $false
    }
}

# Function to restart MySQL with clean state
function Restart-MySQLClean {
    Write-Host "`nRestarting MySQL with clean state..." -ForegroundColor Yellow
    
    Write-Host "Stopping containers..." -ForegroundColor Cyan
    docker-compose down
    
    Write-Host "Removing MySQL volume..." -ForegroundColor Cyan
    docker volume rm vta-mysql-data 2>$null
    
    Write-Host "Starting MySQL..." -ForegroundColor Cyan
    docker-compose up -d mysql
    
    Write-Host "Waiting for MySQL to be ready..." -ForegroundColor Cyan
    Start-Sleep -Seconds 30
    
    Write-Host "MySQL restart complete!" -ForegroundColor Green
}

# Main execution
Write-Host "Step 1: Checking Docker..." -ForegroundColor Cyan
if (-not (Test-DockerRunning)) {
    Write-Host "✗ Docker is not running! Please start Docker Desktop." -ForegroundColor Red
    exit 1
}
Write-Host "✓ Docker is running" -ForegroundColor Green

Write-Host "`nStep 2: Checking MySQL container..." -ForegroundColor Cyan
if (-not (Get-MySQLStatus)) {
    Write-Host "MySQL container not found. Starting containers..." -ForegroundColor Yellow
    docker-compose up -d mysql
    Start-Sleep -Seconds 10
    Get-MySQLStatus
}

Write-Host "`nStep 3: Checking MySQL health..." -ForegroundColor Cyan
if (-not (Test-MySQLConnection)) {
    Write-Host "MySQL is not healthy. Checking logs..." -ForegroundColor Red
    Get-MySQLLogs
    Write-Host "`nAttempting to restart MySQL..." -ForegroundColor Yellow
    Restart-MySQLClean
}

Write-Host "`nStep 4: Checking database structure..." -ForegroundColor Cyan
if (-not (Test-DatabaseExists)) {
    Write-Host "Database missing. This should be created by the schema initialization." -ForegroundColor Red
    Write-Host "Check if mysql_schema.sql is properly mounted." -ForegroundColor Yellow
}

if (-not (Test-TablesExist)) {
    Write-Host "Tables missing. The schema may not have been initialized properly." -ForegroundColor Red
}

Write-Host "`n=== Troubleshooting Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "If issues persist, try these commands:" -ForegroundColor Yellow
Write-Host "1. docker-compose down && docker-compose up -d" -ForegroundColor White
Write-Host "2. docker system prune -f" -ForegroundColor White
Write-Host "3. Check docker-compose.yml for password mismatches" -ForegroundColor White
Write-Host "4. Verify mysql_schema.sql is in the project root" -ForegroundColor White
