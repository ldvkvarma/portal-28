import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class LoginTestScreen extends StatefulWidget {
  const LoginTestScreen({super.key});

  @override
  State<LoginTestScreen> createState() => _LoginTestScreenState();
}

class _LoginTestScreenState extends State<LoginTestScreen> {
  final _usernameController = TextEditingController(text: '24KT5A0511');
  final _passwordController = TextEditingController(text: '4/15/2005');
  bool _isLoading = false;
  String _status = 'Ready to test login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Test', style: GoogleFonts.inter()),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Test Authentication',
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : Text('Test Login', style: GoogleFonts.inter()),
            ),
            const SizedBox(height: 20),
            Text(
              _status,
              style: GoogleFonts.inter(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing authentication...';
    });

    try {
      print('🧪 Starting login test...');
      print('Username: ${_usernameController.text}');
      print('Password: ${_passwordController.text}');

      // Test DatabaseService directly
      final user = await DatabaseService.authenticateUser(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        print('✅ Authentication successful!');
        print('User data: $user');
        print('User type: ${user['userType']}');
        print('User name: ${user['name']}');

        setState(() {
          _status = '✅ Success! User: ${user['name']} (${user['userType']})';
        });

        // Test AuthService
        print('🧪 Testing AuthService...');
        final authUser = await AuthService().login(
          _usernameController.text.trim(),
          _passwordController.text,
        );

        if (authUser != null) {
          print('✅ AuthService login successful!');
          print('AuthService user: $authUser');
          print('Current user: ${AuthService().currentUserData}');
          
          setState(() {
            _status = '✅ Complete Success! User: ${authUser['name']} (${authUser['userType']})';
          });
        } else {
          print('❌ AuthService login failed');
          setState(() {
            _status = '❌ AuthService login failed';
          });
        }
      } else {
        print('❌ Authentication failed');
        setState(() {
          _status = '❌ Authentication failed';
        });
      }
    } catch (e) {
      print('❌ Error during login test: $e');
      setState(() {
        _status = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
