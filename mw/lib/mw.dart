import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_plus/shelf_plus.dart';

import 'ws.dart' as ws;
import 'serial.dart' as serial;
import 'config.dart' as config;

Handler runMiddleware() {
  final app = Router().plus;

  app.use(corsHeaders());

  final public = path.normalize(path.absolute(path.join(Platform.script.toFilePath(), '../../..', 'web')));
  final static = createStaticHandler(public, defaultDocument: 'index.html');
  final router = cascade([
    config.router(),
    serial.router(),
    ws.router(),
    static,
    app,
  ]);

  app.get('/hello', () => 'Welcome!');

  return router;
}
