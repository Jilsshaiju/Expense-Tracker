import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';
import '../core/utils/date_utils.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ExpenseModel> _all = [];
  bool _isLoading = false;
  String? _error;

  List<ExpenseModel> get all => _all;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ExpenseModel> get today {
    final now = DateTime.now();
    return _all.where((e) => AppDateUtils.isSameDay(e.date, now)).toList();
  }

  List<ExpenseModel> get thisWeek {
    final now = DateTime.now();
    return _all.where((e) => AppDateUtils.isSameWeek(e.date, now)).toList();
  }

  List<ExpenseModel> get lastWeek {
    final last = DateTime.now().subtract(const Duration(days: 7));
    return _all.where((e) => AppDateUtils.isSameWeek(e.date, last)).toList();
  }

  List<ExpenseModel> get thisMonth {
    final now = DateTime.now();
    return _all.where((e) => AppDateUtils.isSameMonth(e.date, now)).toList();
  }

  double get todayTotal =>
      today.fold(0.0, (sum, e) => sum + e.amount);

  double get weekTotal =>
      thisWeek.fold(0.0, (sum, e) => sum + e.amount);

  double get monthTotal =>
      thisMonth.fold(0.0, (sum, e) => sum + e.amount);

  Map<String, double> get categoryTotalsMonth {
    final map = <String, double>{};
    for (final e in thisMonth) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  /// Returns a map of day-of-week → total for the current week (Mon–Sun)
  Map<String, double> get weeklyDayTotals {
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final map = {for (final l in labels) l: 0.0};
    for (final e in thisWeek) {
      final label = labels[e.date.weekday - 1];
      map[label] = (map[label] ?? 0) + e.amount;
    }
    return map;
  }

  /// Returns a map of last 6 months label → total
  Map<String, double> get monthlyTrend {
    final now = DateTime.now();
    final map = <String, double>{};
    for (int i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final label = '${_monthAbbr(m.month)}\n${m.year}';
      map[label] = 0.0;
    }
    for (final e in _all) {
      final m = DateTime(e.date.year, e.date.month, 1);
      if (now.difference(m).inDays <= 180) {
        final label =
            '${_monthAbbr(m.month)}\n${m.year}';
        if (map.containsKey(label)) {
          map[label] = map[label]! + e.amount;
        }
      }
    }
    return map;
  }

  String _monthAbbr(int month) {
    const abbrs = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return abbrs[month];
  }

  void listenToExpenses(String uid) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getExpenses(uid).listen((list) {
      _all = list;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = 'Failed to load expenses';
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _firestoreService.addExpense(expense);
  }

  Future<void> deleteExpense(String uid, String expenseId) async {
    await _firestoreService.deleteExpense(uid, expenseId);
  }
}
