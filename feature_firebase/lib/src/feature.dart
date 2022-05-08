import 'package:feature_core/feature_core.dart';

class FirebaseFeature extends Feature<dynamic> {
  @override
  final String key;
  @override
  final dynamic value;
  @override
  final bool isEnabled;
  @override
  final String? name;

  FirebaseFeature({
    required this.key,
    this.value,
    this.isEnabled = false,
    this.name,
  });
}
