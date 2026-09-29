import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/expense_service.dart';

class ExpenseSummaryChart extends StatelessWidget {
  final List<Expense> expenses;
  final String dateRange;
  final ValueChanged<String>? onCategorySelected;

  const ExpenseSummaryChart({
    super.key,
    required this.expenses,
    required this.dateRange,
    this.onCategorySelected,
  });

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFFFF9800);
      case 'transport':
        return const Color(0xFF2196F3);
      case 'shopping':
        return const Color(0xFF9C27B0);
      case 'bills':
        return const Color(0xFFE91E63);
      case 'entertainment':
        return const Color(0xFF673AB7);
      case 'health':
        return const Color(0xFF4CAF50);
      case 'education':
        return const Color(0xFF009688);
      default:
        return const Color(0xFF607D8B);
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt_long;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final expenseService = ExpenseService();
    final totalAmount = expenseService.calculateTotal(expenses);
    final categoryTotals = expenseService.calculateCategoryTotals(expenses);
    final categoryPercentages =
        expenseService.calculateCategoryPercentages(expenses);
    final topCategoryEntry = expenseService.getTopCategory(expenses);

    final sortedCategories = categoryTotals.keys.toList()
      ..sort((a, b) => (categoryTotals[b] ?? 0).compareTo(categoryTotals[a] ?? 0));

    final avgExpense =
        expenses.isNotEmpty ? (totalAmount / expenses.length) : 0.0;

    final emptyRingColor =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    'Spending Breakdown • $dateRange',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(200, 200),
                          painter: _DonutChartPainter(
                            categoryTotals: categoryTotals,
                            totalAmount: totalAmount,
                            emptyRingColor: emptyRingColor,
                          ),
                        ),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Total Spent',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rs. ${totalAmount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${expenses.length} transactions',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [

              Expanded(
                child: _InsightCard(
                  title: 'Top Category',
                  value: topCategoryEntry != null ? topCategoryEntry.key : 'N/A',
                  subtitle: topCategoryEntry != null
                      ? '${((topCategoryEntry.value / (totalAmount == 0 ? 1 : totalAmount)) * 100).toStringAsFixed(0)}% of total'
                      : '0%',
                  icon: topCategoryEntry != null
                      ? getCategoryIcon(topCategoryEntry.key)
                      : Icons.insights,
                  color: topCategoryEntry != null
                      ? getCategoryColor(topCategoryEntry.key)
                      : Colors.blueGrey,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: _InsightCard(
                  title: 'Average Spend',
                  value: 'Rs. ${avgExpense.toStringAsFixed(0)}',
                  subtitle: 'per transaction',
                  icon: Icons.calculate_outlined,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'Category Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedCategories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final category = sortedCategories[index];
              final amount = categoryTotals[category] ?? 0.0;
              final percentage = categoryPercentages[category] ?? 0.0;
              final color = getCategoryColor(category);
              final icon = getCategoryIcon(category);

              return InkWell(
                onTap: () => onCategorySelected?.call(category),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rs. ${amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (percentage / 100.0).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: color.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final Map<String, double> categoryTotals;
  final double totalAmount;
  final Color emptyRingColor;

  _DonutChartPainter({
    required this.categoryTotals,
    required this.totalAmount,
    required this.emptyRingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 22.0;

    final backgroundPaint = Paint()
      ..color = emptyRingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (totalAmount <= 0) return;

    var startAngle = -math.pi / 2;

    for (final entry in categoryTotals.entries) {
      final sweepAngle = (entry.value / totalAmount) * 2 * math.pi;
      final paint = Paint()
        ..color = ExpenseSummaryChart.getCategoryColor(entry.key)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.totalAmount != totalAmount ||
        oldDelegate.categoryTotals != categoryTotals ||
        oldDelegate.emptyRingColor != emptyRingColor;
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _InsightCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
