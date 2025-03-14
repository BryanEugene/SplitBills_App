import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../providers/user_provider.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Dashboard'),
              background: _buildHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureGrid(),
                  SizedBox(height: 24),
                  Text('Recent Transactions',
                       style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 16),
                  _buildTransactionList(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/new-transaction'),
        label: Text('Split Bill'),
        icon: Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<double>(
      future: _calculateTotalSpent(),
      builder: (context, snapshot) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, 
                      Theme.of(context).colorScheme.secondary],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Total Spent',
                   style: TextStyle(color: Colors.white70)),
              Text('\$${snapshot.data?.toStringAsFixed(2) ?? '0.00'}',
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 32,
                     fontWeight: FontWeight.bold,
                   )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: [
        _buildFeatureCard('Sports', Icons.sports, '/sports'),
        _buildFeatureCard('Entertainment', Icons.movie, '/entertainment'),
        _buildFeatureCard('Accommodation', Icons.hotel, '/accommodation'),
      ],
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, String route) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadTransactions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final transactions = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final amount = (transaction['amount'] as num).toDouble();
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.receipt),
                ),
                title: Text(transaction['description']),
                subtitle: Text(transaction['date']),
                trailing: Text(
                  '\$${amount.toStringAsFixed(2)}',
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

  Future<double> _calculateTotalSpent() async {
    final transactions = await _loadTransactions();
    double total = 0.0;
    for (var transaction in transactions) {
      total += (transaction['amount'] as num).toDouble();
    }
    return total;
  }
}
