import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_plus/shelf_plus.dart';

import 'ws.dart' as ws;
import 'serial.dart' as serial;
import 'config.dart' as config;

Handler router() {
  final app = Router().plus;

  app.use(corsHeaders());

  app.get('/hello', () => 'Welcome!');

  final public = createStaticHandler(
    path.normalize(path.absolute(path.join(Platform.script.toFilePath(), '../../..', 'web'))),
    defaultDocument: 'index.html');

  final router = cascade([
    config.router(),
    serial.router(),
    ws.router(),
    public,
    app,
  ]);

  return router;
}
