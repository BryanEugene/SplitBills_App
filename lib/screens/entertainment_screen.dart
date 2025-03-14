import 'package:flutter/material.dart';
import 'package:project_2/database/database_helper.dart';
import 'package:project_2/models/bill_item.dart';
import 'package:project_2/providers/user_provider.dart';
import 'package:provider/provider.dart';

class EntertainmentScreen extends StatefulWidget {
  @override
  _EntertainmentScreenState createState() => _EntertainmentScreenState();
}

class _EntertainmentScreenState extends State<EntertainmentScreen> {
  final List<String> _categories = ['Movies', 'Concert', 'Theme Park', 'Other'];
  String _selectedCategory = 'Movies';
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<int> _selectedFriends = [];
  final _db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entertainment Split'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter amount' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 3,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter description' : null,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Split Bill'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user == null) return;

      final amount = double.parse(_amountController.text);
      final transaction = {
        'amount': amount,
        'description': '${_selectedCategory}: ${_descriptionController.text}',
        'date': DateTime.now().toIso8601String(),
        'payer_id': user.id,
        'category': 'Entertainment',
        'subcategory': _selectedCategory,
      };

      try {
        await _db.saveBillSplit(transaction, [
          BillItem(
            name: _descriptionController.text,
            price: amount,
            assignedUsers: _selectedFriends,
          ),
        ]);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Split bill saved successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving split bill')),
        );
      }
    }
  }
}
