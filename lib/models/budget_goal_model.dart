import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetGoalModel {
  final String id;
  final String uid;
  final String goalName;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String emoji;

  const BudgetGoalModel({
    required this.id,
    required this.uid,
    required this.goalName,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.deadline,
    this.emoji = '🎯',
  });

  double get progressPercent =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  double get remaining => (targetAmount - currentAmount).clamp(0.0, double.infinity);

  bool get isCompleted => currentAmount >= targetAmount;

  factory BudgetGoalModel.fromMap(Map<String, dynamic> map, String docId) {
    return BudgetGoalModel(
      id: docId,
      uid: map['uid'] as String,
      goalName: map['goalName'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num?)?.toDouble() ?? 0.0,
      deadline: (map['deadline'] as Timestamp).toDate(),
      emoji: map['emoji'] as String? ?? '🎯',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'goalName': goalName,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': Timestamp.fromDate(deadline),
      'emoji': emoji,
    };
  }

  BudgetGoalModel copyWith({
    String? goalName,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? emoji,
  }) {
    return BudgetGoalModel(
      id: id,
      uid: uid,
      goalName: goalName ?? this.goalName,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      emoji: emoji ?? this.emoji,
    );
  }
}
