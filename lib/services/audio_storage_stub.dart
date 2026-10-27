/// Web build: the browser gives no writable filesystem for the app to keep
/// uploads in, so the caller treats a `null` result as "not supported here".
Future<String?> storeUserAudio({
  required String sourcePath,
  required String id,
  required String extension,
}) async => null;
