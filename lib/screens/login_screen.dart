import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n.dart';
import '../services/notifications.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/ui.dart';

/// ---------------------------------------------------------------------------
/// Local "login". The brief marks real login/signup as out of scope, so this
/// only creates an on-device profile — there is no account and no server.
/// ---------------------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _name = TextEditingController();
  String _avatar = '🧑‍🎓';

  static const _avatars = [
    '🧑‍🎓',
    '👩‍🎓',
    '🧑‍💻',
    '🦊',
    '🐼',
    '🦉',
    '🐨',
    '🐧',
    '🐯',
    '🦄',
    '🐙',
    '🌙',
  ];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _enter({bool demo = false}) async {
    final state = context.read<AppState>();
    await state.createProfile(_name.text, _avatar);
    if (demo) {
      await state.loadDemoData();
    }
    // First run: ask for the notification permission so bedtime/wake reminders
    // can fire later. Fire-and-forget — a dismissed dialog must not block entry.
    unawaited(
      NotificationService.init().then(
        (_) => NotificationService.requestPermission(),
      ),
    );
    if (!mounted) return;
    // The root widget swaps to the bedroom as soon as a profile exists.
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primaryContainer,
              scheme.surface,
              scheme.tertiaryContainer.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      '🛏️',
                      style: TextStyle(fontSize: 30, color: scheme.onPrimary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TheBedSpace',
                          style: t.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          L.t('tagline'),
                          style: t.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                L.t('login_create'),
                style: AppTheme.display(t).copyWith(fontSize: 30),
              ),
              const SizedBox(height: 6),
              Text(
                L.t('login_sub'),
                style: t.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),

              ExpressiveCard(
                color: scheme.surfaceContainerHigh,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _name,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: L.t('login_name'),
                        hintText: L.t('login_name_hint'),
                        prefixIcon: const Icon(Icons.person_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        filled: true,
                      ),
                      onSubmitted: (_) => _enter(),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      L.t('login_avatar'),
                      style: t.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _avatars.map((a) {
                        final sel = a == _avatar;
                        return GestureDetector(
                          onTap: () => setState(() => _avatar = a),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: sel
                                  ? scheme.primary
                                  : scheme.surfaceContainerHighest,
                              border: Border.all(
                                color: sel
                                    ? scheme.primary
                                    : scheme.outlineVariant,
                                width: sel ? 3 : 1,
                              ),
                            ),
                            child: Text(
                              a,
                              style: const TextStyle(fontSize: 21),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _enter(),
                icon: const Icon(Icons.bedroom_child_rounded),
                label: Text(L.t('login_start')),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _enter(demo: true),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(L.t('login_demo')),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      L.t('login_offline'),
                      style: t.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
