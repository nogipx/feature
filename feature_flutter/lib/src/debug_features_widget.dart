import 'package:feature_core/feature_core.dart';
import 'package:feature_flutter/src/bouncing_button.dart';
import 'package:flutter/material.dart';

class DebugFeaturesWidget extends StatefulWidget {
  final FeaturesManager manager;

  const DebugFeaturesWidget({
    required this.manager,
    Key? key,
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
            final useWrapper = source is TogglingFeatureSourceWrapper;
            final useMixin = source is TogglingFeatureSourceMixin;
            final supportToggling = useWrapper || useMixin;

            return StreamBuilder<Map<String, Feature>>(
              stream: source.stream,
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
                        source.name.isNotEmpty
                            ? source.name
                            : source.runtimeType.toString(),
                        style: Theme.of(context)
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
                        ),
                      if (data.isNotEmpty)
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
                            return BouncingWidget(
                              enableBounce: supportToggling,
                              onTap: supportToggling
                                  ? () {
                                      if (useMixin) {
                                        (source as TogglingFeatureSourceMixin)
                                            .toggle(feature.key);
                                      }
                                      if (useWrapper) {
                                        (source as TogglingFeatureSourceWrapper)
                                            .toggle(feature.key);
                                      }
                                    }
                                  : null,
                              child: Material(
                                borderRadius: BorderRadius.circular(16),
                                elevation: 1,
                                color: supportToggling
                                    ? feature.enabled
                                        ? Colors.green.shade100
                                        : Colors.red.shade100
                                    : Colors.white,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  constraints: const BoxConstraints(
                                    minHeight: 40,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          feature.key,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          feature.value.toString(),
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
