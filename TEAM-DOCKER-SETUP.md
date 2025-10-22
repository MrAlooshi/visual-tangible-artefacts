# VTA Docker Opsætning for Teams

Denne guide hjælper dit team med at køre den komplette VTA applikation ved hjælp af Docker.

## Hurtig Start

### Forudsætninger
- **Docker Desktop** installeret og kørende
- **Git** til at klone repository'et

### Et-kommando Opsætning
```powershell
# Klon repository'et
git clone <dit-repo-url>
cd visual-tangible-artefacts

# Start alt med Docker (brug pre-built images)
docker-compose up -d
```

Det er det! Applikationen vil være tilgængelig på `http://localhost:8080`

**Vigtigt**: Dette setup bruger pre-built Docker images. Du behøver ikke at bygge images selv.

## Hvad der Startes

### Tjenester der Kører:
- **MySQL Database**: `localhost:3306`
  - Database: `vta_dev`
  - Bruger: `vta_user`
  - Adgangskode: `vta_password`

- **Backend API**: `localhost:5192`
  - Komplet REST API
  - ElevenLabs integration (produktion)
  - Fil-lagring for billeder og lyd

- **Frontend Web App**: `http://localhost:8080`
  - Flutter web applikation
  - Forbundet til backend API
  - Komplet funktionalitet

## Management Kommandoer

### Start Tjenester
```powershell
docker-compose up -d
```

### Stop Tjenester
```powershell
docker-compose down
```

### Vis Logs
```powershell
# Alle tjenester
docker-compose logs

# Specifik tjeneste
docker-compose logs backend
docker-compose logs frontend
docker-compose logs mysql
```

### Genstart Tjenester
```powershell
# Genstart alle
docker-compose restart

# Genstart specifik tjeneste
docker-compose restart backend
```

### Opdater Images
```powershell
# Hent nyeste pre-built images
docker-compose pull

# Start med nyeste images
docker-compose up -d
```

**Bemærk**: Images bygges af udviklingsteamet. Brug `docker-compose pull` for at hente opdateringer.

## Database Management

### Adgang til Database
```powershell
# Forbind til MySQL container
docker exec -it vta-mysql mysql -u vta_user -p vta_dev

# Eller brug eksternt værktøj
# Host: localhost
# Port: 3306
# Bruger: vta_user
# Adgangskode: vta_password
# Database: vta_dev
```

### Nulstil Database
```powershell
# Stop tjenester
docker-compose down

# Fjern database volume
docker volume rm visual-tangible-artefacts_mysql_data

# Start tjenester (vil genskabe database)
docker-compose up -d
```

## Fejlfinding

### Almindelige Problemer

1. **Port Konflikter**
   ```powershell
   # Tjek hvad der bruger porte
   netstat -an | findstr :8080
   netstat -an | findstr :5192
   netstat -an | findstr :3306
   ```

2. **Tjenester Starter Ikke**
   ```powershell
   # Tjek tjeneste status
   docker-compose ps
   
   # Tjek logs
   docker-compose logs [tjeneste-navn]
   ```

3. **Frontend Kan Ikke Forbinde til Backend**
   - Sørg for backend kører: `docker-compose ps`
   - Tjek backend logs: `docker-compose logs backend`
   - Verificer backend er sund

4. **ElevenLabs Virker Ikke**
   - Tjek backend logs for API nøgle fejl
   - Verificer ElevenLabs API nøgle er gyldig
   - Tjek netværksforbindelse

### Nulstil Alt
```powershell
# Stop og fjern alt
docker-compose down -v

# Fjern alle billeder
docker-compose down --rmi all

# Start forfra
docker-compose up --build -d
```

## Sikkerhedsnoter

### API Nøgler
- ElevenLabs API nøgle er inkluderet i konfigurationen
- Til produktion, brug miljøvariabler eller secrets management
- Overvej at rotere API nøgler regelmæssigt

### Database
- Standard adgangskoder bruges til udvikling
- Skift adgangskoder til produktions deployment
- Overvej at bruge Docker secrets til følsomme data

## Overvågning

### Sundhedstjek
```powershell
# Tjek alle tjenester
docker-compose ps

# Tjek specifik tjeneste sundhed
docker inspect vta-mysql | findstr Health
```

### Ressource Forbrug
```powershell
# Vis ressource forbrug
docker stats
```

## Udviklings Workflow

### Foretage Ændringer
1. **Kode Ændringer**: Rediger filer i din IDE
2. **Kontakt Udviklingsteamet**: For at få nye images bygget
3. **Hent Opdateringer**: `docker-compose pull && docker-compose up -d`
4. **Test**: Adgang `http://localhost:8080`

### Database Ændringer
1. **Schema Opdateringer**: Modificer `mysql_schema.sql`
2. **Kontakt Udviklingsteamet**: For at få nye images med schema ændringer
3. **Nulstil Database**: Følg database nulstil trin ovenfor
4. **Test**: Verificer ændringer virker

### Frontend Ændringer
1. **Kode Ændringer**: Rediger Flutter filer
2. **Kontakt Udviklingsteamet**: For at få ny frontend image
3. **Hent Opdateringer**: `docker-compose pull frontend && docker-compose up -d frontend`
4. **Test**: Opdater browser

### Backend Ændringer
1. **Kode Ændringer**: Rediger C# filer
2. **Kontakt Udviklingsteamet**: For at få ny backend image
3. **Hent Opdateringer**: `docker-compose pull backend && docker-compose up -d backend`
4. **Test**: Tjek API endpoints

## Miljøvariabler

### Backend Miljøvariabler
- `ASPNETCORE_ENVIRONMENT=Development`
- `ConnectionStrings__DefaultConnection=server=mysql;port=3306;database=vta_dev;user=vta_user;password=vta_password`
- `ElevenLabs__UseLocalhost=false`
- `ElevenLabs__ApiKey=sk_9b25dc7767856fbb11acb9552efbbbec31369a3c41698436`
- `ElevenLabs__BaseUrl=https://api.elevenlabs.io/v1`

### Tilpasse Konfiguration
Rediger `docker-compose.yml` for at modificere miljøvariabler eller tilføje nye.

## Produktions Overvejelser

### Til Produktions Deployment:
1. **Brug Miljøvariabler**: Hardkod ikke secrets
2. **Skift Standard Adgangskoder**: Brug stærke, unikke adgangskoder
3. **Aktiver HTTPS**: Tilføj SSL certifikater
4. **Brug Secrets Management**: Til API nøgler og følsomme data
5. **Overvåg Ressourcer**: Sæt logging og overvågning op
6. **Backup Strategi**: Regelmæssige database backups

## Support

Hvis du støder på problemer:
1. Tjek logs: `docker-compose logs`
2. Verificer alle tjenester kører: `docker-compose ps`
3. Prøv at genstarte: `docker-compose restart`
4. Kontakt udviklingsteamet med specifikke fejlbeskeder
