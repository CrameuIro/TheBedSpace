import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Copies the picked file into the app's own documents directory so it is not
/// lost when the OS clears the shared cache. Returns the new absolute path.
Future<String?> storeUserAudio({
  required String sourcePath,
  required String id,
  required String extension,
}) async {
  final dir = await getApplicationDocumentsDirectory();
  final dest = '${dir.path}/$id.$extension';
  await File(sourcePath).copy(dest);
  return dest;
}
