import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'l10n.dart';
import 'models.dart';
import 'seed.dart';
import 'services/kv_store.dart';

/// ---------------------------------------------------------------------------
/// AppState — the single offline source of truth. Persisted as JSON through
/// [KvStore] (an app-private JSON file), so the whole app works with no backend.
/// ---------------------------------------------------------------------------
class AppState extends ChangeNotifier {
  static const _kProfile = 'profile';
  static const _kGoals = 'goals';
  static const _kEntries = 'entries';
  static const _kUnlocked = 'unlocked';
  static const _kPlaced = 'placed';
  static const _kRead = 'readArticles';
  static const _kSounds = 'userSounds';
  static const _kSettings = 'settings';
  static const _kFriendPermissions = 'friendPermissions';

  /// Bumped whenever the *seed* bedroom layout changes. A stored layout from an
  /// older build is replaced on load, so fixes to the starting room actually
  /// reach an existing install instead of only fresh ones.
  static const kLayoutVersion = 2;

  KvStore? _store;

  PlayerProfile? profile;
  SleepGoals goals = SleepGoals();
  List<SleepEntry> entries = [];
  Set<String> unlocked = {'bed_basic', 'tv_basic', 'desk_basic', 'door_basic'};
  List<PlacedFurniture> placed = [];
  Set<String> readArticles = {};
  List<SoundTrack> userSounds = [];
  Map<String, bool> friendPermissions = {};

  // ---- display settings -----------------------------------------------------
  String lang = 'en';
  ThemeMode themeMode = ThemeMode.system;
  int seedIndex = 0;
  bool loaded = false;

  bool get isLoggedIn => profile != null;

  /// Furniture definitions the player currently owns.
  List<FurnitureDef> get ownedDefs =>
      kFurniture.where((f) => unlocked.contains(f.id)).toList();

  FurnitureDef? defFor(String id) {
    for (final f in kFurniture) {
      if (f.id == id) return f;
    }
    return null;
  }

