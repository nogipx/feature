import 'env_value.dart';

class BuildConfig {
  final Set<EnvProperty> props;

  const BuildConfig({
    this.props = const {},
  });
}

void main() {}

Future buildApp(BuildConfig config) async {}
