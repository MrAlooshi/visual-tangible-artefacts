# VTA Docker Setup Guide

Hele opsætningen er automatiseret. I skal ikke installere .NET, Flutter, Nginx eller MySQL manuelt. I skal kun gøre to ting:

1.  Installere Docker Desktop.
2.  Køre én kommando fra denne guide.

## Forudsætninger

Før I starter, skal I sikre, at følgende er installeret og kører:

  * **Docker Desktop**: Skal være kørende og opdateret.
  * **Git**: Nødvendigt for at klone projekt-repository.

-----

## Arbejdsgang (Workflow)

### Første Gang (og efter `git pull`)

1.  **Åbn en terminal** i projektets root folder.
2.  **Pull de seneste images** fra Docker Hub for at sikre, at I har den nyeste grund-konfiguration:
    ```powershell
    docker pull mralooshi/vta-backend:latest
    docker pull mralooshi/vta-frontend:latest
    ```
3.  **Kør kommandoen** for at bygge lokale ændringer og starte alle services:
    ```powershell
    docker-compose -f docker-compose.build.yml up --build -d
    ```

### Når I Har Ændret i Koden

1.  Foretag jeres kodeændringer (f.eks. i VS Code).
2.  Gå til terminalen og kør følgende kommando for at genbygge og starte:
    ```powershell
    docker-compose -f docker-compose.build.yml up --build -d
    ```

### Når I Blot Vil Starte Applikationen (Ingen Kodeændringer)

Hvis applikationen allerede er bygget, og I blot vil starte den (f.eks. efter en genstart af computeren):

1.  Kør denne kommando (dette er hurtigere, da den ikke genbygger koden):
    ```powershell
    docker-compose -f docker-compose.build.yml up -d
    ```


## Teknisk Overblik

### Hvad kommandoen gør

  * **`up`**: Starter alle services defineret i `docker-compose.build.yml` (backend, frontend, database).
  * **`--build`**: Dette er den vigtigste parameter. Docker tjekker, om kildekoden har ændret sig siden sidste build. Hvis ja, genbygger den automatisk kun de nødvendige images, før den starter applikationen.
  * **`-d`**: Kører containerne i "detached mode" (i baggrunden).

### Den Automatiserede Proces

Når I kører `up --build`:

1.  Docker tjekker, om koden i `Frontend` eller `Backend` mapperne er ændret.
2.  **Hvis ja**: Docker genbygger den specifikke service (f.eks. `vta-frontend` imaget).
3.  **Hvis nej**: Docker genbruger de eksisterende, byggede images.
4.  Docker starter alle services i den korrekte rækkefølge (database først, derefter backend, så frontend).
5.  Applikationen er nu tilgængelig på `http://localhost:8080`.

Denne metode sikrer, at I ikke behøver at installere Flutter, Nginx eller .NET lokalt. Docker håndterer alle afhængigheder. Når I ændrer koden og kører kommandoen igen, genbygger Docker kun de nødvendige dele.


#### Verificeringspunkter

  * Frontend indlæses korrekt på `http://localhost:8080`.
  * "Signup" (oprettelse af ny bruger) fungerer.
  * "Login" fungerer.
  * Navigation efter login (f.eks. til "board") virker.
  * API-kald mellem frontend og backend lykkes.
  * Data er persistent (en bruger oprettet før en genstart af Docker eksisterer stadig efter genstart).

-----

## Almindelige Kommandoer

### Start (Første gang / efter kodeændring)

Bygger ændringer og starter alle services.

```powershell
docker-compose -f docker-compose.build.yml up --build -d
```

### Start (Kun kørsel - ingen ændringer)

Starter alle services uden at bygge.

```powershell
docker-compose -f docker-compose.build.yml up -d
```

### Stop Alt

Stopper og fjerner alle services.

```powershell
docker-compose -f docker-compose.build.yml down
```

### Se Logs

Viser logs fra alle kørende services.

```powershell
docker-compose -f docker-compose.build.yml logs
```

### Genstart Specifik Service

```powershell
docker-compose -f docker-compose.build.yml restart frontend
docker-compose -f docker-compose.build.yml restart backend
docker-compose -f docker-compose.build.yml restart backend-test
```


### Test Backend API Direkte (via terminal)

Disse kommandoer tester mod test-backend'en (`localhost:5193`).

```powershell
# Test signup endpoint
curl -X POST -H "Content-Type: application/json" -d '{"username":"testuser","password":"testpass","name":"Test User","guardianKey":"testkey"}' http://localhost:5193/api/Users/SignUp

# Test login endpoint
curl -X POST -H "Content-Type: application/json" -d '{"username":"testuser","password":"testpass"}' http://localhost:5193/api/Users/Login
```

