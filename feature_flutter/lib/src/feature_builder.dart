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
  final FeatureBuilderCallback? builder;
  final Widget? noFeatureChild;
  final Widget? deactivatedChild;
  final bool visible;
  final Widget? child;

  const FeatureWidget._({
    required this.feature,
    this.builder,
    this.noFeatureChild,
    this.deactivatedChild,
    this.visible = true,
    this.child,
    Key? key,
  }) : super(key: key);

  factory FeatureWidget.builder({
    required Feature? feature,
    required FeatureBuilderCallback builder,
    Widget noFeatureChild = const SizedBox(),
    bool visible = true,
    Key? key,
  }) {
    return FeatureWidget._(
      feature: feature,
      builder: builder,
      noFeatureChild: noFeatureChild,
      visible: visible,
      key: key,
    );
  }

  factory FeatureWidget({
    required Feature? feature,
    Widget? child,
    Widget? deactivatedChild,
    Widget? noFeatureChild,
    bool visible = true,
    Key? key,
  }) {
    return FeatureWidget._(
      feature: feature,
      child: child,
      noFeatureChild: feature != null ? deactivatedChild : noFeatureChild,
      deactivatedChild: deactivatedChild,
      visible: visible,
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
      builder: (context, feature, _) {
        const empty = SizedBox();

        if (!widget.visible) {
          return empty;
        }
        if (feature == null) {
          return widget.noFeatureChild ?? empty;
        }
        if (feature.isToggle) {
          if (widget.builder != null) {
            return widget.builder!.call(context, feature) ?? empty;
          } else {
            return feature.value
                ? widget.child ?? empty
                : widget.deactivatedChild ?? empty;
          }
        }

        return feature.enabled
            ? widget.builder?.call(context, feature) ?? widget.child ?? empty
            : widget.deactivatedChild ?? empty;
      },
    );
  }
}
