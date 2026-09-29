import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final String initialCategory;
  final String initialDateRange;
  final void Function(String category, String dateRange)? onApply;
  final VoidCallback? onReset;

  const FilterBottomSheet({
    super.key,
    this.initialCategory = 'All',
    this.initialDateRange = 'Current Month',
    this.onApply,
    this.onReset,
  });

  static Future<Map<String, String>?> show(
    BuildContext context, {
    String selectedCategory = 'All',
    String selectedDateRange = 'Current Month',
    void Function(String category, String dateRange)? onApply,
    VoidCallback? onReset,
  }) {
    return showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialCategory: selectedCategory,
        initialDateRange: selectedDateRange,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedCategory;
  late String _selectedDateRange;

  static const List<String> _categories = [
    'All',
    'Food',
    'Transport',
    'Bills',
    'Shopping',
    'Health',
    'Other',
  ];

  static const List<String> _dateRanges = [
    'Current Month',
    'Today',
    'This Week',
    'Last Month',
    'All Time',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedDateRange = widget.initialDateRange;
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedDateRange = 'Current Month';
    });
    widget.onReset?.call();
  }

  void _applyFilters() {
    if (widget.onApply != null) {
      widget.onApply!(_selectedCategory, _selectedDateRange);
    }
    Navigator.of(context).pop({
      'category': _selectedCategory,
      'dateRange': _selectedDateRange,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 24.0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Expenses',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 18.0),

            Text(
              'Category',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 10.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return _CategoryChip(
                  label: category,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedCategory = category),
                );
              }).toList(),
            ),
            const SizedBox(height: 20.0),

            Text(
              'Date Range',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              initialValue: _selectedDateRange,
              dropdownColor: theme.cardColor,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 12.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                ),
              ),
              items: _dateRanges.map((range) {
                return DropdownMenuItem(
                  value: range,
                  child: Text(
                    range,
                    style: TextStyle(fontSize: 15.0, color: colorScheme.onSurface),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDateRange = value);
                }
              },
            ),
            const SizedBox(height: 24.0),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.0,
                    child: OutlinedButton(
                      onPressed: _resetFilters,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1565C0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: SizedBox(
                    height: 48.0,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Apply Filter',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? colorScheme.primary : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
