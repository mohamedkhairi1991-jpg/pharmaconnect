import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('database and PostgREST codes map to stable failures', () {
    expect(
      mapCatalogError(
        const PostgrestException(message: 'denied', code: '42501'),
      ).kind,
      CatalogFailureKind.unauthorized,
    );
    expect(
      mapCatalogError(
        const PostgrestException(message: 'duplicate', code: '23505'),
      ).kind,
      CatalogFailureKind.conflict,
    );
    expect(
      mapCatalogError(
        const PostgrestException(message: 'invalid', code: '22023'),
      ).kind,
      CatalogFailureKind.validation,
    );
    expect(
      mapCatalogError(
        const PostgrestException(
          message: 'invalid lifecycle transition',
          code: '23514',
        ),
      ).kind,
      CatalogFailureKind.invalidState,
    );
    expect(
      mapCatalogError(
        const PostgrestException(message: 'missing', code: 'P0002'),
      ).kind,
      CatalogFailureKind.notFound,
    );
  });

  test('authentication, network, and malformed data map safely', () {
    expect(
      mapCatalogError(const AuthException('expired')).kind,
      CatalogFailureKind.unauthenticated,
    );
    expect(
      mapCatalogError(const SocketException('offline')).kind,
      CatalogFailureKind.network,
    );
    expect(
      mapCatalogError(TimeoutException('timeout')).kind,
      CatalogFailureKind.network,
    );
    expect(
      mapCatalogError(const FormatException('bad response')).kind,
      CatalogFailureKind.incompatibleData,
    );
  });

  test('empty protected single-row reads map to not found', () async {
    final _MissingDataSource source = _MissingDataSource();
    final SupabaseOfficialCatalogRepository repository =
        SupabaseOfficialCatalogRepository(source);

    expect(
      () => repository.getOfficialProductDetail('hidden-product'),
      throwsA(
        isA<CatalogFailure>().having(
          (CatalogFailure value) => value.kind,
          'kind',
          CatalogFailureKind.notFound,
        ),
      ),
    );
  });
}

final class _MissingDataSource implements CatalogDataSource {
  @override
  Future<Object?> callRpc(String name, Map<String, Object?> params) async =>
      null;

  @override
  Future<List<Map<String, Object?>>> readMany(
    CatalogReadRequest request,
  ) async => const <Map<String, Object?>>[];

  @override
  Future<Map<String, Object?>?> readMaybeSingle(
    CatalogReadRequest request,
  ) async => null;
}
