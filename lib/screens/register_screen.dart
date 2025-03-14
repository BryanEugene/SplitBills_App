import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                _buildInputField(_nameController, 'Name', Icons.person),
                SizedBox(height: 16),
                _buildInputField(_emailController, 'Email', Icons.email),
                SizedBox(height: 16),
                _buildInputField(_passwordController, 'Password', Icons.lock, 
                               isPassword: true),
                SizedBox(height: 16),
                _buildInputField(_phoneController, 'Phone', Icons.phone),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _register,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Register'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, 
                         IconData icon, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      obscureText: isPassword,
      validator: (value) => value!.isEmpty ? 'This field is required' : null,
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      // Implement registration logic
    }
  }
}
