# Documentazione per il Versioning dell'App

## Introduzione
Questa documentazione descrive le linee guida per la gestione delle versioni per l'applicazione AI Smart Wallet. Utilizziamo il **Semantic Versioning** (SemVer) e gestiamo il rilascio delle versioni tramite Git.

## Formato del Versioning (SemVer)
Il numero di versione è composto da tre numeri principali: `MAJOR.MINOR.PATCH`, più un eventuale numero di build interno o pre-release (`+build`).
Esempio: `1.2.3+4`
- `MAJOR` (1): Incrementato quando vengono fatte modifiche incompatibili o grandi riscritture dell'architettura.
- `MINOR` (2): Incrementato quando si aggiungono nuove funzionalità in modo retrocompatibile.
- `PATCH` (3): Incrementato quando vengono fatti bug fix retrocompatibili o piccoli miglioramenti.
- `+BUILD` (4): Numero sequenziale utilizzato per identificare la specifica build per gli store (App Store / Google Play).

## Aggiornare la Versione
La versione principale dell'applicazione Flutter è definita nel file `pubspec.yaml` alla riga `version:`.

```yaml
name: ai_smart_wallet
description: A smart wallet app
version: 1.0.0+1
```

Quando sei pronto per rilasciare una nuova versione:
1. Aggiorna la versione in `pubspec.yaml`.
2. Esegui `flutter pub get` per assicurarti che il cambiamento venga recepito.
3. (Opzionale) Esegui l'aggiornamento dei file nativi se necessario, anche se Flutter lo fa automaticamente in fase di build.

## Workflow Git per il Versioning (Git Flow)

Si consiglia di usare le seguenti convenzioni per i branch e i commit.

### Branch
- **`main`**: Il branch di produzione. Contiene solo codice rilasciato o pronto per essere rilasciato.
- **`develop`**: Il branch di sviluppo. Qui vengono fuse tutte le feature prima di una release.
- **`feature/nome-feature`**: Branch per sviluppare nuove funzionalità. Vengono staccati da `develop` e uniti nuovamente in `develop`.
- **`bugfix/nome-bug`**: Branch per risolvere bug in fase di sviluppo.
- **`hotfix/nome-hotfix`**: Branch per risolvere bug critici in produzione. Vengono staccati da `main` e uniti sia in `main` che in `develop`.

### Tag Git
Ogni volta che viene rilasciata una nuova versione su `main`, bisogna creare un tag Git corrispondente al numero di versione.
```bash
git tag -a v1.0.0 -m "Release versione 1.0.0"
git push origin v1.0.0
```

## Changelog
Mantenere un file `CHANGELOG.md` aggiornato è un'ottima pratica.
Ogni release dovrebbe avere una sezione nel changelog che elenca:
- **Added**: Nuove funzionalità
- **Changed**: Cambiamenti a funzionalità esistenti
- **Deprecated**: Funzionalità che verranno rimosse in futuro
- **Removed**: Funzionalità rimosse
- **Fixed**: Bug risolti
- **Security**: Risoluzioni di vulnerabilità

Esempio:
```markdown
## [1.0.0] - 2026-06-25
### Added
- Autenticazione biometrica
- Gestione base del portafoglio
### Fixed
- Risolto crash sulla schermata transazioni
```

## Automazione (CI/CD)
(Sezioni future: configurare GitHub Actions / Codemagic / Fastlane per leggere la versione da `pubspec.yaml` e creare automaticamente i tag e le release.)
