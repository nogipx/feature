# feature_core

Manages feature flags in your application. This is the core library.

## Additional packages

There are several additional libraries created to make this one work.
I hope this list will be expanded in the future.

* [**feature_flutter**](https://pub.dev/packages/feature_flutter) - integration and management of features in the flutter application.

### Feature sources

* [**feature_source_firebase**](https://pub.dev/packages/feature_source_firebase) - implementation for remote firebase config

## Concept

  There are three main entities:

* `FeatureAbstract` represents some kind of customization for the application.

* `FeaturesProvider` implements a function that retrieves functions from some repository.

* `FeaturesManager` manages your providers and handles their requests to pull.

## Usage

### Examples

See examples for [`dart`](https://github.com/nogipx/feature/blob/main/feature_core/example/main.dart) and [`flutter`](https://github.com/nogipx/feature/blob/main/feature_flutter/example/lib/main.dart)

### Creating a feature

To create a feature, just inherit from the `FeatureGeneric<T>` class.

```dart
class UseNewComponent extends FeatureGeneric<bool> {
  const UseNewComponent(bool value) : super(key: 'some_new_component', value: value);
}
```

### Creating a feature provider

To add your own feature source, inherit from `FeaturesProvider` and implement the `pullFeatures()` method.
The rest is up to you.

**Important note**: if you need to update the features from within `FeaturesProvider` 
(for example, if you get updates from the backend), use `requestPullFeatures()` to reacquire the features.

### Creating the manager

First, create a FeaturesManager and populate it with your sources.

### Use with Flutter

See the [**feature_flutter**](https://pub.dev/packages/feature_flutter) 
package to integrate features into the Flutter application.

