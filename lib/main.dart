import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/bedroom_screen.dart';
import 'screens/login_screen.dart';
import 'services/audio_service.dart';
import 'services/notifications.dart';
import 'store.dart';
import 'theme.dart';

/// Entry point.
///
/// Deliberately synchronous: `runApp` is called immediately so the Android
/// splash screen (the app-icon screen on Android 12+) is always replaced by a
/// real Flutter frame. Everything slow — reading shared_preferences, starting
/// the notification plugin — happens afterwards inside [_Bootstrap].
///
/// This matters because anything thrown (or awaited forever) *before* `runApp`
/// leaves the device sitting on the launcher icon with no error on screen.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    debugPrint('FlutterError: ${details.exception}');
    FlutterError.presentError(details);
  };
  // Show a readable message instead of a blank grey box / frozen splash when a
  // build or layout error happens at runtime.
  ErrorWidget.builder = (details) => _BootError('${details.exception}');

  final state = AppState();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: state),
        // `.value` (not `create:`) so the shared singleton is never disposed by
        // the provider — it is owned by the app, not by this widget subtree.
        ChangeNotifierProvider<AudioService>.value(
          value: AudioService.instance,
        ),
      ],
      child: _Bootstrap(state: state),
    ),
  );
}

/// Loads persisted state, then hands over to the real app.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap({required this.state});

  final AppState state;

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      // A timeout guarantees the UI is shown even if a platform channel never
      // answers; without it the app would spin forever.
      await widget.state.load().timeout(const Duration(seconds: 8));
    } catch (e, s) {
      debugPrint('AppState.load failed: $e\n$s');
    }
    if (!mounted) return;
    setState(() => _ready = true);

    // Reminders are a "should have" feature: initialise them after the first
    // frame and never await, so a slow/failing channel cannot block the UI.
    unawaited(
      NotificationService.init().timeout(
        const Duration(seconds: 10),
        onTimeout: () => debugPrint('NotificationService.init timed out'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const _BootScreen();
    return const TheBedSpaceApp();
  }
}

/// Shown for the few milliseconds while persisted state is read.
class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(0, Brightness.light),
      home: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

/// Last-resort fallback so an error is never silent.
class _BootError extends StatelessWidget {
  const _BootError(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: const Color(0xFF2B2118),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Text(
                'TheBedSpace hit a problem:\n\n$message',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TheBedSpaceApp extends StatelessWidget {
  const TheBedSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final themeMode = state.themeMode;

    return MaterialApp(
      title: 'TheBedSpace',
      debugShowCheckedModeBanner: false,
      // The key only follows the login state. Signing in or erasing the profile
      // rebuilds the Navigator from scratch, so a route pushed earlier (the
      // setup screen after "Erase everything") can never swallow the swap.
      // Theme and language changes are *not* part of the key: those rebuild in
      // place, so the player stays on the screen they are using.
      key: ValueKey(state.isLoggedIn),
      theme: AppTheme.build(state.seedIndex, Brightness.light),
      darkTheme: AppTheme.build(state.seedIndex, Brightness.dark),
      themeMode: themeMode,
      home: state.isLoggedIn ? const BedroomScreen() : const LoginScreen(),
    );
  }
}
