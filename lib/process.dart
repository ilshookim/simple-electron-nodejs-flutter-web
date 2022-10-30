import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProcessOne extends StatelessWidget {
  const ProcessOne({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_.pageHomeTitle),
        actions: [
          IconButton(
            tooltip: _.pageHomeProcessNext,
            icon: const Icon(Icons.done),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProcessThreeSwitch()));
            },
          ),
        ],      
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_.pageHomeProcessQRCode, style: Theme.of(context).textTheme.headline4),
              Container(height: 40),
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

class ProcessThreeSwitch extends StatelessWidget {
  const ProcessThreeSwitch({super.key});

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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  Container(width: 40),
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

class MainProcessStatus extends StatelessWidget {
  const MainProcessStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_.pageHomeTitle),
        actions: [
          IconButton(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_.pageHomeProcessMainProcessSystemStatus, style: Theme.of(context).textTheme.headline4),
              Container(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
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
                  Container(width: 40),
                  SizedBox(
                    height: 40,
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // 실시간 보기
                      }, 
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      icon: const Icon(Icons.timeline),
                      label: Text(_.pageHomeProcessRealtimeReport),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  Container(width: 40),
                  SizedBox(
                    height: 40,
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProcessOne()));
                      }, 
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      icon: const Icon(Icons.refresh),
                      label: Text(_.pageHomeProcessRestart),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
