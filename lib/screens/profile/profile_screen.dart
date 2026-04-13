import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../main.dart' show ThemeNotifier;
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../models/budget_goal_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../router/app_router.dart';
import 'widgets/budget_progress_card.dart';
import 'widgets/goal_card.dart';

class ProfileScreen extends StatefulWidget {
  final bool isTab;
  const ProfileScreen({super.key, this.isTab = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Edit Profile dialog ─────────────────────────────────────────────
  Future<void> _showEditProfile() async {
    final auth = context.read<AppAuthProvider>();
    final user = auth.userModel;
    if (user == null) return;

    final incomeCtrl =
        TextEditingController(text: user.monthlyIncome.toStringAsFixed(0));
    final budgetCtrl =
        TextEditingController(text: user.monthlyBudget.toStringAsFixed(0));
    final savingsCtrl =
        TextEditingController(text: user.savingsGoal.toStringAsFixed(0));
    final nameCtrl = TextEditingController(text: user.name);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Profile', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 20),
            _sheetField(nameCtrl, 'Full Name', Icons.person_outline),
            const SizedBox(height: 14),
            _sheetField(incomeCtrl, 'Monthly Income (₹)',
                Icons.attach_money_rounded,
                numeric: true),
            const SizedBox(height: 14),
            _sheetField(budgetCtrl, 'Monthly Budget (₹)',
                Icons.account_balance_wallet_outlined,
                numeric: true),
            const SizedBox(height: 14),
            _sheetField(savingsCtrl, 'Savings Goal (₹)',
                Icons.savings_outlined,
                numeric: true),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Save Changes',
              onTap: () async {
                await auth.updateProfile(
                  name: nameCtrl.text.trim(),
                  monthlyIncome:
                      double.tryParse(incomeCtrl.text) ?? user.monthlyIncome,
                  monthlyBudget:
                      double.tryParse(budgetCtrl.text) ?? user.monthlyBudget,
                  savingsGoal:
                      double.tryParse(savingsCtrl.text) ?? user.savingsGoal,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  AppSnackbar.showSuccess(context, 'Profile updated!');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Add Goal dialog ─────────────────────────────────────────────────
  Future<void> _showAddGoal() async {
    final uid = context.read<AppAuthProvider>().uid;
    if (uid == null) return;

    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    DateTime deadline = DateTime.now().add(const Duration(days: 90));
    String emoji = '🎯';
    const emojis = ['🎯', '🏠', '✈️', '📱', '🎓', '🚗', '💍', '🌟'];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Savings Goal',
                  style: AppTextStyles.headlineMedium),
              const SizedBox(height: 16),
              // Emoji picker
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: emojis
                      .map((e) => GestureDetector(
                            onTap: () => setS(() => emoji = e),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.only(right: 8),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: emoji == e
                                    ? AppColors.primary.withAlpha(30)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: emoji == e
                                      ? AppColors.primary
                                      : Colors.transparent,
                                ),
                              ),
                              child: Center(
                                  child: Text(e,
                                      style: const TextStyle(fontSize: 22))),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 14),
              _sheetField(nameCtrl, 'Goal Name', Icons.flag_outlined),
              const SizedBox(height: 14),
              _sheetField(amountCtrl, 'Target Amount (₹)',
                  Icons.savings_outlined,
                  numeric: true),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: deadline,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now()
                        .add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) setS(() => deadline = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Deadline: ${deadline.day}/${deadline.month}/${deadline.year}',
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Add Goal',
                onTap: () async {
                  if (nameCtrl.text.isEmpty || amountCtrl.text.isEmpty) {
                    return;
                  }
                  final goal = BudgetGoalModel(
                    id: const Uuid().v4(),
                    uid: uid,
                    goalName: nameCtrl.text.trim(),
                    targetAmount:
                        double.tryParse(amountCtrl.text) ?? 0,
                    deadline: deadline,
                    emoji: emoji,
                  );
                  await context
                      .read<BudgetProvider>()
                      .addGoal(goal);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    AppSnackbar.showSuccess(context, 'Goal added!');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Contribute dialog ───────────────────────────────────────────────
  Future<void> _contribute(BudgetGoalModel goal) async {
    final uid = context.read<AppAuthProvider>().uid;
    if (uid == null) return;
    final ctrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Contribute to ${goal.goalName}'),
        content: TextField(
          controller: ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
          ],
          decoration: const InputDecoration(
            labelText: 'Amount (₹)',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amt = double.tryParse(ctrl.text);
              if (amt != null && amt > 0) {
                await context
                    .read<BudgetProvider>()
                    .contribute(uid, goal, amt);
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                AppSnackbar.showSuccess(context, 'Contribution added!');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _sheetField(
      TextEditingController ctrl, String label, IconData icon,
      {bool numeric = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: numeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final expenses = context.watch<ExpenseProvider>();
    final budget = context.watch<BudgetProvider>();
    final themeNotifier = context.watch<ThemeNotifier>();
    final user = auth.userModel;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isTab,
        title: Text('Profile', style: AppTextStyles.headlineLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _showEditProfile,
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─ Profile Header ───────────────────────────────
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name,
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                )),
                            Text(user.email,
                                style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 20),

                    // ─ Income / budget pills ────────────────────────
                    Row(
                      children: [
                        _InfoPill(
                          icon: Icons.account_balance_outlined,
                          label: 'Income',
                          value: CurrencyUtils.formatRounded(
                              user.monthlyIncome),
                        ),
                        const SizedBox(width: 12),
                        _InfoPill(
                          icon: Icons.savings_outlined,
                          label: 'Goal',
                          value: CurrencyUtils.formatRounded(
                              user.savingsGoal),
                        ),
                      ],
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 20),

                    // ─ Budget progress ──────────────────────────────
                    BudgetProgressCard(
                      spent: expenses.monthTotal,
                      budget: user.monthlyBudget,
                    ).animate().fadeIn(delay: 150.ms),
                    const SizedBox(height: 20),

                    // ─ Savings Goals ────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Savings Goals',
                            style: AppTextStyles.headlineSmall),
                        TextButton.icon(
                          onPressed: _showAddGoal,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Goal'),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 8),

                    if (budget.goals.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                const Text('🎯',
                                    style: TextStyle(fontSize: 36)),
                                const SizedBox(height: 8),
                                Text('No goals yet',
                                    style: AppTextStyles.headlineSmall),
                                Text('Tap "Add Goal" to create one',
                                    style: AppTextStyles.bodyMedium),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 250.ms)
                    else
                      ...budget.goals.map((goal) => GoalCard(
                            goal: goal,
                            onContribute: () => _contribute(goal),
                            onDelete: () async {
                              final uid = auth.uid;
                              if (uid == null) return;
                              final budgetProvider =
                                  context.read<BudgetProvider>();
                              final messenger =
                                  ScaffoldMessenger.of(context);
                              await budgetProvider.deleteGoal(uid, goal.id);
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Goal deleted'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ).animate().fadeIn(delay: 200.ms)),

                    const SizedBox(height: 20),

                    // ─ Settings ─────────────────────────────────────
                    Card(
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.dark_mode_outlined,
                            label: AppStrings.darkMode,
                            trailing: Switch(
                              value: themeNotifier.isDark,
                              onChanged: themeNotifier.toggle,
                              activeThumbColor: AppColors.primary,
                            ),
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.notifications_outlined,
                            label: 'Notifications',
                            onTap: () {},
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.info_outline_rounded,
                            label: 'About SpendSmart',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 20),

                    // ─ Sign Out ──────────────────────────────────────
                    CustomButton(
                      label: 'Sign Out',
                      onTap: () async {
                        final authProvider = context.read<AppAuthProvider>();
                        final navigator = Navigator.of(context);
                        await authProvider.signOut();
                        navigator.pushNamedAndRemoveUntil(
                            AppRouter.login, (route) => false);
                      },
                      isOutlined: true,
                      icon: Icons.logout_rounded,
                      color: AppColors.error,
                    ).animate().fadeIn(delay: 350.ms),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withAlpha(40)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySmall),
                Text(value, style: AppTextStyles.labelLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: AppTextStyles.bodyLarge),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded,
          color: AppColors.textSecondary),
    );
  }
}
