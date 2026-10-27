import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n.dart';
import '../store.dart';
import '../widgets/ui.dart';

/// Local profile editor, matching the name and avatar controls used at setup.
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
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

  late final TextEditingController _name;
  late String _avatar;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppState>().profile!;
    _name = TextEditingController(text: profile.name);
    _avatar = profile.avatar;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    await context.read<AppState>().updateProfile(_name.text, _avatar);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(L.t('edit_profile'))),
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
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
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
                        prefixIcon: const Icon(Icons.person_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        filled: true,
                      ),
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
                      children: _avatars.map((avatar) {
                        final selected = avatar == _avatar;
                        return GestureDetector(
                          onTap: () => setState(() => _avatar = avatar),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? scheme.primary
                                  : scheme.surfaceContainerHighest,
                              border: Border.all(
                                color: selected
                                    ? scheme.primary
                                    : scheme.outlineVariant,
                                width: selected ? 3 : 1,
                              ),
                            ),
                            child: Text(
                              avatar,
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
              FilledButton(onPressed: _confirm, child: Text(L.t('confirm'))),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(L.t('cancel')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
