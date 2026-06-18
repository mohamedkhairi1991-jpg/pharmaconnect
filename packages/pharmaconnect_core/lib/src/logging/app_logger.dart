import '../config/app_environment.dart';

abstract final class AppLogger {
  static AppEnvironment? _environment;

  static AppEnvironment? get environment => _environment;

  static void configure(AppEnvironment environment) {
    _environment = environment;
  }
}
