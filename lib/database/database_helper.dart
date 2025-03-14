import 'package:project_2/models/bill_item.dart';
import 'package:project_2/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'splitbill.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        payer_id INTEGER NOT NULL,
        FOREIGN KEY (payer_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE friends (
        user_id INTEGER NOT NULL,
        friend_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (friend_id) REFERENCES users (id),
        PRIMARY KEY (user_id, friend_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE bill_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        tax REAL NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE item_assignments (
        item_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        FOREIGN KEY (item_id) REFERENCES bill_items (id),
        FOREIGN KEY (user_id) REFERENCES users (id),
        PRIMARY KEY (item_id, user_id)
      )
    ''');
  }

  Future<int> saveBillSplit(Map<String, dynamic> transaction, 
                           List<BillItem> items) async {
    final db = await database;
    final batch = db.batch();
    
    // Insert transaction
    batch.insert('transactions', transaction);
    
    // Get the transaction id
    final results = await batch.commit();
    final transactionId = results[0] as int;
    
    // Insert items and assignments
    for (var item in items) {
      final itemId = await db.insert('bill_items', {
        'transaction_id': transactionId,
        'name': item.name,
        'price': item.price,
        'tax': item.tax,
      });
      
      for (var userId in item.assignedUsers) {
        await db.insert('item_assignments', {
          'item_id': itemId,
          'user_id': userId,
        });
      }
    }
    
    return transactionId;
  }

  Future<int> saveSportsSplit(Map<String, dynamic> transaction, List<int> participants) async {
    final db = await database;
    final transactionId = await db.insert('transactions', transaction);
    
    for (var userId in participants) {
      await db.insert('item_assignments', {
        'item_id': transactionId,
        'user_id': userId,
      });
    }
    return transactionId;
  }

  Future<int> saveAccommodationSplit(Map<String, dynamic> transaction, 
                                   List<int> participants, int nights) async {
    final db = await database;
    final transactionId = await db.insert('transactions', {
      ...transaction,
      'nights': nights,
    });
    
    for (var userId in participants) {
      await db.insert('item_assignments', {
        'item_id': transactionId,
        'user_id': userId,
      });
    }
    return transactionId;
  }

  Future<User?> authenticateUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    
    if (users.isEmpty) return null;
    return User.fromMap(users.first);
  }

  Future<int> registerUser(Map<String, dynamic> userData) async {
    final db = await database;
    return await db.insert('users', userData);
  }

  Future<List<Map<String, dynamic>>> getFriends(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT u.* FROM users u
      INNER JOIN friends f ON u.id = f.friend_id
      WHERE f.user_id = ?
    ''', [userId]);
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory(int userId) async {
    final db = await database;
    return await db.query(
      'transactions',
      where: 'payer_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  Future<Map<String, double>> getCategoryTotals(int userId) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM transactions
      WHERE payer_id = ?
      GROUP BY category
    ''', [userId]);

    return Map.fromEntries(
      results.map((row) => MapEntry(row['category'] as String, row['total'] as double))
    );
  }

  Future<List<Map<String, dynamic>>> getPendingSettlements(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT u.name, u.email, SUM(b.price) as amount
      FROM users u
      JOIN item_assignments ia ON u.id = ia.user_id
      JOIN bill_items b ON ia.item_id = b.id
      JOIN transactions t ON b.transaction_id = t.id
      WHERE t.payer_id = ? AND u.id != ?
      GROUP BY u.id
    ''', [userId, userId]);
  }
}
