import 'package:feature_core/feature_core.dart';
import 'package:flutter/material.dart';

import '../_index.dart';

class DebugFeaturesWidget extends StatefulWidget {
  final FeaturesManagerStreamed manager;

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
          stream: widget.manager.stream,
          builder: (context, snapshot) {
            final features = snapshot.data?.values.toList() ?? [];

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
                      onTap: () {},
                      // extra: widget.manager.getExtra,
                    );
                  },
            );
          },
        ),
      ),
    );
  }
}
//
// class _SourceListItem extends StatefulWidget {
//   final FeatureSource source;
//   final TextStyle? sourceTitleStyle;
//
//   final BorderRadius? featureBorderRadius;
//   final Color? featureActivatedColor;
//   final Color? featureDeactivatedColor;
//   final TextStyle? featureTitleStyle;
//
//   final WidgetFeatureCallback? featureNameBuilder;
//   final WidgetFeatureCallback? featureValueBuilder;
//
//   const _SourceListItem({
//     required this.source,
//     this.sourceTitleStyle,
//     this.featureBorderRadius,
//     this.featureActivatedColor,
//     this.featureDeactivatedColor,
//     this.featureTitleStyle,
//     this.featureNameBuilder,
//     this.featureValueBuilder,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<_SourceListItem> createState() => _SourceListItemState();
// }
//
// class _SourceListItemState extends State<_SourceListItem> {
//   late final useTogglingWrapper =
//       widget.source is TogglingFeatureSourceWrapper &&
//           (widget.source as TogglingFeatureSourceWrapper).enableToggling;
//
//   late final useTogglingMixin = widget.source is TogglingFeatureSourceMixin;
//
//   late final supportToggling = useTogglingWrapper || useTogglingMixin;
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<Map<String, AbstractFeature>>(
//       stream: widget.source.stream,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const SizedBox();
//         }
//         final data = snapshot.data!.values.toList();
//         return Padding(
//           padding: const EdgeInsets.only(top: 16, bottom: 8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(
//                 widget.source.name.isNotEmpty
//                     ? widget.source.name
//                     : widget.source.runtimeType.toString(),
//                 style: widget.sourceTitleStyle ??
//                     Theme.of(context)
//                         .textTheme
//                         .headline6
//                         ?.copyWith(color: Colors.grey),
//               ),
//               const SizedBox(height: 12),
//               if (data.isEmpty)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     'No features',
//                     style: Theme.of(context)
//                         .textTheme
//                         .bodyText2
//                         ?.copyWith(color: Colors.grey),
//                   ),
//                 )
//               else
//                 ListView.separated(
//                   itemCount: data.length,
//                   primary: false,
//                   shrinkWrap: true,
//                   separatorBuilder: (_, __) => const SizedBox(
//                     height: 8,
//                   ),
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemBuilder: (context, index) {
//                     final feature = data[index];
//                     return _FeatureListItem(
//                       feature: feature,
//                       featureBorderRadius: widget.featureBorderRadius,
//                       featureActivatedColor: widget.featureActivatedColor,
//                       featureDeactivatedColor: widget.featureDeactivatedColor,
//                       featureTitleStyle: widget.featureTitleStyle,
//                       featureNameBuilder: widget.featureNameBuilder,
//                       featureValueBuilder: widget.featureValueBuilder,
//                       onToggle: supportToggling
//                           ? () {
//                               if (useTogglingMixin) {
//                                 (widget.source as TogglingFeatureSourceMixin)
//                                     .toggle(feature.key);
//                               }
//                               if (useTogglingWrapper) {
//                                 (widget.source as TogglingFeatureSourceWrapper)
//                                     .toggle(feature.key);
//                               }
//                             }
//                           : null,
//                     );
//                   },
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
