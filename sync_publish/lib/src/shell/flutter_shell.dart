import 'dart:convert';
import 'dart:io';

import 'package:process_run/cmd_run.dart';
import 'package:process_run/shell.dart';

class FlutterCommand extends FlutterCmd {
  FlutterCommand(String cmd) : super(cmd.split(' '));

  @override
  Future<ProcessResult> run() => runCmd(this);
}

class FlutterShell {
  final Directory workingDirectory;

  String? _flutterPath;
  ShellLinesController? _lines;
  Shell? _shell;

  FlutterShell({
    required this.workingDirectory,
  });

  Stream<String> get eventStream {
    if (_lines != null) {
      return _lines!.stream;
    }
    throw Exception('Cannot get event stream: shell is not open.');
  }

  FlutterShell open() {
    _flutterPath = whichSync('flutter');
    if (_flutterPath == null) {
      throw Exception('Flutter executable not found.');
    }

    _lines = ShellLinesController(encoding: Utf8Codec());
    _shell = Shell(
      stdout: _lines!.sink,
      workingDirectory: workingDirectory.path,
    );
    return this;
  }

  bool get isOpen {
    return _flutterPath != null && _lines != null && _shell != null;
  }

  Future<void> run(String command) async {
    if (!isOpen) {
      open();
    }
    await _shell!.runExecutableArguments(
      _flutterPath!,
      command.split(' '),
    );
  }

  Future<void> runWithoutFlutter(String command, String options) async {
    if (!isOpen) {
      open();
    }
    await _shell!.runExecutableArguments(
      command,
      options.split(' '),
    );
  }

  void close() async {
    _shell?.kill();
    _shell = null;
    _lines?.close();
    _lines = null;
    _flutterPath = null;
  }
}