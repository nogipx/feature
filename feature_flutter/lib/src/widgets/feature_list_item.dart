import 'package:feature_core/feature_core.dart';
import 'package:flutter/material.dart';

import '../_index.dart';

class FeatureExtra {
  final String providerName;
  final FeatureAbstract? featureOverride;

  const FeatureExtra({
    this.providerName = '',
    this.featureOverride,
  });
}

class FeatureDefaultListItem extends StatelessWidget {
  final FeatureAbstract feature;
  final VoidCallback? onTap;
  final FeatureExtra? extra;
  final bool isOverridden;

  const FeatureDefaultListItem({
    Key? key,
    required this.feature,
    this.onTap,
    this.extra,
    this.isOverridden = false,
  }) : super(key: key);

  static const _radius = BorderRadius.all(Radius.circular(12));
  static const _containerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: _radius,
    boxShadow: [
      BoxShadow(
        color: Color(0xB3C8C8C8),
        blurRadius: 2,
        offset: Offset(0, 1),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    assert(() {
      if (extra?.featureOverride != null &&
          extra?.featureOverride?.key != feature.key) {
        return false;
      }
      return true;
    }());

    return BouncingWidget(
      enableBounce: onTap != null,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: _containerDecoration,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Builder(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  feature.key,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (feature.value is bool)
                Icon(
                  Icons.edit,
                  size: 20,
                  color: isOverridden ? Colors.orange : Colors.grey,
                )
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfo(value: feature.value.runtimeType.toString()),
              _buildInfo(key: 'Value', value: feature.value.toString()),
            ],
          )
        ],
      );
    });
  }

  Widget _buildInfo({
    String? key,
    required String value,
  }) {
    return Builder(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: _radius,
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(
            key != null ? '$key: $value' : value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
          ),
        );
      },
    );
  }
}
