import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import '../models/user_model.dart';
import '../models/budget_goal_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Collections ────────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> _expensesCol(String uid) =>
      _db.collection('users').doc(uid).collection('expenses');

  CollectionReference<Map<String, dynamic>> _goalsCol(String uid) =>
      _db.collection('users').doc(uid).collection('goals');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  // ── User Profile ──────────────────────────────────────────────────
  Future<void> createUserProfile(UserModel user) async {
    await _userDoc(user.uid).set(user.toMap());
  }

  Stream<UserModel?> getUserProfile(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserModel.fromMap(snap.data()!);
    });
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _userDoc(uid).update(data);
  }

  // ── Expenses ──────────────────────────────────────────────────────
  Future<void> addExpense(ExpenseModel expense) async {
    await _expensesCol(expense.uid).add(expense.toMap());
  }

  Future<void> deleteExpense(String uid, String expenseId) async {
    await _expensesCol(uid).doc(expenseId).delete();
  }

  Future<void> updateExpense(String uid, ExpenseModel expense) async {
    await _expensesCol(uid).doc(expense.id).update(expense.toMap());
  }

  Stream<List<ExpenseModel>> getExpenses(String uid) {
    return _expensesCol(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ── Goals ─────────────────────────────────────────────────────────
  Future<void> addGoal(BudgetGoalModel goal) async {
    await _goalsCol(goal.uid).add(goal.toMap());
  }

  Future<void> updateGoal(String uid, BudgetGoalModel goal) async {
    await _goalsCol(uid).doc(goal.id).update(goal.toMap());
  }

  Future<void> deleteGoal(String uid, String goalId) async {
    await _goalsCol(uid).doc(goalId).delete();
  }

  Stream<List<BudgetGoalModel>> getGoals(String uid) {
    return _goalsCol(uid).snapshots().map((snap) => snap.docs
        .map((doc) => BudgetGoalModel.fromMap(doc.data(), doc.id))
        .toList());
  }
}
