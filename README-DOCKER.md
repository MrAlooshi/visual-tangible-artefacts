# VTA Docker Opsætningsguide

Denne guide indeholder alle trin der er nødvendige for at få Visual Tangible Artefacts (VTA) applikationen til at køre korrekt med Docker. Følg disse trin nøjagtigt for at undgå problemer.

## Forudsætninger

Før du starter, skal du sikre dig at have:

- **Docker Desktop**: Installeret og kørende
- **Git**: Til at klone repository'et
- **PowerShell**: Til at køre kommandoer (ikke Command Prompt)

## Trin-for-Trin Opsætning

### Trin 1: Klon Repository'et

```powershell
git clone
cd visual-tangible-artefacts
```

### Trin 2: Opret Manglende Konfigurationsfil

**VIGTIGT**: hvis assets\cfg\app_settings.json mangler skal den oprettes før første build

```powershell
# Opret cfg mappen
mkdir Frontend\vta_app\assets\cfg

# Opret app_settings.json filen
New-Item -Path "Frontend\vta_app\assets\cfg\app_settings.json" -ItemType File -Force
```

### Trin 3: Indsæt Konfigurationsindhold

Åbn filen `Frontend\vta_app\assets\cfg\app_settings.json` og indsæt følgende indhold:

```json
{
    "ApiSettings": {
        "BaseUrl": {
            "Local": "http://localhost:5192/api/",
            "Remote": "http://localhost:5192/api/"
        }
    },
    "ElevenLabs": {
        "LocalhostUrl": "http://localhost:5192/api/elevenlabs",
        "ProductionUrl": "https://api.elevenlabs.io/v1"
    }
}
```

**Gem filen** efter du har indsat indholdet.

### Trin 4: Hent Docker Images

```powershell
docker pull mralooshi/vta-backend:latest
docker pull mralooshi/vta-frontend:latest
```

### Trin 5: Byg og Start Alle Services

```powershell
docker-compose -f docker-compose.build.yml up --build -d
```

### Trin 6: Verificer at Alt Kører

```powershell
docker ps
```

Du skal se følgende containere kørende:
- `vta-mysql` (healthy)
- `vta-backend-build` 
- `vta-frontend-build`

### Trin 7: Test Applikationen

Åbn din browser og gå til: `http://localhost:8080`

Du skal nu se VTA applikationen i stedet for en blank hvid skærm.

## Almindelige Kommandoer

| Handling | Kommando |
|----------|----------|
| **Start med build** | `docker-compose -f docker-compose.build.yml up --build -d` |
| **Start uden build** | `docker-compose -f docker-compose.build.yml up -d` |
| **Stop alle services** | `docker-compose -f docker-compose.build.yml down` |
| **Se logs** | `docker-compose -f docker-compose.build.yml logs` |
| **Genstart specifik service** | `docker-compose -f docker-compose.build.yml restart [service-navn]` |
| **Tjek status** | `docker-compose -f docker-compose.build.yml ps` |

## Applikationsadgang

Når alt kører korrekt:

- **Frontend**: `http://localhost:8080`
- **Backend API**: `http://localhost:5192/api`
- **MySQL Database**: `localhost:3306`

## Database Information

### Udviklingsdatabase
- **Database**: `vta_dev`
- **Bruger**: `vta_user`
- **Password**: `vta_password`
- **Root Password**: `root_password`

### Database Administration
Du kan bruge MySQL Workbench eller enhver MySQL klient til at forbinde til databasen med ovenstående credentials.

## Fejlsøgning

### Problem: Blank Hvid Skærm på localhost:8080

**Årsag**: Manglende `app_settings.json` fil

**Løsning**:
1. Opret mappen: `mkdir Frontend\vta_app\assets\cfg`
2. Opret filen: `New-Item -Path "Frontend\vta_app\assets\cfg\app_settings.json" -ItemType File -Force`
3. Indsæt konfigurationsindholdet (se Trin 3 ovenfor)
4. Genbyg frontend: `docker-compose -f docker-compose.build.yml up --build -d frontend`

### Problem: MySQL Container Viser "Unhealthy"

**Løsning**:
```powershell
# Kør fejlsøgningsscriptet
.\troubleshoot-mysql.ps1

# Eller genstart MySQL manuelt
docker-compose down
docker volume rm vta-mysql-data
docker-compose up -d mysql
```

### Problem: Frontend Kan Ikke Forbinde til Backend

**Løsning**:
1. Verificer backend kører: `docker-compose -f docker-compose.build.yml ps`
2. Tjek backend logs: `docker-compose -f docker-compose.build.yml logs backend`
3. Verificer API URL i `Frontend\vta_app\assets\cfg\app_settings.json` peger på `http://localhost:5192/api/`

### Problem: Services Kan Ikke Starte

