import 'package:feature_core/feature_core.dart';
import 'package:feature_flutter_example/_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TestFeaturesProvider extends FeaturesProvider {
  TestFeaturesProvider()
      : super(
          name: 'Test Provider',
          key: 'test_provider',
        );

  @override
  Future<Iterable<FeatureAbstract>> pullFeatures() async {
    return const [
      FeatureGeneric(key: 'feature1', value: 'first'),
      FeatureGeneric(key: 'feature2', value: 90),
    ];
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final features = FeaturesManagerStreamed(
    providers: [
      TestFeaturesProvider(),
    ],
  );

  await features.forceReloadFeatures();

  GetIt.instance.registerSingleton(features);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(title: 'Flutter Demo Home Page'),
    );
  }
}
