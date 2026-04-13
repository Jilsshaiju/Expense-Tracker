import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/expense_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.categoryColor(expense.category);
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: catColor.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(_categoryEmoji(expense.category),
                style: const TextStyle(fontSize: 22)),
          ),
        ),
        title: Text(expense.description,
            style: AppTextStyles.headlineSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: catColor.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                expense.category,
                style: TextStyle(
                    fontSize: 11,
                    color: catColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppDateUtils.relativeLabel(expense.date),
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyUtils.formatRounded(expense.amount),
              style: AppTextStyles.amountMedium.copyWith(
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline,
                    size: 20, color: AppColors.error),
              ),
            ]
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05);
  }

  String _categoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return '🍔';
      case 'travel':
        return '🚗';
      case 'bills':
        return '💡';
      case 'shopping':
        return '🛍️';
      default:
        return '💸';
    }
  }
}
