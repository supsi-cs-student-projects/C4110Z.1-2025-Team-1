import 'dart:io';

import 'package:demo_todo_with_flutter/routes/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'package:demo_todo_with_flutter/services/localeProvider.dart';


import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const Bloom(),
    ),);
}

class Bloom extends StatelessWidget {
  const Bloom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'Bloom',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          primary: Colors.black,
        ),
        fontFamily: 'Avenir',
      ),
      home: LoginPage(),
    );
  }
}