-----

## Troubleshooting

### Grundlæggende Fejlsøgning

1.  **Tjek status**: Se hvilke services der kører, og hvilke der er stoppet.
    `docker-compose -f docker-compose.build.yml ps`
2.  **Se logs**: Tjek log-output for en specifik service (f.eks. `backend`).
    `docker-compose -f docker-compose.build.yml logs backend`
3.  **Nulstil alt**: Stop alt, og genbyg fra bunden.
    `docker-compose -f docker-compose.build.yml down && docker-compose -f docker-compose.build.yml up --build -d`

### Tjek Optagede Porte

Hvis en service ikke kan starte, er det ofte pga. en port-konflikt.

```powershell
# Tjek hvad der bruger portene
netstat -an | findstr :8080
netstat -an | findstr :5192
netstat -an | findstr :5193
netstat -an | findstr :3306
netstat -an | findstr :3307
```

### Specifikke Problemer og Løsninger

#### Frontend kan ikke forbinde til Backend

  * **Problem**: Fejl i browser-konsollen: `net::ERR_NAME_NOT_RESOLVED` eller `Failed to fetch`.
  * **Løsning**:
    1.  Verificer at backend kører: `docker-compose -f docker-compose.build.yml ps`
    2.  Tjek backend logs for fejl: `docker-compose -f docker-compose.build.yml logs backend`
    3.  Verificer API URL i `Frontend/vta_app/assets/cfg/app_settings.json`. Den skal pege på `http://localhost:5192/api/`.

#### Databaseforbindelses-problemer

  * **Problem**: Backend-loggen viser fejl om, at den ikke kan forbinde til MySQL.
  * **Løsning**:
    1.  Tjek MySQL status: `docker-compose -f docker-compose.build.yml ps mysql`
    2.  Tjek MySQL logs for fejl under opstart: `docker-compose -f docker-compose.build.yml logs mysql`
    3.  Verificer connection string i `docker-compose.build.yml`'s miljøvariabler for backend-servicen.

#### Signup Fejler

  * **Problem**: Signup-kaldet fejler med "status code: null".
  * **Løsning**:
    1.  Dette er næsten altid et tegn på, at API URL'en er forkert konfigureret (se første punkt).
    2.  Verificer at backend modtager kaldet: `docker-compose -f docker-compose.build.yml logs backend`
    3.  Test API'et direkte med `curl`-kommandoerne fra "Testmiljø" sektionen (husk at ændre port til 5192 for dev).

#### Blank Skærm efter Signup

  * **Problem**: Signup lykkes (bruger oprettes i DB), men frontend viser en blank skærm.
  * **Løsning**:
    1.  Genbyg frontend: `docker-compose -f docker-compose.build.yml up --build -d frontend`
    2.  Tjek browser-konsollen (F12) for JavaScript-fejl.

-----

## Vigtige Porte

  * **Frontend**: `http://localhost:8080` (Applikationen i browseren)
  * **Backend API (Dev)**: `http://localhost:5192` (Udviklings-API)
  * **Backend API (Test)**: `http://localhost:5193` (Test-API)
  * **MySQL Database (Dev)**: `localhost:3306` 
  * **MySQL Database (Test)**: `localhost:3307` 
  Brug eventuelt mysql workbench til at tjekke databasen

## Databaseinformation

### Development Database

  * **Database**: `vta_dev`
  * **Bruger**: `vta_user`
  * **Password**: `vta_password`

### Test Database

  * **Database**: `vta_test`
  * **Bruger**: `vta_user`
  * **Password**: `vta_password`

-----

## Sikkerhedsoverblik

  * **ElevenLabs API**: Konfigureret til produktion med API-nøgle.
  * **Secrets**: Alle nødvendige secrets (DB-password, JWT-nøgle) er inkluderet i Docker-opsætningen.
  * **Database**: Data er persistente og overlever genstart af containerne (gemmes i et Docker-volume).
  * **CORS**: Konfigureret til at tillade alle origins (standard for udvikling).
  * **JWT**: Token-baseret autentificering er implementeret.
  * **Test Isolation**: Testmiljøet (services og database) er fuldt adskilt fra udviklingsmiljøet.



## Support

Hvis der opstår problemer:

1.  Sikr at Docker Desktop kører.
2.  Gennemgå "Troubleshooting" sektionen ovenfor.