**Tjek for port konflikter**:
```powershell
# Tjek hvad der bruger portene
Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
Get-NetTCPConnection -LocalPort 5192 -ErrorAction SilentlyContinue
Get-NetTCPConnection -LocalPort 3306 -ErrorAction SilentlyContinue
```

### Problem: Signup Fejler

**Test API direkte**:
```powershell
# Test signup endpoint
Invoke-RestMethod -Uri "http://localhost:5192/api/Users/SignUp" -Method POST -ContentType "application/json" -Body '{"username":"testuser","password":"testpass","name":"Test User","guardianKey":"testkey"}'

# Test login endpoint
Invoke-RestMethod -Uri "http://localhost:5192/api/Users/Login" -Method POST -ContentType "application/json" -Body '{"username":"testuser","password":"testpass"}'
```

## Container Information

### Service Navne og Porte
- **MySQL**: `vta-mysql` på port `3306`
- **Backend**: `vta-backend-build` på port `5192` (internt port 8080)
- **Frontend**: `vta-frontend-build` på port `8080` (internt port 80)

### Netværk
Alle services kører på det samme Docker netværk (`vta-network`) og kan kommunikere med hinanden via service navne.

## Teknisk Overblik

### Hvad Kommandoerne Gør

- **`up`**: Starter alle services defineret i `docker-compose.build.yml` (backend, frontend, database)
- **`--build`**: Tjekker om kildekode er ændret siden sidste build. Hvis ja, genbygger kun de nødvendige images
- **`-d`**: Kører containerne i "detached mode" (baggrund)

### Den Automatiserede Proces

Når du kører `up --build`:

1. Docker tjekker om kode i `Frontend` eller `Backend` mapperne er ændret
2. **Hvis ja**: Docker genbygger den specifikke service (f.eks. `vta-frontend` image)
3. **Hvis nej**: Docker genbruger eksisterende byggede images
4. Docker starter alle services i korrekt rækkefølge (database først, derefter backend, så frontend)
5. Applikationen er tilgængelig på `http://localhost:8080`

### Service Afhængigheder

- **MySQL**: Starter først og venter på health check
- **Backend**: Starter efter MySQL er healthy og forbinder til `mysql:3306`
- **Frontend**: Starter efter backend og forbinder til `backend:8080`

### Volumes og Persistent Data

- **`mysql_data`**: Gemmer MySQL data persistent
- **`backend_assets`**: Gemmer backend assets persistent
- **`mysql_schema.sql`**: Mountes som read-only til database initialization

## ElevenLabs Konfiguration

Applikationen er konfigureret til at bruge ElevenLabs API:

- **API Key**: Konfigureret i environment variabler
- **Base URL**: `https://api.elevenlabs.io/v1`
- **Use Localhost**: Sat til `false` for produktion

## Sikkerhedsoverblik

- **ElevenLabs API**: Konfigureret til produktion med API nøgle
- **Secrets**: Alle nødvendige secrets (DB password, JWT nøgle) er inkluderet i Docker opsætning
- **Database**: Data er persistent og overlever container genstart (gemmes i Docker volume)
- **CORS**: Konfigureret til at tillade alle origins (standard for udvikling)
- **JWT**: Token-baseret autentificering er implementeret
- **Test Isolation**: Test miljø (services og database) er fuldt adskilt fra udviklingsmiljø

## Verificeringscheckliste

Før du går videre, verificer at følgende fungerer:

- [ ] Docker Desktop kører
- [ ] `app_settings.json` filen eksisterer i `Frontend\vta_app\assets\cfg\`
- [ ] Alle containere kører (`docker ps`)
- [ ] Frontend indlæses korrekt på `http://localhost:8080` (ikke blank skærm)
- [ ] Signup (brugeroprettelse) fungerer
- [ ] Login fungerer
- [ ] Navigation efter login fungerer
- [ ] API kald mellem frontend og backend lykkes
- [ ] Data er persistent (bruger oprettet før Docker genstart eksisterer stadig efter genstart)

## Support

Hvis du støder på problemer:

1. **Sørg for at Docker Desktop kører**
2. **Gennemgå fejlsøgningssektionen ovenfor**
3. **Tjek logs for specifikke fejlmeddelelser**:
   ```powershell
   docker-compose -f docker-compose.build.yml logs [service-navn]
   ```
4. **Prøv nulstillingskommandoen**:
   ```powershell
   docker-compose -f docker-compose.build.yml down
   docker-compose -f docker-compose.build.yml up --build -d
   ```

## Vigtige Noter

- **Brug altid PowerShell** - ikke Command Prompt
- **Følg trinene i rækkefølge** - spring ikke over trin
- **Opret `app_settings.json` filen** før første build - dette er kritisk!
- **Verificer at alle containere kører** før du tester applikationen