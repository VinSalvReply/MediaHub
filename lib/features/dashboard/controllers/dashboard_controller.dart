import 'package:flutter/foundation.dart';
import 'package:mediahub/data/repositories/dashboard_repository.dart';
import 'package:mediahub/features/dashboard/models/dashboard_data.dart';

class DashboardController extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardController({DashboardRepository? repository})
    : _repository = repository ?? DashboardRepository();

  DashboardData? data;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadDashboard() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      data = await _repository.getDashboard();
    } catch (error, stackTrace) {
      debugPrint(
        'DashboardController.loadDashboard error: $error\n$stackTrace',
      );
      errorMessage = 'Impossibile caricare la dashboard';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
