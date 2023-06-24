import 'package:feature_core/feature_core.dart';
import 'package:feature_flutter_example/_main_screen.dart';
import 'package:flutter/material.dart';

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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final features = FeaturesManager(providers: [
    TestFeaturesProvider(),
  ]);

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
