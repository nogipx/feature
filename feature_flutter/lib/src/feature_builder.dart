import 'dart:async';

import 'package:feature_core/feature_core.dart';
import 'package:feature_flutter/src/feature_provider.dart';
import 'package:flutter/material.dart';

typedef FeatureBuilderCallback<T> = Widget Function(
  BuildContext context,
  Feature<T>? feature,
);

enum _Type { child, builder }

class FeatureWidget extends StatefulWidget {
  final Feature? feature;
  final FeatureBuilderCallback? builder;
  final Widget? activatedChild;

  /// Represents original widget before experiment.
  /// It will be used if feature is missing or disabled.
  final Widget? child;

  /// Controls whether widget should not builds at all.
  final bool visible;
  final _Type type;

  const FeatureWidget._({
    required this.feature,
    required this.type,
    this.builder,
    this.activatedChild,
    this.visible = true,
    this.child,
    Key? key,
  }) : super(key: key);

  factory FeatureWidget.builder({
    Feature? feature,
    required FeatureBuilderCallback builder,
    bool visible = true,
    Key? key,
  }) {
    return FeatureWidget._(
      feature: feature,
      builder: builder,
      visible: visible,
      key: key,
      type: _Type.builder,
    );
  }

  factory FeatureWidget({
    Feature? feature,
    Widget? child,
    Widget? activatedChild,
    bool visible = true,
    Key? key,
  }) {
    return FeatureWidget._(
      feature: feature,
      child: child,
      activatedChild: activatedChild,
      visible: visible,
      key: key,
      type: _Type.child,
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
      builder: (context, feature, _) {
        const empty = SizedBox();

        if (!widget.visible) {
          return empty;
        } else if (feature == null) {
          return widget.type == _Type.builder
              ? widget.builder?.call(context, feature) ?? empty
              : widget.child ?? empty;
        }

        if (widget.type == _Type.builder) {
          return widget.builder?.call(context, feature) ?? empty;
        } else {
          return feature.enabled
              ? widget.activatedChild ?? empty
              : widget.child ?? empty;
        }
      },
    );
  }
}
