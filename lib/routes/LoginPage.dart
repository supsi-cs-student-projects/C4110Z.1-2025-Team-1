import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appwrite/models.dart' as models;
import '../services/auth.dart';
import 'Homepage.dart';
import 'RegisterPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoggingIn = false;
  bool _navigated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Dummy email generator (same as in RegisterPage)
  String dummyEmail(String username) {
    return "$username@bloom.com";
  }

  Future<void> _login() async {
    if (_isLoggingIn) return;

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final userAccount = await _authService.login(
        email: dummyEmail(_nameController.text.trim()),
        password: _passwordController.text.trim(),
      );

      if (!_navigated) {
        _navigated = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<models.Account>(
      future: _authService.getAccount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && !_navigated) {
          _navigated = true;
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          });
          return const SizedBox();
        } else {
          return _buildLoginPage(context);
        }
      },
    );
  }

  Widget _buildLoginPage(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
          _login();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth * 0.9;
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/logo/Bloom_logo.png',
                          width: maxWidth,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Welcome back to Bloom!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'RetroGaming',
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Login to access your account',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'RetroGaming',
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Username
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter your username...',
                          filled: true,
                          fillColor: Colors.grey[200],
                          labelStyle: const TextStyle(
                            fontFamily: 'RetroGaming',
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        ),
                        style: const TextStyle(fontFamily: 'RetroGaming', color: Colors.black),
                      ),
                      const SizedBox(height: 12),
                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password...',
                          filled: true,
                          fillColor: Colors.grey[200],
                          labelStyle: const TextStyle(
                            fontFamily: 'RetroGaming',
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(fontFamily: 'RetroGaming', color: Colors.black),
                      ),
                      const SizedBox(height: 24),
                      // Login Button
                      ElevatedButton(
                        onPressed: _isLoggingIn ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF157907),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                        ),
                        child: _isLoggingIn
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Login', style: TextStyle(color: Colors.white, fontFamily: 'RetroGaming')),
                      ),
                      const SizedBox(height: 24),
                      // Go to Register
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterPage())),
                          child: const Text("Don't have an account?", style: TextStyle(color: Colors.blue, fontFamily: 'RetroGaming')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}