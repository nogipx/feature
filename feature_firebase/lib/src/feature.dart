import 'package:feature_core/feature_core.dart';

class FirebaseFeature<T extends dynamic> extends Feature<T> {
  FirebaseFeature({
    required String key,
    required T value,
  }) : super(key: key, value: value);

  @override
  Feature<T> creator() => FirebaseFeature(key: key, value: value);
}
