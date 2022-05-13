import 'dart:async';

import 'package:feature_core/feature_core.dart';
import 'package:feature_flutter/src/feature_provider.dart';
import 'package:flutter/material.dart';

typedef FeatureBuilderCallback<T> = Widget? Function(
  BuildContext context,
  Feature<T> feature,
);

class FeatureWidget extends StatefulWidget {
  final Feature? feature;
  final FeatureBuilderCallback builder;
  final Widget noFeatureChild;
  final Widget deactivatedChild;

  const FeatureWidget._({
    required this.feature,
    required this.builder,
    this.noFeatureChild = const SizedBox(),
    this.deactivatedChild = const SizedBox(),
    Key? key,
  }) : super(key: key);

  factory FeatureWidget.builder({
    required Feature? feature,
    required FeatureBuilderCallback builder,
    Widget noFeatureChild = const SizedBox(),
    Key? key,
  }) {
    return FeatureWidget._(
      feature: feature,
      builder: builder,
      noFeatureChild: noFeatureChild,
      key: key,
    );
  }

  factory FeatureWidget.toggle({
    required Feature<bool>? feature,
    Widget child = const SizedBox(),
    Widget deactivatedChild = const SizedBox(),
    Widget noFeatureChild = const SizedBox(),
    Key? key,
  }) {
    return FeatureWidget._(
      feature: feature,
      builder: (_, __) => child,
      noFeatureChild: feature != null ? deactivatedChild : noFeatureChild,
      deactivatedChild: deactivatedChild,
      key: key,
    );
  }

  @override
  State<FeatureWidget> createState() => _FeatureWidgetState();
}

class _FeatureWidgetState extends State<FeatureWidget> {
  late final ValueNotifier<Feature?> _feature;
  late final StreamSubscription? _updateSubscription;

  @override
  void initState() {
    super.initState();
    _feature = ValueNotifier(widget.feature);

    if (_feature.value != null) {
      _updateSubscription = FeaturesProvider.of(context)
          ?.manager
          .featureStream(_feature.value!.key)
          ?.listen((feature) {
        _feature.value = feature;
      });
    }
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    _feature.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Feature?>(
      valueListenable: _feature,
      builder: (BuildContext context, feature, Widget? child) {
        if (feature == null) {
          return widget.noFeatureChild;
        }
        return feature.enabled
            ? widget.builder(context, feature) ?? const SizedBox()
            : widget.deactivatedChild;
      },
    );
  }
}
