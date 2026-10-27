// Runtime smoke tests for TheBedSpace.
//
// There is no device in the build environment, so every screen is rendered in a
// phone-sized viewport instead. Any exception thrown while building a widget
// (CustomPainter maths, missing theme data, bad sizes...) fails these tests.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:thebedspace/main.dart';
import 'package:thebedspace/models.dart';
import 'package:thebedspace/screens/articles_screen.dart';
import 'package:thebedspace/screens/bedroom_screen.dart';
import 'package:thebedspace/screens/chat_screen.dart';
import 'package:thebedspace/screens/decor_screen.dart';
import 'package:thebedspace/screens/desk_screen.dart';
import 'package:thebedspace/screens/friend_room_screen.dart';
import 'package:thebedspace/screens/friends_screen.dart';
import 'package:thebedspace/screens/goals_screen.dart';
import 'package:thebedspace/screens/login_screen.dart';
import 'package:thebedspace/screens/profile_edit_screen.dart';
import 'package:thebedspace/screens/recovery_screen.dart';
import 'package:thebedspace/screens/settings_screen.dart';
import 'package:thebedspace/screens/sleep_log_sheet.dart';
import 'package:thebedspace/screens/stats_screen.dart';
import 'package:thebedspace/screens/tv_screen.dart';
import 'package:thebedspace/screens/weekly_screen.dart';
import 'package:thebedspace/seed.dart';
import 'package:thebedspace/services/audio_service.dart';
import 'package:thebedspace/services/kv_store.dart';
import 'package:thebedspace/store.dart';
import 'package:thebedspace/theme.dart';

/// The one in-memory store shared by every [AppState] in a test. Two states
/// reading the same instance is exactly what "close the app and open it again"
/// looks like to the app, without touching a real file.
late MemoryKvStore _store;

/// Builds a logged-in state with two weeks of sample nights.
Future<AppState> _state({bool demo = true, bool loggedIn = true}) async {
  final state = AppState();
  await state.load();
  if (loggedIn) {
    await state.createProfile('Alex', '🧑‍🎓');
    if (demo) await state.loadDemoData();
  }
  return state;
}

extension on WidgetTester {
  /// Uses a phone-sized viewport so overflow (a real error on device) is caught.
  void usePhoneViewport() {
    view.devicePixelRatio = 3.0;
    view.physicalSize = const Size(1080, 2340);
    addTearDown(view.reset);
  }
}

Future<void> _pump(
  WidgetTester tester,
  AppState state,
  Widget screen, {
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: state),
        ChangeNotifierProvider<AudioService>.value(
          value: AudioService.instance,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(state.seedIndex, brightness),
        home: screen,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 350));
}

