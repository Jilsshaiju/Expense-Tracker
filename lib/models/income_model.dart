import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeModel {
  final String id;
  final String uid;
  final double amount;
  final String category;
  final String source;
  final DateTime date;
  final String notes;

  const IncomeModel({
    required this.id,
    required this.uid,
    required this.amount,
    required this.category,
    required this.source,
    required this.date,
    this.notes = '',
  });

  factory IncomeModel.fromMap(Map<String, dynamic> map, String docId) {
    return IncomeModel(
      id: docId,
      uid: map['uid'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String? ?? 'Other',
      source: map['source'] as String? ?? 'Income',
      date: (map['date'] as Timestamp).toDate(),
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'amount': amount,
      'category': category,
      'source': source,
      'date': Timestamp.fromDate(date),
      'notes': notes,
    };
  }
}
