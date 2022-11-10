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
          Data.initLogger(transfer: data);
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
            home: const LandingPage(),
          );
        },
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = AppLocalizations.of(context)!;
    final data = Provider.of<Data>(context);

    if (data.demo && !data.demoInit) {
      data.initReportDemo(_.pageReportDescription);
    }

    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(height: 42, child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.timeline), Text(' ${_.pageReportTab}')])),
            Tab(height: 42, child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.home), Text(' ${_.pageHomeTab}')])),
            Tab(height: 42, child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.settings), Text(' ${_.pageSettingsTab}')])),
          ],
          labelColor: Colors.blue,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.blue, width: 8.0),
            insets: EdgeInsets.only(top: 0.0, bottom: 36.0),
          ),
        ),
        body: const TabBarView(
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
