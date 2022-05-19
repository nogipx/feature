# feature_core

Manages feature flags in your application. This is the core library.

[Creating a feature](#creating-a-feature) | [Creating a feature source](#creating-a-feature-source) | [Creating the manager](#creating-the-manager)

[Use with Flutter](#use-with-flutter) | [Use wrappers](#use-wrappers) | [Manager API](#manager-api)

## Additional packages

There are several additional libraries created to make this one work.
I hope this list will be expanded in the future.

* [**feature_flutter**](https://pub.dev/packages/feature_flutter) - integration and management of features in the flutter application.

### Wrappers

* [**feature_source_retain**](https://pub.dev/packages/feature_source_retain) - adds ability to locally save state of features

### Feature sources

* [**feature_source_firebase**](https://pub.dev/packages/feature_source_firebase) - implementation for remote firebase config

## Concept

  There are three main entities: `Feature`, `FeatureSource`, `FeatureManager`.

* `Feature` represents some kind of customization for the application. It has a subtype, `FeatureToggle`, which is actually `Feature<bool>`.

* `FeatureSource` implements a function that retrieves functions from some repository and handles their updates. It can work without `FeatureManager`.

* `FeatureManager` combines all feature streams provided by the sources into a single `Stream<Map<String, Feature>>`. Also provides methods for accessing features. ([*Manager API*](#manager-api))

## Usage

### Creating a feature

To create a feature, just inherit from the `Feature` class and specify the value type of the feature. For example `Feature<bool>` for toggles, or `Feature<String>` for settings. When creating a toggle, inherit from `FeatureToggle` for convenience.  

**Important note**: in order to enable/disable the feature, the `creator()` method must be implemented - it must return a copy of the current object. (google it: `downcast')

```dart
class UseNewComponent extends FeatureToggle {
  UseNewComponent(bool value) : super(value: value, enabled: true);
  @override
  Feature<bool> creator() => UseNewComponent(value);
}
```

```dart
class FirebaseFeature<T extends dynamic> extends Feature<T> {
  FirebaseFeature({
    required String key,
    required T value,
  }) : super(key: key, value: value);

  @override
  Feature<T> creator() => FirebaseFeature(key: key, value: value);
}
```

### Creating a feature source

To add your own feature source, inherit from `FeatureSource` and implement the `pullFeatures()` method.
The rest is up to you.

**Important note**: if you need to update the features from within FeatureSource (for example, if you get updates from the backend), use `notifyNeedUpdate()` to reacquire the features.

```dart
class FirebaseFeatureSource extends FeatureSource {
  final FirebaseRemoteConfig _remoteConfig;

  FirebaseFeatureSource({
    required FirebaseRemoteConfig remoteConfig,
  }) : _remoteConfig = remoteConfig {
    _remoteConfig
      ..addListener(_onUpdate)
      ..fetchAndActivate();
  }

  Future<void> _onUpdate() async {
    notifyNeedUpdate();
  }

  @override
  void dispose() {
    super.dispose();
    _remoteConfig.removeListener(_onUpdate);
  }

  @override
  @protected
  FutureOr<Iterable<Feature>> pullFeatures() async {
    /// pulling features ...
  }
}
```

### Creating the manager

First, create a FeaturesManager and populate it with your sources.
The library provides a default source named `LocalFeatureSource`.

Once created, you need to `init()` the manager - it will pull all the features from the sources into a single repository.


```dart
final featuresManager = FeaturesManager(
  sources: {
    LocalFeatureSource(
      features: [
        TestLocalFeature(),
        TestTextLocalFeature(),
      ],
    ),
    ...
  },
);
await featuresManager.init();
```

You can also connect the manager instance to the global scope for easier access. The global entry point `Features` is a proxy for the instance and has the same public api.

The `connect()` method returns the instance you passed.

```dart
Features.connect(
  instance: FeaturesManager(...),
);

/// Instance available by
Features.I
```

### Use with Flutter

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

### Use wrappers

The **feature_core** package contains a wrapper that allows you to enable and disable features - `TogglingFeatureSourceWrapper`.
There is also a mixin that adds the same functionality to your custom function source - `TogglingFeatureSourceMixin`.

#### [See the full list of wrappers here](#wrappers)

```dart
class CustomFeatureSource extends FeatureSource with TogglingFeatureSourceMixin {}
```

```dart
FeaturesManager(
  sources: {
    TogglingFeatureSourceWrapper(
      name: 'Custom name for source',
      source: LocalFeatureSource(
        features: [...]
      )
    ),
    ...
  }
);
```

## Manager API

```dart
/// Stream with actual features combined from all sources. 
/// It will produce new data every time some source updated.
Stream<Map<String, Feature>> get stream;

/// Actual manager's features.
Map<String, Feature> get features;

/// Sources where manager gets features.
Set<FeatureSource> get sources;

/// Returns stream which provides updates
/// only for particular feature. 
/// Null if there is not exists feature with provided key.
Stream<Feature>? featureStream(String key)

/// Gets the feature and compare its value with passed.
bool check(String key, dynamic value);

/// Returns feature's value.
dynamic value(String key);

Feature? getFeature(String key);

T? getFeatureByType<T extends Feature>();

T? getSource<T extends FeatureSource>();

Future<void> init();

void dispose();
```
