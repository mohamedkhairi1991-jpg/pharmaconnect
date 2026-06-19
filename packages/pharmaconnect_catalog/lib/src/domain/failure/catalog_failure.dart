enum CatalogFailureKind {
  unauthenticated,
  unauthorized,
  notFound,
  validation,
  conflict,
  invalidState,
  incompatibleData,
  network,
  serviceUnavailable,
  unexpected,
}

final class CatalogFailure implements Exception {
  const CatalogFailure({
    required this.kind,
    this.diagnosticCode,
    this.cause,
    this.stackTrace,
  });

  const CatalogFailure.incompatibleData({
    required String diagnosticCode,
    Object? cause,
    StackTrace? stackTrace,
  }) : this(
         kind: CatalogFailureKind.incompatibleData,
         diagnosticCode: diagnosticCode,
         cause: cause,
         stackTrace: stackTrace,
       );

  final CatalogFailureKind kind;
  final String? diagnosticCode;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    final String code = diagnosticCode == null ? '' : ': $diagnosticCode';
    return 'CatalogFailure(${kind.name}$code)';
  }
}
