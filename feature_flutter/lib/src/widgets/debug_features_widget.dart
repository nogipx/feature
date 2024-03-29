import 'package:feature_core/feature_core.dart';
import 'package:flutter/material.dart';

import '../_index.dart';

class DebugFeaturesWidget extends StatefulWidget {
  final IFeaturesManager manager;

  final Widget Function(BuildContext context, int index)? featureBuilder;

  const DebugFeaturesWidget({
    required this.manager,
    this.featureBuilder,
    Key? key,
  }) : super(key: key);

  @override
  State<DebugFeaturesWidget> createState() => _DebugFeaturesWidgetState();
}

class _DebugFeaturesWidgetState extends State<DebugFeaturesWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: StreamBuilder<MappedFeatures>(
          stream: widget.manager.featuresStream,
          builder: (context, snapshot) {
            final features = snapshot.data?.values.toList() ??
                widget.manager.features.values.toList();

            return ListView.separated(
              itemCount: features.length,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              physics: const BouncingScrollPhysics(),
              itemBuilder: widget.featureBuilder ??
                  (context, index) {
                    final feature = features[index];

                    return FeatureDefaultListItem(
                      feature: feature,
                      isOverridden: widget.manager.isOverridden(feature.key),
                      onTap: () {
                        final value = feature.value;
                        if (value is bool) {
                          _onEditBoolFeature(feature);
                        }
                      },
                    );
                  },
            );
          },
        ),
      ),
    );
  }

  Future<void> _onEditBoolFeature(FeatureAbstract feature) async {
    final mainColor = Theme.of(context).colorScheme.primary.withOpacity(.3);

    final isActive = feature.value;
    final isOverridden = widget.manager.isOverridden(feature.key);

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Set "true" value'),
                tileColor: isOverridden && isActive ? mainColor : null,
                onTap: () {
                  widget.manager.overrideFeature(
                    feature.copyWith(value: true),
                  );
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Set "false" value'),
                tileColor: isOverridden && !isActive ? mainColor : null,
                onTap: () {
                  widget.manager.overrideFeature(
                    feature.copyWith(value: false),
                  );
                  Navigator.of(context).pop();
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  child: const Text('Reset'),
                  onPressed: () {
                    widget.manager.clearOverrides(
                      key: feature.key,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
