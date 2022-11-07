import 'package:logging/logging.dart';
import 'package:shelf_plus/shelf_plus.dart';

import 'localbus.dart';

final logger = Logger('serial');
final serials = {};

Handler router() {
  final app = Router().plus;

  localBus.on('ws', null, (ev, context) {
    logger.info("${ev.eventName} - ${ev.eventData}");
  });

  app.get('/serial', () {
    localBus.emit('serial', null, 'I am a serial');
    return 'I am a serial';
  });

  return app;
}
