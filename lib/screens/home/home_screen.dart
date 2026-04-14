import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/income_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../router/app_router.dart';
import '../analytics/analytics_screen.dart';
import '../goals/goals_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeTab(),
    AnalyticsScreen(isTab: true),
    SizedBox.shrink(), // placeholder for FAB
    GoalsScreen(isTab: true),
    ProfileScreen(isTab: true),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initData();
    });
  }

  void _initData() {
    final uid = context.read<AppAuthProvider>().uid;
    if (uid == null) return;
    context.read<ExpenseProvider>().listenToExpenses(uid);
    context.read<BudgetProvider>().listenToGoals(uid);
    context.read<IncomeProvider>().listenToIncomes(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRouter.addExpense),
        tooltip: 'Add Expense',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, AppStrings.home),
              _navItem(1, Icons.bar_chart_rounded, Icons.bar_chart_outlined,
                  AppStrings.analytics),
              const SizedBox(width: 56), // space for FAB
              _navItem(3, Icons.flag_rounded, Icons.outlined_flag_rounded,
                  AppStrings.goals),
              _navItem(4, Icons.person_rounded, Icons.person_outline,
                  AppStrings.profile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData active, IconData inactive, String label) {
    final selected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? active : inactive,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 24),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

// ─── Home Tab ────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final expenses = context.watch<ExpenseProvider>();
    final incomes = context.watch<IncomeProvider>();
    final goals = context.watch<BudgetProvider>().goals;
    final user = auth.userModel;
    final monthlyIncome = incomes.monthTotal;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(35),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset('logo.png'),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'PanamFlow',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.notifications),
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.tagline,
                  style: TextStyle(
                    color: Colors.white.withAlpha(240),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _MonthlySpendingCard(
            userName: user?.name ?? user?.email ?? 'User',
            monthSpent: expenses.monthTotal,
            monthBudget: user?.monthlyBudget ?? 0,
            todaySpent: expenses.todayTotal,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Income',
                  value: monthlyIncome,
                  color: Colors.green,
                  icon: Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'Expense',
                  value: expenses.monthTotal,
                  color: Colors.redAccent,
                  icon: Icons.trending_down_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const Icon(Icons.account_balance_wallet_outlined,
                  color: AppColors.primary),
              title: const Text('Monthly Budget'),
              subtitle: Text('₹${(user?.monthlyBudget ?? 0).toStringAsFixed(0)}'),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _showBudgetEditor(context, user?.monthlyBudget ?? 0),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRouter.addIncome),
                  child: const Text('Add Income'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRouter.addExpense),
                  child: const Text('Add Expense'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Goals Preview'),
            trailing: TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.goals),
              child: const Text('Open'),
            ),
          ),
          if (goals.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: const Text('No goals yet. Tap Open to create one.'),
            )
          else
            SizedBox(
              height: 108,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: goals.length > 5 ? 5 : goals.length,
                separatorBuilder: (_, index) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final g = goals[index];
                  final percent = (g.progressPercent * 100).toStringAsFixed(0);
                  return InkWell(
                    onTap: () => Navigator.pushNamed(context, AppRouter.goals),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 190,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withAlpha(70),
                        ),
                        color: Theme.of(context).colorScheme.primary.withAlpha(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.goalName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(value: g.progressPercent),
                          const SizedBox(height: 6),
                          Text(
                            '₹${g.currentAmount.toStringAsFixed(0)} / ₹${g.targetAmount.toStringAsFixed(0)} ($percent%)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Recent Expenses & Income'),
            trailing: TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.transactions),
              child: const Text('See all'),
            ),
          ),
          ...expenses.all.take(4).map((e) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.withAlpha(25),
                    child: const Icon(Icons.remove, color: Colors.red),
                  ),
                  title: Text(e.description),
                  subtitle: Text(e.category),
                  trailing: Text(
                    '- ₹${e.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w700),
                  ),
                ),
              )),
          ...incomes.all.take(4).map((i) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withAlpha(25),
                    child: const Icon(Icons.add, color: Colors.green),
                  ),
                  title: Text(i.source),
                  subtitle: Text(i.category),
                  trailing: Text(
                    '+ ₹${i.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.w700),
                  ),
                ),
              )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showBudgetEditor(BuildContext context, double current) {
    final ctrl = TextEditingController(text: current.toStringAsFixed(0));
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Monthly Budget'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await context.read<AppAuthProvider>().updateProfile(
                      monthlyBudget: double.tryParse(ctrl.text) ?? 0,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(AppRouter.home, (r) => false);
                }
              },
              child: const Text('Save Budget'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '₹${value.toStringAsFixed(0)}',
                style:
                    TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _MonthlySpendingCard extends StatelessWidget {
  final String userName;
  final double monthSpent;
  final double monthBudget;
  final double todaySpent;

  const _MonthlySpendingCard({
    required this.userName,
    required this.monthSpent,
    required this.monthBudget,
    required this.todaySpent,
  });

  String _money(double value, {bool decimals = false}) {
    final format = NumberFormat(decimals ? '#,##0.00' : '#,##0');
    return '₹${format.format(value)}';
  }

  @override
  Widget build(BuildContext context) {
    final usedRatio = monthBudget > 0 ? (monthSpent / monthBudget) : 0.0;
    final progress = usedRatio.clamp(0.0, 1.0);
    final balance = monthBudget - monthSpent;
    final isOverspent = balance < 0;
    final initials = userName.trim().isEmpty
        ? 'U'
        : userName.trim().split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $userName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withAlpha(220),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Monthly Spending',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _money(monthSpent, decimals: true),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: Colors.white.withAlpha(45),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1FE0CF)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Budget: ${_money(monthBudget)}',
                style: TextStyle(
                  color: Colors.white.withAlpha(210),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                isOverspent ? 'Overspent: ${_money(balance.abs())}' : 'Left: ${_money(balance)}',
                style: const TextStyle(
                  color: Color(0xFF67E8F9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _AmountTile(
                  title: 'Today',
                  value: _money(todaySpent),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AmountTile(
                  title: 'This Month',
                  value: _money(monthSpent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  final String title;
  final String value;

  const _AmountTile({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withAlpha(180),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
