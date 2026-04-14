import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/income_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/income_provider.dart';
import '../../router/app_router.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _sourceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _category = 'Salary';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Income')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Track every source of money to keep your monthly summary accurate.',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (v) => (double.tryParse(v ?? '') ?? 0) > 0
                    ? null
                    : 'Enter valid amount',
              ),
              TextFormField(
                controller: _sourceCtrl,
                decoration: const InputDecoration(labelText: 'Source'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter source' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: const ['Salary', 'Business', 'Freelance', 'Gift', 'Other']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? 'Other'),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save Income'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = context.read<AppAuthProvider>().uid;
    if (uid == null) return;
    final income = IncomeModel(
      id: const Uuid().v4(),
      uid: uid,
      amount: double.parse(_amountCtrl.text),
      category: _category,
      source: _sourceCtrl.text.trim(),
      date: DateTime.now(),
      notes: _notesCtrl.text.trim(),
    );
    await context.read<IncomeProvider>().addIncome(income);
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.home, (r) => false);
  }
}
