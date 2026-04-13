import '../../models/expense_model.dart';

class InsightEngine {
  InsightEngine._();

  /// Generate a list of human-readable insights from a list of expenses.
  static List<String> generateInsights({
    required List<ExpenseModel> thisWeek,
    required List<ExpenseModel> lastWeek,
    required List<ExpenseModel> thisMonth,
    required double monthlyBudget,
  }) {
    final insights = <String>[];

    // ── Budget insights ────────────────────────────────────────────────
    final monthTotal = _sum(thisMonth);
    if (monthlyBudget > 0) {
      final pct = (monthTotal / monthlyBudget) * 100;
      if (pct >= 90) {
        insights.add(
            '🚨 You\'ve used ${pct.toStringAsFixed(0)}% of your monthly budget.');
      } else if (pct >= 70) {
        insights.add(
            '⚠️ You\'ve used ${pct.toStringAsFixed(0)}% of your budget. Slow down a bit!');
      } else {
        insights.add(
            '✅ Great! You\'ve used only ${pct.toStringAsFixed(0)}% of your budget this month.');
      }
    }

    // ── Week-over-week comparison ──────────────────────────────────────
    final thisWkTotal = _sum(thisWeek);
    final lastWkTotal = _sum(lastWeek);
    if (lastWkTotal > 0 && thisWkTotal > 0) {
      final diff = ((thisWkTotal - lastWkTotal) / lastWkTotal) * 100;
      if (diff > 0) {
        insights.add(
            '📈 You spent ${diff.abs().toStringAsFixed(0)}% more this week compared to last week.');
      } else if (diff < 0) {
        insights.add(
            '📉 Great job! You spent ${diff.abs().toStringAsFixed(0)}% less this week than last week.');
      }
    }

    // ── Top category ──────────────────────────────────────────────────
    final catMap = _categoryTotals(thisMonth);
    if (catMap.isNotEmpty) {
      final topCat = catMap.entries.reduce((a, b) => a.value > b.value ? a : b);
      final topPct = (topCat.value / monthTotal * 100).toStringAsFixed(0);
      insights.add(
          '🍕 ${topCat.key} is your biggest expense this month ($topPct% of spending).');

      // Savings tip for top category
      final saving = topCat.value * 0.20;
      insights.add(
          '💡 Reducing ${topCat.key} by 20% could save you ₹${saving.toStringAsFixed(0)} per month!');
    }

    // ── Daily average ─────────────────────────────────────────────────
    if (thisMonth.isNotEmpty) {
      final days = _daysElapsedThisMonth();
      if (days > 0) {
        final avg = monthTotal / days;
        insights.add(
            '📊 Your daily average spend this month is ₹${avg.toStringAsFixed(0)}.');
      }
    }

    // ── Savings potential ─────────────────────────────────────────────
    if (monthlyBudget > 0 && monthTotal < monthlyBudget) {
      final leftover = monthlyBudget - monthTotal;
      insights.add(
          '💰 Keep going! You can save ₹${leftover.toStringAsFixed(0)} more this month.');
    }

    return insights.isEmpty
        ? ['Add your expenses to unlock smart insights! 🚀']
        : insights;
  }

  static double _sum(List<ExpenseModel> expenses) =>
      expenses.fold(0.0, (sum, e) => sum + e.amount);

  static Map<String, double> _categoryTotals(List<ExpenseModel> expenses) {
    final map = <String, double>{};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  static int _daysElapsedThisMonth() {
    final now = DateTime.now();
    return now.day;
  }
}
