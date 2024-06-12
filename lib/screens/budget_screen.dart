import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  double currentBalance = 0.0;
  double estimatedMonthlyExpenses = 0.0;
  Map<DateTime, List<Transaction>> dailyTransactions = {};
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    // Load balance and estimated expenses from Firestore
    firestore.DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('budget')
        .doc('info')
        .get();
    if (doc.exists) {
      setState(() {
        currentBalance = doc['currentBalance'] ?? 0.0;
        estimatedMonthlyExpenses = doc['estimatedMonthlyExpenses'] ?? 0.0;
      });
    }

    // Load transactions from Firestore
    firestore.QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('transactions')
        .get();
    for (var doc in querySnapshot.docs) {
      DateTime date = (doc['date'] as firestore.Timestamp).toDate();
      Transaction transaction =
      Transaction.fromJson(doc.data() as Map<String, dynamic>);
      if (dailyTransactions[date] == null) {
        dailyTransactions[date] = [];
      }
      dailyTransactions[date]!.add(transaction);
    }
    setState(() {});
  }

  void _setBalance() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text('Set Balance'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter current balance'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {
                  currentBalance = double.parse(controller.text);
                });
                await _firestore
                    .collection('users')
                    .doc(_user!.uid)
                    .collection('budget')
                    .doc('info')
                    .set({
                  'currentBalance': currentBalance,
                }, firestore.SetOptions(merge: true));
                Navigator.of(context).pop();
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  }

  void _setEstimatedMonthlyExpenses() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text('Estimated Monthly Expenses'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter estimated expenses'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {
                  estimatedMonthlyExpenses = double.parse(controller.text);
                });
                await _firestore
                    .collection('users')
                    .doc(_user!.uid)
                    .collection('budget')
                    .doc('info')
                    .set({
                  'estimatedMonthlyExpenses': estimatedMonthlyExpenses,
                }, firestore.SetOptions(merge: true));
                Navigator.of(context).pop();
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  }

  void _addTransaction() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController memoController = TextEditingController();
        TextEditingController incomeController = TextEditingController();
        TextEditingController expenseController = TextEditingController();

        return AlertDialog(
          title: Text('Add Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: memoController,
                decoration: InputDecoration(hintText: 'Memo'),
              ),
              TextField(
                controller: incomeController,
                decoration: InputDecoration(hintText: '+'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: expenseController,
                decoration: InputDecoration(hintText: '-'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                double income = incomeController.text.isNotEmpty
                    ? double.parse(incomeController.text)
                    : 0.0;
                double expense = expenseController.text.isNotEmpty
                    ? double.parse(expenseController.text)
                    : 0.0;

                Transaction transaction = Transaction(
                  memo: memoController.text,
                  amount: income > 0 ? income : expense,
                  type: income > 0 ? '+' : '-',
                  isExpected: false,
                );

                if (dailyTransactions[selectedDay] == null) {
                  dailyTransactions[selectedDay] = [];
                }
                setState(() {
                  dailyTransactions[selectedDay]!.add(transaction);
                  currentBalance += (income - expense);
                });

                await _firestore
                    .collection('users')
                    .doc(_user!.uid)
                    .collection('transactions')
                    .add({
                  'memo': transaction.memo,
                  'amount': transaction.amount,
                  'type': transaction.type,
                  'isExpected': transaction.isExpected,
                  'date': selectedDay,
                });

                await _firestore
                    .collection('users')
                    .doc(_user!.uid)
                    .collection('budget')
                    .doc('info')
                    .set({
                  'currentBalance': currentBalance,
                }, firestore.SetOptions(merge: true));

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () async {
                double income = incomeController.text.isNotEmpty
                    ? double.parse(incomeController.text)
                    : 0.0;
                double expense = expenseController.text.isNotEmpty
                    ? double.parse(expenseController.text)
                    : 0.0;

                Transaction transaction = Transaction(
                  memo: memoController.text,
                  amount: income > 0 ? income : expense,
                  type: income > 0 ? '+' : '-',
                  isExpected: true,
                );

                if (dailyTransactions[selectedDay] == null) {
                  dailyTransactions[selectedDay] = [];
                }
                setState(() {
                  dailyTransactions[selectedDay]!.add(transaction);
                  estimatedMonthlyExpenses += (income - expense);
                });

                await _firestore
                    .collection('users')
                    .doc(_user!.uid)
                    .collection('transactions')
                    .add({
                  'memo': transaction.memo,
                  'amount': transaction.amount,
                  'type': transaction.type,
                  'isExpected': transaction.isExpected,
                  'date': selectedDay,
                });

                await _firestore
                    .collection('users')
                    .doc(_user!.uid)
                    .collection('budget')
                    .doc('info')
                    .set({
                  'estimatedMonthlyExpenses': estimatedMonthlyExpenses,
                }, firestore.SetOptions(merge: true));

                Navigator.of(context).pop();
              },
              child: Text('Save as Expected'),
            ),
          ],
        );
      },
    );
  }

  void _editTransaction(DateTime day, int index) {
    Transaction transaction = dailyTransactions[day]![index];
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController memoController =
        TextEditingController(text: transaction.memo);
        TextEditingController amountController =
        TextEditingController(text: transaction.amount.toString());
        return AlertDialog(
          title: Text('Edit Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: memoController,
                decoration: InputDecoration(hintText: 'Memo'),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(hintText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                double oldAmount = transaction.amount;
                double newAmount = double.parse(amountController.text);

                setState(() {
                  dailyTransactions[day]![index] = Transaction(
                    memo: memoController.text,
                    amount: newAmount,
                    type: transaction.type,
                    isExpected: transaction.isExpected,
                  );
                  if (transaction.isExpected) {
                    estimatedMonthlyExpenses += (transaction.type == '+'
                        ? newAmount - oldAmount
                        : oldAmount - newAmount);
                  } else {
                    currentBalance += (transaction.type == '+'
                        ? newAmount - oldAmount
                        : oldAmount - newAmount);
                  }
                });

                firestore.QuerySnapshot querySnapshot = await _firestore
                    .collection('users')
                    .doc(_user!.uid)
                    .collection('transactions')
                    .where('memo', isEqualTo: transaction.memo)
                    .where('amount', isEqualTo: transaction.amount)
                    .where('type', isEqualTo: transaction.type)
                    .where('isExpected', isEqualTo: transaction.isExpected)
                    .where('date', isEqualTo: day)
                    .get();

                if (querySnapshot.docs.isNotEmpty) {
                  await _firestore
                      .collection('users')
                      .doc(_user!.uid)
                      .collection('transactions')
                      .doc(querySnapshot.docs.first.id)
                      .update({
                    'memo': memoController.text,
                    'amount': newAmount,
                  });
                }

                await _firestore
                    .collection('users')
                    .doc(_user!.uid)
                    .collection('budget')
                    .doc('info')
                    .set({
                  'currentBalance': currentBalance,
                  'estimatedMonthlyExpenses': estimatedMonthlyExpenses,
                }, firestore.SetOptions(merge: true));

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  if (transaction.isExpected) {
                    estimatedMonthlyExpenses -= transaction.amount;
                  } else {
                    currentBalance -= transaction.amount;
                  }
                  dailyTransactions[day]!.removeAt(index);
                });

                firestore.QuerySnapshot querySnapshot = await _firestore
                    .collection('users')
                    .doc(_user!.uid)
                    .collection('transactions')
                    .where('memo', isEqualTo: transaction.memo)
                    .where('amount', isEqualTo: transaction.amount)
                    .where('type', isEqualTo: transaction.type)
                    .where('isExpected', isEqualTo: transaction.isExpected)
                    .where('date', isEqualTo: day)
                    .get();

                if (querySnapshot.docs.isNotEmpty) {
                  await _firestore
                      .collection('users')
                      .doc(_user!.uid)
                      .collection('transactions')
                      .doc(querySnapshot.docs.first.id)
                      .delete();
                }

                await _firestore
                    .collection('users')
                    .doc(_user!.uid)
                    .collection('budget')
                    .doc('info')
                    .set({
                  'currentBalance': currentBalance,
                  'estimatedMonthlyExpenses': estimatedMonthlyExpenses,
                }, firestore.SetOptions(merge: true));

                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  List<Transaction> _getTransactionsForDay(DateTime day) {
    return dailyTransactions[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    List<Transaction> transactions = _getTransactionsForDay(selectedDay);
    double dailyTotal = transactions.fold(0.0, (sum, item) {
      if (item.isExpected) {
        return sum;
      } else {
        return sum + (item.type == '+' ? item.amount : -item.amount);
      }
    });

    double dailyExpected = transactions.fold(0.0, (sum, item) {
      if (item.isExpected) {
        return sum + (item.type == '+' ? item.amount : -item.amount);
      } else {
        return sum;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addTransaction,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text(
                  'Current Balance: \$${currentBalance.toStringAsFixed(2)}'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: _setBalance,
              ),
            ),
            ListTile(
              title: Text(
                  'Estimated Monthly Expenses: \$${estimatedMonthlyExpenses.toStringAsFixed(2)}'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: _setEstimatedMonthlyExpenses,
              ),
            ),
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  this.selectedDay = selectedDay;
                  this.focusedDay = focusedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  if (dailyTransactions[day] != null) {
                    double dailyTotal =
                    dailyTransactions[day]!.fold(0.0, (sum, item) {
                      if (item.isExpected) {
                        return sum;
                      } else {
                        return sum +
                            (item.type == '+' ? item.amount : -item.amount);
                      }
                    });
                    double dailyExpected =
                    dailyTransactions[day]!.fold(0.0, (sum, item) {
                      if (item.isExpected) {
                        return sum +
                            (item.type == '+' ? item.amount : -item.amount);
                      } else {
                        return sum;
                      }
                    });
                    return Center(
                      child: Column(
                        children: [
                          Text('${day.day}'),
                          Text(
                            '\$${dailyTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              color:
                              dailyTotal >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                          if (dailyExpected != 0)
                            Text(
                              'Expected: \$${dailyExpected.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    );
                  } else {
                    return Center(child: Text('${day.day}'));
                  }
                },
              ),
            ),
            Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                Transaction transaction = transactions[index];
                return ListTile(
                  title: Text(transaction.memo),
                  subtitle: Text('\$${transaction.amount.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        transaction.type,
                        style: TextStyle(
                          color: transaction.type == '+'
                              ? Colors.green
                              : transaction.type == '-'
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editTransaction(selectedDay, index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Total: \$${dailyTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: dailyTotal >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (dailyExpected != 0)
                    Text(
                      'Expected: \$${dailyExpected.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/calendar');
              break;
            case 1:
              Navigator.pushNamed(context, '/budget');
              break;
            case 2:
              Navigator.pushNamed(context, '/home');
              break;
            case 3:
              Navigator.pushNamed(context, '/map');
              break;
            case 4:
              Navigator.pushNamed(context, '/diary');
              break;
          }
        },
      ),
    );
  }
}
