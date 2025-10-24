# Team Troubleshooting Guide for 405 Sign-Up Errors

## ✅ Prerequisites Checklist

### 1. Docker Setup
```powershell
# Check if Docker is running
docker version

# Check if containers are running
docker ps
```

### 2. Use Correct Docker Compose File
```powershell
# IMPORTANT: Use the build file, not the regular one
docker-compose -f docker-compose.build.yml up --build -d
```

### 3. Verify Container Status
You should see these containers running:
- `vta-mysql` (port 3306)
- `vta-backend-build` (port 5192) 
- `vta-frontend-build` (port 8080)

## 🔍 Debugging Steps

### Step 1: Test Backend Directly
```powershell
# Test if backend responds
Invoke-WebRequest -Uri "http://localhost:5192/swagger" -Method Get

# Test sign-up endpoint
Invoke-RestMethod -Uri "http://localhost:5192/api/Users/SignUp" -Method Post -ContentType "application/json" -Body '{"username":"test123","password":"test123","name":"Test","guardianKey":"test"}'
```

### Step 2: Check Backend Logs
```powershell
# Check for errors
docker logs vta-backend-build --tail 20

# Check for sign-up requests
docker logs vta-backend-build | findstr "SignUp"
```

### Step 3: Verify Frontend Configuration
Check `Frontend/vta_app/assets/cfg/app_settings.json`:
```json
{
    "ApiSettings": {
        "BaseUrl": {
            "Local": "http://localhost:5192/api/",
            "Remote": "http://localhost:5192/api/"
        }
    }
}
```

### Step 4: Verify Backend Configuration
Check `Backend/VTA.API/appsettingsLocal.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "server=localhost;port=3306;user=vta_user;password=vta_password;database=vta_dev"
  }
}
```

## 🚨 Common Issues & Solutions

### Issue 1: Wrong Docker Compose File
**Problem:** Using `docker-compose up -d` instead of `docker-compose -f docker-compose.build.yml up -d`
**Solution:** Always use the build file

### Issue 2: Old Code Version
**Problem:** Team doesn't have the latest code with the fixed method name
**Solution:** 
```powershell
git pull
docker-compose -f docker-compose.build.yml up --build -d
```

### Issue 3: Port Conflicts
**Problem:** Another service using port 5192
**Solution:**
```powershell
# Check what's using port 5192
netstat -ano | findstr :5192

# Stop conflicting services
docker-compose down
docker-compose -f docker-compose.build.yml up -d
```

### Issue 4: Frontend Not Rebuilt
**Problem:** Frontend using old configuration
**Solution:**
```powershell
# Rebuild frontend
docker-compose -f docker-compose.build.yml up --build -d frontend
```

### Issue 5: Database Connection Issues
**Problem:** Backend can't connect to MySQL
**Solution:**
```powershell
# Check MySQL is healthy
docker exec vta-mysql mysqladmin ping -h localhost -u root -proot_password

# Check database exists
docker exec vta-mysql mysql -u root -proot_password -e "SHOW DATABASES;"
```

## 🔧 Complete Reset (If All Else Fails)

```powershell
# Stop everything
docker-compose down
docker-compose -f docker-compose.build.yml down

# Remove volumes (WARNING: This deletes all data)
docker volume rm vta-mysql-data vta-backend_assets

# Pull latest code
git pull

# Start fresh
docker-compose -f docker-compose.build.yml up --build -d
```

## 📋 Final Verification

Run this test to confirm everything works:
```powershell
# Test sign-up
$body = @{
    username = "testuser_$(Get-Date -Format 'yyyyMMddHHmmss')"
    password = "testpass123"
    name = "Test User"
    guardianKey = "testguardian"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5192/api/Users/SignUp" -Method Post -ContentType "application/json" -Body $body
```

If this works, the issue is in the frontend configuration or code.

## 📞 What to Report

If still getting 405 errors, please provide:
1. Output of `docker ps`
2. Output of `docker logs vta-backend-build --tail 20`
3. Frontend configuration file content
4. Exact error message from frontend
5. Network tab from browser developer tools showing the actual request
