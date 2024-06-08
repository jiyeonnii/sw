// lib/screens/budget_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/bottom_nav_bar.dart';

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

  @override
  void initState() {
    super.initState();
    dailyTransactions[selectedDay] = [];
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
              onPressed: () {
                setState(() {
                  currentBalance = double.parse(controller.text);
                });
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
              onPressed: () {
                setState(() {
                  estimatedMonthlyExpenses = double.parse(controller.text);
                });
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
        TextEditingController nameController = TextEditingController();
        TextEditingController amountController = TextEditingController();
        String type = '+';
        bool isExpected = false;

        return AlertDialog(
          title: Text('Add Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'Enter name'),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(hintText: 'Enter amount'),
                keyboardType: TextInputType.number,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        type = '+';
                      });
                    },
                    child: Text('+', style: TextStyle(color: type == '+' ? Colors.green : Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        type = '-';
                      });
                    },
                    child: Text('-', style: TextStyle(color: type == '-' ? Colors.red : Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isExpected = !isExpected;
                      });
                    },
                    child: Text('Expected', style: TextStyle(color: isExpected ? Colors.grey : Colors.grey)),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  double amount = double.parse(amountController.text);
                  Transaction newTransaction = Transaction(
                    name: nameController.text,
                    amount: amount,
                    type: type,
                    isExpected: isExpected,
                  );
                  if (dailyTransactions[selectedDay] != null) {
                    dailyTransactions[selectedDay]!.add(newTransaction);
                  } else {
                    dailyTransactions[selectedDay] = [newTransaction];
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Current Balance: \$${currentBalance.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: _setBalance,
            ),
          ),
          ListTile(
            title: Text('Estimated Monthly Expenses: \$${estimatedMonthlyExpenses.toStringAsFixed(2)}'),
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
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                Transaction transaction = transactions[index];
                return ListTile(
                  title: Text(transaction.name),
                  subtitle: Text(transaction.amount.toString()),
                  trailing: Text(
                    transaction.type,
                    style: TextStyle(
                      color: transaction.type == '+'
                          ? Colors.green
                          : transaction.type == '-'
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total: ${dailyTotal.toStringAsFixed(2)}',
              style: TextStyle(
                color: dailyTotal >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addTransaction,
            child: Text('Add Transaction'),
          ),
        ],
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

class Transaction {
  final String name;
  final double amount;
  final String type;
  final bool isExpected;

  Transaction({
    required this.name,
    required this.amount,
    required this.type,
    required this.isExpected,
  });
}
