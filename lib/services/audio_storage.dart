// Copies a user-picked audio file into a location the app can read again.
//
// Mobile and desktop have a real filesystem, but the browser does not — and
// `dart:io` cannot even be compiled for web. The implementation is therefore
// selected at compile time; the web stub reports the feature as unavailable.
export 'audio_storage_stub.dart' if (dart.library.io) 'audio_storage_io.dart';
