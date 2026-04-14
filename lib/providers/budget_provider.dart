import 'package:flutter/foundation.dart';
import '../models/budget_goal_model.dart';
import '../services/firestore_service.dart';

class BudgetProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<BudgetGoalModel> _goals = [];
  bool _isLoading = false;

  List<BudgetGoalModel> get goals => _goals;
  bool get isLoading => _isLoading;

  void listenToGoals(String uid) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getGoals(uid).listen((list) {
      _goals = list;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addGoal(BudgetGoalModel goal) async {
    await _firestoreService.addGoal(goal);
  }

  Future<void> updateGoal(String uid, BudgetGoalModel goal) async {
    await _firestoreService.updateGoal(uid, goal);
  }

  Future<void> deleteGoal(String uid, String goalId) async {
    await _firestoreService.deleteGoal(uid, goalId);
  }

  /// Contribute an amount to a goal.
  Future<void> contribute(
      String uid, BudgetGoalModel goal, double amount) async {
    final updated = goal.copyWith(
      currentAmount: (goal.currentAmount + amount)
          .clamp(0.0, goal.targetAmount),
    );
    await _firestoreService.updateGoal(uid, updated);
  }

  void clearLocal() {
    _goals = [];
    notifyListeners();
  }
}
