import 'package:riverpod/riverpod.dart';

enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment fromDartDefines() {
    const String value = String.fromEnvironment(
      'APP_ENVIRONMENT',
      defaultValue: 'development',
    );

    return AppEnvironment.values.firstWhere(
      (AppEnvironment environment) => environment.name == value,
      orElse: () => AppEnvironment.development,
    );
  }
}

final Provider<AppEnvironment> appEnvironmentProvider =
    Provider<AppEnvironment>((Ref ref) => AppEnvironment.fromDartDefines());
