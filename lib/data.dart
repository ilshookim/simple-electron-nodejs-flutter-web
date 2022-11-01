import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';

import 'api.dart';

class Data extends ChangeNotifier {
  static const defaultLocale = 'en';
  static const defaultBaudRate = '115200';
  static const defaultSerialPort = '';
  static const defaultSerialPortNone = 'none';
  static final api = Api.instance;

  final logger = Logger('Data');
  bool _serialState = false;
  String _locale = api.cache['locale'] ?? defaultLocale;
  String _baudRate = api.cache['baudRate'] ?? defaultBaudRate;
  String _serialPort = api.cache['serialPort'] ?? defaultSerialPort;
  List<String> _serialPortList = [defaultSerialPortNone];
  final StreamController<String> _wsRecipientCtrl = StreamController<String>();
  final StreamController<String> _wsSentCtrl = StreamController<String>();
  WebSocketChannel? _wsChannel;
  String _wsID = '';

  bool get deviceState => _serialState && _wsID.isNotEmpty;
  bool get serialState => _serialState;
  String get locale => _locale;
  String get baudRate => _baudRate;
  String get serialPort => _serialPortList.firstWhere((port) => port == _serialPort, orElse: () => Data.defaultSerialPortNone);
  List<String> get serialPortList => _serialPortList;
  get stream => _wsRecipientCtrl.stream;
  get sink => _wsSentCtrl.sink;
  get websocketID => _wsID;
  get debug => api.debug;
  String get platform => api.cache['platform'];
  String get platformVersion => api.cache['platformVersion'];
  String get middlewareVersion => api.cache['middlewareVersion'];
  String get projectVersion => api.cache['projectVersion'];
  String get loggingPath => api.cache['loggingPath'];

  static void init(done) {
    Data.initLogger();

    final logger = Logger('Data');
    logger.info('init');
    Future.wait([
      api.getConfigListFrom(),
      api.getSerialPortListFrom(),
    ]).whenComplete(() {
      logger.info('done');
      done();
    });
  }

  static void initLogger({transfer, level = Level.CONFIG}) {
    Logger.root.clearListeners();
    Logger.root.level = level;
    Logger.root.onRecord.listen((record) {
      transfer?.sendJson({'type': 'log', 'level': record.level.name, 'name': record.loggerName, 'msg': record.message});
      debugPrint('[${record.time}][${record.level.name}][${record.loggerName}] ${record.message}');
    });
  }

  Data() {
    final serialPortList = api.cache['serialPortList'];
    if (serialPortList != null && serialPortList.isNotEmpty) {
      setSerialPortList(serialPortList);
    }

    _wsSentCtrl.stream.listen((event) {
      _wsChannel?.sink.add(event);
    });

    openSerialPort();

    _connectAndRetryWebSocket();
    logger.info('connect websocket (automatically): ${api.wsUrl}');
  }

  @override
  void dispose() {
    _wsChannel?.sink.close();
    super.dispose();
  }

  void setDebug(bool debug) {
    api.cache['debug'] = '$debug';
    notifyListeners();
    api.setConfigTo('debug', '$debug');
  }

  void setLocale(String locale) {
    _locale = locale;
    notifyListeners();
    api.setConfigTo('locale', locale);
  }

  void setBaudRate(String baudRate) {
    _baudRate = baudRate;
    notifyListeners();
    api.setConfigTo('baudRate', baudRate);
  }

  void setSerialPort(String serialPort) {
    _serialPort = serialPort;
    notifyListeners();
    api.setConfigTo('serialPort', serialPort);
  }

  void setSerialPortList(List<String> serialPortList) {
    serialPortList.insert(0, defaultSerialPortNone);
    _serialPortList = serialPortList;
    notifyListeners();
  }

  void _connectAndRetryWebSocket({int delay = 3}) {
    _wsChannel ??= WebSocketChannel.connect(Uri.parse(api.wsUrl));

    _wsChannel?.stream.listen((event) {
      _wsRecipientCtrl.add(event);
      if (_wsID.isEmpty) {
        logger.info('connected websocket: $event');
        _wsID = event;
        notifyListeners();
      }
    }, onError: (e) async {
      logger.warning('connect websocket: $e');
      _wsRecipientCtrl.addError(e);
      _wsChannel?.sink.close();
      _wsChannel = null;
      if (_wsID.isNotEmpty) {
        _wsID = '';
        notifyListeners();
      }
      Future.delayed(Duration(seconds: delay)).then((_) => _connectAndRetryWebSocket(delay: delay));
    }, onDone: () async {
      logger.info('connect websocket: done');
      _wsChannel = null;
      if (_wsID.isNotEmpty) {
        _wsID = '';
        notifyListeners();
      }
      Future.delayed(Duration(seconds: delay)).then((_) => _connectAndRetryWebSocket(delay: delay));
    }, cancelOnError: true);
  }

  void disconnectWebSocket() {
    logger.info('disconnect websocket');
    _wsChannel?.sink.close();
    _wsRecipientCtrl.add('disconnect');
  }

  void sendJson(payload) {
    _wsSentCtrl.sink.add(json.encode(payload));
  }

  Future openSerialPort() async {
    if (serialPort == defaultSerialPortNone) return {'ok': false, 'message': defaultSerialPortNone};
    final result = await api.openSerialPortTo(serialPort, baudRate);
    if (result['ok'] ?? false) _serialState = true;
    notifyListeners();
    return result;
  }

  bool closeSerialPort() {
    if (serialPort == defaultSerialPortNone) return false;
    api.closeSerialPortTo(serialPort).then((ok) {
      if (ok) {
        _serialState = false;
        notifyListeners();
      }
    });
    return true;
  }
}
