import 'package:feature_core/feature_core.dart';
import 'package:feature_flutter/feature_flutter.dart';
import 'package:flutter/material.dart';

import '../_index.dart';
import '_index.dart';

enum _Type { child, builder }

class FeatureWidget extends StatelessWidget {
  final String? featureKey;
  final FeatureBuilderCallback? builder;
  final Widget? activatedChild;

  /// Represents original widget before experiment.
  /// It will be used if feature is missing or disabled.
  final Widget? child;

  /// Controls whether widget should not builds at all.
  final bool visible;
  final _Type type;

  const FeatureWidget._({
    required this.featureKey,
    required this.type,
    this.builder,
    this.activatedChild,
    this.visible = true,
    this.child,
    Key? key,
  }) : super(key: key);

  factory FeatureWidget.builder({
    String? featureKey,
    required FeatureBuilderCallback builder,
    bool visible = true,
    Key? key,
  }) {
    return FeatureWidget._(
      featureKey: featureKey,
      builder: builder,
      visible: visible,
      key: key,
      type: _Type.builder,
    );
  }

  factory FeatureWidget({
    String? featureKey,
    Widget? child,
    Widget? activatedChild,
    bool visible = true,
    Key? key,
  }) {
    return FeatureWidget._(
      featureKey: featureKey,
      child: child,
      activatedChild: activatedChild,
      visible: visible,
      key: key,
      type: _Type.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MappedFeatures>(
      stream: FeaturesInherited.of(context)?.manager.stream,
      builder: (context, snapshot) {
        final feature = snapshot.data?[featureKey];
        const empty = SizedBox();

        if (!visible) {
          return empty;
        } else if (feature == null) {
          return type == _Type.builder
              ? builder?.call(context, feature) ?? empty
              : child ?? empty;
        }

        if (type == _Type.builder) {
          return builder?.call(context, feature) ?? empty;
        } else {
          return activatedChild ?? empty;
        }
      },
    );
  }
}
