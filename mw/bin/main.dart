import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:shelf_plus/shelf_plus.dart';

import 'package:mw/mw.dart' as mw;

final logger = Logger.root;
final port = int.parse(Platform.environment['PORT'] ?? '8090');

void main() {
  initLogger();

  shelfRun(mw.router, defaultBindPort: port)
    .then((server) => initLogger(shelfDone: true))
    .onError((error, stackTrace) => logger.shout('abnormal exited', error, stackTrace));

  ProcessSignal.sigint.watch().listen((signal) {
    logger.info('middleware shutting down - SIGINT (Crtl-C)');
    exit(0);
  });

  ProcessSignal.sigterm.watch().listen((signal) {
    logger.info('middleware killed - SIGTERM fired');
  });    
}

void initLogger({shelfDone = false}) {
  final file = File(
    Platform.isLinux ? '${Platform.environment['HOME']}/.config/wapui/logs/main.log' : 
    Platform.isMacOS ? '${Platform.environment['HOME']}/Library/Logs/wapui/main.log' : 
    Platform.isWindows ? '${Platform.environment['USERPROFILE']}\\AppData\\Roaming\\wapui\\logs\\main.log' : 'main.log'
  );
  if (!file.existsSync()) file.createSync(recursive: true);

  if (shelfDone) logger.clearListeners();
  logger.onRecord.listen((record){
    final message = '${record.level.name}: ${record.time}: ${record.message}';
    unawaited(file.writeAsString('$message\n', mode: FileMode.append));
    print(message);
  });

  logger.level = Level.ALL;
  if (shelfDone) logger.info('middleware logging in ${file.path}');
}
