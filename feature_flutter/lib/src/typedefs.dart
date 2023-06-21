import 'package:feature_core/feature_core.dart';
import 'package:flutter/material.dart';

typedef FeatureBuilderCallback<T> = Widget Function(
  BuildContext context,
  FeatureAbstract<T>? feature,
);

typedef WidgetFeatureCallback = Widget Function(
  FeatureAbstract feature,
  bool canToggle,
);
