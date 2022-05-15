import 'package:feature_core/feature_core.dart';
import 'package:flutter/cupertino.dart';

class FeaturesProvider extends InheritedWidget {
  final FeaturesManager manager;

  const FeaturesProvider({
    required this.manager,
    required Widget child,
    Key? key,
  }) : super(child: child, key: key);

  static FeaturesProvider? of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<FeaturesProvider>();

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}
