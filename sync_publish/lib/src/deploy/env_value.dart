class EnvProperty {
  final String key;
  final String? value;
  final String? defaultValue;

  final bool required;
  final bool loadFromEnv;

  const EnvProperty(
    this.key, {
    this.value,
    this.defaultValue,
    this.required = false,
    this.loadFromEnv = true,
  });

  /// Watch issue: https://github.com/flutter/flutter/issues/55870
  /// .fromEnvironment() work only with const keyword.
  ///
  // String? get fromEnvironment =>
  //     String.fromEnvironment(key, defaultValue: defaultValue ?? '');

  String get dartDefine => '--dart-define=$key=$value';

  @override
  operator ==(Object other) => other is EnvProperty && other.key == key;

  @override
  int get hashCode => Object.hashAll([key]);

  EnvProperty copyWith({
    String? value,
    String? defaultValue,
    bool? required,
    bool? loadFromEnv,
  }) {
    return EnvProperty(
      key,
      value: value ?? this.value,
      defaultValue: defaultValue ?? this.defaultValue,
      required: required ?? this.required,
      loadFromEnv: loadFromEnv ?? this.loadFromEnv,
    );
  }
}
