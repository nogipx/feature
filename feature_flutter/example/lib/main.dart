import 'dart:async';
import 'dart:math';

import 'package:feature_core/feature_core.dart';
import 'package:feature_flutter/feature_flutter.dart';
import 'package:feature_flutter_example/_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final class TestFeaturesProvider extends FeaturesProvider {
  TestFeaturesProvider() : super(key: 'test_provider');

  @override
  Future<Iterable<FeatureAbstract>> pullFeatures() async {
    return const [
      FeatureGeneric(key: 'feature1', value: 'first'),
      FeatureGeneric(key: 'feature2', value: 90),
    ];
  }
}

final class TestPeriodicFeaturesProvider extends FeaturesProvider {
  TestPeriodicFeaturesProvider() : super(key: 'test_periodic_provider') {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      requestPullFeatures();
    });
  }

  bool _switch = false;

  @override
  Future<Iterable<FeatureAbstract>> pullFeatures() async {
    final rnd = Random();
    _switch = !_switch;

    return [
      FeatureGeneric(
        key: 'dynamicFeature',
        value: rnd.nextInt(100),
      ),
      FeatureGeneric(
        key: 'dynamicBool',
        value: _switch,
      ),
    ];
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final features = FeaturesManager(
    providers: [
      TestFeaturesProvider(),
      TestPeriodicFeaturesProvider(),
    ],
  );

  await features.forceReloadFeatures();

  GetIt.instance.registerSingleton<IFeaturesManager>(features);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FeaturesInherited(
      manager: GetIt.instance.get(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MainScreen(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}
