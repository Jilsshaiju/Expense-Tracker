import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>().all
        .map((e) => _Item(
              id: e.id,
              title: e.description,
              category: e.category,
              amount: e.amount,
              date: e.date,
              isIncome: false,
            ))
        .toList();
    final incomes = context.watch<IncomeProvider>().all
        .map((e) => _Item(
              id: e.id,
              title: e.source,
              category: e.category,
              amount: e.amount,
              date: e.date,
              isIncome: true,
            ))
        .toList();
    final all = [...expenses, ...incomes]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: all.length,
        itemBuilder: (context, index) {
          final item = all[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    (item.isIncome ? Colors.green : Colors.red).withAlpha(20),
                child: Icon(
                  item.isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
                  color: item.isIncome ? Colors.green : Colors.red,
                ),
              ),
              title: Text(item.title),
              subtitle: Text(item.category),
              trailing: Text(
                '${item.isIncome ? '+' : '-'} ₹${item.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: item.isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onLongPress: () async {
                final uid = context.read<AppAuthProvider>().uid;
                if (uid == null) return;
                if (item.isIncome) {
                  await context.read<IncomeProvider>().deleteIncome(uid, item.id);
                } else {
                  await context.read<ExpenseProvider>().deleteExpense(uid, item.id);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _Item {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final bool isIncome;
  _Item({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.isIncome,
  });
}
