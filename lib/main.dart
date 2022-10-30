import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'data.dart';
import 'home.dart';
import 'report.dart';
import 'settings.dart';

void main() {
  Data.init(() {
    runApp(const App());
  });
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Data>(create: (_) => Data()),
      ],
      child: Consumer<Data>(
        builder: (context, data, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale(data.locale),
            home: homePage(),
          );
        },
      ),
    );
  }

  Widget homePage() {
    return const DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.timeline)),
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.settings)),
          ],
          labelColor: Colors.blue,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.blue, width: 8.0),
            insets: EdgeInsets.only(top: 0.0, bottom: 40.0),
          ),
        ),
        body: TabBarView(
          children: [
            ReportsPage(),
            HomePage(),
            SettingsPage(),
          ],
        ),
      ),
    );
  }
}
