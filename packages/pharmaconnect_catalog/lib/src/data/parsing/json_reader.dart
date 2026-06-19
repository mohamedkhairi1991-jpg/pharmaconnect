import '../../domain/failure/catalog_failure.dart';

final class JsonReader {
  const JsonReader(this.json, {required this.context});

  final Map<String, Object?> json;
  final String context;

  String string(String key) {
    final Object? value = json[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw _invalid(key);
  }

  String? nullableString(String key) {
    final Object? value = json[key];
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    throw _invalid(key);
  }

  bool boolean(String key) {
    final Object? value = json[key];
    if (value is bool) {
      return value;
    }
    throw _invalid(key);
  }

  int integer(String key) {
    final Object? value = json[key];
    if (value is int) {
      return value;
    }
    throw _invalid(key);
  }

  DateTime dateTime(String key) {
    final String value = string(key);
    final DateTime? parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw _invalid(key);
    }
    return parsed.toUtc();
  }

  DateTime? nullableDateTime(String key) {
    final String? value = nullableString(key);
    if (value == null) {
      return null;
    }
    final DateTime? parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw _invalid(key);
    }
    return parsed.toUtc();
  }

  Map<String, Object?> object(String key) {
    final Object? value = json[key];
    if (value is Map<String, dynamic>) {
      return value.cast<String, Object?>();
    }
    throw _invalid(key);
  }

  Map<String, Object?>? nullableObject(String key) {
    final Object? value = json[key];
    if (value == null) {
      return null;
    }
    if (value is Map<String, dynamic>) {
      return value.cast<String, Object?>();
    }
    throw _invalid(key);
  }

  List<Map<String, Object?>> objects(String key) {
    final Object? value = json[key];
    if (value == null) {
      return const <Map<String, Object?>>[];
    }
    if (value is! List<dynamic>) {
      throw _invalid(key);
    }
    return List<Map<String, Object?>>.unmodifiable(
      value.map((Object? item) {
        if (item is Map<String, dynamic>) {
          return item.cast<String, Object?>();
        }
        throw _invalid(key);
      }),
    );
  }

  CatalogFailure _invalid(String key) {
    return CatalogFailure.incompatibleData(
      diagnosticCode: 'malformed_$context.$key',
    );
  }
}
