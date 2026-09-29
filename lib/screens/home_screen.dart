import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/widgets/empty_state.dart';
import 'package:expense_tracker/widgets/error_view.dart';
import 'package:expense_tracker/widgets/expense_card.dart';
import 'package:expense_tracker/widgets/expense_summary_chart.dart';
import 'package:expense_tracker/widgets/loading_view.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'add_edit_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final ExpenseService _expenseService = ExpenseService();
  final AuthService _authService = AuthService();

  int _currentTabIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedDateRange = 'Current Month';

  static const List<String> _categories = [
    'All',
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addExpense() async {
    final newExpense = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditExpenseScreen(),
      ),
    );

    if (newExpense != null) {
      try {
        await _expenseService.addExpense(newExpense);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Expense added successfully!'),
                ],
              ),
              backgroundColor: Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add expense: $e'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _editExpense(Expense expense) async {
    final updated = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExpenseScreen(expense: expense),
      ),
    );
    if (updated != null) {
      try {
        await _expenseService.updateExpense(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Expense updated successfully!'),
                ],
              ),
              backgroundColor: Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update expense: $e'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteExpense(Expense expense) async {
    try {
      await _expenseService.deleteExpense(expense.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${expense.title}"'),
            backgroundColor: const Color(0xFF323232),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Undo',
              textColor: const Color(0xFF90CAF9),
              onPressed: () async {
                try {
                  await _expenseService.addExpense(expense);
                } catch (_) {}
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete expense: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedDateRange = 'Current Month';
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _openDateRangePicker() {
    final ranges = [
      'Today',
      'This Week',
      'Current Month',
      'Last Month',
      'All Time',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Spending Period',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ...ranges.map((range) {
                  final isSelected = _selectedDateRange == range;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    selected: isSelected,
                    selectedTileColor:
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                    leading: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey,
                    ),
                    title: Text(
                      range,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : null,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedDateRange = range;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Sign Out'),
          ],
        ),
        content: Text(
          _authService.isAnonymous
              ? 'Are you sure you want to end your guest session? You will return to the sign-in screen.'
              : 'Are you sure you want to sign out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<List<Expense>>(
      stream: _expenseService.getExpensesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Expense Tracker')),
            body: ErrorView(
              title: 'Failed to load expenses',
              message: '${snapshot.error}',
              onRetry: () => setState(() {}),
            ),
          );
        }

        final allExpenses = snapshot.data ?? [];
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData;

        final periodExpenses = _expenseService.filterByDateRange(
          allExpenses,
          _selectedDateRange,
        );

        final displayedExpenses = _expenseService.filterExpenses(
          allExpenses,
          selectedCategory: _selectedCategory,
          selectedDateRange: _selectedDateRange,
          searchQuery: _searchQuery,
        );

        return Scaffold(

          appBar: _buildAppBar(theme, colorScheme),

          body: isLoading
              ? const LoadingView(message: 'Loading your expenses...')
              : _buildTabContent(
                  allExpenses: allExpenses,
                  periodExpenses: periodExpenses,
                  displayedExpenses: displayedExpenses,
                  theme: theme,
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),

          floatingActionButton: FloatingActionButton(
            onPressed: _addExpense,
            elevation: 4,
            shape: const CircleBorder(),
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            tooltip: 'Add Expense',
            child: const Icon(Icons.add_rounded, size: 28),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,

          bottomNavigationBar: _buildBottomAppBar(theme, colorScheme, isDark),
        );
      },
    );
  }

  AppBar _buildAppBar(ThemeData theme, ColorScheme colorScheme) {
    switch (_currentTabIndex) {
      case 0:
        return AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expense Tracker',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Dashboard & Expenses',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                themeNotifier.isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: Colors.white,
              ),
              tooltip: themeNotifier.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
              onPressed: () => setState(() => themeNotifier.toggleTheme()),
            ),
          ],
        );
      case 1:
        return AppBar(
          title: const Text(
            'Spending Analytics',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            TextButton.icon(
              onPressed: _openDateRangePicker,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              icon: const Icon(Icons.calendar_today_rounded, size: 14),
              label: Text(
                _selectedDateRange,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        );
      case 2:
        return AppBar(
          title: const Text(
            'Search & Filter',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            if (_selectedCategory != 'All' ||
                _selectedDateRange != 'Current Month' ||
                _searchQuery.isNotEmpty)
              TextButton(
                onPressed: _resetFilters,
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        );
      case 3:
      default:
        return AppBar(
          title: const Text(
            'My Account',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        );
    }
  }

  Widget _buildTabContent({
    required List<Expense> allExpenses,
    required List<Expense> periodExpenses,
    required List<Expense> displayedExpenses,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    switch (_currentTabIndex) {
      case 0:
        return _buildHomeTab(
          allExpenses: allExpenses,
          periodExpenses: periodExpenses,
          displayedExpenses: displayedExpenses,
          theme: theme,
          colorScheme: colorScheme,
          isDark: isDark,
        );
      case 1:
        return _buildAnalyticsTab(
          expenses: periodExpenses,
          theme: theme,
          colorScheme: colorScheme,
          isDark: isDark,
        );
      case 2:
        return _buildSearchAndFilterTab(
          allExpenses: allExpenses,
          displayedExpenses: displayedExpenses,
          theme: theme,
          colorScheme: colorScheme,
          isDark: isDark,
        );
      case 3:
      default:
        return _buildAccountTab(
          theme: theme,
          colorScheme: colorScheme,
          isDark: isDark,
        );
    }
  }

  Widget _buildHomeTab({
    required List<Expense> allExpenses,
    required List<Expense> periodExpenses,
    required List<Expense> displayedExpenses,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final periodTotal = _expenseService.calculateTotal(periodExpenses);
    final avgPerDay = periodExpenses.isNotEmpty
        ? (periodTotal / (periodExpenses.length.clamp(1, 999)))
        : 0.0;

    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        children: [

          _buildHeroBalanceCard(
            periodTotal: periodTotal,
            transactionCount: periodExpenses.length,
            dailyAvg: avgPerDay,
            isDark: isDark,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 18),

          _buildCategoryFilterPills(theme, colorScheme, isDark),
          const SizedBox(height: 14),

          if (_selectedCategory != 'All' ||
              _selectedDateRange != 'Current Month' ||
              _searchQuery.isNotEmpty)
            _buildActiveFilterChips(theme, colorScheme),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  '${displayedExpenses.length} items',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          if (displayedExpenses.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: EmptyState(
                title: _searchQuery.isNotEmpty
                    ? "No Matching Expenses"
                    : (_selectedCategory == 'All' &&
                            _selectedDateRange == 'Current Month')
                        ? "No Expenses This Month"
                        : "No Expenses Found",
                message: _searchQuery.isNotEmpty
                    ? "No expenses matched \"$_searchQuery\"."
                    : (_selectedCategory == 'All' &&
                            _selectedDateRange == 'Current Month')
                        ? "Tap the + button below to log your first transaction."
                        : "No expenses recorded for $_selectedCategory in $_selectedDateRange.",
                icon: _searchQuery.isNotEmpty
                    ? Icons.search_off_rounded
                    : Icons.receipt_long_rounded,

                actionText: null,
                onAction: null,
              ),
            )
          else
            ...displayedExpenses.map(
              (expense) => ExpenseCard(
                expense: expense,
                onTap: () => _editExpense(expense),
                onEdit: () => _editExpense(expense),
                onDelete: () => _deleteExpense(expense),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroBalanceCard({
    required double periodTotal,
    required int transactionCount,
    required double dailyAvg,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0D47A1), const Color(0xFF1565C0)]
              : [const Color(0xFF1565C0), const Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Total Spending',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              InkWell(
                onTap: _openDateRangePicker,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedDateRange,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down,
                          color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            'Rs. ${periodTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_rounded,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '$transactionCount Transactions',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 16,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Row(
                  children: [
                    const Icon(Icons.show_chart_rounded,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Avg: Rs. ${dailyAvg.toStringAsFixed(0)}/tx',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterPills(
      ThemeData theme, ColorScheme colorScheme, bool isDark) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedCategory = cat;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : (isDark
                        ? const Color(0xFF262626)
                        : const Color(0xFFF1F3F5)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : (isDark
                          ? const Color(0xFF383838)
                          : const Color(0xFFE2E8F0)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(cat),
                    size: 15,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveFilterChips(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (_selectedCategory != 'All')
                  InputChip(
                    label: Text('Category: $_selectedCategory'),
                    visualDensity: VisualDensity.compact,
                    onDeleted: () => setState(() => _selectedCategory = 'All'),
                  ),
                if (_selectedDateRange != 'Current Month')
                  InputChip(
                    label: Text('Period: $_selectedDateRange'),
                    visualDensity: VisualDensity.compact,
                    onDeleted: () =>
                        setState(() => _selectedDateRange = 'Current Month'),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Reset',
                style: TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab({
    required List<Expense> expenses,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return ExpenseSummaryChart(
      expenses: expenses,
      dateRange: _selectedDateRange,
      onCategorySelected: (cat) {
        setState(() {
          _selectedCategory = cat;
          _currentTabIndex = 0;
        });
      },
    );
  }

  Widget _buildSearchAndFilterTab({
    required List<Expense> allExpenses,
    required List<Expense> displayedExpenses,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [

        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search title, merchant, or notes...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: isDark ? const Color(0xFF222222) : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (val) => setState(() => _searchQuery = val),
        ),
        const SizedBox(height: 18),

        const Text(
          'Date Period',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            'Today',
            'This Week',
            'Current Month',
            'Last Month',
            'All Time'
          ].map((period) {
            final isSelected = _selectedDateRange == period;
            return ChoiceChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedDateRange = period),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        const Text(
          'Category',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return FilterChip(
              avatar: Icon(
                _getCategoryIcon(cat),
                size: 15,
                color: isSelected ? Colors.white : colorScheme.primary,
              ),
              label: Text(cat),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = cat),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Search Results',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              '${displayedExpenses.length} matches found',
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (displayedExpenses.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24.0),
            child: EmptyState(
              title: "No Results Found",
              message: "Try searching with a different term or adjust the filters above.",
              icon: Icons.filter_alt_off_rounded,
            ),
          )
        else
          ...displayedExpenses.map(
            (expense) => ExpenseCard(
              expense: expense,
              onTap: () => _editExpense(expense),
              onEdit: () => _editExpense(expense),
              onDelete: () => _deleteExpense(expense),
            ),
          ),
      ],
    );
  }

  Widget _buildAccountTab({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final user = _authService.currentUser;
    final isDemo = _authService.demoModeNotifier.value;
    final isGuest = _authService.isAnonymous || isDemo;
    final email = user?.email ?? (isDemo ? 'Demo Mode User' : (isGuest ? 'Guest Session' : 'User Account'));

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                child: Icon(
                  isGuest ? Icons.person_outline_rounded : Icons.person_rounded,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGuest ? 'Guest Session' : 'Active Account',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isGuest ? Colors.amber : Colors.green)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isGuest ? 'Temporary Session' : 'Firebase Synced',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isGuest
                              ? (isDark ? Colors.amberAccent : Colors.orange[800])
                              : (isDark ? Colors.greenAccent : Colors.green[800]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Text(
            'Appearance',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SwitchListTile(
            secondary: Icon(
              themeNotifier.isDarkMode
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              color: colorScheme.primary,
            ),
            title: const Text('Dark Mode'),
            subtitle: Text(themeNotifier.isDarkMode ? 'Dark Theme Active' : 'Light Theme Active'),
            value: themeNotifier.isDarkMode,
            onChanged: (_) => setState(() => themeNotifier.toggleTheme()),
          ),
        ),
        const SizedBox(height: 24),

        ElevatedButton.icon(
          onPressed: _confirmSignOut,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent.withValues(alpha: 0.12),
            foregroundColor: Colors.redAccent,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
          ),
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text(
            'Sign Out',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAppBar(
      ThemeData theme, ColorScheme colorScheme, bool isDark) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: theme.cardColor,
      elevation: 10,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            _buildNavTabItem(
              tabIndex: 0,
              icon: Icons.wallet_rounded,
              label: 'Expenses',
              colorScheme: colorScheme,
              theme: theme,
            ),

            _buildNavTabItem(
              tabIndex: 1,
              icon: Icons.donut_large_rounded,
              label: 'Analytics',
              colorScheme: colorScheme,
              theme: theme,
            ),

            const SizedBox(width: 48),

            _buildNavTabItem(
              tabIndex: 2,
              icon: Icons.search_rounded,
              label: 'Search',
              colorScheme: colorScheme,
              theme: theme,
            ),

            _buildNavTabItem(
              tabIndex: 3,
              icon: Icons.person_rounded,
              label: 'Account',
              colorScheme: colorScheme,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTabItem({
    required int tabIndex,
    required IconData icon,
    required String label,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    final isSelected = _currentTabIndex == tabIndex;

    return InkWell(
      onTap: () => setState(() => _currentTabIndex = tabIndex),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? colorScheme.primary
                  : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? colorScheme.primary
                    : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'health':
        return Icons.medical_services_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
