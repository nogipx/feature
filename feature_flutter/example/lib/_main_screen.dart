import 'dart:async';

import 'package:feature_flutter/feature_flutter.dart';
import 'package:feature_flutter_example/_features_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.title});

  final String title;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _counter = 0;
  late final StreamSubscription? _sub;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    _sub = FeaturesInherited.getManager(context).featuresStream.listen((event) {
      setState(() {
        _counter = event['dynamicFeature']?.value ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const FeaturesScreen();
              }));
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(16),
              ),
              child: FeatureWidget(
                // This function will switch the red/green color because
                // the function widget reacts to the bool value as switches
                featureKey: 'dynamicBool',
                activatedChild: const SizedBox(
                  height: 40,
                  width: 80,
                  child: ColoredBox(color: Colors.green),
                ),
                // child: const ColoredBox(color: Colors.red),
              ),
            ),
            FeatureWidget(
              featureKey: 'feature3',
              activatedChild: const Text(
                'This will not shown because "feature3" not exists.',
              ),
            ),
            FeatureWidget.builder(
              featureKey: 'feature1',
              builder: (context, feature) {
                return Text(feature?.value);
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
