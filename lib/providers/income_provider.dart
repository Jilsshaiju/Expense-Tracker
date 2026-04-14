import 'package:flutter/foundation.dart';
import '../models/income_model.dart';
import '../services/firestore_service.dart';
import '../core/utils/date_utils.dart';

class IncomeProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  List<IncomeModel> _all = [];
  bool _isLoading = false;

  List<IncomeModel> get all => _all;
  bool get isLoading => _isLoading;

  List<IncomeModel> get thisMonth {
    final now = DateTime.now();
    return _all.where((i) => AppDateUtils.isSameMonth(i.date, now)).toList();
  }

  double get monthTotal => thisMonth.fold(0.0, (sum, i) => sum + i.amount);

  void listenToIncomes(String uid) {
    _isLoading = true;
    notifyListeners();
    _firestore.getIncomes(uid).listen((items) {
      _all = items;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addIncome(IncomeModel income) => _firestore.addIncome(income);

  Future<void> deleteIncome(String uid, String incomeId) =>
      _firestore.deleteIncome(uid, incomeId);

  void clearLocal() {
    _all = [];
    notifyListeners();
  }
}
