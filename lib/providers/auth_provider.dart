import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _userModel;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get userModel => _userModel;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  String? get uid => _authService.currentUser?.uid;

  AppAuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) {
      if (user == null) {
        _status = AuthStatus.unauthenticated;
        _userModel = null;
      } else {
        _status = AuthStatus.authenticated;
        _listenToProfile(user.uid);
      }
      notifyListeners();
    });
  }

  void _listenToProfile(String uid) {
    _firestoreService.getUserProfile(uid).listen((model) {
      _userModel = model;
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading();
      final cred = await _authService.signUp(email: email, password: password);
      await _authService.updateDisplayName(name);

      final user = UserModel(
        uid: cred.user!.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
      await _firestoreService.createUserProfile(user);
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred.');
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading();
      await _authService.signIn(email: email, password: password);
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred.');
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> updateProfile({
    double? monthlyIncome,
    double? monthlyBudget,
    double? savingsGoal,
    String? name,
    String? photoUrl,
  }) async {
    if (uid == null) return;
    final updates = <String, dynamic>{};
    if (monthlyIncome != null) updates['monthlyIncome'] = monthlyIncome;
    if (monthlyBudget != null) updates['monthlyBudget'] = monthlyBudget;
    if (savingsGoal != null) updates['savingsGoal'] = savingsGoal;
    if (name != null) updates['name'] = name;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    await _firestoreService.updateUserProfile(uid!, updates);
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status = AuthStatus.unauthenticated;
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
