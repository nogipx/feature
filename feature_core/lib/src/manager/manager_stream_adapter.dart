import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '_index.dart';

class FeaturesManagerStreamed extends FeaturesManager {
  late final BehaviorSubject<MappedFeatures> _controller;

  Stream<MappedFeatures> get stream => _controller.stream;

  FeaturesManagerStreamed({
    List<FeaturesProvider> providers = const [],
  }) : super(providers: providers) {
    _controller = BehaviorSubject.seeded({});
  }

  @override
  void onUpdate(MappedFeatures features) {
    _controller.sink.add(features);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }
}
