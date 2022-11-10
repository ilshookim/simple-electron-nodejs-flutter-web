import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'api.dart';
import 'data.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    final _ = AppLocalizations.of(context)!;
    final selectedLocale = Localizations.localeOf(context).toString();
    final baudRates = [2400, 4800, 9600, 19200, 28800, 38400, 57600, 76800, 115200, 230400, 460800, 576000, 921600];
    final data = Provider.of<Data>(context);
    final api = Api.instance;
    var websocketState = Data.defaultSerialPortNone;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_.pageSettingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.usb, color: Colors.blue),
                  title: Text(_.pageSettingsDevice),
                  subtitle: Text(data.deviceState ? _.pageHomeDeviceOnline : _.pageHomeDeviceOffline),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: _.pageSettingsDevice,
                        child: Switch(
                          value: data.deviceState,
                          onChanged: (_) {
                            if (data.serialState) {
                              data.closeSerialPort(onClose: (ok, message) {
                                if (ok) return;
                                final _ = AppLocalizations.of(context)!;
                                if (message == Data.defaultSerialPortNone) message = _.pageSettingsSerialPortIsNone;
                                ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(
                                  content: Text(message),
                                ));
                              });
                            } else {
                              data.openSerialPort(onOpen: (ok, message) {
                                if (ok) return;
                                final _ = AppLocalizations.of(context)!;
                                if (message == Data.defaultSerialPortNone) message = _.pageSettingsSerialPortIsNone;
                                ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(
                                  content: Text(message),
                                ));
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.linear_scale),
                  title: Text(_.pageSettingsSerialPort),
                  subtitle: Text(data.serialPort == Data.defaultSerialPortNone ? _.pageSettingsNone : data.serialPort),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (data.debug) IconButton(
                        tooltip: _.pageSettingsOpenSerialPort,
                        icon: const Icon(Icons.layers),
                        onPressed: () {
                          data.openSerialPort(onOpen: (ok, message) {
                            if (ok) return;
                            if (message == Data.defaultSerialPortNone) message = _.pageSettingsSerialPortIsNone;
                            ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(
                              content: Text(message),
                            ));
                          });
                        },
                      ),
                      if (data.debug) IconButton(
                        tooltip: _.pageSettingsCloseSerialPort,
                        icon: const Icon(Icons.layers_clear),
                        onPressed: () {
                          data.closeSerialPort(onClose: (ok, message) {
                            if (ok) return;
                            if (message == Data.defaultSerialPortNone) message = _.pageSettingsSerialPortIsNone;
                            ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(
                              content: Text(message),
                            ));
                          });
                        },
                      ),
                      IconButton(
                        tooltip: _.pageSettingsRefresh,
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          api.getSerialPortListFrom().then((serialPortList) {
                            if (serialPortList.isNotEmpty) {
                              data.serialPortList = serialPortList;
                            }
                          });
                        },
                      ),
                      PopupMenuButton(
                        itemBuilder: (context) {
                          return data.serialPortList.map((port){
                            return CheckedPopupMenuItem(
                              checked: data.serialPort == port,
                              value: port,
                              child: Text(port == Data.defaultSerialPortNone ? port = _.pageSettingsNone : port)
                            );
                          }).toList();
                        },
                        onSelected: (String value){
                          if (data.serialState) data.closeSerialPort();
                          data.serialPort = value;
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.compare_arrows),
                  title: Text(_.pageSettingsBaudRate),
                  subtitle: Text(data.baudRate),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton(
                        itemBuilder: (context) {
                          return baudRates.map((baudRate){
                              return CheckedPopupMenuItem(
                                checked: data.baudRate == '$baudRate',
                                value: '$baudRate',
                                child: Text('$baudRate')
                              );
                          }).toList();
                        },
                        onSelected: (String value){
                          if (data.serialState) data.closeSerialPort();
                          data.baudRate = value;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.assistant_photo, color: Colors.blue),
                  title: Text(_.pageSettingsLanguage),
                  subtitle: Text(_.pageSettingsInputLanguage(selectedLocale)),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        CheckedPopupMenuItem(
                          checked: selectedLocale == 'en',
                          value: 'en',
                          child: Text(_.pageSettingsInputLanguage('en')),
                        ),
                        CheckedPopupMenuItem(
                          checked: selectedLocale == 'ko',
                          value: 'ko',
                          child: Text(_.pageSettingsInputLanguage('ko')),
                        ),
                      ];
                    },
                    onSelected: (String value){
                      data.locale = value;
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: Text(_.pageSettingsDebugMode),
                  trailing: Tooltip(
                    message: _.pageSettingsDebugMode,
                    child: Checkbox(
                      value: data.debug,
                      onChanged: (value) {
                        if (value != null) data.debug = value;
                      },
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: Text(_.pageSettingsDemoMode),
                  trailing: Tooltip(
                    message: _.pageSettingsDemoMode,
                    child: Checkbox(
                      value: data.demo,
                      onChanged: (value) {
                        if (value != null) {
                          data.demo = value;
                          if (value) {
                            data.initReportDemo(_.pageReportDescription);
                          } else {
                            data.clearReport(name: _.pageReportDescription);
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.priority_high, color: Colors.blue),
                title: Text(_.pageSettingsInfo),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: _.pageSettingsCopyInfo,
                      icon: const Icon(Icons.content_copy),
                      onPressed: () async {
                        final info = 
                          '${_.pageSettingsDeviceState}: (${data.deviceState})\n'
                          '${_.pageSettingsSerialPortState}: ${data.serialPort} (${data.deviceState})\n'
                          '${_.pageSettingsWebSocketID}: ${data.websocketID} ($websocketState)\n'
                          '${_.pageSettingsOriginURL}: ${api.originUrl}\n' 
                          '${_.pageSettingsMiddlewareURL}: ${api.baseUrl}\n'
                          '${_.pageSettingsWebSocketURL}: ${api.wsUrl}\n'
                          '${_.pageSettingsLoggingPath}: ${data.loggingPath}\n'
                          '${_.pageSettingsPlatform}: ${data.projectVersion}\n'
                          '${_.pageSettingsMiddleware}: ${data.middlewareVersion}\n'
                          '\n'
                          'Copyright © AIRCAT Co, Ltd. developed by ilshookim';
                        await Clipboard.setData(ClipboardData(text: info));
                      },
                    ),
                ]),
              ),
              ListTile(
                leading: const Icon(Icons.keyboard_arrow_right),
                title: Text(_.pageSettingsWebSocketID),
                subtitle: StreamBuilder(
                  stream: data.stream,
                  builder: (context, snapshot) {
                    websocketState = '${snapshot.connectionState}';
                    return Text('${snapshot.data} (${snapshot.connectionState})');
                  },
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (data.debug) IconButton(
                      tooltip: _.pageSettingsCheckWebSocket,
                      icon: const Icon(Icons.done_all),
                      onPressed: () async {
                        data.sendJson({'type': 'echo', 'msg': 'Welcome!'});
                      },
                    ),
                    if (data.debug) IconButton(
                      tooltip: _.pageSettingsReconnectWebSocket,
                      icon: const Icon(Icons.sync),
                      onPressed: () {
                        data.disconnectWebSocket();
                      },
                    ),
                ]),
              ),
              if (data.debug) ListTile(
                leading: const Icon(Icons.keyboard_arrow_right),
                title: Text(_.pageSettingsWebSocketURL),
                subtitle: Text(api.wsUrl),
              ),
              if (data.debug) ListTile(
                leading: const Icon(Icons.keyboard_arrow_right),
                title: Text(_.pageSettingsMiddlewareURL),
                subtitle: Text(api.baseUrl),
              ),
              if (data.debug) ListTile(
                leading: const Icon(Icons.keyboard_arrow_right),
                title: Text(_.pageSettingsOriginURL),
                subtitle: Text(api.originUrl),
              ),
              if (data.debug) ListTile(
                leading: const Icon(Icons.keyboard_arrow_right),
                title: Text(_.pageSettingsLoggingPath),
                subtitle: Text(data.loggingPath),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: _.pageSettingsCopyInfo,
                      icon: const Icon(Icons.content_copy),
                      onPressed: () {
                        final info = data.loggingPath;
                        Clipboard.setData(ClipboardData(text: info));
                      },
                    ),
                ]),
              ),
              ListTile(
                leading: const Icon(Icons.keyboard_arrow_right),
                title: Text(_.pageSettingsPlatform),
                subtitle: Text(data.projectVersion),
              ),
              ListTile(
                leading: const Icon(Icons.keyboard_arrow_right),
                title: Text(_.pageSettingsMiddleware),
                subtitle: Text(data.middlewareVersion),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
