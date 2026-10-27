import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n.dart';
import '../models.dart';
import '../widgets/ui.dart';

/// ---------------------------------------------------------------------------
/// Friend chat (Could-have). Entirely local: replies are canned strings that
/// rotate as you send, and nothing leaves the device — the real friend server
/// is out of scope for the MVP.
/// ---------------------------------------------------------------------------
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.friend});

  final Friend friend;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messages = <_Msg>[];
  final _input = TextEditingController();
  final _scroll = ScrollController();
  int _replyIndex = 0;

  @override
  void initState() {
    super.initState();
    // Seed the thread with a short exchange so an empty chat is never shown.
    _messages.add(_Msg(L.t('chat_seed_them')));
    _messages.add(_Msg(L.t('chat_seed_me'), mine: true));
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text, mine: true));
      _input.clear();
    });
    _scrollToEnd();

    // Canned reply, delayed a beat so it feels like a conversation.
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        if (widget.friend.isSleeping(DateTime.now())) {
          _messages.add(
            _Msg(
              L.tr('chat_r_asleep', {'name': widget.friend.name}),
              system: true,
            ),
          );
        } else {
          const keys = ['chat_r1', 'chat_r2', 'chat_r3', 'chat_r4'];
          _messages.add(_Msg(L.t(keys[_replyIndex++ % keys.length])));
        }
      });
      _scrollToEnd();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final sleeping = widget.friend.isSleeping(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: sleeping
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHighest,
              child: Text(
                widget.friend.avatar,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.friend.name,
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    sleeping ? L.t('chat_asleep') : L.t('chat_online'),
                    style: t.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: L.t('chat_clear'),
            onPressed: () => setState(_messages.clear),
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Reminder that this is a local demo, not a real messenger.
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                L.t('chat_sub'),
                style: t.textTheme.bodySmall?.copyWith(
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ),
            Expanded(
              child: _messages.isEmpty
                  ? EmptyState(emoji: '💬', message: L.t('chat_empty'))
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) => _Bubble(
                        msg: _messages[i],
                        avatar: widget.friend.avatar,
                      ),
                    ),
            ),
            _Composer(
              controller: _input,
              hint: L.tr('chat_hint', {'name': widget.friend.name}),
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

/// One message in the thread.
class _Msg {
  _Msg(this.text, {this.mine = false, this.system = false});

  final String text;
  final bool mine;

  /// System notes (e.g. "they are asleep") are centred and styled differently.
  final bool system;
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg, required this.avatar});

  final _Msg msg;
  final String avatar;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;

    if (msg.system) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              msg.text,
              textAlign: TextAlign.center,
              style: t.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: msg.mine ? scheme.primary : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(msg.mine ? 18 : 4),
          bottomRight: Radius.circular(msg.mine ? 4 : 18),
        ),
      ),
      child: Text(
        msg.text,
        style: t.textTheme.bodyMedium?.copyWith(
          color: msg.mine ? scheme.onPrimary : scheme.onSurface,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: msg.mine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.mine) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: scheme.surfaceContainerHighest,
              child: Text(avatar, style: const TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 8),
          ],
          bubble,
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.hint,
    required this.onSend,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onSend,
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(14),
              backgroundColor: scheme.primary,
            ),
            child: Icon(Icons.send_rounded, size: 20, color: scheme.onPrimary),
          ),
        ],
      ),
    );
  }
}
