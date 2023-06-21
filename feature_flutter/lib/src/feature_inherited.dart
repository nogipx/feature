import 'package:feature_core/feature_core.dart';
import 'package:flutter/cupertino.dart';

class FeaturesInherited extends InheritedWidget {
  final FeaturesManagerStreamed manager;

  const FeaturesInherited({
    required this.manager,
    required Widget child,
    Key? key,
  }) : super(child: child, key: key);

  static FeaturesInherited? of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<FeaturesInherited>();

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}
