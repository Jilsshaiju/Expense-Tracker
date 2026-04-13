import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/expense_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_utils.dart';
import 'widgets/pie_chart_widget.dart';
import 'widgets/bar_chart_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  final bool isTab;

  const AnalyticsScreen({super.key, this.isTab = false});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isTab,
        title: Text('Analytics', style: AppTextStyles.headlineLarge),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: AppTextStyles.labelLarge,
          tabs: const [
            Tab(text: AppStrings.daily),
            Tab(text: AppStrings.weekly),
            Tab(text: AppStrings.monthly),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Daily View ─────────────────────────────────────────
          _AnalyticsView(
            expenses: expenses,
            mode: 'daily',
          ),
          // ── Weekly View ────────────────────────────────────────
          _AnalyticsView(
            expenses: expenses,
            mode: 'weekly',
          ),
          // ── Monthly View ───────────────────────────────────────
          _AnalyticsView(
            expenses: expenses,
            mode: 'monthly',
          ),
        ],
      ),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  final ExpenseProvider expenses;
  final String mode;

  const _AnalyticsView({required this.expenses, required this.mode});

  @override
  Widget build(BuildContext context) {
    final list = switch (mode) {
      'daily' => expenses.today,
      'weekly' => expenses.thisWeek,
      _ => expenses.thisMonth,
    };

    final barData = switch (mode) {
      'weekly' => expenses.weeklyDayTotals,
      'monthly' => expenses.monthlyTrend,
      _ => _buildDailyHourlyMap(),
    };

    final total = list.fold(0.0, (s, e) => s + e.amount);

    // Category totals from filtered list
    final catTotals = <String, double>{};
    for (final e in list) {
      catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary row
          _SummaryRow(
            total: total,
            count: list.length,
            avgPerItem: list.isNotEmpty ? total / list.length : 0,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),

          // Pie chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.spendingByCategory,
                      style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 16),
                  PieChartWidget(categoryTotals: catTotals),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),
          const SizedBox(height: 16),

          // Bar chart
          if (mode != 'daily')
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: BarChartWidget(
                  data: barData,
                  title: mode == 'weekly'
                      ? 'This Week Day-by-Day'
                      : 'Last 6 Months',
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),

          const SizedBox(height: 16),

          // Category breakdown table
          if (catTotals.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category Breakdown',
                        style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 12),
                    ...catTotals.entries.map((e) => _CategoryRow(
                          category: e.key,
                          amount: e.value,
                          total: total,
                        )),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ],
      ),
    );
  }

  Map<String, double> _buildDailyHourlyMap() => {};
}

class _SummaryRow extends StatelessWidget {
  final double total;
  final int count;
  final double avgPerItem;

  const _SummaryRow({
    required this.total,
    required this.count,
    required this.avgPerItem,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
            label: 'Total Spent',
            value: CurrencyUtils.formatRounded(total),
            icon: Icons.arrow_upward_rounded,
            color: AppColors.error),
        const SizedBox(width: 12),
        _StatCard(
            label: 'Transactions',
            value: count.toString(),
            icon: Icons.receipt_long_outlined,
            color: AppColors.primary),
        const SizedBox(width: 12),
        _StatCard(
            label: 'Avg per tx',
            value: CurrencyUtils.formatRounded(avgPerItem),
            icon: Icons.analytics_outlined,
            color: AppColors.accent),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(value,
                style: AppTextStyles.headlineSmall
                    .copyWith(color: color, fontSize: 15)),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String category;
  final double amount;
  final double total;

  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? amount / total : 0.0;
    final color = AppColors.categoryColor(category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(category, style: AppTextStyles.bodyLarge),
              const Spacer(),
              Text(
                '${(pct * 100).toStringAsFixed(1)}%',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Text(CurrencyUtils.formatRounded(amount),
                  style: AppTextStyles.labelLarge.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withAlpha(25),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}
