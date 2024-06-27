import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:just_run/pages/history.dart';
import 'package:just_run/pages/login.dart';
import 'package:just_run/pages/home.dart';
import 'package:just_run/pages/result.dart';
import 'package:just_run/pages/running.dart';
import 'package:just_run/pages/loading.dart';
import 'package:just_run/routes.dart';

void main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      runApp(MyApp());
}

class MyApp extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
            return MaterialApp(
                  initialRoute: Routes.loading,
                  routes: {
                        Routes.loading: (context) => Loading(),
                        Routes.login: (context) => Login(),
                        Routes.home: (context) => Home(),
                        Routes.running: (context) => Running(),
                        Routes.history: (context) => History(),
                        Routes.result: (context) => Result(),
                  },
                  localizationsDelegates: [
                        AppLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: [
                        Locale('en'),
                  ],
            );
      }
}
