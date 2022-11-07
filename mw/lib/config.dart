import 'package:shelf_plus/shelf_plus.dart';

Handler router() {
  final app = Router().plus;

  app.get('/config', () => 'I am a config');

  return app;
}
