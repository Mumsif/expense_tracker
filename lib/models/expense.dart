
class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String? note;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.category = 'General',
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      if (note != null) 'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parsedDate;
    final dynamic rawDate = map['date'];

    if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate != null && rawDate.runtimeType.toString().contains('Timestamp')) {
      parsedDate = (rawDate as dynamic).toDate() as DateTime;
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Expense(
      id: docId ?? map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: parsedDate,
      category: map['category'] as String? ?? 'General',
      note: map['note'] as String?,
    );
  }

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }
}
