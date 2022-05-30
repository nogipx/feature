# feature_flutter

**Important note:** We recommend that you read about the [**feature_core**](https://pub.dev/packages/feature_core) package before using it.

## Installation

To use this library you need to have the following packages:

```yaml
dependencies:
  feature_core: &feature_version ^1.0.2
  feature_flutter: *feature_version
```

## Usage

With the [**feature_flutter**](https://pub.dev/packages/feature_flutter) package you can integrate features into the Flutter application.

The package provides three main widgets: `FeaturesProvider`, `FeatureWidget`, `DebugFeaturesWidget`.

#### `FeaturesProvider`

Passes the manager down the tree.

```dart
void main() {
  final FeaturesManager featuresManager = FeaturesManager(...);

  runApp(MaterialApp(
    home: FeaturesProvider(
      manager: featuresManager,
    ),
    ...
  ));
}
```

#### `FeatureWidget`

Allows you to show/hide widgets depending on the value of a feature.

You can use a simplified variant

```dart
FeatureWidget(
  feature: featuresManager.getFeature('feature_key'),
  child: Text(
    'child when feature: has 'false' value,'
    'OR is disabled OR not found in manager',
  ),
  activatedChild: Text(
    'child when feature found in manager AND is enabled.'
  ),
  visible: true, // default, totally shows/hides widget
)
```

Or you can handle feature values more flexibly through the builder.

**Important note**: By default, if the bilder returns nothing, an empty ``SizedBox`` is used.

```dart
FeatureWidget.builder(
  feature: featuresManager.getFeatureByType<SomeFeature>(),
  builder: (BuildContext context, Feature? feature) {
    if (feature == null) {
      return // your widget here
    }
    if (feature.enabled) {
      return // your widget here
    }
  },
)
```

#### `DebugFeaturesWidget`

Just a handy widget which depends on the manager and gives access to enable/disable features.
