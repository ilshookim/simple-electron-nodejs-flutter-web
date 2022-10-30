import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'data.dart';
import 'process.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    final _ = AppLocalizations.of(context)!;
    final data = Provider.of<Data>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_.pageHomeTitle),
        actions: [
          IconButton(
            tooltip: data.deviceState ? _.pageHomeDeviceOnline : _.pageHomeDeviceOffline,
            icon: (data.deviceState) ? const Icon(Icons.usb) : const Icon(Icons.usb, color: Colors.grey),
            onPressed: () {
              DefaultTabController.of(context)?.animateTo(2);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(height: 50),
            Text(_.pageHomeProcessTitle, style: Theme.of(context).textTheme.headline4),
            Container(height: 40),
            SizedBox(
              height: 40,
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                onPressed: () {
                  if (data.deviceState) {
                  } else {
                    var snackBar = SnackBar(
                      content: Text(_.pageHomeDeviceOffline),
                      action: SnackBarAction(
                        label: _.pageHomeProcessStartForce,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProcessOne()));
                        },
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: Text(_.pageHomeProcessStart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
