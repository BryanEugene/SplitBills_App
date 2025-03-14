import 'package:flutter/material.dart';
import 'package:project_2/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/bill_item.dart';
import '../services/receipt_scanner.dart';
import '../services/share_service.dart';

class ReceiptSplitScreen extends StatefulWidget {
  @override
  _ReceiptSplitScreenState createState() => _ReceiptSplitScreenState();
}

class _ReceiptSplitScreenState extends State<ReceiptSplitScreen> {
  final _db = DatabaseHelper();
  List<BillItem> items = [];
  List<Map<String, dynamic>> friends = [];
  double taxRate = 0.0;
  final _receiptScanner = ReceiptScanner();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Split Receipt'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildItemCard(items[index]);
              },
            ),
          ),
          _buildSummaryCard(),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _saveSplit,
              child: Text('Confirm Split'),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _scanReceipt,
            heroTag: 'scan',
            child: Icon(Icons.camera_alt),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _addItem,
            heroTag: 'add',
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BillItem item) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(item.name),
        subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
        children: [
          _buildAssigneesList(item),
        ],
      ),
    );
  }

  Widget _buildAssigneesList(BillItem item) {
    return Column(
      children: [
        for (var friend in friends)
          CheckboxListTile(
            title: Text(friend['name']),
            value: item.assignedUsers.contains(friend['id']),
            onChanged: (bool? value) {
              setState(() {
                if (value!) {
                  item.assignedUsers.add(friend['id']);
                } else {
                  item.assignedUsers.remove(friend['id']);
                }
              });
            },
          ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Summary', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () => _shareSummary(),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal:'),
                Text('\$${_calculateSubtotal().toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tax:'),
                Text('\$${_calculateTax().toStringAsFixed(2)}'),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:'),
                Text('\$${_calculateTotal().toStringAsFixed(2)}',
                     style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateSubtotal() {
    return items.fold(0, (sum, item) => sum + item.price);
  }

  double _calculateTax() {
    return _calculateSubtotal() * (taxRate / 100);
  }

  double _calculateTotal() {
    return _calculateSubtotal() + _calculateTax();
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onAdd: (name, price) {
          setState(() {
            items.add(BillItem(name: name, price: price));
          });
        },
      ),
    );
  }

  Future<void> _scanReceipt() async {
    final scannedItems = await _receiptScanner.scanReceipt();
    for (var item in scannedItems) {
      final match = RegExp(r'\$?(\d+\.?\d*)').firstMatch(item);
      if (match != null) {
        final price = double.tryParse(match.group(1)!) ?? 0.0;
        setState(() {
          items.add(BillItem(
            name: item.replaceAll(match.group(0)!, '').trim(),
            price: price,
          ));
        });
      }
    }
  }

  void _saveSplit() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;

    final transaction = {
      'amount': _calculateTotal(),
      'description': 'Split Bill',
      'date': DateTime.now().toIso8601String(),
      'payer_id': user.id,
    };

    await _db.saveBillSplit(transaction, items);
    Navigator.pop(context);
  }

  void _shareSummary() async {
    await ShareService.shareBillSummary(
      _calculateTotal(),
      items.fold<Set<int>>({}, (set, item) => set..addAll(item.assignedUsers)).length + 1,
      'Split Bill',
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final Function(String name, double price) onAdd;

  _AddItemDialog({required this.onAdd});

  @override
  __AddItemDialogState createState() => __AddItemDialogState();
}

class __AddItemDialogState extends State<_AddItemDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Item Name'),
          ),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty && 
                _priceController.text.isNotEmpty) {
              widget.onAdd(
                _nameController.text,
                double.parse(_priceController.text),
              );
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
