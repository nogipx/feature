# feature_core

Manages feature flags in your application. This is the core library.


## Additional packages

There are some additional libraries built-to-work with it.
I hope this list will be expanded in the future.

* [**feature_fluter**](https://pub.dev/packages/feature_flutter) — easy integrate and manage features in flutter application

### Wrappers

* [**feature_source_retain**](https://pub.dev/packages/feature_flutter) — add the features retaining functionality to your sources

### Feature sources

* [**feature_source_firebase**](https://pub.dev/packages/feature_flutter) — implementation for firebase remote config

## Usage

---

### Concept

* There are three main entities: `Feature`, `FeatureSource`, `FeatureManager`.

* `Feature` has a subtype, `FeatureToggle`, which is actually `Feature<bool>`. The entity represents some kind of customization for the application.

* `FeatureSource` implements a function that retrieves functions from some repository and handles their updates. It can work without `FeatureManager`.

* The `FeatureManager` combines all feature streams provided by the sources into a single `Map<String, Feature>`. Also provides methods for accessing features. ([*Manager API*](#manager-api))

### Creating the manager

First, create a FeaturesManager and populate it with your sources.
The library provides a default source named `LocalFeatureSource`.

Once created, you need to `init()` the manager - it will pull all the features from the sources into a single repository.


```dart
final featureManager = FeaturesManager(
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
await featureManager.init();
```

You can also connect the manager instance to the global scope for easier access. The global entry point `Features` is a proxy for the instance and has the same public api.

The `connect()` method returns the instance you passed.

```dart
Features.connect(
  instance: FeaturesManager(...),
);
```

---

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