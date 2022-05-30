import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:sync_publish/export.dart';

import 'increment_command.dart';
import 'sync_command.dart';

Future<void> main(List<String> arguments) async {
  final entrypoint = Entrypoint(Directory.current);

  final runner = CommandRunner('sync', 'Sync all packages');
  runner.addCommand(VersioningPackagesCommand(entrypoint));
  runner.addCommand(IncrementVersionsCommand(entrypoint));
  runner.run(arguments).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64); // Exit code 64 indicates a usage error.
  });
}
