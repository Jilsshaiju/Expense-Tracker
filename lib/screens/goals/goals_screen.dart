import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../models/budget_goal_model.dart';
import '../../router/app_router.dart';

class GoalsScreen extends StatelessWidget {
  final bool isTab;
  const GoalsScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    final goals = context.watch<BudgetProvider>().goals;
    final uid = context.watch<AppAuthProvider>().uid;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !isTab,
        title: const Text('Goals'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoal(context),
        child: const Icon(Icons.add),
      ),
      body: goals.isEmpty
          ? const Center(child: Text('No goals added yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final g = goals[index];
                final progress = g.targetAmount == 0
                    ? 0.0
                    : (g.currentAmount / g.targetAmount).clamp(0.0, 1.0);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                g.goalName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: progress),
                        const SizedBox(height: 8),
                        Text(
                          '₹${g.currentAmount.toStringAsFixed(0)} / ₹${g.targetAmount.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: uid == null
                                    ? null
                                    : () => _showContributeDialog(
                                        context: context, uid: uid, goal: g),
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text('Contribute'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: uid == null
                                  ? null
                                  : () => context
                                      .read<BudgetProvider>()
                                      .deleteGoal(uid, g.id),
                              icon: const Icon(Icons.delete_outline_rounded),
                              color: Colors.red,
                              tooltip: 'Delete goal',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showAddGoal(BuildContext context) async {
    final uid = context.read<AppAuthProvider>().uid;
    if (uid == null) return;
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Goal name'),
            ),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Target amount'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text) ?? 0;
                if (nameCtrl.text.trim().isEmpty || amount <= 0) return;
                final goal = BudgetGoalModel(
                  id: const Uuid().v4(),
                  uid: uid,
                  goalName: nameCtrl.text.trim(),
                  targetAmount: amount,
                  deadline: DateTime.now().add(const Duration(days: 120)),
                );
                await context.read<BudgetProvider>().addGoal(goal);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(AppRouter.home, (r) => false);
                }
              },
              child: const Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showContributeDialog({
    required BuildContext context,
    required String uid,
    required BudgetGoalModel goal,
  }) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Contribute to ${goal.goalName}'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(ctrl.text) ?? 0;
              if (amount <= 0) return;
              await context.read<BudgetProvider>().contribute(uid, goal, amount);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
