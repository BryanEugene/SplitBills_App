import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../providers/user_provider.dart';

class SportsScreen extends StatefulWidget {
  @override
  _SportsScreenState createState() => _SportsScreenState();
}

class _SportsScreenState extends State<SportsScreen> {
  final _db = DatabaseHelper();
  List<int> _selectedFriends = [];
  final _formKey = GlobalKey<FormState>();
  final _venueController = TextEditingController();
  final _equipmentController = TextEditingController();
  final _participantsController = TextEditingController();
  double _totalAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sports Split')),
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
                      TextFormField(
                        controller: _venueController,
                        decoration: InputDecoration(
                          labelText: 'Venue Cost',
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: _calculateTotal,
                        validator: (value) => 
                            value!.isEmpty ? 'Enter venue cost' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _equipmentController,
                        decoration: InputDecoration(
                          labelText: 'Equipment Cost',
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: _calculateTotal,
                        validator: (value) => 
                            value!.isEmpty ? 'Enter equipment cost' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _participantsController,
                        decoration: InputDecoration(
                          labelText: 'Number of Participants',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => 
                            value!.isEmpty ? 'Enter number of participants' : null,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Summary',
                           style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Amount:'),
                          Text('\$${_totalAmount.toStringAsFixed(2)}',
                               style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Per Person:'),
                          Text('\$${_calculatePerPerson().toStringAsFixed(2)}',
                               style: TextStyle(
                                 fontWeight: FontWeight.bold,
                                 color: Theme.of(context).primaryColor,
                               )),
                        ],
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

  void _calculateTotal([String? _]) {
    setState(() {
      _totalAmount = (double.tryParse(_venueController.text) ?? 0) +
                    (double.tryParse(_equipmentController.text) ?? 0);
    });
  }

  double _calculatePerPerson() {
    int participants = int.tryParse(_participantsController.text) ?? 1;
    return participants > 0 ? _totalAmount / participants : _totalAmount;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user == null) return;

      final transaction = {
        'amount': _totalAmount,
        'description': 'Sports Activity Split',
        'date': DateTime.now().toIso8601String(),
        'payer_id': user.id,
        'category': 'Sports',
      };

      try {
        await _db.saveSportsSplit(
          transaction,
          _selectedFriends,
        );
        
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
