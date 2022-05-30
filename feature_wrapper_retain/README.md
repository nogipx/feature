# feature_wrapper_firebase

**Important note:** We recommend that you read about the [**feature_core**](https://pub.dev/packages/feature_core) package before using it.

## Installation

To use this library you need to have the following packages:

```yaml
dependencies:
  feature_core: &feature_version ^1.0.2
  feature_wrapper_retain: *feature_version
```

## Usage

Compatible with wrappers:

* `TogglingFeatureSourceWrapper` from [feature_core](https://pub.dev/packages/feature_core)
* `RetainFeatureSourceWrapper` from [feature_wrapper_retain](https://pub.dev/packages/feature_wrapper_retain)

```dart
FeaturesManager(
  sources: {
    ...,
    FirebaseFeatureSource(
      remoteConfig: FirebaseRemoteConfig.instance, // required
      minimumFetchInterval: const Duration(hours: 12), // default
      fetchTimeout: const Duration(minutes: 1) // default
    ),
    ...,
  }
);
```