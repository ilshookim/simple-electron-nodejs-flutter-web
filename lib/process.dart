import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:video_player/video_player.dart';

import 'api.dart';

class ProcessWelcomeVideo extends StatefulWidget {
  const ProcessWelcomeVideo({super.key});

  @override
  State<ProcessWelcomeVideo> createState() => _ProcessWelcomeVideoState();
}

class _ProcessWelcomeVideoState extends State<ProcessWelcomeVideo> {
  final localVideoUrl = '${Api.instance.baseUrl}/bee.mp4';
  final remoteVideoUrl = 'https://github.com/flutter/plugins/raw/main/packages/video_player/video_player/example/assets/Butterfly-209.mp4';
  final mediaWidth = 1280 * 0.5, mediaHeight = 720 * 0.5;

  late VideoPlayerController _controller;
  var videoPlayerController = false;
  var remoteVideo = false;

  void loadVideo({int howLongDelaySeconds = 1}) {
    if (videoPlayerController) {
      setState(() {
        _controller.dispose();
      });
    }
    _controller = VideoPlayerController.network(remoteVideo ? remoteVideoUrl : localVideoUrl)
      ..setLooping(true)
      ..initialize().then((_) {
        videoPlayerController = true;
        Future.delayed(Duration(seconds: howLongDelaySeconds), () => setState(() {
          _controller.play();
        }));
        if (remoteVideo) {
          ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(
            content: Text(remoteVideoUrl),
          ));
        }
      });
  }

  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _ = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_.pageHomeTitle),
        actions: [
          Center(child: Text(_.pageHomeProcessWelcomeLocalVideo)),
          Tooltip(
            message: _.pageHomeProcessWelcomeSwitchVideo,
            child: Switch(
              activeColor: Colors.white,
              value: remoteVideo,
              onChanged: (value) {
                remoteVideo = value;
                loadVideo();
              },
            ),
          ),
          Center(child: Text(_.pageHomeProcessWelcomeRemoteVideo)),
          const VerticalDivider(),
          IconButton(
            tooltip: _.pageHomeProcessNext,
            icon: const Icon(Icons.done),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProcessAsk()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_.pageHomeProcessWelcome),
              Container(height: 10),
              Stack(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: mediaWidth, maxHeight: mediaHeight),
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: _controller.value.isInitialized ? VideoPlayer(_controller) : Container(),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: mediaWidth, maxHeight: mediaHeight),
                    child: Center(
                      child: !_controller.value.isInitialized || _controller.value.isBuffering
                        ? const CircularProgressIndicator()
                        : FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        onPressed: () {
                          setState(() {
                            _controller.value.isPlaying ? _controller.pause() : _controller.play();
                          });
                        },
                        child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                      ),
                    ),
                  ),
                ],
              ),
              Container(height: 10),
              SizedBox(
                height: 40,
                width: 200,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.keyboard_backspace),
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  label: Text(_.pageHomeProcessCancel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProcessAsk extends StatelessWidget {
  const ProcessAsk({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_.pageHomeTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_.pageHomeProcessCorrect, style: Theme.of(context).textTheme.headline4),
              Container(height: 40),
              Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                runSpacing: 14,
                children: [
                  SizedBox(
                    height: 40,
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }, 
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      icon: const Icon(Icons.home),
                      label: Text(_.pageHomeProcessHome),
                    ),
                  ),
                  const VerticalDivider(),
                  SizedBox(
                    height: 40,
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MainProcess()));
                      },
                      child: Text(_.pageHomeProcessOk),
                    ),
                  ),
                  const VerticalDivider(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainProcess extends StatelessWidget {
  const MainProcess({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_.pageHomeTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_.pageHomeProcessMainProcess, style: Theme.of(context).textTheme.headline4),
              Container(height: 40),
              SizedBox(
                height: 40,
                width: 200,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MainProcessStatus()));
                  },
                  label: Text(_.pageHomeProcessRun),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainProcessStatus extends StatefulWidget {
  const MainProcessStatus({super.key});

  @override
  State<MainProcessStatus> createState() => _MainProcessSystemStatusState();
}

class _MainProcessSystemStatusState extends State<MainProcessStatus> {
  final logger = Logger('MainProcessStatus');
  final example = [
    "[Proc 1]..[in here message]",
    "[Proc 2]..[in here message]",
    "[Proc 3]..[in here message]",
    "[Proc 4]..[in here message]",
    "[Proc 5]..[in here message]",
    "[Proc 6]..[in here message]",
    "[Proc 7]..[in here message]",
    "[Proc 8]..[in here message]",
    "[Proc 9]..[in here message]",
    "[Proc 10]..[in here message]",
    "[Proc 11]..[in here message]",
    "[Proc 12]..[in here message]",
    "[Proc 13]..[in here message]",
    "[Proc 14]..[in here message]",
    "[Proc 15]..[procedure is done]"
  ];
  int step = 0;
  bool stepsDone = false;
  final int stepsTotal = 15;
  final stepsStatus = <String>[];

  Timer? _timer;
  void startTimerRandomly({min=800, max=1800}) {
    final random = Random();
    final randomDuration = Duration(milliseconds: min + random.nextInt(max - min));
    _timer?.cancel();
    _timer = Timer.periodic(randomDuration, (Timer timer) {
      setState(() {
        stepsStatus.add(json.encode({
          'step': step + 1,
          'time': DateFormat("HH:mm:ss").format(DateTime.now()),
          'status': example[step],
        }));
      });
      step++;
      stepsDone = step >= stepsTotal || step >= example.length;
      if (stepsDone) {
        timer.cancel();
      } else {
        startTimerRandomly();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    stepsStatus.add(json.encode({
      'step': step,
      'time': DateFormat("HH:mm:ss").format(DateTime.now()),
      'status': '[Proc 0]..[procedure is ready]',
    }));
    startTimerRandomly();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _ = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text(_.pageHomeTitle)),
        actions: [
          if (!stepsDone) IconButton(
            tooltip: _.pageHomeProcessNext,
            icon: const Icon(Icons.done),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MainProcessDone()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_.pageHomeProcessMainProcessSystemStatus, style: Theme.of(context).textTheme.headline4),
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    itemCount: stepsStatus.length,
                    itemBuilder:(context, index) {
                      final reverse = stepsStatus.length - index - 1;
                      final item = json.decode(stepsStatus[reverse]);
                      return Card(
                        child: ListTile(
                          tileColor: !stepsDone && reverse == step ? Colors.blue[50] : null,
                          leading: !stepsDone && reverse == step
                              ? const Icon(Icons.keyboard_arrow_right, color: Colors.blue)
                              : const Icon(Icons.keyboard_arrow_right),
                          title: Text(_.pageHomeProcessMainProcessStep(item['step'], stepsTotal)),
                          subtitle: Text(item['status']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.update),
                              Text(item['time']),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  if (!stepsDone) const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
            Container(height: 40),
            if (!stepsDone) SizedBox(
              height: 40,
              width: 200,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.stop),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                label: Text(_.pageHomeProcessStop),
              ),
            ),
            if (stepsDone) SizedBox(
              height: 40,
              width: 200,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.done),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MainProcessDone()));
                },
                label: Text(_.pageHomeProcessOk),
              ),
            ),
            Container(height: 60),
          ],
        ),
      ),
    );
  }
}

class MainProcessDone extends StatelessWidget {
  const MainProcessDone({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_.pageHomeTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_.pageHomeProcessMainProcessDone, style: Theme.of(context).textTheme.headline4),
              Container(height: 40),
              SizedBox(
                height: 40,
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProcessComplete()));
                  },
                  child: Text(_.pageHomeProcessOk),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProcessComplete extends StatelessWidget {
  const ProcessComplete({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_.pageHomeTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_.pageHomeProcessCompleted, style: Theme.of(context).textTheme.headline4),
              Container(height: 40),
              Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                runSpacing: 14,
                children: [
                  SizedBox(
                    height: 40,
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }, 
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      icon: const Icon(Icons.home),
                      label: Text(_.pageHomeProcessHome),
                    ),
                  ),
                  const VerticalDivider(),
                  SizedBox(
                    height: 40,
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProcessWelcomeVideo()));
                      }, 
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      icon: const Icon(Icons.refresh),
                      label: Text(_.pageHomeProcessRestart),
                    ),
                  ),
                  const VerticalDivider(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
