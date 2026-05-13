# mediahub

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

```text
lib/
├── core/
│   ├── constants/        # Costanti globali (colori, dimensioni, config)
│   ├── theme/            # Tema dell’app (MaterialTheme, typography, ecc.)
│   └── utils/            # Utility e helper condivisi
│
├── data/
│   ├── dto/              # Modelli grezzi come arrivano dalle API (JSON)
│   ├── mappers/          # Conversione DTO → modelli di dominio (UI)
│   ├── repositories/     # Espongono dati puliti alle feature
│   └── services/         # Chiamate API / mock / sorgenti dati
│
├── features/
│   ├── users/
│   │   ├── controllers/  # Logica e stato della feature
│   │   ├── models/       # Modelli usati dalla UI (domain)
│   │   ├── pages/        # Pagine (entry point della feature)
│   │   └── widgets/      # Widget specifici della feature
│   │
│   ├── dashboard/        # Feature dashboard
│   └── auth/             # Feature autenticazione
│
├── layout/
│   ├── main_layout.dart  # Layout principale (sidebar + contenuto)
│   └── sidebar.dart      # Navigazione laterale
│
├── routes/
│   └── app_router.dart   # Configurazione routing (go_router)
│
├── app.dart              # Configurazione MaterialApp
└── main.dart             # Entry point applicazione
```
