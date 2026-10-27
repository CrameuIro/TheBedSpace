import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'kv_store.dart';

/// Persists every value in one small JSON file inside the app's own directory.
/// Only path_provider is involved; if even that is unavailable the platform temp
/// directory (the app's private cache folder on Android) is used instead.
class FileKvStore implements KvStore {
  FileKvStore(this._file, Map<String, String> values)
    : _values = Map<String, String>.from(values);

  final File _file;
  final Map<String, String> _values;

  /// Flushes run one after another. Without this, a `clear()` still writing its
  /// empty document could finish *after* the write that followed it (erasing a
  /// brand-new profile) and lose it.
  Future<void> _tail = Future<void>.value();

  @override
  String get label => 'file store (${_file.path})';

  @override
  String? read(String key) => _values[key];

  @override
  Future<void> write(String key, String value) {
    _values[key] = value;
    return _enqueue(_flush);
  }

  @override
  Future<void> clear() {
    _values.clear();
    return _enqueue(_flush);
  }

  Future<void> _enqueue(Future<void> Function() op) {
    final next = _tail.then((_) => op());
    _tail = next.catchError((_) {});
    return next;
  }

  /// Writes via a temp file + rename so a crash mid-write cannot leave a
  /// half-written JSON document behind. Windows refuses to rename over an
  /// existing file, so a direct write is used as the fallback.
  Future<void> _flush() async {
    final data = jsonEncode(_values);
    try {
      final tmp = File('${_file.path}.tmp');
      await tmp.writeAsString(data, flush: true);
      if (await _file.exists()) await _file.delete();
      await tmp.rename(_file.path);
    } catch (e) {
      debugPrint('kv: atomic write unavailable ($e); writing directly');
      await _file.writeAsString(data, flush: true);
    }
  }
}

/// Returns null when no writable location could be found.
Future<KvStore?> openFileKvStore() async {
  File? file;
  // Prefer app-private, persistent directories. `Directory.systemTemp` is only
  // the last resort: on Android it is the cache folder, which the system may
  // clear under storage pressure.
  for (final dir in await _candidateDirs()) {
    file = File('${dir.path}${Platform.pathSeparator}thebedspace_store.json');
    if (await _isWritable(file)) break;
    file = null;
  }
  if (file == null) return null;

  var values = <String, String>{};
  try {
    if (await file.exists()) {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map) {
        values = {
          for (final entry in decoded.entries)
            if (entry.value is String)
              entry.key as String: entry.value as String,
        };
      }
    }
  } catch (e) {
    debugPrint('kv: could not read ${file.path}: $e');
  }

  return FileKvStore(file, values);
}

/// Candidate directories, best (persistent, app-private) first.
Future<List<Directory>> _candidateDirs() async {
  final dirs = <Directory>[];
  for (final get in [
    getApplicationSupportDirectory,
    getApplicationDocumentsDirectory,
  ]) {
    try {
      final dir = await get();
      if (!dir.existsSync()) dir.createSync(recursive: true);
      dirs.add(dir);
    } catch (e) {
      debugPrint('kv: app directory unavailable: $e');
    }
  }
  if (Platform.isAndroid) {
    // Fallback that needs no plugin channel: on Android the runtime temp folder
    // is `<app data>/cache`, and its parent is the app's persistent private
    // directory. Keeps saves alive even if a plugin channel fails.
    try {
      final tmp = Directory.systemTemp;
      final root = tmp.parent;
      if (root.path != tmp.path && root.path.length > 1) {
        if (!root.existsSync()) root.createSync(recursive: true);
        dirs.add(root);
      }
    } catch (e) {
      debugPrint('kv: app data directory unavailable: $e');
    }
  }
  try {
    dirs.add(Directory.systemTemp);
  } catch (e) {
    debugPrint('kv: temp directory unavailable: $e');
  }
  return dirs;
}

/// Writes and deletes a probe file, so an unwritable sandbox is detected here
/// rather than on the player's first save.
Future<bool> _isWritable(File file) async {
  try {
    final probe = File('${file.path}.probe');
    await probe.writeAsString('ok', flush: true);
    await probe.delete();
    return true;
  } catch (e) {
    debugPrint('kv: ${file.parent.path} is not writable: $e');
    return false;
  }
}
