import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/insight_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';

import 'widgets/expense_card.dart';
import 'widgets/summary_card.dart';
import 'widgets/insight_chip.dart';
import '../add_expense/add_expense_screen.dart';
import '../analytics/analytics_screen.dart';
import '../goals/goals_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/widgets/app_snackbar.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers — recompute insights in a post-frame callback
    // to avoid calling notifyListeners() during build.
    final expProvider = context.watch<ExpenseProvider>();
    final authProvider = context.watch<AppAuthProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightProvider>().recompute(
            thisWeek: expProvider.thisWeek,
            lastWeek: expProvider.lastWeek,
            thisMonth: expProvider.thisMonth,
            monthlyBudget: authProvider.userModel?.monthlyBudget ?? 0,
          );
    });

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const AddExpenseScreen(),
              transitionsBuilder:
                  (context, anim, secondaryAnimation, child) => SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0, 1), end: Offset.zero)
                    .animate(
                        CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 320),
            ),
          );
        },
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
    final insights = context.watch<InsightProvider>();
    final user = auth.userModel;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {},
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: Text(AppStrings.appName,
                  style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.primary)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Row(
                  children: [
                    Image.asset(
                      'logo.png',
                      width: 36,
                      height: 36,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppStrings.tagline,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SummaryCard(
                todayTotal: expenses.todayTotal,
                monthTotal: expenses.monthTotal,
                monthlyBudget: user?.monthlyBudget ?? 0,
                userName: user?.name ?? 'User',
              ),
            ),
            // Insights Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(AppStrings.insights,
                        style: AppTextStyles.headlineSmall),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 68,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: insights.insights.length,
                  itemBuilder: (_, i) =>
                      InsightChip(text: insights.insights[i]),
                ),
              ),
            ),
            // Recent Expenses
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Expenses',
                        style: AppTextStyles.headlineSmall),
                    if (expenses.all.isNotEmpty)
                      TextButton(
                        onPressed: () {},
                        child: const Text('See all'),
                      ),
                  ],
                ),
              ),
            ),
            if (expenses.isLoading)
              const SliverToBoxAdapter(
                  child: Center(
                      child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator())))
            else if (expenses.all.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Text('💸', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('No expenses yet',
                            style: AppTextStyles.headlineSmall),
                        const SizedBox(height: 4),
                        Text('Tap + to add your first expense',
                            style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final exp = expenses.all[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ExpenseCard(
                        expense: exp,
                        onDelete: () async {
                          final uid = auth.uid;
                          if (uid == null) return;
                          await context
                              .read<ExpenseProvider>()
                              .deleteExpense(uid, exp.id);
                          if (context.mounted) {
                            AppSnackbar.showSuccess(
                                context, 'Expense deleted');
                          }
                        },
                      ),
                    );
                  },
                  childCount: expenses.all.length > 20
                      ? 20
                      : expenses.all.length,
                ),
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }
}
