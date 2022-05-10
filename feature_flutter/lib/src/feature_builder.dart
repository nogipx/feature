import 'package:feature_core/feature_core.dart';
import 'package:feature_flutter/src/feature_provider.dart';
import 'package:flutter/material.dart';

typedef FeatureBuilderCallback<T> = Widget Function(
  BuildContext context,
  Feature<T> feature,
);

class FeatureBuilder extends StatefulWidget {
  final Feature? feature;
  final FeatureBuilderCallback builder;
  final Widget featureReplacement;

  const FeatureBuilder({
    required this.feature,
    required this.builder,
    this.featureReplacement = const SizedBox(),
    Key? key,
  }) : super(key: key);

  @override
  State<FeatureBuilder> createState() => _FeatureBuilderState();
}

class _FeatureBuilderState extends State<FeatureBuilder> {
  Stream<Feature>? _featureStream;

  @override
  void initState() {
    if (widget.feature?.key != null) {
      _featureStream = FeaturesProvider.of(context)
          ?.manager
          .featureStream(widget.feature!.key);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_featureStream == null) {
      return widget.featureReplacement;
    }
    return StreamBuilder<Feature?>(
      stream: _featureStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final feature = snapshot.data!;
          return widget.builder(context, feature);
        } else {
          return widget.featureReplacement;
        }
      },
    );
  }
}
