# VTA Docker Setup

I skal ikke selv "sætte systemet op". I skal kun gøre to ting:

1. **Installere Docker**
2. **Køre én kommando**

## Jeres Workflow (Sådan Skal I Arbejde)

Her er den simple guide til jer:

### Første Gang (og efter git pull):

1. **Åbn en terminal** i projektmappen
2. **Kør denne kommando** for at bygge og starte alt:

```powershell
docker-compose -f docker-compose.build.yml up --build -d
```

### Når I Har Ændret i Koden:

1. **I laver en ændring** i koden (f.eks. i VS Code)
2. **I går tilbage til terminalen** og kører præcis den samme kommando igen:

```powershell
docker-compose -f docker-compose.build.yml up --build -d
```

## Hvad Kommandoen Gør

- **`up`**: Starter applikationen (både frontend og backend)
- **`--build`**: Dette er den magiske del. Docker tjekker, om kildekoden har ændret sig siden sidst. Hvis den har, genbygger den automatisk kun det nødvendige (f.eks. jeres frontend-image), før den starter appen
- **`-d`**: Kører det hele i baggrunden

## Dette Løser Begge Jeres Krav Perfekt:

**Nemt setup**: I skal ikke installere Flutter, Nginx, eller backend-sprog. I skal kun have Docker og køre én kommando.

**Kan ændre kode**: I ændrer koden lokalt, kører kommandoen igen, og Docker genbygger og serverer den nye version.

## Hvad Der Sker Automatisk

Når I kører kommandoen:

1. **Docker tjekker** om koden er ændret
2. **Hvis ja**: Genbygger kun de dele der er ændret
3. **Hvis nej**: Bruger eksisterende images (hurtigt!)
4. **Starter alle tjenester** (MySQL, Backend, Frontend)
5. **Applikationen er tilgængelig** på `http://localhost:8080`

## Almindelige Kommandoer

### Start Alt
```powershell
docker-compose -f docker-compose.build.yml up --build -d
```

### Stop Alt
```powershell
docker-compose -f docker-compose.build.yml down
```

### Se Logs
```powershell
docker-compose -f docker-compose.build.yml logs
```

### Genstart Specifik Tjeneste
```powershell
docker-compose -f docker-compose.build.yml restart frontend
docker-compose -f docker-compose.build.yml restart backend
docker-compose -f docker-compose.build.yml restart backend-test
```

## Test Miljø

### Kør Kun Test Services
```powershell
docker-compose -f docker-compose.build.yml up --build -d backend-test mysql-test
```


### Test Backend API Direkte
```powershell
# Test signup endpoint
curl -X POST -H "Content-Type: application/json" -d '{"username":"testuser","password":"testpass","name":"Test User","guardianKey":"testkey"}' http://localhost:5192/api/Users/SignUp

# Test login endpoint
curl -X POST -H "Content-Type: application/json" -d '{"username":"testuser","password":"testpass"}' http://localhost:5192/api/Users/Login
```

## Fejlfinding

### Hvis Noget Ikke Virker:
1. **Tjek status**: `docker-compose -f docker-compose.build.yml ps`
2. **Se logs**: `docker-compose -f docker-compose.build.yml logs [tjeneste-navn]`
3. **Genstart alt**: `docker-compose -f docker-compose.build.yml down && docker-compose -f docker-compose.build.yml up --build -d`

### Hvis Porte Er Optaget:
```powershell
# Tjek hvad der bruger porte
netstat -an | findstr :8080
netstat -an | findstr :5192
netstat -an | findstr :5193
netstat -an | findstr :3306
netstat -an | findstr :3307
```

### Almindelige Problemer og Løsninger

#### Frontend Kan Ikke Forbinde til Backend
**Problem**: `net::ERR_NAME_NOT_RESOLVED` eller `Failed to fetch`
**Løsning**: 
- Tjek at backend kører: `docker-compose -f docker-compose.build.yml ps`
- Tjek backend logs: `docker-compose -f docker-compose.build.yml logs backend`
- Verificer API URL i `Frontend/vta_app/assets/cfg/app_settings.json` er `http://localhost:5192/api/`

#### Database Forbindelsesproblemer
**Problem**: Backend kan ikke forbinde til MySQL
**Løsning**:
- Tjek MySQL status: `docker-compose -f docker-compose.build.yml ps mysql`
- Tjek MySQL logs: `docker-compose -f docker-compose.build.yml logs mysql`
- Verificer connection string i docker-compose miljøvariabler

#### Signup Fungerer Ikke
**Problem**: Signup fejler med status code null
**Løsning**:
- Tjek at API URL er korrekt konfigureret
- Verificer at backend modtager requests: `docker-compose -f docker-compose.build.yml logs backend`
- Test API direkte med curl kommandoer ovenfor

#### Blank Skærm Efter Signup
**Problem**: Signup lykkes men viser blank skærm
**Løsning**: 
- Genbygg frontend: `docker-compose -f docker-compose.build.yml up --build -d frontend`
- Tjek browser console for JavaScript fejl

## Vigtige Porte

- **Frontend**: `http://localhost:8080`
- **Backend API (Dev)**: `localhost:5192`
- **Backend API (Test)**: `localhost:5193`
- **MySQL Database (Dev)**: `localhost:3306`
- **MySQL Database (Test)**: `localhost:3307`

## Database Information

### Development Database
- **Database**: `vta_dev`
- **Bruger**: `vta_user`
- **Adgangskode**: `vta_password`

### Test Database
- **Database**: `vta_test`
- **Bruger**: `vta_user`
- **Adgangskode**: `vta_password`

## Sikkerhed

- **ElevenLabs API**: Konfigureret til produktion med API key
- **Alle secrets**: Inkluderet i Docker images
- **Database**: Persistent data (overlever genstarter)
- **CORS**: Konfigureret til at tillade alle origins for udvikling
- **JWT**: Sikker token-baseret autentificering
- **Test Isolation**: Separate test database og backend service

## Seneste Forbedringer

### Test Miljø Integration
- **Separate test services**: `backend-test` og `mysql-test` for isoleret testing
- **Dedicated test database**: `vta_test` database på port 3307
- **Test backend API**: Tilgængelig på port 5193

### Forbedret Navigation og Fejlhåndtering
- **Signup flow**: Korrekt navigation tilbage til login efter succesfuld registrering
- **API connectivity**: Løst frontend-backend kommunikationsproblemer
- **Response handling**: Forbedret HTTP response parsing

## Support

Hvis der er problemer:
1. **Tjek Docker Desktop** er kørende
2. **Se troubleshooting sektion** ovenfor for specifikke løsninger
3. **Kontakt udviklingsteamet** med specifikke fejlbeskeder

---

**Husk**: Denne løsning gør det nemt for jer at arbejde med projektet uden at skulle sætte komplekse udviklingsmiljøer op. I skal kun have Docker og køre én kommando!
