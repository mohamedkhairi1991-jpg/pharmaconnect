import '../../domain/failure/catalog_failure.dart';

Map<String, Object?> parseRpcObject(Object? response, String context) {
  if (response is Map<String, dynamic>) {
    return response.cast<String, Object?>();
  }
  if (response is List<dynamic> &&
      response.length == 1 &&
      response.single is Map<String, dynamic>) {
    return (response.single as Map<String, dynamic>).cast<String, Object?>();
  }
  throw CatalogFailure.incompatibleData(diagnosticCode: 'malformed_$context');
}

List<Map<String, Object?>> parseObjectList(Object? response, String context) {
  if (response is! List<dynamic>) {
    throw CatalogFailure.incompatibleData(diagnosticCode: 'malformed_$context');
  }
  return List<Map<String, Object?>>.unmodifiable(
    response.map((Object? item) {
      if (item is Map<String, dynamic>) {
        return item.cast<String, Object?>();
      }
      throw CatalogFailure.incompatibleData(
        diagnosticCode: 'malformed_$context',
      );
    }),
  );
}
