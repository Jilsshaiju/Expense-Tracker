import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String uid;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String notes;
  final bool isDebt;
  final String owedTo;

  const ExpenseModel({
    required this.id,
    required this.uid,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.notes = '',
    this.isDebt = false,
    this.owedTo = '',
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String docId) {
    return ExpenseModel(
      id: docId,
      uid: map['uid'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      description: map['description'] as String,
      date: (map['date'] as Timestamp).toDate(),
      notes: map['notes'] as String? ?? '',
      isDebt: map['isDebt'] as bool? ?? false,
      owedTo: map['owedTo'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'amount': amount,
      'category': category,
      'description': description,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'isDebt': isDebt,
      'owedTo': owedTo,
    };
  }

  ExpenseModel copyWith({
    String? id,
    String? uid,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    String? notes,
    bool? isDebt,
    String? owedTo,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      isDebt: isDebt ?? this.isDebt,
      owedTo: owedTo ?? this.owedTo,
    );
  }

  @override
  String toString() =>
      'ExpenseModel(id: $id, amount: $amount, category: $category)';
}
