import 'kv_store.dart';

/// Web builds have no filesystem; the JSON-file fallback simply reports that it
/// is unavailable, and [openKvStore] falls through to the in-memory store.
Future<KvStore?> openFileKvStore() async => null;
