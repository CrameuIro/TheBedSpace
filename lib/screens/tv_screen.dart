import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n.dart';
import '../models.dart';
import '../seed.dart';
import '../services/audio_service.dart';
import '../services/audio_storage.dart';
import '../store.dart';
import '../widgets/ui.dart';
import 'articles_screen.dart';

/// ---------------------------------------------------------------------------
/// The bedroom TV: fall-asleep sounds (built-in + user uploads) and short
/// health articles. Marked "Should" in the brief.
/// ---------------------------------------------------------------------------
class TvScreen extends StatelessWidget {
  const TvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(L.t('media')),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.music_note_rounded),
                text: L.t('sounds'),
              ),
              Tab(
                icon: const Icon(Icons.article_rounded),
                text: L.t('articles'),
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [_SoundsTab(), ArticlesList()]),
      ),
    );
  }
}

class _SoundsTab extends StatelessWidget {
  const _SoundsTab();

  Future<void> _pickAudio(BuildContext context) async {
    final state = context.read<AppState>();
    try {
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'],
      );
      final path = picked?.path;
      if (path == null) return;

      final ext = path.split('.').last;
      final id = 'u${DateTime.now().millisecondsSinceEpoch}';
      final dest = await storeUserAudio(
        sourcePath: path,
        id: id,
        extension: ext,
      );
      if (dest == null) {
        // Browser builds have nowhere to keep the file.
        if (context.mounted) showToast(context, L.t('upload_unsupported'));
        return;
      }

      final name = picked!.name.replaceAll(RegExp(r'\.[a-z0-9]+$'), '');
      final track = SoundTrack(
        id: id,
        nameEn: name,
        nameZh: name,
        emoji: '🎧',
        filePath: dest,
      );
      await state.addUserSound(track);
      if (context.mounted) {
        showToast(context, L.tr('uploaded_toast', {'name': name}));
      }
    } catch (_) {
      if (context.mounted) showToast(context, L.t('upload_failed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final audio = context.watch<AudioService>();
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              SectionHeader(title: L.t('builtin_sounds')),
              _SoundGrid(
                tracks: kBuiltInSounds,
                currentId: audio.current?.id,
                onTap: (tr) => audio.play(tr),
              ),
              const SizedBox(height: 8),
              if (state.userSounds.isNotEmpty) ...[
                SectionHeader(title: L.t('my_sounds')),
                _SoundGrid(
                  tracks: state.userSounds,
                  currentId: audio.current?.id,
                  onTap: (tr) => audio.play(tr),
                  onLongPress: (tr) => state.removeUserSound(tr.id),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _pickAudio(context),
                icon: const Icon(Icons.upload_file_rounded),
                label: Text(L.t('upload_audio')),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                child: Text(
                  L.t('upload_hint'),
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
              if (audio.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    L.t('play_failed'),
                    style: TextStyle(color: scheme.error),
                  ),
                ),
            ],
          ),
        ),
        if (audio.current != null) _NowPlayingBar(audio: audio),
      ],
    );
  }
}

class _SoundGrid extends StatelessWidget {
  const _SoundGrid({
    required this.tracks,
    required this.currentId,
    required this.onTap,
    this.onLongPress,
  });

  final List<SoundTrack> tracks;
  final String? currentId;
  final void Function(SoundTrack) onTap;
  final void Function(SoundTrack)? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tracks.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, i) {
        final tr = tracks[i];
        final sel = tr.id == currentId;
        final scheme = Theme.of(context).colorScheme;
        return ExpressiveCard(
          color: sel ? scheme.primaryContainer : scheme.surfaceContainerHigh,
          onTap: () => onTap(tr),
          padding: const EdgeInsets.all(14),
          child: GestureDetector(
            onLongPress: onLongPress == null ? null : () => onLongPress!(tr),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr.emoji, style: const TextStyle(fontSize: 26)),
                    if (sel)
                      Icon(
                        Icons.graphic_eq_rounded,
                        color: scheme.primary,
                        size: 20,
                      ),
                  ],
                ),
                Text(
                  tr.name(L.lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NowPlayingBar extends StatelessWidget {
  const _NowPlayingBar({required this.audio});
  final AudioService audio;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(audio.current!.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L.t('now_playing'),
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    Text(
                      audio.current!.name(L.lang),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: audio.stop,
                icon: const Icon(Icons.stop_rounded),
                tooltip: L.t('stop'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                L.t('sleep_timer'),
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final m in [null, 10, 20, 30, 45, 60])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: PillChip(
                            label: m == null
                                ? L.t('timer_off')
                                : L.tr('minutes', {'n': '$m'}),
                            selected: audio.timerMinutes == m,
                            onTap: () => audio.setTimer(m),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
