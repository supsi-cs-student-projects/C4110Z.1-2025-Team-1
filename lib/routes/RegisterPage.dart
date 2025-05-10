import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:appwrite/models.dart' as models;
import '../services/auth.dart';
import 'Homepage.dart';
import 'LoginPage.dart';

import 'package:demo_todo_with_flutter/services/localeProvider.dart';
import 'package:provider/provider.dart';

// localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController1 = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isPasswordVisible1 = false;
  bool _isPasswordVisible2 = false;
  bool _isRegistering = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController1.dispose();
    _passwordController2.dispose();
    _nameController.dispose();
    super.dispose();
  }

  //dummy email generator
  String dummyEmail(String username) {
    return "$username@bloom.com";
  }


  Future<void> _register() async {
    if (_isRegistering) return; // blocca se già in corso
    setState(() {
      _isRegistering = true;
    });

    if (_passwordController1.text != _passwordController2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.registerPage_passwordNotMatching)),
      );
      setState(() {
        _isRegistering = false;
      });
      return;
    }
    try {
      final userAccount = await _authService.signUp(
        name: _nameController.text.trim(),
        email: dummyEmail(_nameController.text.trim()),
        password: _passwordController1.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.registerPage_error + ': $e')),
      );
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
          _register();
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
                       Text(
                        AppLocalizations.of(context)!.registerPage_welcome,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'RetroGaming',
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.registerPage_createAccount,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'RetroGaming',
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      //const SizedBox(height: 24),
                      const SizedBox(height: 12),
                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.registerPage_username,
                          hintText: AppLocalizations.of(context)!.registerPage_usernameHint,
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
                        controller: _passwordController1,
                        obscureText: !_isPasswordVisible1,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.registerPage_password,
                          hintText: AppLocalizations.of(context)!.registerPage_passwordHint,
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
                              _isPasswordVisible1 ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible1 = !_isPasswordVisible1;
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(fontFamily: 'RetroGaming', color: Colors.black),
                      ),
                      const SizedBox(height: 12),
                      // Repeat Password
                      TextFormField(
                        controller: _passwordController2,
                        obscureText: !_isPasswordVisible2,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.registerPage_confirmPassword,
                          hintText: AppLocalizations.of(context)!.registerPage_confirmPasswordHint,
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
                              _isPasswordVisible2 ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible2 = !_isPasswordVisible2;
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(fontFamily: 'RetroGaming', color: Colors.black),
                      ),
                      const SizedBox(height: 24),
                      // Create Account Button
                      ElevatedButton(
                        onPressed: _isRegistering ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF157907),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                        ),
                        child: Text(AppLocalizations.of(context)!.registerPage_register, style: TextStyle(color: Colors.white, fontFamily: 'RetroGaming')),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage())),
                          child: Text(AppLocalizations.of(context)!.registerPage_alreadyHaveAccount, style: TextStyle(color: Colors.blue, fontFamily: 'RetroGaming')),
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
