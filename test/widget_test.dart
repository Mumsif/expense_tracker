import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/widgets/empty_state.dart';

void main() {
  group('Expense Model Tests', () {
    test('Expense creation and toMap conversion', () {
      final now = DateTime(2026, 3, 15, 10, 30);
      final expense = Expense(
        id: 'exp_1',
        title: 'Lunch',
        amount: 250.0,
        date: now,
        category: 'Food',
        note: 'Team meal',
      );

      final map = expense.toMap();
      expect(map['id'], 'exp_1');
      expect(map['title'], 'Lunch');
      expect(map['amount'], 250.0);
      expect(map['date'], now.toIso8601String());
      expect(map['category'], 'Food');
      expect(map['note'], 'Team meal');
    });

    test('Expense fromMap parsing', () {
      final map = {
        'id': 'exp_2',
        'title': 'Taxi',
        'amount': 450.0,
        'date': '2026-03-20T14:00:00.000',
        'category': 'Transport',
      };

      final expense = Expense.fromMap(map, 'exp_2');
      expect(expense.id, 'exp_2');
      expect(expense.title, 'Taxi');
      expect(expense.amount, 450.0);
      expect(expense.category, 'Transport');
      expect(expense.note, isNull);
    });

    test('Expense copyWith immutability', () {
      final expense = Expense(
        id: 'exp_3',
        title: 'Groceries',
        amount: 1200.0,
        date: DateTime.now(),
        category: 'Shopping',
      );

      final updated = expense.copyWith(amount: 1500.0, title: 'Supermarket');
      expect(updated.id, 'exp_3');
      expect(updated.title, 'Supermarket');
      expect(updated.amount, 1500.0);
      expect(updated.category, 'Shopping');
    });
  });

  group('ExpenseService Business Logic Tests', () {
    final service = ExpenseService();
    final sampleExpenses = [
      Expense(
        id: '1',
        title: 'Burger',
        amount: 300.0,
        date: DateTime(2026, 3, 10),
        category: 'Food',
      ),
      Expense(
        id: '2',
        title: 'Uber Ride',
        amount: 500.0,
        date: DateTime(2026, 3, 12),
        category: 'Transport',
      ),
      Expense(
        id: '3',
        title: 'Coffee',
        amount: 200.0,
        date: DateTime(2026, 3, 15),
        category: 'Food',
        note: 'Espresso',
      ),
    ];

    test('calculateTotal sums correctly', () {
      final total = service.calculateTotal(sampleExpenses);
      expect(total, 1000.0);
    });

    test('filterByCategory returns matched category only', () {
      final foodExpenses = service.filterByCategory(sampleExpenses, 'Food');
      expect(foodExpenses.length, 2);
      expect(foodExpenses.every((e) => e.category == 'Food'), isTrue);

      final allExpenses = service.filterByCategory(sampleExpenses, 'All');
      expect(allExpenses.length, 3);
    });

    test('searchExpenses matches title and notes case-insensitively', () {
      final results = service.searchExpenses(sampleExpenses, 'burger');
      expect(results.length, 1);
      expect(results.first.title, 'Burger');

      final noteResults = service.searchExpenses(sampleExpenses, 'espresso');
      expect(noteResults.length, 1);
      expect(noteResults.first.id, '3');
    });

    test('calculateCategoryTotals computes exact group sums', () {
      final totals = service.calculateCategoryTotals(sampleExpenses);
      expect(totals['Food'], 500.0);
      expect(totals['Transport'], 500.0);
    });
  });

  group('Widget Tests', () {
    testWidgets('EmptyState renders title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'No Expenses Found',
              message: 'Try adding an expense.',
            ),
          ),
        ),
      );

      expect(find.text('No Expenses Found'), findsOneWidget);
      expect(find.text('Try adding an expense.'), findsOneWidget);
    });
  });
}