  // ==========================================================================
  // persistence
  // ==========================================================================
  Future<void> load() async {
    // Never throws: [openKvStore] degrades to a file store, then to memory, so
    // startup cannot be blocked by a broken native preference store.
    final opened = await openKvStore();
    _store = opened.store;
    if (opened.isTemporary) {
      debugPrint('AppState.load: storage is memory-only for this session');
    }

    // Every value is decoded defensively. A single unreadable field must never
    // take the rest of the player's data down with it, which is what used to
    // drop people back on the "Create your space" screen at every launch.
    profile = _decode(
      _kProfile,
      (j) => PlayerProfile.fromJson(j as Map<String, dynamic>),
    );

    goals =
        _decode(
          _kGoals,
          (j) => SleepGoals.fromJson(j as Map<String, dynamic>),
        ) ??
        goals;

    final loadedEntries = _decode(
      _kEntries,
      (j) => (j as List)
          .map((e) => SleepEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    if (loadedEntries != null) {
      entries = loadedEntries..sort((a, b) => a.bedtime.compareTo(b.bedtime));
    }

    unlocked =
        _decode(
          _kUnlocked,
          (j) => (j as List).map((e) => e as String).toSet(),
        ) ??
        unlocked;

    readArticles =
        _decode(_kRead, (j) => (j as List).map((e) => e as String).toSet()) ??
        readArticles;

    userSounds =
        _decode(
          _kSounds,
          (j) => (j as List)
              .map((e) => SoundTrack.fromJson(e as Map<String, dynamic>))
              .toList(),
        ) ??
        userSounds;

    friendPermissions =
        _decode(
          _kFriendPermissions,
          (j) => (j as Map<String, dynamic>).map(
            (id, allowed) => MapEntry(id, allowed == true),
          ),
        ) ??
        friendPermissions;

    final storedPlacements = _decode(
      _kPlaced,
      (j) => (j as List)
          .map((e) => PlacedFurniture.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    final settings = _decode(_kSettings, (j) => j as Map<String, dynamic>);
    var layoutVersion = 0;
    if (settings != null) {
      lang = (settings['lang'] as String?) ?? 'en';
      seedIndex = (settings['seedIndex'] as num?)?.toInt() ?? 0;
      final tm = (settings['themeMode'] as num?)?.toInt() ?? 0;
      themeMode = ThemeMode.values[tm.clamp(0, ThemeMode.values.length - 1)];
      layoutVersion = (settings['layoutVersion'] as num?)?.toInt() ?? 1;
    }
    L.set(lang);

    // Seed or refresh the starting bedroom. Layouts written by older builds are
    // rebuilt because those defaults stacked the furniture against the window
    // and hid the desk behind the player figure.
    if (storedPlacements == null || layoutVersion < kLayoutVersion) {
      _seedDefaultLayout();
    } else {
      placed = storedPlacements;
    }

    loaded = true;
    notifyListeners();

    // Persist the refreshed layout (and the new version stamp) straight away so
    // the migration does not run again next launch.
    if (layoutVersion < kLayoutVersion) {
      await _savePlaced();
      await _saveSettings();
    }
  }

  /// Decodes one stored value, returning null when it is absent or unreadable.
  T? _decode<T>(String key, T Function(dynamic) parse) {
    final raw = _store?.read(key);
    if (raw == null) return null;
    try {
      return parse(jsonDecode(raw));
    } catch (e) {
      debugPrint('AppState.load: ignoring unreadable "$key" ($e)');
      return null;
    }
  }

  /// Writes one value. Failures are logged rather than thrown: the in-memory
  /// state is still correct, and a storage hiccup must not break the flow the
  /// player is in the middle of.
  Future<void> _persist(String key, String value) async {
    try {
      final store = _store ??= (await openKvStore()).store;
      await store.write(key, value);
    } catch (e) {
      debugPrint('AppState.persist("$key") failed: $e');
    }
  }

  Future<void> _saveProfile() async =>
      _persist(_kProfile, jsonEncode(profile!.toJson()));
  Future<void> _saveGoals() async =>
      _persist(_kGoals, jsonEncode(goals.toJson()));
  Future<void> _saveEntries() async =>
      _persist(_kEntries, jsonEncode(entries.map((e) => e.toJson()).toList()));
  Future<void> _saveUnlocked() async =>
      _persist(_kUnlocked, jsonEncode(unlocked.toList()));
  Future<void> _savePlaced() async =>
      _persist(_kPlaced, jsonEncode(placed.map((e) => e.toJson()).toList()));
  Future<void> _saveRead() async =>
      _persist(_kRead, jsonEncode(readArticles.toList()));
  Future<void> _saveSounds() async => _persist(
    _kSounds,
    jsonEncode(userSounds.map((e) => e.toJson()).toList()),
  );
  Future<void> _saveFriendPermissions() async =>
      _persist(_kFriendPermissions, jsonEncode(friendPermissions));
  Future<void> _saveSettings() async => _persist(
    _kSettings,
    jsonEncode({
      'lang': lang,
      'seedIndex': seedIndex,
      'themeMode': themeMode.index,
      'layoutVersion': kLayoutVersion,
    }),
  );

  void _seedDefaultLayout() {
    // Starting bedroom: a bed, a TV, a desk and a door.
    //
    // Positions are kept away from the back wall (the window sits at the top of
    // the scene) and spaced out so nothing overlaps the player figure — the desk
    // has to stay tappable, since it is the doorway to the sleep data screens.
    placed = [
      PlacedFurniture(defId: 'bed_basic', x: 0.25, y: 0.74),
      PlacedFurniture(defId: 'tv_basic', x: 0.80, y: 0.28),
      PlacedFurniture(defId: 'desk_basic', x: 0.66, y: 0.78),
      PlacedFurniture(defId: 'door_basic', x: 0.11, y: 0.44),
    ];
  }

  // ==========================================================================
  // profile / settings
  // ==========================================================================
  Future<void> createProfile(String name, String avatar) async {
    profile = PlayerProfile(
      name: name.trim().isEmpty ? 'Student' : name.trim(),
      avatar: avatar,
    );
    // Notify first: the screen must switch to the bedroom immediately. The
    // write below is only persistence and must never gate the navigation.
    notifyListeners();
    await _saveProfile();
  }

  Future<void> updateProfile(String name, String avatar) async {
    final current = profile;
    if (current == null) return;
    final trimmed = name.trim();
    current.name = trimmed.isEmpty ? current.name : trimmed;
    current.avatar = avatar;
    notifyListeners();
    await _saveProfile();
  }

  Future<void> setLang(String code) async {
    lang = code;
    L.set(code);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setSeedIndex(int i) async {
    seedIndex = i;
    notifyListeners();
    await _saveSettings();
  }

  // ==========================================================================
  // game loop
  // ==========================================================================
  /// Adds XP/coins and returns the levels gained.
  int _grantXp(int xp, {int coins = 0}) {
    final before = profile!.level;
    profile!.xp += xp;
    profile!.coins += coins;
    return profile!.level - before;
  }

  /// Logs a night; rewards XP and coins, and records the current room score so
  /// bedroom-vs-sleep correlation can be computed later.
  /// Returns the number of levels gained.
  Future<int> logSleep({
    required DateTime bedtime,
    required DateTime wake,
    required int quality,
    required List<String> factors,
    String note = '',
  }) async {
    final entry = SleepEntry(
      id: 'n${DateTime.now().microsecondsSinceEpoch}',
      bedtime: bedtime,
      wake: wake,
      quality: quality,
      factors: factors,
      note: note,
      roomScoreAtLog: roomScore,
    );
    entries.add(entry);
    entries.sort((a, b) => a.bedtime.compareTo(b.bedtime));

    var gained = 0;
    gained += _grantXp(20, coins: 12);
    if (entry.durationHours >= goals.targetHours) {
      gained += _grantXp(25, coins: 20);
    }
    if (entry.bedSlotMinutes <= goals.bedSlotMinutes + 30) {
      gained += _grantXp(10, coins: 8);
    }

    await _saveEntries();
    await _saveProfile();
    notifyListeners();
    return gained;
  }

  Future<void> deleteEntry(String id) async {
    entries.removeWhere((e) => e.id == id);
    await _saveEntries();
    notifyListeners();
  }

  Future<void> setGoals(SleepGoals g) async {
    goals = g;
    await _saveGoals();
    notifyListeners();
  }

  // ==========================================================================
  // furniture
  // ==========================================================================
  /// Sum of every placed piece's sleep score.
  int get roomScore =>
      placed.fold(0, (sum, p) => sum + (defFor(p.defId)?.sleepScore ?? 0));

  /// Number the summed furniture scores are divided by, taken from Ethan's
  /// BedScreen prototype (apps/ethan_nguyen/TheBedspace/src/BedScreen.cpp).
  static const int kScoreDivisor = 4;

  /// The "total bedroom sleep score" shown to the player, calculated as in
  /// the BedScreen prototype: add up each placed piece's score, then divide
  /// the sum by four.
  double get bedroomSleepScore => roomScore / kScoreDivisor;

  bool isPlaced(String defId) => placed.any((p) => p.defId == defId);

  Future<bool> buyFurniture(FurnitureDef def) async {
    final level = profile?.level ?? 1;
    if (level < def.unlockLevel) return false;
    if (profile!.coins < def.price) return false;
    profile!.coins -= def.price;
    unlocked.add(def.id);
    await _saveUnlocked();
    await _saveProfile();
    notifyListeners();
    return true;
  }

  /// Places (or un-places) a piece. Structural categories are exclusive.
  Future<void> togglePlaced(
    FurnitureDef def, {
    double x = 0.5,
    double y = 0.5,
  }) async {
    final existing = placed.where((p) => p.defId == def.id).toList();
    if (existing.isNotEmpty) {
      placed.removeWhere((p) => p.defId == def.id);
    } else {
      if (kStructuralCategories.contains(def.category)) {
        placed.removeWhere((p) => defFor(p.defId)?.category == def.category);
      }
      placed.add(PlacedFurniture(defId: def.id, x: x, y: y));
    }
    await _savePlaced();
    notifyListeners();
  }

  Future<void> movePlaced(PlacedFurniture item, double nx, double ny) async {
    item.x = nx.clamp(0.06, 0.94);
    item.y = ny.clamp(0.12, 0.88);
    await _savePlaced();
    notifyListeners();
  }

  Future<void> resetRoom() async {
    _seedDefaultLayout();
    await _savePlaced();
    notifyListeners();
  }

  Future<void> markRead(String articleId) async {
    readArticles.add(articleId);
    await _saveRead();
    notifyListeners();
  }

  Future<void> addUserSound(SoundTrack track) async {
    userSounds.removeWhere((s) => s.id == track.id);
    userSounds.add(track);
    await _saveSounds();
    notifyListeners();
  }

  Future<void> removeUserSound(String id) async {
    userSounds.removeWhere((s) => s.id == id);
    await _saveSounds();
    notifyListeners();
  }

  /// Friends can see the player's demo profile by default. A saved `false`
  /// explicitly revokes that friend's access.
  bool canFriendView(String friendId) => friendPermissions[friendId] ?? true;

  Future<void> setFriendPermission(String friendId, bool allowed) async {
    friendPermissions[friendId] = allowed;
    notifyListeners();
    await _saveFriendPermissions();
  }

  // ==========================================================================
  // derived statistics
  // ==========================================================================
  List<SleepEntry> get recent =>
      entries.length <= 7 ? entries : entries.sublist(entries.length - 7);

  List<SleepEntry> lastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return entries.where((e) => e.wake.isAfter(cutoff)).toList();
  }

  double get avgDuration => entries.isEmpty
      ? 0
      : entries.map((e) => e.durationHours).reduce((a, b) => a + b) /
            entries.length;

  double get avgQuality => entries.isEmpty
      ? 0
      : entries.map((e) => e.quality).reduce((a, b) => a + b) / entries.length;

  /// Average bedtime as a clock string (handles the after-midnight wrap).
  String get avgBedtime {
    if (entries.isEmpty) return '--:--';
    final avgSlot =
        entries.map((e) => e.bedSlotMinutes).reduce((a, b) => a + b) /
        entries.length;
    return Util.clockFrom18(avgSlot.round());
  }

  String get avgWake {
    if (entries.isEmpty) return '--:--';
    final avg =
        entries
            .map((e) => e.wake.hour * 60 + e.wake.minute)
            .reduce((a, b) => a + b) /
        entries.length;
    return Util.clock(avg.round());
  }

  /// Nights in the last 7 days where the duration goal was reached.
  int get goalsMetThisWeek =>
      lastDays(7).where((e) => e.durationHours >= goals.targetHours).length;

  SleepEntry? get bestNight {
    if (entries.isEmpty) return null;
    return entries.reduce((a, b) => a.durationHours >= b.durationHours ? a : b);
  }

  SleepEntry? get worstNight {
    if (entries.isEmpty) return null;
    return entries.reduce((a, b) => a.durationHours <= b.durationHours ? a : b);
  }

  /// Sleep debt over the last 7 nights, in hours.
  double get sleepDebt {
    final n = recent;
    if (n.isEmpty) return 0;
    final target = goals.targetHours * n.length;
    final actual = n.map((e) => e.durationHours).reduce((a, b) => a + b);
    return math.max(0, target - actual);
  }

  /// How late the average bedtime is versus the goal, in hours.
  double get bedtimeDeltaHours => entries.isEmpty
      ? 0
      : (entries.map((e) => e.bedSlotMinutes).reduce((a, b) => a + b) /
                    entries.length -
                goals.bedSlotMinutes) /
            60.0;

  // ==========================================================================
  // staying up late → recovery advice
  // ==========================================================================

  /// A night counts as "staying up late" when bedtime was at least this long
  /// after the goal bedtime…
  static const int kLateAfterGoalMinutes = 60;

  /// …or at/after 01:00 whatever the goal is (minutes past 18:00).
  static const int kLateAbsoluteSlot = 7 * 60;

  bool isLateNight(SleepEntry e) =>
      e.bedSlotMinutes - goals.bedSlotMinutes >= kLateAfterGoalMinutes ||
      e.bedSlotMinutes >= kLateAbsoluteSlot;

  /// The recovery report for the most recent night, when it was a late one
  /// and it ended within the last day (older nights are no longer actionable).
  LateNightReport? get latestLateNight {
    if (entries.isEmpty) return null;
    final last = entries.last;
    if (DateTime.now().difference(last.wake).inHours >= 20) return null;
    return lateNightReport(last);
  }

  /// Builds a personalised plan for recovering from [e], or null when [e] was
  /// not a late night.
  LateNightReport? lateNightReport(SleepEntry e) {
    if (!isLateNight(e)) return null;
    final goalSlot = goals.bedSlotMinutes;
    final late = math.max(0, e.bedSlotMinutes - goalSlot);
    final short = math.max(0.0, goals.targetHours - e.durationHours);
    String clockOf(int slot) => Util.clock(18 * 60 + slot);

    // One late night: go straight back to the usual bedtime. Very late: step
    // back an hour per night, since a body clock cannot jump several hours.
    final tonight = late <= 120 ? goalSlot : e.bedSlotMinutes - 60;
    final tips = <RecoveryTip>[
      RecoveryTip(
        '🛏️',
        tonight == goalSlot
            ? L.tr('late_tip_bed_goal', {'goal': clockOf(goalSlot)})
            : L.tr('late_tip_bed_step', {
                'tonight': clockOf(tonight),
                'goal': clockOf(goalSlot),
              }),
      ),
      RecoveryTip(
        '⏰',
        L.tr('late_tip_wake', {'wake': Util.clock(goals.wakeMinutes)}),
      ),
      RecoveryTip('☀️', L.t('late_tip_light')),
      if (short >= 1)
        RecoveryTip('😴', L.tr('late_tip_nap', {'short': Util.hours(short)})),
      RecoveryTip(
        '☕',
        L.t(
          e.factors.contains('caffeine')
              ? 'late_tip_caffeine_logged'
              : 'late_tip_caffeine',
        ),
      ),
      RecoveryTip(
        '📵',
        L.tr(e.factors.contains('phone') ? 'late_tip_phone' : 'late_tip_wind', {
          'cutoff': clockOf(tonight - 60),
        }),
      ),
      for (final f in kFactorTags)
        if (f.harmful &&
            f.id != 'caffeine' &&
            f.id != 'phone' &&
            e.factors.contains(f.id))
          RecoveryTip(
            f.emoji,
            L.tr('late_tip_factor', {
              'factor': f.label(L.lang),
              'tip': f.tip(L.lang),
            }),
          ),
    ];

    // Tie the advice back to the bedroom: point at the placed piece that
    // hurts sleep the most, if there is one.
    FurnitureDef? worst;
    for (final p in placed) {
      final d = defFor(p.defId);
      if (d != null &&
          d.sleepScore < 0 &&
          (worst == null || d.sleepScore < worst.sleepScore)) {
        worst = d;
      }
    }
    if (worst != null) {
      tips.add(
        RecoveryTip(
          '🏠',
          L.tr('late_tip_room', {
            'name': worst.name(L.lang),
            's': '${worst.sleepScore}',
          }),
        ),
      );
    }

    return LateNightReport(
      entry: e,
      minutesLate: late,
      hoursShort: short,
      tonightBedSlot: tonight,
      tips: tips,
    );
  }

  /// Which harmful factor appears most often before a short night.
  List<MapEntry<String, int>> get factorImpact {
    final counts = <String, int>{};
    for (final e in entries) {
      if (e.durationHours < goals.targetHours) {
        for (final f in e.factors) {
          counts[f] = (counts[f] ?? 0) + 1;
        }
      }
    }
    final list = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  /// Pearson correlation between the room score recorded at each log and the
  /// hours that night. This is the "bedroom predicts sleep" check from the
  /// project brief.
  ({double r, int n}) get roomSleepCorrelation {
    final xs = entries.map((e) => e.roomScoreAtLog.toDouble()).toList();
    final ys = entries.map((e) => e.durationHours).toList();
    final n = xs.length;
    if (n < 3) return (r: 0, n: n);
    final mx = xs.reduce((a, b) => a + b) / n;
    final my = ys.reduce((a, b) => a + b) / n;
    var num = 0.0, dx2 = 0.0, dy2 = 0.0;
    for (var i = 0; i < n; i++) {
      final dx = xs[i] - mx;
      final dy = ys[i] - my;
      num += dx * dy;
      dx2 += dx * dx;
      dy2 += dy * dy;
    }
    if (dx2 == 0 || dy2 == 0) return (r: 0, n: n);
    return (r: num / math.sqrt(dx2 * dy2), n: n);
  }

  // ==========================================================================
  // demo + reset
  // ==========================================================================
  Future<void> loadDemoData() async {
    final now = DateTime.now();
    entries = [];
    final rnd = math.Random(7);
    const List<List<String>> factorPool = [
      ['phone', 'latework'],
      ['caffeine', 'latework'],
      ['stress'],
      ['phone'],
      [],
      ['exercise'],
      ['nap', 'phone'],
      ['alcohol', 'bigmeal'],
    ];
    for (var i = 14; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final bedHour = 22 + rnd.nextDouble() * 3.5; // 22:00 – 01:30
      final bed = DateTime(
        day.year,
        day.month,
        day.day,
        bedHour.floor(),
        (bedHour % 1 * 60).floor(),
      );
      final dur = 5.6 + rnd.nextDouble() * 3.2;
      final wake = bed.add(Duration(minutes: (dur * 60).round()));
      final factors = factorPool[rnd.nextInt(factorPool.length)].toList();
      entries.add(
        SleepEntry(
          id: 'demo$i',
          bedtime: bed,
          wake: wake,
          quality: math.max(1, math.min(5, (dur - 4).round())),
          factors: factors,
          roomScoreAtLog: roomScore + (i % 3 == 0 ? 1 : 0),
        ),
      );
    }
    entries.sort((a, b) => a.bedtime.compareTo(b.bedtime));
    profile?.xp = math.max(profile!.xp, 320);
    profile?.coins = math.max(profile!.coins, 160);
    unlocked.addAll(['lamp_warm', 'plant_fern', 'rug_wool']);
    await _saveEntries();
    await _saveProfile();
    await _saveUnlocked();
    notifyListeners();
  }

  Future<void> eraseAll() async {
    profile = null;
    goals = SleepGoals();
    entries = [];
    unlocked = {'bed_basic', 'tv_basic', 'desk_basic', 'door_basic'};
    readArticles = {};
    userSounds = [];
    friendPermissions = {};
    _seedDefaultLayout();
    // Notify before touching the disk so the login screen appears at once even
    // if the file write is slow.
    notifyListeners();
    try {
      await _store?.clear();
    } catch (e) {
      debugPrint('AppState.eraseAll failed: $e');
    }
  }
}
