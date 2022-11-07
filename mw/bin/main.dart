import 'dart:io';

import 'package:mw/mw.dart' as mw;
import 'package:shelf_plus/shelf_plus.dart';

final port = int.parse(Platform.environment['PORT'] ?? '8090');

void main(List<String> arguments) => shelfRun(mw.runMiddleware, defaultBindPort: port);
