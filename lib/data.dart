import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
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
  static const defaultDemo = false;
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

  String get platform => api.getStringCache('platform');
  String get platformVersion => api.getStringCache('platformVersion');
  String get middlewareVersion => api.getStringCache('middlewareVersion');
  String get projectVersion => api.getStringCache('projectVersion');
  String get loggingPath => api.getStringCache('loggingPath');

  bool get debug => api.getBoolCache('debug');
  set debug(bool debug) => api.setConfigTo('debug', debug).then((_) => notifyListeners());

  bool _demo = api.getBoolCache('demo', defaults: defaultDemo);
  bool get demo => _demo;
  set demo(bool demo) {
    _demo = demo;
    api.setConfigTo('demo', demo).then((_) => notifyListeners());
  }

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

  bool demoInit = false;
  bool demoReport = false;
  void initReportDemo(description) {
    importReportFromBytes(Uint8List.fromList(_csv.codeUnits), description, redraw: false);
    demoInit = true;
    demoReport = true;
  }

  String reportName = '';
  final List<String> reportTitles = [];
  final List<List<double>> reportSeries = [];
  void clearReport({name = ''}) { reportName = name; reportTitles.clear(); reportSeries.clear(); }
  bool importReportFromBytes(Uint8List bytes, String fileName, {redraw = true}) {
    List<List<dynamic>> reportData = [];
    try {
      String csv = utf8.decode(bytes.toList());
      reportData = const CsvToListConverter(fieldDelimiter: '\t').convert(csv, eol: '\n');
    }
    catch (exc) {
      logger.warning('invalid CSV format $exc');
      return false;
    }
    clearReport(name: fileName);
    for (int i=0; i<reportData.length; i++) {
      reportData[i].removeAt(0);
      if (i == 0) {
        for (final channel in reportData[i]) {
          reportTitles.add(channel.trim());
          reportSeries.add([]);
        }
      } else {
        var j = 0;
        for (final value in reportData[i]) {
          reportSeries[j++].add(value);
        }
      }
    }
    demoReport = false;
    if (redraw) notifyListeners();
    return true;
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

const _csv =
'''
	series 1	series 2	series 3	series 4	series 5	series 6	series 7	series 8	series 9
1	1945	0	23.25	1832	1605	1941	129	141	1541
2	2012	67	90.25	1850	1608	1993	142	144	1544
3	2016	71	94.25	1854	1615	1906	138	139	1539
4	2015	70	93.25	1868	1609	2013	142	129	1529
5	2033	88	111.25	1858	1598	1468	129	142	1542
6	2034	89	112.25	1880	1606	2052	141	138	1538
7	2039	94	117.25	1898	1604	1494	145	142	1542
8	2012	67	90.25	1901	1624	1494	135	129	1529
9	1990	45	68.25	1918	1601	1498	131	141	1541
10	2002	57	80.25	1929	1594	1533	130	145	1545
11	2007	62	85.25	1956	1610	1488	140	135	1535
12	2032	87	110.25	1969	1608	1453	126	131	1531
13	2024	79	102.25	1986	1573	1488	136	130	1530
14	2011	66	89.25	1974	1597	1462	130	140	1540
15	2007	62	85.25	1950	1608	1465	133	126	1526
16	2024	79	102.25	1917	1614	1488	133	136	1536
17	2036	91	114.25	1920	1618	1434	130	130	1530
18	2037	92	115.25	1944	1629	1404	140	133	1533
19	2052	107	130.25	1923	1619	1439	147	133	1533
20	2105	160	183.25	1934	1625	1429	132	130	1530
21	2158	213	236.25	1938	1616	1460	134	140	1540
22	2223	278	301.25	1945	1609	1496	132	147	1547
23	2305	360	383.25	1946	1577	1495	150	132	1532
24	2376	431	454.25	1958	1619	1535	170	134	1534
25	2421	476	499.25	1970	1611	1562	180	132	1532
26	2469	524	547.25	1973	1636	1635	250	150	1541
27	2496	551	574.25	1948	1637	1728	512	170	1532
28	2536	591	614.25	1947	1649	1757	758	180	1549
29	2564	619	642.25	1946	1665	1802	1024	250	1556
30	2575	630	653.25	1925	1686	1825	1355	512	1557
31	2617	672	695.25	1941	1689	1911	1536	758	1577
32	2598	653	676.25	1946	1723	1922	1786	1024	1595
33	2653	708	731.25	1952	1676	1957	2048	1355	1659
34	2654	709	732.25	1952	1672	1933	3566	1536	1743
35	2570	625	648.25	1965	1683	1995	3578	1786	1877
36	2583	638	661.25	1979	1688	2003	4010	2048	2013
37	2606	661	684.25	1993	1692	2050	4022	3566	2162
38	2644	699	722.25	2033	1690	2055	4030	3578	2328
39	2639	694	717.25	2052	1692	2072	4031	4010	2457
40	2659	714	737.25	2080	1701	2079	4033	4022	2571
''';
