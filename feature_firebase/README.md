# feature_source_firebase

## Installation

To use this library you need to have the following packages:

```yaml
dependencies:
  feature_core: ^1.0.0
  feature_source_firebase: ^1.0.0
  firebase_remote_config: ^2.0.0
```

## Usage

We recommend that you read about the [feature_core](https://pub.dev/packages/feature_core) package before using it.

Compatible with wrappers:

* `TogglingFeatureSourceWrapper` from [feature_core](https://pub.dev/packages/feature_core)
* `RetainFeatureSourceWrapper` from [feature_source_retain](https://pub.dev/packages/feature_source_retain)

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