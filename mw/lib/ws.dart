import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:nanoid/nanoid.dart';
import 'package:shelf_plus/shelf_plus.dart';

import 'localbus.dart';

final logger = Logger('ws');
final connections = {};

Handler router() {
  localBus.on('serial', null, (ev, context) {
    connections.forEach((uid, ws) => ws.send('You sent me: ${ev.eventData}'));
    logger.info("${ev.eventName} - ${ev.eventData} to ${connections.length}");
  });

  final app = Router().plus;

  app.get('/', (Request req) => WebSocketSession(
    onOpen: (ws) {
      final uid = nanoid(10);
      connections[uid] = ws;
      logger.info('Websocket $uid connected');
    },
    onMessage: (ws, data) {
      final connection = connections.entries.firstWhere((element) => element.value == ws);
      final uid = connection.key;
      final payload = parseJson(data);
      final json = payload is! String;
      final echo = json && payload['type'] == 'echo';
      final log = json && payload['type'] == 'log';

      // {'type': 'echo', 'msg': 'Welcome!'}
      // {'type': 'log', 'level': 'info', 'logger': 'App', 'msg': 'Logging'}
      // {'msg': 'relayed to serial port'}
      // others 'relayed to serial port'
      if (echo) {
        ws.send(payload['msg']);
      } else if (log) {
        logger.info('Websocket $uid ${payload['msg']}');
      } else if (json) {
        localBus.emit('ws', null, {uid: uid, data: payload['msg']});
      } else {
        localBus.emit('ws', null, {'uid': uid, 'data': data});
      }
    },
    onClose: (ws) {
      final connection = connections.entries.firstWhere((element) => element.value == ws);
      final uid = connection.key;
      connections.remove(uid);
      logger.info('Websocket $uid disconnected');
    },
    onError: (ws, err) {
      final connection = connections.entries.firstWhere((element) => element.value == ws);
      final uid = connection.key;
      logger.warning('Websocket $uid error $err');
      connections.remove(uid);
    },
  ));

  return app;
}

parseJson(payload) {
  dynamic parsed;
  try {
    parsed = jsonDecode(payload);
  } catch (e) {
    parsed = payload;
  }
  return parsed;
}
