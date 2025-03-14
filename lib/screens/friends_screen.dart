import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database/database_helper.dart';
import '../providers/user_provider.dart';
import '../services/share_service.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Friends')),
      body: FutureBuilder(
        future: _loadFriends(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: (snapshot.data as List).length,
            itemBuilder: (context, index) {
              var friend = (snapshot.data as List)[index];
              return ListTile(
                title: Text(friend['name']),
                subtitle: Text(friend['email']),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeFriend(friend['id']),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFriend,
        child: Icon(Icons.person_add),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadFriends() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user!.id;
    return await _db.getFriends(userId);
  }

  void _addFriend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Friend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Add by Email'),
              onTap: () {
                Navigator.pop(context);
                _addFriendByEmail();
              },
            ),
            ListTile(
              leading: Icon(Icons.contacts),
              title: Text('Add from Contacts'),
              onTap: () {
                Navigator.pop(context);
                _addFromContacts();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addFromContacts() async {
    if (await FlutterContacts.requestPermission()) {
      try {
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );
        final selectedContact = await showDialog<Contact>(
          context: context,
          builder: (context) => ContactSelectionDialog(contacts: contacts),
        );

        if (selectedContact != null && selectedContact.phones.isNotEmpty) {
          final phone = selectedContact.phones.first.number;
          final db = await _db.database;
          final user = await db.query(
            'users',
            where: 'phone = ?',
            whereArgs: [phone],
          );

          if (user.isNotEmpty) {
            final userId = Provider.of<UserProvider>(context, listen: false).user!.id;
            await db.insert('friends', {
              'user_id': userId,
              'friend_id': user.first['id'],
            });
            setState(() {});
          } else {
            _showInviteDialog(selectedContact);
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing contacts')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact permission denied')),
      );
    }
  }

  void _addFriendByEmail() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add by Email'),
        content: TextField(
          decoration: InputDecoration(
            labelText: 'Friend\'s Email',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (email) => _handleEmailSubmission(email),
        ),
      ),
    );
  }

  Future<void> _handleEmailSubmission(String email) async {
    final userId = Provider.of<UserProvider>(context, listen: false).user!.id;
    final db = await _db.database;
    final friend = (await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    )).firstOrNull;

    if (friend != null) {
      await db.insert('friends', {
        'user_id': userId,
        'friend_id': friend['id'],
      });
      Navigator.pop(context);
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found')),
      );
    }
  }

  void _showInviteDialog(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invite Friend'),
        content: Text('${contact.displayName} is not using the app. Would you like to invite them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ShareService.inviteFriend(
                contact.displayName ?? 'Friend',
                contact.phones?.first.number ?? '',
              );
              Navigator.pop(context);
            },
            child: Text('Invite'),
          ),
        ],
      ),
    );
  }

  void _removeFriend(int friendId) async {
    final userId = Provider.of<UserProvider>(context, listen: false).user!.id;
    final db = await _db.database;
    await db.delete(
      'friends',
      where: 'user_id = ? AND friend_id = ?',
      whereArgs: [userId, friendId],
    );
    setState(() {});
  }
}

class ContactSelectionDialog extends StatelessWidget {
  final List<Contact> contacts;

  ContactSelectionDialog({required this.contacts});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Contact'),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(contact.displayName[0]),
              ),
              title: Text(contact.displayName),
              subtitle: Text(contact.phones.isNotEmpty 
                ? contact.phones.first.number 
                : 'No phone'),
              onTap: () => Navigator.pop(context, contact),
            );
          },
        ),
      ),
    );
  }
}
