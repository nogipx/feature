import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:sync_publish/export.dart';

import 'increment_command.dart';
import 'sync_command.dart';

Future<void> main(List<String> arguments) async {
  final entrypoint = Entrypoint(Directory.current);

  if (await entrypoint.containsPubspec()) {
    print('Current directory contains pubspec. Go to parent directory.');
    exit(64);
  }

  final runner = CommandRunner('sync_publish', 'Sync all packages');
  runner.addCommand(VersioningPackagesCommand(
    entrypoint,
    onSync: (package) {
      entrypoint.updateReadmeCoreVersion(
          package: package, version: package.version);
    },
  ));
  runner.addCommand(IncrementVersionsCommand(entrypoint));
  runner.run(arguments).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64); // Exit code 64 indicates a usage error.
  });
}