void main() {
  setUp(() {
    _store = MemoryKvStore();
    debugKvStoreOverride = () async => _store;
  });

  tearDown(() => debugKvStoreOverride = null);

  final screens = <String, Widget Function()>{
    'login': () => const LoginScreen(),
    'profile edit': () => const ProfileEditScreen(),
    'bedroom': () => const BedroomScreen(),
    'tv': () => const TvScreen(),
    'desk': () => const DeskScreen(),
    'stats': () => const StatsScreen(),
    'goals': () => const GoalsScreen(),
    'weekly': () => const WeeklyScreen(),
    'recovery': () => const RecoveryScreen(),
    'settings': () => const SettingsScreen(),
    'decor': () => const DecorScreen(),
    'friends': () => const FriendsScreen(),
    'chat': () => ChatScreen(friend: kFriends.first),
    'article detail': () => ArticleDetail(article: kArticles.first),
    'friend room': () => FriendRoomScreen(friend: kFriends.first),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} renders (light)', (tester) async {
      tester.usePhoneViewport();
      final state = await _state();
      await _pump(tester, state, entry.value());
      expect(tester.takeException(), isNull);
    });

    testWidgets('${entry.key} renders (dark)', (tester) async {
      tester.usePhoneViewport();
      final state = await _state();
      await _pump(tester, state, entry.value(), brightness: Brightness.dark);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('every seed colour and brightness builds a theme', (
    tester,
  ) async {
    for (var i = 0; i < kSeedPalettes.length; i++) {
      for (final b in Brightness.values) {
        final theme = AppTheme.build(i, b);
        expect(theme.colorScheme.brightness, b);
      }
    }
  });

  testWidgets('screens render in Chinese too', (tester) async {
    tester.usePhoneViewport();
    final state = await _state();
    await state.setLang('zh');
    for (final build in screens.values) {
      await _pump(tester, state, build());
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('empty state (no nights logged) does not crash', (tester) async {
    tester.usePhoneViewport();
    final state = await _state(demo: false);
    for (final build in screens.values) {
      await _pump(tester, state, build());
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('logging a night awards XP and keeps the room consistent', (
    tester,
  ) async {
    final state = await _state(demo: false);
    final before = state.entries.length;
    final levelBefore = state.profile!.level;
    await state.logSleep(
      bedtime: DateTime(2026, 10, 18, 23, 30),
      wake: DateTime(2026, 10, 19, 7, 15),
      quality: 4,
      factors: const ['phone', 'caffeine'],
      note: 'late lab report',
    );
    expect(state.entries.length, before + 1);
    expect(state.profile!.level, greaterThanOrEqualTo(levelBefore));
    expect(state.roomScore, isA<int>());
  });

  testWidgets('the real entry point shows login, then the bedroom', (
    tester,
  ) async {
    tester.usePhoneViewport();
    final state = await _state(demo: false, loggedIn: false);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>.value(value: state),
          ChangeNotifierProvider<AudioService>(
            create: (_) => AudioService.instance,
          ),
        ],
        child: const TheBedSpaceApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('TheBedSpace'), findsWidgets);
    expect(find.text('Enter my bedroom'), findsWidgets);

    // Creating a profile swaps the home screen to the bedroom.
    await state.createProfile('Alex', '🧑‍🎓');
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Enter my bedroom'), findsNothing);
    expect(find.byIcon(Icons.settings_rounded), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login screen creates a local profile', (tester) async {
    tester.usePhoneViewport();
    final state = await _state(loggedIn: false);
    await _pump(tester, state, const LoginScreen());

    await tester.enterText(find.byType(TextField), 'Sam');
    await tester.tap(find.text('Enter my bedroom'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(state.isLoggedIn, isTrue);
    expect(state.profile?.name, 'Sam');
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile and sleep data survive a relaunch', (tester) async {
    final first = AppState();
    await first.load();
    expect(first.isLoggedIn, isFalse);
    await first.createProfile('Alex', '🧑‍🎓');
    await first.logSleep(
      bedtime: DateTime(2026, 10, 18, 23, 30),
      wake: DateTime(2026, 10, 19, 7, 15),
      quality: 4,
      factors: const ['phone'],
    );
    final nights = first.entries.length;

    // Second instance = the next launch. It must find the saved profile/data
    // instead of dropping back to the "Create your space" screen.
    final second = AppState();
    await second.load();
    expect(second.isLoggedIn, isTrue);
    expect(second.entries.length, nights);
    expect(second.placed.length, 4);
  });

  test('friend permissions survive a relaunch', () async {
    final first = AppState();
    await first.load();
    expect(first.canFriendView(kFriends.first.id), isTrue);

    await first.setFriendPermission(kFriends.first.id, false);
    final second = AppState();
    await second.load();

    expect(second.canFriendView(kFriends.first.id), isFalse);
    expect(second.canFriendView(kFriends[1].id), isTrue);
  });

  testWidgets('a stale layout is migrated to the new starting positions', (
    tester,
  ) async {
    final first = AppState();
    await first.load();
    await first.createProfile('Alex', '🧑‍🎓');
    // Simulate an install from the previous build: furniture is stacked against
    // the window and the settings blob has no layoutVersion stamp.
    await first.movePlaced(first.placed.first, 0.9, 0.2);
    await _store.write(
      'settings',
      jsonEncode({'lang': 'en', 'seedIndex': 0, 'themeMode': 0}),
    );

    final second = AppState();
    await second.load();
    // The layout was rebuilt, so nothing is left shoved up against the window.
    expect(second.placed.every((p) => p.y > 0.2), isTrue);
  });

  testWidgets('erase returns to login, and entering the bedroom works again', (
    tester,
  ) async {
    // Regression for: erase -> login screen -> "Enter my bedroom" no response.
    tester.usePhoneViewport();
    final state = await _state(demo: false);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>.value(value: state),
          ChangeNotifierProvider<AudioService>(
            create: (_) => AudioService.instance,
          ),
        ],
        child: const TheBedSpaceApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byIcon(Icons.settings_rounded), findsWidgets);

    await state.eraseAll();
    await tester.pump(const Duration(milliseconds: 350));
    expect(state.isLoggedIn, isFalse);
    expect(state.entries, isEmpty);
    expect(find.text('Enter my bedroom'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Sam');
    await tester.tap(find.text('Enter my bedroom'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(state.isLoggedIn, isTrue);
    expect(state.profile!.name, 'Sam');
    expect(find.text('Enter my bedroom'), findsNothing);
    expect(find.byIcon(Icons.settings_rounded), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bedroom sleep score is the summed item scores divided by 4', (
    tester,
  ) async {
    final state = await _state();
    expect(state.bedroomSleepScore, state.roomScore / 4);
    expect(Util.score(1.25), '+1.25');
    expect(Util.score(-0.5), '-0.50');
  });

  testWidgets('a night well past the bedtime goal gets a recovery plan', (
    tester,
  ) async {
    final state = await _state(demo: false);
    // Default goal: bed at 21:00, 8 hours.
    final late = SleepEntry(
      id: 'late',
      bedtime: DateTime(2026, 10, 20, 1, 30),
      wake: DateTime(2026, 10, 20, 7, 0),
      quality: 2,
      factors: ['phone', 'stress'],
    );
    final onTime = SleepEntry(
      id: 'ok',
      bedtime: DateTime(2026, 10, 19, 21, 30),
      wake: DateTime(2026, 10, 20, 6, 0),
      quality: 4,
      factors: [],
    );
    expect(state.isLateNight(late), isTrue);
    expect(state.isLateNight(onTime), isFalse);
    expect(state.lateNightReport(onTime), isNull);

    final report = state.lateNightReport(late)!;
    expect(report.minutesLate, 270);
    expect(report.hoursShort, closeTo(2.5, 0.01));
    // More than two hours late: step back one hour tonight (00:30).
    expect(report.tonightBedSlot, 6 * 60 + 30);
    final text = report.tips.map((t) => t.text).join('\n');
    expect(text, contains('00:30'));
    expect(text, contains('phone'));
    expect(text, contains('nap'));
    expect(text, contains('Stress / deadline'));
  });

  testWidgets('the late-night recovery plan renders', (tester) async {
    tester.usePhoneViewport();
    final state = await _state(demo: false);
    final report = state.lateNightReport(
      SleepEntry(
        id: 'late',
        bedtime: DateTime(2026, 10, 20, 2, 0),
        wake: DateTime(2026, 10, 20, 7, 0),
        quality: 2,
        factors: ['caffeine', 'latework'],
      ),
    )!;
    await _pump(
      tester,
      state,
      Scaffold(
        body: ListView(children: [LateNightPlan(report: report)]),
      ),
    );
    expect(find.text('You stayed up late'), findsOneWidget);
    expect(find.textContaining('logged caffeine'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('bedtimes after midnight land on the next day', () {
    final night = DateTime(2026, 10, 23); // the evening of Fri 23/10
    double hours(int bed, int wake) {
      final (b, w) = Util.nightTimes(night, bed, wake);
      return w.difference(b).inMinutes / 60;
    }

    // 23:00 -> 07:00 is 8 h, starting on the evening itself.
    final (b1, w1) = Util.nightTimes(night, 23 * 60, 7 * 60);
    expect(b1, DateTime(2026, 10, 23, 23));
    expect(w1, DateTime(2026, 10, 24, 7));
    // 01:00 -> 07:00 is 6 h, not 30 h: bedtime is after midnight.
    final (b2, w2) = Util.nightTimes(night, 1 * 60, 7 * 60);
    expect(b2, DateTime(2026, 10, 24, 1));
    expect(w2, DateTime(2026, 10, 24, 7));
    expect(hours(0, 7 * 60), 7); // exactly midnight
    expect(hours(21 * 60 + 30, 5 * 60), 7.5);
    expect(hours(2 * 60, 10 * 60 + 30), 8.5); // sleeping in
    // A daytime bedtime still gives under 24 h, never 30 h.
    expect(hours(11 * 60, 7 * 60), 20);
    expect(hours(12 * 60, 13 * 60), 1); // noon nap
    expect(hours(23 * 60, 23 * 60), 24); // same time: wake the next day
  });

  testWidgets('the sleep log sheet opens on a normal 8 h night', (
    tester,
  ) async {
    tester.usePhoneViewport();
    final state = await _state(demo: false);
    await _pump(
      tester,
      state,
      Builder(
        builder: (c) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => showSleepLogSheet(c),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('8h'), findsOneWidget);
    expect(find.text('Goal met'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('picking 01:00 gives 6 h, and 11:00 asks to check AM / PM', (
    tester,
  ) async {
    tester.usePhoneViewport();
    final state = await _state(demo: false);
    await _pump(
      tester,
      state,
      Builder(
        builder: (c) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => showSleepLogSheet(c),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    Future<void> pickBedtime(String hour) async {
      await tester.tap(find.text('Bedtime'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();
      final fields = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(fields.at(0), hour);
      await tester.enterText(fields.at(1), '00');
      // The test locale shows a 12-hour picker; both picks here are AM.
      if (find.text('AM').evaluate().isNotEmpty) {
        await tester.tap(find.text('AM'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }

    await pickBedtime('01');
    expect(find.text('6h'), findsOneWidget);
    expect(find.textContaining('longer than a night'), findsNothing);

    await pickBedtime('11');
    expect(find.text('20h'), findsOneWidget);
    expect(find.textContaining('longer than a night'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Save this night'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    final save = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Save this night'),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      ),
    );
    expect(save.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
