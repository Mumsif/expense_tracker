import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/models/expense.dart';

class ExpenseService {

  static final ExpenseService _instance = ExpenseService._internal();
  factory ExpenseService() => _instance;
  ExpenseService._internal();

  CollectionReference<Map<String, dynamic>> get _expensesRef {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('expenses');
    }
    return FirebaseFirestore.instance.collection('expenses');
  }

  Stream<List<Expense>> getExpensesStream() {
    return _expensesRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Expense.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> addExpense(Expense expense) async {
    await _expensesRef.doc(expense.id).set(expense.toMap());
  }

  Future<void> updateExpense(Expense expense) async {
    await _expensesRef.doc(expense.id).update(expense.toMap());
  }

  Future<void> deleteExpense(String id) async {
    await _expensesRef.doc(id).delete();
  }

  double calculateTotal(List<Expense> expenses) {
    return expenses.fold(0.0, (total, expense) => total + expense.amount);
  }

  double calculateCurrentMonthTotal(List<Expense> expenses) {
    final now = DateTime.now();
    return calculateMonthTotal(expenses, year: now.year, month: now.month);
  }

  double calculateMonthTotal(List<Expense> expenses, {required int year, required int month}) {
    return expenses
        .where((e) => e.date.year == year && e.date.month == month)
        .fold(0.0, (total, expense) => total + expense.amount);
  }

  List<Expense> filterByCategory(List<Expense> expenses, String selectedCategory) {
    if (selectedCategory.isEmpty || selectedCategory.toLowerCase() == 'all') {
      return expenses;
    }

    return expenses
        .where((expense) =>
            expense.category.toLowerCase() == selectedCategory.toLowerCase())
        .toList();
  }

  List<Expense> filterByDateRange(List<Expense> expenses, String dateRange) {
    if (dateRange.isEmpty || dateRange == 'All Time') {
      return expenses;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (dateRange) {
      case 'Today':
        return expenses.where((e) {
          return e.date.year == today.year &&
              e.date.month == today.month &&
              e.date.day == today.day;
        }).toList();

      case 'This Week':

        final monday = today.subtract(Duration(days: today.weekday - 1));
        final nextMonday = monday.add(const Duration(days: 7));
        return expenses.where((e) {
          return !e.date.isBefore(monday) && e.date.isBefore(nextMonday);
        }).toList();

      case 'Current Month':
        return expenses.where((e) {
          return e.date.year == now.year && e.date.month == now.month;
        }).toList();

      case 'Last Month':
        final lastMonthDate = DateTime(now.year, now.month - 1, 1);
        return expenses.where((e) {
          return e.date.year == lastMonthDate.year &&
              e.date.month == lastMonthDate.month;
        }).toList();

      default:
        return expenses;
    }
  }

  List<Expense> searchExpenses(List<Expense> expenses, String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return expenses;
    }

    return expenses.where((expense) {
      final matchesTitle = expense.title.toLowerCase().contains(cleanQuery);
      final matchesNote = expense.note != null &&
          expense.note!.toLowerCase().contains(cleanQuery);
      return matchesTitle || matchesNote;
    }).toList();
  }

  List<Expense> filterExpenses(
    List<Expense> expenses, {
    String selectedCategory = 'All',
    String selectedDateRange = 'Current Month',
    String searchQuery = '',
  }) {
    var result = filterByCategory(expenses, selectedCategory);
    result = filterByDateRange(result, selectedDateRange);
    result = searchExpenses(result, searchQuery);
    return result;
  }

  Map<String, double> calculateCategoryTotals(List<Expense> expenses) {
    final Map<String, double> totals = {};
    for (final expense in expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0.0) + expense.amount;
    }
    return totals;
  }

  Map<String, double> calculateCategoryPercentages(List<Expense> expenses) {
    final totals = calculateCategoryTotals(expenses);
    final overallTotal = calculateTotal(expenses);
    if (overallTotal == 0.0) return {};

    final Map<String, double> percentages = {};
    totals.forEach((category, amount) {
      percentages[category] = (amount / overallTotal) * 100.0;
    });
    return percentages;
  }

  MapEntry<String, double>? getTopCategory(List<Expense> expenses) {
    final totals = calculateCategoryTotals(expenses);
    if (totals.isEmpty) return null;

    MapEntry<String, double>? top;
    for (final entry in totals.entries) {
      if (top == null || entry.value > top.value) {
        top = entry;
      }
    }
    return top;
  }
}

