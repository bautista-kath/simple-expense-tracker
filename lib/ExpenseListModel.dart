import 'dart:collection';
import 'package:scoped_model/scoped_model.dart';
import 'Expense.dart';
import 'Database.dart';

class ExpenseListModel extends Model {
  ExpenseListModel() {
    load();
  }

  final List<Expense> _items = [];
  UnmodifiableListView<Expense> get items => UnmodifiableListView(_items);

  double get totalExpense => _items.fold(0.0, (sum, item) => sum + item.amount);

  void load() async {
    List<Expense> dbItems = await SQLiteDbProvider.db.getAllExpenses();
    _items.addAll(dbItems);
    notifyListeners();
  }

  Expense? byId(int id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }



  void add(Expense item) async {
    Expense val = await SQLiteDbProvider.db.insert(item);
    _items.add(val);
    notifyListeners();
  }

  void update(Expense item) {
    int index = _items.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _items[index] = item;
      SQLiteDbProvider.db.update(item);
      notifyListeners();
    }
  }

  void delete(Expense item) {
    _items.removeWhere((e) => e.id == item.id);
    SQLiteDbProvider.db.delete(item.id);
    notifyListeners();
  }
}
