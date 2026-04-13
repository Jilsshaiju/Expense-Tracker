import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final double monthlyIncome;
  final double monthlyBudget;
  final double savingsGoal;
  final String? photoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.monthlyIncome = 0.0,
    this.monthlyBudget = 0.0,
    this.savingsGoal = 0.0,
    this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      monthlyIncome: (map['monthlyIncome'] as num?)?.toDouble() ?? 0.0,
      monthlyBudget: (map['monthlyBudget'] as num?)?.toDouble() ?? 0.0,
      savingsGoal: (map['savingsGoal'] as num?)?.toDouble() ?? 0.0,
      photoUrl: map['photoUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'monthlyIncome': monthlyIncome,
      'monthlyBudget': monthlyBudget,
      'savingsGoal': savingsGoal,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    double? monthlyIncome,
    double? monthlyBudget,
    double? savingsGoal,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
    );
  }
}
