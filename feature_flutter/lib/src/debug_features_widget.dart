import 'package:feature_core/feature_core.dart';
import 'package:feature_flutter/src/bouncing_button.dart';
import 'package:flutter/material.dart';

typedef WidgetFeatureCallback = Widget Function(
    Feature feature, bool canToggle);

class DebugFeaturesWidget extends StatefulWidget {
  final FeaturesManager manager;
  final BorderRadius? featureBorderRadius;
  final Color? featureActivatedColor;
  final Color? featureDeactivatedColor;
  final TextStyle? sourceTitleStyle;
  final TextStyle? featureTitleStyle;

  final WidgetFeatureCallback? featureNameBuilder;
  final WidgetFeatureCallback? featureValueBuilder;

  const DebugFeaturesWidget({
    required this.manager,
    Key? key,
    this.featureBorderRadius,
    this.featureActivatedColor,
    this.featureDeactivatedColor,
    this.featureNameBuilder,
    this.sourceTitleStyle,
    this.featureTitleStyle,
    this.featureValueBuilder,
  }) : super(key: key);

  @override
  State<DebugFeaturesWidget> createState() => _DebugFeaturesWidgetState();
}

class _DebugFeaturesWidgetState extends State<DebugFeaturesWidget> {
  late final List<FeatureSource> _sources = widget.manager.sources.toList();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          itemCount: _sources.length,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final source = _sources[index];

            return _SourceListItem(
              source: source,
              sourceTitleStyle: widget.sourceTitleStyle,
              featureBorderRadius: widget.featureBorderRadius,
              featureActivatedColor: widget.featureActivatedColor,
              featureDeactivatedColor: widget.featureDeactivatedColor,
              featureTitleStyle: widget.featureTitleStyle,
              featureNameBuilder: widget.featureNameBuilder,
              featureValueBuilder: widget.featureValueBuilder,
            );
          },
        ),
      ),
    );
  }
}

class _SourceListItem extends StatefulWidget {
  final FeatureSource source;
  final TextStyle? sourceTitleStyle;

  final BorderRadius? featureBorderRadius;
  final Color? featureActivatedColor;
  final Color? featureDeactivatedColor;
  final TextStyle? featureTitleStyle;

  final WidgetFeatureCallback? featureNameBuilder;
  final WidgetFeatureCallback? featureValueBuilder;

  const _SourceListItem({
    required this.source,
    this.sourceTitleStyle,
    this.featureBorderRadius,
    this.featureActivatedColor,
    this.featureDeactivatedColor,
    this.featureTitleStyle,
    this.featureNameBuilder,
    this.featureValueBuilder,
    Key? key,
  }) : super(key: key);

  @override
  State<_SourceListItem> createState() => _SourceListItemState();
}

class _SourceListItemState extends State<_SourceListItem> {
  late final useTogglingWrapper =
      widget.source is TogglingFeatureSourceWrapper &&
          (widget.source as TogglingFeatureSourceWrapper).enableToggling;

  late final useTogglingMixin = widget.source is TogglingFeatureSourceMixin;

  late final supportToggling = useTogglingWrapper || useTogglingMixin;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, Feature>>(
      stream: widget.source.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }
        final data = snapshot.data!.values.toList();
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.source.name.isNotEmpty
                    ? widget.source.name
                    : widget.source.runtimeType.toString(),
                style: widget.sourceTitleStyle ??
                    Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              if (data.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'No features',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        ?.copyWith(color: Colors.grey),
                  ),
                )
              else
                ListView.separated(
                  itemCount: data.length,
                  primary: false,
                  shrinkWrap: true,
                  separatorBuilder: (_, __) => const SizedBox(
                    height: 8,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final feature = data[index];
                    return _FeatureListItem(
                      feature: feature,
                      featureBorderRadius: widget.featureBorderRadius,
                      featureActivatedColor: widget.featureActivatedColor,
                      featureDeactivatedColor: widget.featureDeactivatedColor,
                      featureTitleStyle: widget.featureTitleStyle,
                      featureNameBuilder: widget.featureNameBuilder,
                      featureValueBuilder: widget.featureValueBuilder,
                      onToggle: supportToggling
                          ? () {
                              if (useTogglingMixin) {
                                (widget.source as TogglingFeatureSourceMixin)
                                    .toggle(feature.key);
                              }
                              if (useTogglingWrapper) {
                                (widget.source as TogglingFeatureSourceWrapper)
                                    .toggle(feature.key);
                              }
                            }
                          : null,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FeatureListItem extends StatelessWidget {
  final Feature feature;
  final VoidCallback? onToggle;
  final BorderRadius? featureBorderRadius;
  final TextStyle? featureTitleStyle;
  final Color? featureActivatedColor;
  final Color? featureDeactivatedColor;

  final WidgetFeatureCallback? featureNameBuilder;
  final WidgetFeatureCallback? featureValueBuilder;

  const _FeatureListItem({
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
        color: supportToggling
            ? feature.enabled
                ? featureActivatedColor ?? Colors.green.shade100
                : featureDeactivatedColor ?? Colors.red.shade100
            : featureDeactivatedColor ?? Colors.white,
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
