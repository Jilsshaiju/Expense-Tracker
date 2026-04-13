import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_utils.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, double> categoryTotals;

  const PieChartWidget({super.key, required this.categoryTotals});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categoryTotals.isEmpty ||
        widget.categoryTotals.values.every((v) => v == 0)) {
      return _buildEmpty();
    }

    final total =
        widget.categoryTotals.values.fold(0.0, (a, b) => a + b);
    final entries = widget.categoryTotals.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse
                        .touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sectionsSpace: 3,
              centerSpaceRadius: 52,
              sections: List.generate(entries.length, (i) {
                final cat = entries[i].key;
                final val = entries[i].value;
                final pct = total > 0 ? val / total * 100 : 0.0;
                final isTouched = i == _touchedIndex;
                return PieChartSectionData(
                  color: AppColors.categoryColor(cat),
                  value: val,
                  title: '${pct.toStringAsFixed(0)}%',
                  radius: isTouched ? 72 : 60,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                  badgeWidget: isTouched
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.categoryColor(cat),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withAlpha(40),
                                  blurRadius: 4)
                            ],
                          ),
                          child: Text(
                            CurrencyUtils.formatRounded(val),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      : null,
                  badgePositionPercentageOffset: 1.1,
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: entries.map((e) {
            final color = AppColors.categoryColor(e.key);
            final pct =
                total > 0 ? (e.value / total * 100).toStringAsFixed(0) : '0';
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text('${e.key} ($pct%)',
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w500)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📊', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text('No data available',
                style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
