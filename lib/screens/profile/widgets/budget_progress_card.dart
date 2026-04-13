import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';

class BudgetProgressCard extends StatelessWidget {
  final double spent;
  final double budget;

  const BudgetProgressCard({
    super.key,
    required this.spent,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final pct = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final remaining = budget - spent;
    final isOver = spent > budget;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Monthly Budget', style: AppTextStyles.headlineSmall),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOver
                        ? AppColors.error.withAlpha(25)
                        : AppColors.success.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOver ? '🔴 Over Budget' : '🟢 On Track',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isOver ? AppColors.error : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: CircularPercentIndicator(
                radius: 70,
                lineWidth: 14,
                percent: pct,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(pct * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.amountMedium.copyWith(
                        color: isOver ? AppColors.error : AppColors.primary,
                      ),
                    ),
                    Text('used', style: AppTextStyles.bodySmall),
                  ],
                ),
                progressColor:
                    isOver ? AppColors.error : AppColors.primary,
                backgroundColor: AppColors.primary.withAlpha(20),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 800,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _BudgetStat(
                    label: 'Spent',
                    value: CurrencyUtils.formatRounded(spent),
                    color: isOver ? AppColors.error : AppColors.primary,
                  ),
                ),
                Container(
                    height: 40, width: 1, color: AppColors.primary.withAlpha(20)),
                Expanded(
                  child: _BudgetStat(
                    label: isOver ? 'Over By' : 'Remaining',
                    value: CurrencyUtils.formatRounded(
                        isOver ? -remaining : remaining),
                    color: isOver ? AppColors.error : AppColors.success,
                  ),
                ),
                Container(
                    height: 40, width: 1, color: AppColors.primary.withAlpha(20)),
                Expanded(
                  child: _BudgetStat(
                    label: 'Budget',
                    value: CurrencyUtils.formatRounded(budget),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BudgetStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.labelLarge.copyWith(
                color: color, fontSize: 15),
            textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(label,
            style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
      ],
    );
  }
}
