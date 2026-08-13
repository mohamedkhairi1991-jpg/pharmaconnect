import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/failure/catalog_failure.dart';

CatalogFailure mapCatalogError(Object error, [StackTrace? stackTrace]) {
  if (error is CatalogFailure) {
    return error;
  }
  if (error is AuthException) {
    return CatalogFailure(
      kind: CatalogFailureKind.unauthenticated,
      diagnosticCode: error.code,
      cause: error,
      stackTrace: stackTrace,
    );
  }
  if (error is PostgrestException) {
    final String message = error.message.toLowerCase();
    final CatalogFailureKind kind = switch (error.code) {
      '42501' => CatalogFailureKind.unauthorized,
      '23505' => CatalogFailureKind.conflict,
      '22023' => CatalogFailureKind.validation,
      'P0002' => CatalogFailureKind.notFound,
      '23514'
          when message.contains('transition') ||
              message.contains('only submitted') ||
              message.contains('terminal') =>
        CatalogFailureKind.invalidState,
      '23514' => CatalogFailureKind.validation,
      _ => CatalogFailureKind.unexpected,
    };
    return CatalogFailure(
      kind: kind,
      diagnosticCode: error.code,
      cause: error,
      stackTrace: stackTrace,
    );
  }
  if (error is StorageException) {
    final CatalogFailureKind kind = switch (error.statusCode) {
      '401' => CatalogFailureKind.unauthenticated,
      '403' => CatalogFailureKind.unauthorized,
      '409' => CatalogFailureKind.conflict,
      _ => CatalogFailureKind.unexpected,
    };
    return CatalogFailure(
      kind: kind,
      diagnosticCode: error.statusCode,
      cause: error,
      stackTrace: stackTrace,
    );
  }
  if (error is SocketException ||
      error is TimeoutException ||
      error is AuthRetryableFetchException) {
    return CatalogFailure(
      kind: CatalogFailureKind.network,
      cause: error,
      stackTrace: stackTrace,
    );
  }
  if (error is FormatException || error is TypeError) {
    return CatalogFailure.incompatibleData(
      diagnosticCode: 'malformed_catalog_response',
      cause: error,
      stackTrace: stackTrace,
    );
  }
  return CatalogFailure(
    kind: CatalogFailureKind.unexpected,
    cause: error,
    stackTrace: stackTrace,
  );
}

Future<T> guardCatalogCall<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } on Object catch (error, stackTrace) {
    throw mapCatalogError(error, stackTrace);
  }
}
