import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';

import 'api.dart';

typedef SerialPortCallback = void Function(bool ok, String message);

class Data extends ChangeNotifier {
  static const defaultLocale = 'en';
  static const defaultBaudRate = '115200';
  static const defaultSerialPort = '';
  static const defaultSerialPortNone = 'none';
  static const defaultReportLabel = false;
  static const defaultReportMarker = true;
  static const defaultReportLegend = true;
  static final api = Api.instance;

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

  final logger = Logger('Data');
  Data() {
    final serialPortList = api.getCache('serialPortList');
    if (serialPortList != null && serialPortList.isNotEmpty) {
      this.serialPortList = serialPortList;
    }
    _wsSentCtrl.stream.listen((event) {
      _wsChannel?.sink.add(event);
    });
    openSerialPort(onOpen: (ok, message) {
      logger.info('open serial (automatically): $ok ($message)');
    });
    _connectAndRetryWebSocket();
    logger.info('connect websocket (automatically): ${api.wsUrl}');
  }

  @override
  void dispose() {
    _wsChannel?.sink.close();
    super.dispose();
  }

  bool get demoForceStart => true;
  String get platform => api.getStringCache('platform');
  String get platformVersion => api.getStringCache('platformVersion');
  String get middlewareVersion => api.getStringCache('middlewareVersion');
  String get projectVersion => api.getStringCache('projectVersion');
  String get loggingPath => api.getStringCache('loggingPath');

  bool get debug => api.getBoolCache('debug');
  set debug(bool debug) => api.setConfigTo('debug', debug).then((_) => notifyListeners());

  String _locale = api.getStringCache('locale', defaults: defaultLocale);
  String get locale => _locale;
  set locale(String locale) {
    _locale = locale;
    api.setConfigTo('locale', locale).then((_) => notifyListeners());
  }

  String _baudRate = api.getStringCache('baudRate', defaults: defaultBaudRate);
  String get baudRate => _baudRate;
  set baudRate(String baudRate) {
    _baudRate = baudRate;
    api.setConfigTo('baudRate', baudRate).then((_) => notifyListeners());
  }

  String _serialPort = api.getStringCache('serialPort', defaults: defaultSerialPort);
  String get serialPort => _serialPortList.firstWhere((port) => port == _serialPort, orElse: () => Data.defaultSerialPortNone);
  set serialPort(String serialPort) {
    _serialPort = serialPort;
    api.setConfigTo('serialPort', serialPort).then((_) => notifyListeners());
  }

  List<String> _serialPortList = [defaultSerialPortNone];
  List<String> get serialPortList => _serialPortList;
  set serialPortList(List<String> serialPortList) {
    serialPortList.insert(0, defaultSerialPortNone);
    _serialPortList = serialPortList;
    notifyListeners();
  }

  bool _reportLabel = api.getBoolCache('reportLabel', defaults: defaultReportLabel);
  bool get reportLabel => _reportLabel;
  set reportLabel(bool reportLabel) {
    _reportLabel = reportLabel;
    api.setConfigTo('reportLabel', reportLabel).then((_) => notifyListeners());
  }

  bool _reportMarker = api.getBoolCache('reportMarker', defaults: defaultReportMarker);
  bool get reportMarker => _reportMarker;
  set reportMarker(bool reportMarker) {
    _reportMarker = reportMarker;
    api.setConfigTo('reportMarker', reportMarker).then((_) => notifyListeners());
  }

  bool _reportLegend = api.getBoolCache('reportLegend', defaults: defaultReportLegend);
  bool get reportLegend => _reportLegend;
  set reportLegend(bool reportLegend) {
    _reportLegend = reportLegend;
    api.setConfigTo('reportLegend', reportLegend).then((_) => notifyListeners());
  }

  final StreamController<String> _wsRecipientCtrl = StreamController<String>();
  final StreamController<String> _wsSentCtrl = StreamController<String>();
  get stream => _wsRecipientCtrl.stream;
  get sink => _wsSentCtrl.sink;
  WebSocketChannel? _wsChannel;
  get websocketID => _wsID;
  String _wsID = '';
  bool _serialState = false;
  bool get serialState => _serialState;
  bool get deviceState => _serialState && _wsID.isNotEmpty;

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

  Future openSerialPort({SerialPortCallback? onOpen}) async {
    if (serialPort == defaultSerialPortNone && onOpen != null) { onOpen(false, defaultSerialPortNone); return false; }
    final response = await api.openSerialPortTo(serialPort, baudRate);
    final ok = response['ok'] ?? false;
    if (!ok && onOpen != null) { onOpen(response['message'] ?? 'Unknown', ok); return false; }
    if (onOpen != null) onOpen(ok, serialPort);
    _serialState = true;
    notifyListeners();
    return true;
  }

  Future closeSerialPort({SerialPortCallback? onClose}) async {
    if (serialPort == defaultSerialPortNone && onClose != null) { onClose(false, defaultSerialPortNone); return false; }
    final response = await api.closeSerialPortTo(serialPort);
    final ok = response['ok'] ?? false;
    if (!ok && onClose != null) { onClose(response['message'] ?? 'Unknown', ok); return false; }
    if (onClose != null) onClose(ok, serialPort);
    _serialState = false;
    notifyListeners();
    return true;
  }
}
