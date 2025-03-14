import 'package:flutter/material.dart';
import 'package:project_2/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';

class AccommodationScreen extends StatefulWidget {
  @override
  _AccommodationScreenState createState() => _AccommodationScreenState();
}

class _AccommodationScreenState extends State<AccommodationScreen> {
  final _db = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _nightsController = TextEditingController();
  List<int> _selectedFriends = [];
  double _totalAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accommodation Split')),
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
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Accommodation Name',
                        ),
                        validator: (value) => 
                            value!.isEmpty ? 'Enter accommodation name' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Price per Night',
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: _calculateTotal,
                        validator: (value) => 
                            value!.isEmpty ? 'Enter price' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _nightsController,
                        decoration: InputDecoration(
                          labelText: 'Number of Nights',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: _calculateTotal,
                        validator: (value) => 
                            value!.isEmpty ? 'Enter number of nights' : null,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Participants',
                           style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 16),
                      _buildFriendsList(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              _buildSummaryCard(),
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

  Widget _buildFriendsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _db.getFriends(Provider.of<UserProvider>(context, listen: false).user!.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        return Column(
          children: snapshot.data!.map((friend) {
            return CheckboxListTile(
              title: Text(friend['name']),
              value: _selectedFriends.contains(friend['id']),
              onChanged: (bool? value) {
                setState(() {
                  if (value!) {
                    _selectedFriends.add(friend['id']);
                  } else {
                    _selectedFriends.remove(friend['id']);
                  }
                });
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Summary', style: Theme.of(context).textTheme.titleLarge),
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
    );
  }

  void _calculateTotal([String? _]) {
    setState(() {
      _totalAmount = (double.tryParse(_priceController.text) ?? 0) *
                    (double.tryParse(_nightsController.text) ?? 1);
    });
  }

  double _calculatePerPerson() {
    return _selectedFriends.isNotEmpty ? 
           _totalAmount / (_selectedFriends.length + 1) : _totalAmount;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user == null) return;

      final transaction = {
        'amount': _totalAmount,
        'description': '${_nameController.text} Accommodation',
        'date': DateTime.now().toIso8601String(),
        'payer_id': user.id,
        'category': 'Accommodation',
      };

      try {
        await _db.saveAccommodationSplit(
          transaction,
          _selectedFriends,
          int.parse(_nightsController.text),
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
