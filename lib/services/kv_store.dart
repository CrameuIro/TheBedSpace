import 'package:flutter/foundation.dart';

import 'kv_file.dart';

/// ---------------------------------------------------------------------------
/// A tiny key -> string store. The app only persists a handful of JSON strings.
///
/// Deliberately does NOT use a native preference plugin: on some devices the
/// shared_preferences Dart package and its Android implementation are version
/// mismatched, which throws `NoSuchMethodError: SharedPreferencesApi$Registrar`
/// on every launch. Owning a plain JSON file keeps persistence inside Dart and
/// removes that entire failure mode.
/// ---------------------------------------------------------------------------
abstract class KvStore {
  String get label;

  String? read(String key);

  Future<void> write(String key, String value);

  Future<void> clear();
}

/// Used on web (no filesystem) and as a last resort if no location is writable.
/// Nothing survives a restart, so the UI can warn.
class MemoryKvStore implements KvStore {
  final Map<String, String> _map = {};

  @override
  String get label => 'memory';

  bool get isPersistent => false;

  @override
  String? read(String key) => _map[key];

  @override
  Future<void> write(String key, String value) async => _map[key] = value;

  @override
  Future<void> clear() async => _map.clear();
}

/// Result of [openKvStore].
class KvOpenResult {
  KvOpenResult(this.store);

  final KvStore store;

  /// True when nothing will survive a restart (memory-only fallback).
  bool get isTemporary => store is MemoryKvStore;
}

/// Test seam: returns a fixed store instead of touching the filesystem.
@visibleForTesting
Future<KvStore> Function()? debugKvStoreOverride;

/// Opens the persistent store. Never throws.
Future<KvOpenResult> openKvStore() async {
  final override = debugKvStoreOverride;
  if (override != null) return KvOpenResult(await override());

  try {
    final fileStore = await openFileKvStore();
    if (fileStore != null) return KvOpenResult(fileStore);
  } catch (e) {
    debugPrint('kv: file store failed: $e');
  }
  debugPrint('kv: no writable location, running in memory only');
  return KvOpenResult(MemoryKvStore());
}
