import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'manager/locale_provider.dart';
import 'pages/history.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/result.dart';
import 'pages/running.dart';
import 'pages/loading.dart';
import 'pages/setting.dart';
import 'manager/routes.dart';

void main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      runApp(MyApp());
}

class MyApp extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
            return ChangeNotifierProvider(
                  create: (_) => LocaleProvider(),
                  child: Consumer<LocaleProvider>(
                        builder: (context, provider, child) {
                              return MaterialApp(
                                    initialRoute: Routes.loading,
                                    routes: {
                                          Routes.loading: (context) => Loading(),
                                          Routes.login: (context) => Login(),
                                          Routes.home: (context) => Home(),
                                          Routes.running: (context) => Running(),
                                          Routes.report: (context) => Report(),
                                          Routes.result: (context) => Result(),
                                          Routes.setting: (context) => Setting(),
                                    },
                                    localizationsDelegates: [
                                          AppLocalizations.delegate,
                                          GlobalMaterialLocalizations.delegate,
                                          GlobalWidgetsLocalizations.delegate,
                                          GlobalCupertinoLocalizations.delegate,
                                    ],
                                    supportedLocales: L10n.all,
                                    locale: provider.locale,
                              );
                        },
                  ),
            );
      }
}
