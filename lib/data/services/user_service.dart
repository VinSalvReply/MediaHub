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

const _activityTypes = ["login", "edit", "upload", "delete"];

const _events = [
  "Flutter Meetup",
  "Tech Conference",
  "Design Sprint",
  "Hackathon",
  "Workshop UX",
];

const _contentTypes = ["image", "video", "post"];

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
      return {
        "id": i + 1,
        "name": _names[i % _names.length],
        "last_name": _lastNames[i % _lastNames.length],
        "email": "user${i + 1}@mediahub.dev",
        "role": _roles[i % _roles.length],
        "is_active": _random.nextBool(),
        "created_at": _randomDate().toIso8601String(),
        "last_login": _random.nextBool()
            ? _randomDate().toIso8601String()
            : null,
      };
    });
  }

  // ================= ACTIVITY =================

  Future<List<Map<String, dynamic>>> getUserActivity(int userId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return List.generate(10 + _random.nextInt(10), (i) {
      final type = _activityTypes[_random.nextInt(_activityTypes.length)];

      return {
        "type": type,
        "description": _activityDescription(type),
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
      };
    });
  }

  // ================= CONTENT =================

  Future<List<Map<String, dynamic>>> getUserContent(int userId) async {
    await Future.delayed(const Duration(milliseconds: 900));

    return List.generate(8 + _random.nextInt(12), (i) {
      final type = _contentTypes[_random.nextInt(_contentTypes.length)];

      return {
        "id": i + 1,
        "title": _contentTitles[_random.nextInt(_contentTitles.length)],
        "type": type,
        "created_at": _randomDate().toIso8601String(),
      };
    });
  }

  // ================= HELPERS =================

  DateTime _randomDate() {
    return DateTime.now().subtract(
      Duration(days: _random.nextInt(60), hours: _random.nextInt(24)),
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
        return "Modifica profilo";
      case "upload":
        return "Caricamento contenuto";
      case "delete":
        return "Eliminazione contenuto";
      default:
        return "Attività generica";
    }
  }
}
