// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class Api {
  static final instance = Api();
  static final homeUrl = Uri.parse(window.location.href);
  static const defaultUrl = 'http://localhost:8090';

  late String wsUrl;
  late String baseUrl;
  late String originUrl;
  final Map cache = {};
  final logger = Logger('Api');

  get debug => cache['debug'] != null && cache['debug'] == '${true}';

  Api() {
    originUrl = '$homeUrl';
    baseUrl = homeUrl.isScheme('http') && homeUrl.host != 'localhost' ? _makeUrl(originUrl, scheme: 'http') : defaultUrl;
    wsUrl = _makeUrl(baseUrl);
    if (debug) {
      logger.config('originUrl: $originUrl');
      logger.config('baseUrl: $baseUrl');
      logger.config('wsUrl: $wsUrl');
    }
  }

  String _makeUrl(origin, {String scheme = 'ws'}) {
    final uri = Uri.parse(origin);
    final url = uri.hasPort ? '$scheme://${uri.host}:${uri.port}' : '$scheme://${uri.host}';
    return url;
  }

  void _setCache(key, value) {
    cache[key] = value;
    logger.config('set cache $key to $value');
  }

  Future getConfigFrom(key) async {
    final url = Uri.parse('$baseUrl/config/$key');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      logger.severe(response.body);
      return cache[key];
    }
    logger.info(response.body);
    final body = json.decode(response.body);
    final config = body['config'];
    _setCache(key, config['value']);
    return cache[key];
  }

  Future setConfigTo(key, value) async {
    final url = Uri.parse('$baseUrl/config/$key');
    final response = await http.put(url,
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: jsonEncode({ 'value': value })
    );
    if (response.statusCode != 200) {
      logger.severe(response.body);
      return cache[key];
    }
    logger.info(response.body);
    _setCache(key, value);
    return cache[key];
  }

  Future getConfigListFrom() async {
    final url = Uri.parse('$baseUrl/config');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      logger.severe(response.body);
      return [];
    }
    logger.fine(response.body);
    final body = json.decode(response.body);
    final configs = body['configs'];
    for (final config in configs) {
      final key = config['key'];
      final value = config['value'];
      _setCache(key, value);
    }
    return configs;
  }

  Future getSerialPortListFrom() async {
    const key = 'serialPortList';
    final url = Uri.parse('$baseUrl/serial');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      logger.severe(response.body);
      return List<String>.empty();
    }
    logger.info(response.body);
    final body = json.decode(response.body);
    final portList = List<String>.from(body['portList'] as List);
    _setCache(key, portList);
    return cache[key];
  }

  Future openSerialPortTo(path, baudRate) async {
    final url = Uri.parse('$baseUrl/serial/open');
    final response = await http.post(url,
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: jsonEncode({ 'path': path, 'baudRate': int.parse(baudRate) })
    );
    if (response.statusCode != 200) {
      logger.severe(response.body);
    } else {
      logger.info(response.body);
    }
    final body = json.decode(response.body);
    return body;
  }

  Future closeSerialPortTo(path) async {
    final url = Uri.parse('$baseUrl/serial/close');
    final response = await http.post(url,
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: jsonEncode({ 'path': path })
    );
    if (response.statusCode != 200) {
      logger.severe(response.body);
      return false;
    }
    logger.info(response.body);
    final body = json.decode(response.body);
    final ok = body['ok'] ?? false;
    return ok;
  }
}
