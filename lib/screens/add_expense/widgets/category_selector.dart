import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

class CategorySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const Map<String, String> _emojis = {
    'Food': '🍔',
    'Travel': '🚗',
    'Bills': '💡',
    'Shopping': '🛍️',
    'Health': '🩺',
    'Education': '📘',
    'Entertainment': '🎬',
    'Personal Care': '🧴',
    'Debt': '🤝',
    'Others': '💸',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AppStrings.categories.map((cat) {
        final isSelected = selected == cat;
        final color = AppColors.categoryColor(cat);
        return GestureDetector(
          onTap: () => onSelected(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : color.withAlpha(60),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: color.withAlpha(80),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_emojis[cat] ?? '💸',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  cat,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
