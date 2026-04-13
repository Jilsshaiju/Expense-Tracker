import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';

class SummaryCard extends StatelessWidget {
  final double todayTotal;
  final double monthTotal;
  final double monthlyBudget;
  final String userName;

  const SummaryCard({
    super.key,
    required this.todayTotal,
    required this.monthTotal,
    required this.monthlyBudget,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final remaining =
        monthlyBudget > 0 ? monthlyBudget - monthTotal : 0.0;
    final progress = monthlyBudget > 0
        ? (monthTotal / monthlyBudget).clamp(0.0, 1.0)
        : 0.0;
    final isOverBudget = monthlyBudget > 0 && monthTotal > monthlyBudget;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, ${userName.split(' ').first} 👋',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.white70)),
                  const SizedBox(height: 2),
                  Text('Monthly Spending',
                      style: AppTextStyles.headlineSmall
                          .copyWith(color: Colors.white)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                    size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            CurrencyUtils.format(monthTotal),
            style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -1),
          ),
          if (monthlyBudget > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withAlpha(40),
                valueColor: AlwaysStoppedAnimation<Color>(
                    isOverBudget ? AppColors.error : AppColors.accentLight),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget: ${CurrencyUtils.formatRounded(monthlyBudget)}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: Colors.white70),
                ),
                Text(
                  isOverBudget
                      ? 'Over by ${CurrencyUtils.formatRounded(-remaining)}'
                      : 'Left: ${CurrencyUtils.formatRounded(remaining)}',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: isOverBudget
                          ? AppColors.error
                          : AppColors.accentLight),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _statPill('Today', CurrencyUtils.formatRounded(todayTotal)),
              const SizedBox(width: 10),
              _statPill('This Month',
                  CurrencyUtils.formatRounded(monthTotal)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1);
  }

  Widget _statPill(String label, String value) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.white60)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
