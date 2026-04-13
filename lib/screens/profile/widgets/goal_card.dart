import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../models/budget_goal_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';

class GoalCard extends StatelessWidget {
  final BudgetGoalModel goal;
  final VoidCallback? onContribute;
  final VoidCallback? onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    this.onContribute,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = goal.isCompleted ? AppColors.success : AppColors.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Text(goal.emoji,
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.goalName,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Due: ${AppDateUtils.toDisplay(goal.deadline)}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (goal.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('✅ Done',
                        style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Progress bar
            LinearPercentIndicator(
              lineHeight: 8,
              percent: goal.progressPercent,
              backgroundColor: color.withAlpha(25),
              progressColor: color,
              barRadius: const Radius.circular(8),
              animation: true,
              animationDuration: 700,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 10),

            // Amount row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${CurrencyUtils.formatRounded(goal.currentAmount)} saved',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: color),
                ),
                Text(
                  'Goal: ${CurrencyUtils.formatRounded(goal.targetAmount)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action buttons
            if (!goal.isCompleted)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onContribute,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Contribute',
                          style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side:
                            const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: AppColors.error),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
