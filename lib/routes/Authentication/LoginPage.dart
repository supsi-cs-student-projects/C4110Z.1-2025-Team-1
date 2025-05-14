import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appwrite/models.dart' as models;

import 'package:demo_todo_with_flutter/services/localeProvider.dart';
import 'package:provider/provider.dart';

// localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import '../../services/auth.dart';

import '../Homepage.dart';
import 'RegisterPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

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

  //dummy email generator
  String dummyEmail(String username) {
    username = username.replaceAll(" ", "").trim();
    return "$username@bloom.com";
  }

  String generateGuestName() {
    const adjectives = ['Swift', 'Happy', 'Brave', 'Mighty', 'Gentle', 'Fuzzy', 'Witty'];
    const animals = ['Tiger', 'Penguin', 'Panda', 'Fox', 'Koala', 'Wolf', 'Dolphin'];

    final random = Random.secure();
    final adjective = adjectives[random.nextInt(adjectives.length)];
    final animal = animals[random.nextInt(animals.length)];
    final number = random.nextInt(10000);

    return '$adjective$animal$number'; // e.g., HappyFox8372
  }


  //Enter as guest (it can be done better by adding a parameter to login method)
  Future<void> _enterAsGuest() async {
    if (_isLoggingIn) return;

    setState(() {
      _isLoggingIn = true;
    });
    //name generator with guest and random number
    String guestName = generateGuestName();

    try {
      final userAccount = await _authService.signUp(
        name: guestName,
        email: dummyEmail(guestName.trim()),
        password: guestName.trim(),
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
        SnackBar(content: Text(AppLocalizations.of(context)!.loginPage_loginError + ': $e')),
      );
    } finally {
      setState(() {
        _isLoggingIn = false;
      });
    }

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
        SnackBar(content: Text(AppLocalizations.of(context)!.loginPage_loginError + ': $e')),
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
    final localeProvider = Provider.of<LocaleProvider>(context);
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
          _login();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {

          // Constrain width for desktop, full width on mobile
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
                        AppLocalizations.of(context)!.loginPage_welcome, //WELCOME BACK
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
                        AppLocalizations.of(context)!.loginPage_access, //
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
                          labelText: AppLocalizations.of(context)!.loginPage_username, //Username
                          hintText: AppLocalizations.of(context)!.loginPage_usernameHint, //Enter your username...
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
                          labelText: AppLocalizations.of(context)!.loginPage_password, //Password
                          hintText: AppLocalizations.of(context)!.loginPage_passwordHint, //Enter your password...
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
                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          //ENTER AS GUEST BUTTON
                          ElevatedButton(
                            onPressed: _enterAsGuest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF157907),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                            ),
                            child: Text(AppLocalizations.of(context)!.loginPage_enterAsGuest, style: TextStyle(color: Colors.white, fontFamily: 'RetroGaming')),
                          ),



                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF157907),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                            ),
                            child: Text(AppLocalizations.of(context)!.loginPage_login, style: TextStyle(color: Colors.white, fontFamily: 'RetroGaming')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Go to Register
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterPage())),
                          child: Text(AppLocalizations.of(context)!.loginPage_goToRegister, style: TextStyle(color: Colors.blue, fontFamily: 'RetroGaming')),
                        ),
                      ),
                      const SizedBox(height: 24),
                    // Locale Change Button
                    Center(
                      child: ElevatedButton(
                        onPressed: localeProvider.toggleLocale,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          Localizations.localeOf(context).languageCode == 'en'
                            ? 'Change to Italian'
                            : 'Change to English',
                          style: const TextStyle(color: Colors.white, fontFamily: 'RetroGaming'),
                        ),
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