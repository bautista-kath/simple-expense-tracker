import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'ExpenseListModel.dart';
import 'FormPage.dart';

void main() {
  final expenses = ExpenseListModel();
  runApp(ScopedModel<ExpenseListModel>(
    model: expenses,
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Expense Calculator'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ScopedModelDescendant<ExpenseListModel>(
        builder: (context, child, expenses) {
          return ListView.separated(
            itemCount: expenses.items.isEmpty ? 1 : expenses.items.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: Text(
                    "Total Expenses: \₱${expenses.totalExpense.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                );
              } else {
                index -= 1;
                return Dismissible(
                  key: Key(expenses.items[index].id.toString()),
                  onDismissed: (direction) {
                    expenses.delete(expenses.items[index]);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Deleted expense ${expenses.items[index].id}")),
                    );
                  },
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormPage(
                            id: expenses.items[index].id,
                            expenses: expenses,
                          ),
                        ),
                      );
                    },
                    leading: Icon(Icons.monetization_on),
                    trailing: Icon(Icons.edit),
                    title: Text(
                      "${expenses.items[index].category}: \$${expenses.items[index].amount}\nSpent on ${expenses.items[index].formattedDate}",
                      style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }
            },
            separatorBuilder: (context, index) => Divider(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormPage(id: 0, expenses: ScopedModel.of<ExpenseListModel>(context)),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
