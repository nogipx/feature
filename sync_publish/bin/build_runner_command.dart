import 'package:args/command_runner.dart';
import 'package:sync_publish/export.dart';
import 'package:collection/collection.dart';

class StartBuildRunnerCommand extends Command {
  @override
  final String name = "runner";
  @override
  final String description = "Build runner";

  final Entrypoint entrypoint;

  StartBuildRunnerCommand(this.entrypoint) {
    argParser.addOption(
      'build',
      abbr: 'b',
      help: 'Run build runner for package',
      valueHelp: 'your_package',
    );
    argParser.addFlag(
      'buildAll',
      abbr: 'B',
      help: 'Run build runner for all packages',
    );
  }

  @override
  void run() async {
    final args = argResults!;

    if (args.wasParsed('build')) {
      final name = args.arguments[1];
      final package =
          entrypoint.getPackages().firstWhereOrNull((e) => e.name == name);
      if (package != null) {
        package.startBuildRunner();
      }
    }
    if (args.wasParsed('buildAll')) {
      final packages = entrypoint.getPackages();
      for (final package in packages) {
        await package.startBuildRunner();
      }
    }
  }
}
