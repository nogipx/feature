# feature_firebase

Для использования этой библиотеки вам нужно иметь следующие пакеты:

```yaml
dependencies:
  feature_core: ^1.0.0
  feature_source_firebase: ^1.0.0
  firebase_remote_config: ^2.0.0
```

## Usage

```dart
FeaturesManager(
  sources: {
    ...,
    FirebaseFeatureSource(
      remoteConfig: FirebaseRemoteConfig.instance, // required
      minimumFetchInterval: const Duration(hours: 12), // default
      fetchTimeout: const Duration(minutes: 1) // default
    )
  }
);

```