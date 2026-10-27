// File-backed fallback for [KvStore].
//
// `dart:io` cannot be compiled for web, so the implementation is chosen at
// compile time (same pattern as `audio_storage.dart`).
export 'kv_file_stub.dart' if (dart.library.io) 'kv_file_io.dart';
