import 'package:flutter/material.dart';
import 'ExpenseListModel.dart';
import 'Expense.dart';
import 'package:intl/intl.dart';

class FormPage extends StatefulWidget {
  const FormPage({Key? key, required this.id, required this.expenses}) : super(key: key);

  final int id;
  final ExpenseListModel expenses;

  @override
  _FormPageState createState() => _FormPageState(id: id, expenses: expenses);
}

class _FormPageState extends State<FormPage> {
  _FormPageState({Key? key, required this.id, required this.expenses});

  final int id;
  final ExpenseListModel expenses;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  double? _amount;
  DateTime? _date;
  String? _category;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (id != 0) {
      final expense = expenses.byId(id);
      if (expense != null) {
        _amount = expense.amount;
        _date = expense.date;
        _category = expense.category;
        _dateController.text = DateFormat('yyyy-MM-dd').format(expense.date);
      }
    }
  }

  void _submit() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      if (_date == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select a valid date'))
        );
        return;
      }
      if (id == 0) {
        expenses.add(Expense(DateTime.now().millisecondsSinceEpoch, _amount!, _date!, _category!));
      } else {
        expenses.update(Expense(id, _amount!, _date!, _category!));
      }
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Expense"),
          content: Text("Are you sure you want to delete this expense?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                expenses.delete(Expense(id, _amount!, _date!, _category!));
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pop(context); // Go back to the previous page
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text(id == 0 ? 'Add Expense' : 'Edit Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                style: TextStyle(fontSize: 22),
                decoration: const InputDecoration(
                  icon: Icon(Icons.monetization_on),
                  labelText: 'Amount',
                  labelStyle: TextStyle(fontSize: 18),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty || double.tryParse(val) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
                initialValue: _amount?.toString() ?? '',
                onSaved: (val) => _amount = double.parse(val!),
              ),
              TextFormField(
                controller: _dateController,
                style: TextStyle(fontSize: 22),
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  labelText: 'Date',
                  labelStyle: TextStyle(fontSize: 18),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              TextFormField(
                style: TextStyle(fontSize: 22),
                decoration: const InputDecoration(
                  icon: Icon(Icons.category),
                  labelText: 'Category',
                  labelStyle: TextStyle(fontSize: 18),
                ),
                initialValue: _category ?? '',
                onSaved: (val) => _category = val!,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text('Save'),
                  ),
                  if (id != 0) // Show delete button only if editing an existing expense
                    ElevatedButton(
                      onPressed: _confirmDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
