import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../main.dart' show ThemeNotifier;
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/income_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';
import '../../router/app_router.dart';

class ProfileScreen extends StatefulWidget {
  final bool isTab;
  const ProfileScreen({super.key, this.isTab = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final expenses = context.watch<ExpenseProvider>().monthTotal;
    final incomeTotal = context.watch<IncomeProvider>().monthTotal;
    final goals = context.watch<BudgetProvider>().goals;
    final goalContribution =
        goals.fold<double>(0, (sum, g) => sum + g.currentAmount);
    final themeNotifier = context.watch<ThemeNotifier>();
    final user = auth.userModel;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isTab,
        title: const Text('Profile'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withAlpha(190),
                            Theme.of(context).colorScheme.secondary.withAlpha(180),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _pickProfileImage,
                            child: CircleAvatar(
                              radius: 34,
                              backgroundImage:
                                  (user.photoUrl?.isNotEmpty ?? false)
                                      ? FileImage(File(user.photoUrl!))
                                      : null,
                              child: (user.photoUrl?.isNotEmpty ?? false)
                                  ? null
                                  : Text(user.name.substring(0, 1).toUpperCase()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700)),
                                Text(user.email,
                                    style: TextStyle(
                                        color: Colors.white.withAlpha(230))),
                                Text(
                                  'Goal contribution: ₹${goalContribution.toStringAsFixed(0)}',
                                  style:
                                      TextStyle(color: Colors.white.withAlpha(240)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  const Text('Income'),
                                  Text('₹${incomeTotal.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  const Text('Expense'),
                                  Text('₹${expenses.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Column(
                        children: [
                          SwitchListTile(
                            value: themeNotifier.isDark,
                            onChanged: themeNotifier.toggle,
                            title: const Text('Dark Mode'),
                          ),
                          ListTile(
                            title: const Text('Set Bill Reminder'),
                            leading: const Icon(Icons.notifications_active_outlined),
                            onTap: _scheduleBillReminder,
                          ),
                          ListTile(
                            title: const Text('Reset All Financial Data'),
                            leading: const Icon(Icons.restart_alt_rounded,
                                color: Colors.red),
                            textColor: Colors.red,
                            onTap: _resetAllData,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                      onPressed: () async {
                        await context.read<AppAuthProvider>().signOut();
                        if (!context.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                            context, AppRouter.login, (route) => false);
                      },
                      child: const Text('Sign Out'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _pickProfileImage() async {
    final provider = context.read<AppAuthProvider>();
    final uid = provider.uid;
    if (uid == null) return;
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    await provider.updateProfile(photoUrl: file.path);
  }

  Future<void> _scheduleBillReminder() async {
    String billType = 'Electricity Bill';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay.now();
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set Bill Reminder',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: billType,
                items: const [
                  'Electricity Bill',
                  'Water Bill',
                  'Phone Recharge',
                  'Internet Bill',
                  'Credit Card Bill',
                ]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setModalState(() => billType = v ?? billType),
                decoration: const InputDecoration(labelText: 'Bill Type'),
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Reminder Date'),
                subtitle: Text(DateFormat('EEE, dd MMM yyyy').format(selectedDate)),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                    );
                    if (picked != null) {
                      setModalState(() => selectedDate = picked);
                    }
                  },
                  child: const Text('Choose'),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time_outlined),
                title: const Text('Reminder Time'),
                subtitle: Text(selectedTime.format(ctx)),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setModalState(() => selectedTime = picked);
                    }
                  },
                  child: const Text('Choose'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final when = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                    if (when.isBefore(DateTime.now())) {
                      return;
                    }
                    await NotificationService.instance.scheduleBillReminder(
                      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                      title: billType,
                      body: '$billType payment is due now.',
                      when: when,
                    );
                    if (ctx.mounted) Navigator.pop(ctx, true);
                  },
                  icon: const Icon(Icons.alarm_add_rounded),
                  label: const Text('Save Reminder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || created != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bill reminder set successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _resetAllData() async {
    final uid = context.read<AppAuthProvider>().uid;
    if (uid == null) return;
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Reset data?'),
            content: const Text(
                'This will clear income, expenses, goals, budget and monthly values from app and Firebase.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Reset')),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    await FirestoreService().resetUserFinancialData(uid);
    if (!mounted) return;
    context.read<ExpenseProvider>().clearLocal();
    context.read<IncomeProvider>().clearLocal();
    context.read<BudgetProvider>().clearLocal();
    Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.home, (r) => false);
  }
}
