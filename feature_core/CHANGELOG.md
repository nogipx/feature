# [1.2.0]
* Update deps

# [1.1.1]
* Update readme and deps constraints

# [1.1.0]
* Breaking changes: new architecture in `feature_core`
* `FeatureSource` separated to:
--- `FeaturesContainer` to save actual features
--- `FeaturesProvider` to pull features from some source
--- `FeaturesManager` to control and manage providers
* Abstract `Feature` renamed to `FeatureAbstract` and made constant, without any state

# [1.0.0]
* Initial version.
