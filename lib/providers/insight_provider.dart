import 'package:flutter/foundation.dart';
import '../core/utils/insight_engine.dart';
import '../models/expense_model.dart';

class InsightProvider extends ChangeNotifier {
  List<String> _insights = ['Add expenses to unlock smart insights! 🚀'];

  List<String> get insights => _insights;

  void recompute({
    required List<ExpenseModel> thisWeek,
    required List<ExpenseModel> lastWeek,
    required List<ExpenseModel> thisMonth,
    required double monthlyBudget,
  }) {
    _insights = InsightEngine.generateInsights(
      thisWeek: thisWeek,
      lastWeek: lastWeek,
      thisMonth: thisMonth,
      monthlyBudget: monthlyBudget,
    );
    notifyListeners();
  }
}
