import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  double currentBalance = 0.0;
  double estimatedMonthlyExpenses = 0.0;
  Map<DateTime, double> dailyTransactions = {};

  void _addTransaction(DateTime date, double amount) {
    setState(() {
      if (dailyTransactions.containsKey(date)) {
        dailyTransactions[date] = dailyTransactions[date]! + amount;
      } else {
        dailyTransactions[date] = amount;
      }
    });
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

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: ListView.builder(
              itemCount: dailyTransactions.length,
              itemBuilder: (context, index) {
                DateTime date = dailyTransactions.keys.elementAt(index);
                return ListTile(
                  title: Text('${date.month}/${date.day}/${date.year}'),
                  subtitle: Text('\$${dailyTransactions[date]!.toStringAsFixed(2)}'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        TextEditingController controller = TextEditingController();
                        return AlertDialog(
                          title: Text('Add Transaction'),
                          content: TextField(
                            controller: controller,
                            decoration: InputDecoration(hintText: 'Enter amount'),
                            keyboardType: TextInputType.number,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                _addTransaction(date, double.parse(controller.text));
                                Navigator.of(context).pop();
                              },
                              child: Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
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
