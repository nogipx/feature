import 'package:feature_core/feature_core.dart';
import 'package:flutter/cupertino.dart';

class FeaturesInherited extends InheritedWidget {
  final IFeaturesManager manager;

  const FeaturesInherited({
    required this.manager,
    required Widget child,
    Key? key,
  }) : super(child: child, key: key);

  static FeaturesInherited of(BuildContext context) {
    final widget = context.getInheritedWidgetOfExactType<FeaturesInherited>();
    assert(
      widget != null,
      'The FeaturesInherited widget was not found. '
      'Perhaps you forgot to inject it into the widget tree?',
    );
    return widget!;
  }

  static IFeaturesManager getManager(BuildContext context) {
    final widget = of(context);
    return widget.manager;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}
