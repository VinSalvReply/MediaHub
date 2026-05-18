import 'dart:math';

const _names = [
  "Luca",
  "Marco",
  "Giulia",
  "Francesca",
  "Alessandro",
  "Chiara",
  "Davide",
  "Elena",
];

const _lastNames = ["Rossi", "Bianchi", "Ferrari", "Romano", "Gallo", "Conti"];

const _roles = ["Admin", "Editor", "User"];

const _segments = ["Power user", "Casual", "Inactive"];

const _activityTypes = ["login", "edit", "upload", "delete"];

const _devices = ["web", "mobile", "desktop"];

const _events = [
  "Flutter Meetup",
  "Tech Conference",
  "Design Sprint",
  "Hackathon",
  "Workshop UX",
];

const _eventStatus = ["upcoming", "live", "ended"];

const _contentTypes = ["image", "video", "post"];

const _contentStatus = ["draft", "published", "archived"];

const _contentTitles = [
  "Landing Page Design",
  "Promo Video",
  "User Interview",
  "Marketing Campaign",
  "Dashboard UI",
];

class UserService {
  final _random = Random();

  // ================= USERS =================

  Future<List<Map<String, dynamic>>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return List.generate(20, (i) {
      final isActive = _random.nextBool();

      return {
        "id": i + 1,
        "name": _names[i % _names.length],
        "last_name": _lastNames[i % _lastNames.length],
        "email": "user${i + 1}@mediahub.dev",
        "role": _roles[i % _roles.length],
        "segment": _segments[_random.nextInt(_segments.length)],
        "is_active": isActive,
        "created_at": _randomDate().toIso8601String(),
        "last_login": isActive || _random.nextBool()
            ? _randomDate().toIso8601String()
            : null,
      };
    });
  }

  // ================= ACTIVITY =================

  Future<List<Map<String, dynamic>>> getUserActivity(int userId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return List.generate(12 + _random.nextInt(10), (i) {
      final type = _activityTypes[_random.nextInt(_activityTypes.length)];

      return {
        "type": type,
        "description": _activityDescription(type),
        "entity": _randomEntity(),
        "device": _devices[_random.nextInt(_devices.length)],
        "date": _randomDate().toIso8601String(),
      };
    });
  }

  // ================= EVENTS =================

  Future<List<Map<String, dynamic>>> getUserEvents(int userId) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return List.generate(4 + _random.nextInt(6), (i) {
      return {
        "id": i + 1,
        "title": _events[_random.nextInt(_events.length)],
        "date": _randomFutureDate().toIso8601String(),
        "attendees": 20 + _random.nextInt(200),
        "status": _eventStatus[_random.nextInt(_eventStatus.length)],
      };
    });
  }

  // ================= CONTENT =================

  Future<List<Map<String, dynamic>>> getUserContent(int userId) async {
    await Future.delayed(const Duration(milliseconds: 900));

    return List.generate(10 + _random.nextInt(12), (i) {
      final type = _contentTypes[_random.nextInt(_contentTypes.length)];

      return {
        "id": i + 1,
        "title": _contentTitles[_random.nextInt(_contentTitles.length)],
        "type": type,
        "status": _contentStatus[_random.nextInt(_contentStatus.length)],
        "created_at": _randomDate().toIso8601String(),
      };
    });
  }

  // ================= TREND (grafico) =================

  Future<List<Map<String, dynamic>>> getUsageTrend() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return List.generate(14, (i) {
      return {
        "date": DateTime.now().subtract(Duration(days: i)).toIso8601String(),
        "active_users": 40 + _random.nextInt(80),
        "content_created": 10 + _random.nextInt(40),
      };
    }).reversed.toList();
  }

  // ================= ALERTS =================

  Future<List<Map<String, dynamic>>> getAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      {"type": "warning", "message": "High inactive users rate"},
      {"type": "info", "message": "New event starting soon"},
    ];
  }

  // ================= TOP USERS =================

  Future<List<Map<String, dynamic>>> getTopUsers() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return List.generate(5, (i) {
      return {
        "name": _names[_random.nextInt(_names.length)],
        "score": 200 + _random.nextInt(800),
      };
    });
  }

  // ================= HELPERS =================

  DateTime _randomDate() {
    final now = DateTime.now();

    return now.subtract(
      Duration(days: _random.nextInt(30), hours: _random.nextInt(24)),
    );
  }

  DateTime _randomFutureDate() {
    return DateTime.now().add(Duration(days: _random.nextInt(60)));
  }

  String _activityDescription(String type) {
    switch (type) {
      case "login":
        return "Accesso effettuato";
      case "edit":
        return "Modifica contenuto";
      case "upload":
        return "Caricamento asset";
      case "delete":
        return "Eliminazione elemento";
      default:
        return "Attività generica";
    }
  }

  String _randomEntity() {
    return [
      "Post #${_random.nextInt(100)}",
      "Event #${_random.nextInt(50)}",
      "Profile update",
      "Media asset",
    ][_random.nextInt(4)];
  }
}
