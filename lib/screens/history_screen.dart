import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../providers/user_provider.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('History'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'By Category'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAllTransactions(),
            _buildCategoryView(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllTransactions() {
    return FutureBuilder(
      future: _loadTransactions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        final transactions = snapshot.data as List;
        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(_getCategoryIcon(transaction['category'] ?? '')),
                ),
                title: Text(transaction['description']),
                subtitle: Text(transaction['date']),
                trailing: Text(
                  '\$${transaction['amount'].toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _loadTransactions() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return [];
    return await _db.getTransactionHistory(user.id);
  }

  Widget _buildCategoryView() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildCategoryCard('Entertainment', Icons.movie, 150.00),
        _buildCategoryCard('Sports', Icons.sports, 200.00),
        _buildCategoryCard('Accommodation', Icons.hotel, 500.00),
      ],
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, double amount) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 24),
                    SizedBox(width: 8),
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Entertainment':
        return Icons.movie;
      case 'Sports':
        return Icons.sports;
      case 'Accommodation':
        return Icons.hotel;
      default:
        return Icons.receipt;
    }
  }
}
