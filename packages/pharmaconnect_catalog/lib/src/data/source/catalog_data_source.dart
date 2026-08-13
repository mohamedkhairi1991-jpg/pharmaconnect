import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../error/supabase_catalog_failure_mapper.dart';

final class CatalogReadRequest {
  const CatalogReadRequest({
    required this.table,
    required this.projection,
    this.filters = const <String, Object>{},
    this.orderBy,
    this.ascending = true,
    this.limit,
    this.offset = 0,
  });

  final String table;
  final String projection;
  final Map<String, Object> filters;
  final String? orderBy;
  final bool ascending;
  final int? limit;
  final int offset;
}

abstract interface class CatalogDataSource {
  Future<List<Map<String, Object?>>> readMany(CatalogReadRequest request);

  Future<Map<String, Object?>?> readMaybeSingle(CatalogReadRequest request);

  Future<Object?> callRpc(String name, Map<String, Object?> params);
}

abstract interface class CatalogStorageDataSource {
  Future<void> uploadBinary({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String mimeType,
  });

  Future<void> remove({required String bucket, required String path});
}

final class SupabaseCatalogDataSource implements CatalogDataSource {
  const SupabaseCatalogDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, Object?>>> readMany(CatalogReadRequest request) =>
      guardCatalogCall(() async {
        PostgrestFilterBuilder<PostgrestList> query = _client
            .from(request.table)
            .select(request.projection);
        for (final MapEntry<String, Object> filter in request.filters.entries) {
          query = query.eq(filter.key, filter.value);
        }
        PostgrestTransformBuilder<PostgrestList> transformed = query;
        if (request.orderBy != null) {
          transformed = transformed.order(
            request.orderBy!,
            ascending: request.ascending,
          );
        }
        if (request.limit != null) {
          transformed = transformed.range(
            request.offset,
            request.offset + request.limit! - 1,
          );
        }
        final PostgrestList response = await transformed;
        return List<Map<String, Object?>>.unmodifiable(
          response.map((PostgrestMap row) => row.cast<String, Object?>()),
        );
      });

  @override
  Future<Map<String, Object?>?> readMaybeSingle(CatalogReadRequest request) =>
      guardCatalogCall(() async {
        PostgrestFilterBuilder<PostgrestList> query = _client
            .from(request.table)
            .select(request.projection);
        for (final MapEntry<String, Object> filter in request.filters.entries) {
          query = query.eq(filter.key, filter.value);
        }
        final PostgrestMap? response = await query.maybeSingle();
        return response?.cast<String, Object?>();
      });

  @override
  Future<Object?> callRpc(String name, Map<String, Object?> params) =>
      guardCatalogCall(() => _client.rpc<Object?>(name, params: params));
}

final class SupabaseCatalogStorageDataSource
    implements CatalogStorageDataSource {
  const SupabaseCatalogStorageDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<void> uploadBinary({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String mimeType,
  }) => guardCatalogCall(() async {
    await _client.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: false),
        );
  });

  @override
  Future<void> remove({required String bucket, required String path}) =>
      guardCatalogCall(() async {
        await _client.storage.from(bucket).remove(<String>[path]);
      });
}
