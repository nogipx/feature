import 'package:feature_core/feature_core.dart';
import 'package:flutter/material.dart';

import '_index.dart';

class FeatureListItem extends StatelessWidget {
  final FeatureAbstract feature;
  final VoidCallback? onToggle;

  final BorderRadius? featureBorderRadius;
  final TextStyle? featureTitleStyle;
  final Color? featureActivatedColor;
  final Color? featureDeactivatedColor;

  final WidgetFeatureCallback? featureNameBuilder;
  final WidgetFeatureCallback? featureValueBuilder;

  const FeatureListItem({
    required this.feature,
    this.onToggle,
    Key? key,
    this.featureBorderRadius,
    this.featureActivatedColor,
    this.featureDeactivatedColor,
    this.featureTitleStyle,
    this.featureNameBuilder,
    this.featureValueBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final supportToggling = onToggle != null;

    return BouncingWidget(
      enableBounce: supportToggling,
      onTap: supportToggling ? onToggle : null,
      child: Material(
        borderRadius: featureBorderRadius ?? BorderRadius.circular(16),
        elevation: 1,
        color: featureDeactivatedColor ?? Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          constraints: const BoxConstraints(
            minHeight: 40,
            maxHeight: 100,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 5,
                child: featureNameBuilder?.call(feature, supportToggling) ??
                    Text(
                      feature.key,
                      style: featureTitleStyle ??
                          Theme.of(context).textTheme.bodyText1,
                    ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: featureValueBuilder?.call(feature, supportToggling) ??
                    Text(
                      feature.value.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
