import 'package:feature_flutter/feature_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Features'),
      ),
      body: DebugFeaturesWidget(
        manager: GetIt.instance.get(),
      ),
    );
  }
}
