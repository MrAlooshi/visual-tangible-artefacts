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
netstat -an | findstr :3306
```

## Vigtige Porte

- **Frontend**: `http://localhost:8080`
- **Backend API**: `localhost:5192`
- **MySQL Database**: `localhost:3306`

## Database Information

- **Database**: `vta_dev`
- **Bruger**: `vta_user`
- **Adgangskode**: `vta_password`

## Sikkerhed

- **ElevenLabs API**: Konfigureret til produktion
- **Alle secrets**: Inkluderet i Docker images
- **Database**: Persistent data (overlever genstarter)

## Support

Hvis der er problemer:
1. **Tjek Docker Desktop** er kørende
2. **Kør kommandoen igen** med `--build` flag
3. **Kontakt udviklingsteamet** med specifikke fejlbeskeder

---

**Husk**: Denne løsning gør det nemt for jer at arbejde med projektet uden at skulle sætte komplekse udviklingsmiljøer op. I skal kun have Docker og køre én kommando!
