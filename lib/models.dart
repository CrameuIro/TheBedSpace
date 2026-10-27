// ---------------------------------------------------------------------------
// TheBedSpace — data models
// ---------------------------------------------------------------------------

/// A single logged night of sleep.
class SleepEntry {
  SleepEntry({
    required this.id,
    required this.bedtime,
    required this.wake,
    required this.quality,
    required this.factors,
    this.note = '',
    this.roomScoreAtLog = 0,
  });

  final String id;
  DateTime bedtime;
  DateTime wake;

  /// Self-rated quality, 1 (terrible) .. 5 (great).
  int quality;

  /// Pre-sleep factor ids (see [kFactorTags]).
  List<String> factors;
  String note;

  /// The bedroom "sleep score" of the room at the moment this night was logged.
  /// Used to correlate the decorated bedroom with self-submitted sleep hours.
  int roomScoreAtLog;

  double get durationHours => wake.difference(bedtime).inMinutes / 60.0;

  /// Minutes past 18:00 -> bedtime position, avoids midnight wrap-around.
  int get bedSlotMinutes {
    var m = bedtime.hour * 60 + bedtime.minute;
    if (m < 12 * 60) m += 24 * 60; // treat after-midnight as "late"
    return m - 18 * 60;
  }

  /// The calendar day this night belongs to.
  DateTime get nightDate {
    final d = DateTime(bedtime.year, bedtime.month, bedtime.day);
    return bedtime.hour < 12 ? d.subtract(const Duration(days: 1)) : d;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'bedtime': bedtime.toIso8601String(),
    'wake': wake.toIso8601String(),
    'quality': quality,
    'factors': factors,
    'note': note,
    'roomScoreAtLog': roomScoreAtLog,
  };

  static SleepEntry fromJson(Map<String, dynamic> j) => SleepEntry(
    id: j['id'] as String,
    bedtime: DateTime.parse(j['bedtime'] as String),
    wake: DateTime.parse(j['wake'] as String),
    quality: (j['quality'] as num).toInt(),
    factors: (j['factors'] as List? ?? const [])
        .map((e) => e as String)
        .toList(),
    note: (j['note'] as String?) ?? '',
    roomScoreAtLog: (j['roomScoreAtLog'] as num?)?.toInt() ?? 0,
  );
}

/// One piece of advice in a late-night recovery plan.
class RecoveryTip {
  const RecoveryTip(this.emoji, this.text);
  final String emoji;
  final String text;
}

/// Produced after a night that started well past the player's bedtime goal
/// ("staying up late"): what happened, and a plan for recovering today.
class LateNightReport {
  const LateNightReport({
    required this.entry,
    required this.minutesLate,
    required this.hoursShort,
    required this.tonightBedSlot,
    required this.tips,
  });

  final SleepEntry entry;

  /// How far past the goal bedtime the player went to bed.
  final int minutesLate;

  /// How far short of the duration goal the night was (0 if it was not).
  final double hoursShort;

  /// Suggested bedtime for tonight, as minutes past 18:00.
  final int tonightBedSlot;

  final List<RecoveryTip> tips;
}

/// Goals the player sets for themselves.
class SleepGoals {
  SleepGoals({
    this.targetHours = 8.0,
    this.bedSlotMinutes = 180, // 18:00 + 180min = 21:00
    this.wakeMinutes = 7 * 60, // 07:00
    this.remindersEnabled = false,
    this.bedReminderLeadMinutes = 30,
  });

  /// Target sleep duration in hours.
  double targetHours;

  /// Target bedtime as minutes past 18:00 (0 = 18:00, 360 = 00:00).
  int bedSlotMinutes;

  /// Target wake time as minutes past midnight.
  int wakeMinutes;

  bool remindersEnabled;
  int bedReminderLeadMinutes;

  Map<String, dynamic> toJson() => {
    'targetHours': targetHours,
    'bedSlotMinutes': bedSlotMinutes,
    'wakeMinutes': wakeMinutes,
    'remindersEnabled': remindersEnabled,
    'bedReminderLeadMinutes': bedReminderLeadMinutes,
  };

  static SleepGoals fromJson(Map<String, dynamic> j) => SleepGoals(
    targetHours: (j['targetHours'] as num?)?.toDouble() ?? 8.0,
    bedSlotMinutes: (j['bedSlotMinutes'] as num?)?.toInt() ?? 180,
    wakeMinutes: (j['wakeMinutes'] as num?)?.toInt() ?? 7 * 60,
    remindersEnabled: (j['remindersEnabled'] as bool?) ?? false,
    bedReminderLeadMinutes:
        (j['bedReminderLeadMinutes'] as num?)?.toInt() ?? 30,
  );
}

/// The player profile (stored fully offline — the login screen only creates a
/// local profile, no server involved).
class PlayerProfile {
  PlayerProfile({
    required this.name,
    this.avatar = '🧑‍🎓',
    this.xp = 0,
    this.coins = 60,
  });

  String name;
  String avatar;
  int xp;
  int coins;

  /// Level curve: level n needs 120 * n XP inside that level.
  int get xpForNextLevel => 120 * level;
  int get level {
    var lv = 1;
    var remaining = xp;
    while (remaining >= 120 * lv) {
      remaining -= 120 * lv;
      lv++;
    }
    return lv;
  }

  /// XP accumulated inside the current level.
  int get xpInLevel {
    var lv = 1;
    var remaining = xp;
    while (remaining >= 120 * lv) {
      remaining -= 120 * lv;
      lv++;
    }
    return remaining;
  }

  double get levelProgress =>
      xpForNextLevel == 0 ? 0 : xpInLevel / xpForNextLevel;

  Map<String, dynamic> toJson() => {
    'name': name,
    'avatar': avatar,
    'xp': xp,
    'coins': coins,
  };

  static PlayerProfile fromJson(Map<String, dynamic> j) => PlayerProfile(
    name: j['name'] as String,
    avatar: (j['avatar'] as String?) ?? '🧑‍🎓',
    xp: (j['xp'] as num?)?.toInt() ?? 0,
    coins: (j['coins'] as num?)?.toInt() ?? 60,
  );
}

/// A furniture blueprint (catalogue entry).
class FurnitureDef {
  const FurnitureDef({
    required this.id,
    required this.nameEn,
    required this.nameZh,
    required this.category,
    required this.unlockLevel,
    required this.price,
    required this.sleepScore,
    required this.effectEn,
    required this.effectZh,
    this.source = '',
    this.isDefault = false,
    this.width = 0.24,
    this.height = 0.18,
  });

  final String id;
  final String nameEn;
  final String nameZh;

  /// bed | media | study | light | rug | plant | wall | chair
  final String category;
  final int unlockLevel;
  final int price;

  /// Impact of this piece on bedroom sleep quality, -3 .. +3.
  final int sleepScore;
  final String effectEn;
  final String effectZh;

  /// Where the guidance comes from.
  final String source;
  final bool isDefault;

  /// Relative footprint inside the room (0..1 of room width/height).
  final double width;
  final double height;

  String name(String lang) => lang == 'zh' ? nameZh : nameEn;
  String effect(String lang) => lang == 'zh' ? effectZh : effectEn;
}

/// A piece of furniture the player has bought and placed in the room.
class PlacedFurniture {
  PlacedFurniture({required this.defId, required this.x, required this.y});

  final String defId;

  /// Normalised room coordinates, 0..1 (x = left→right, y = back→front).
  double x;
  double y;

  Map<String, dynamic> toJson() => {'defId': defId, 'x': x, 'y': y};

  static PlacedFurniture fromJson(Map<String, dynamic> j) => PlacedFurniture(
    defId: j['defId'] as String,
    x: (j['x'] as num).toDouble(),
    y: (j['y'] as num).toDouble(),
  );
}

/// A health / sleep article shown on the bedroom TV.
class Article {
  const Article({
    required this.id,
    required this.titleEn,
    required this.titleZh,
    required this.bodyEn,
    required this.bodyZh,
    required this.icon,
    this.readingMinutes = 3,
  });

  final String id;
  final String titleEn;
  final String titleZh;
  final String bodyEn;
  final String bodyZh;
  final String icon;
  final int readingMinutes;

  String title(String lang) => lang == 'zh' ? titleZh : titleEn;
  String body(String lang) => lang == 'zh' ? bodyZh : bodyEn;
}

/// A pre-sleep factor tag (caffeine, phone use, ...).
class FactorTag {
  const FactorTag({
    required this.id,
    required this.emoji,
    required this.labelEn,
    required this.labelZh,
    required this.tipEn,
    required this.tipZh,
    this.harmful = true,
  });

  final String id;
  final String emoji;
  final String labelEn;
  final String labelZh;
  final String tipEn;
  final String tipZh;
  final bool harmful;

  String label(String lang) => lang == 'zh' ? labelZh : labelEn;
  String tip(String lang) => lang == 'zh' ? tipZh : tipEn;
}

/// A built-in or user-uploaded sound track.
class SoundTrack {
  const SoundTrack({
    required this.id,
    required this.nameEn,
    required this.nameZh,
    required this.emoji,
    this.assetPath,
    this.filePath,
  });

  final String id;
  final String nameEn;
  final String nameZh;
  final String emoji;
  final String? assetPath;
  final String? filePath;

  bool get isUserUploaded => filePath != null;

  String name(String lang) => lang == 'zh' ? nameZh : nameEn;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameEn': nameEn,
    'nameZh': nameZh,
    'emoji': emoji,
    'filePath': filePath,
  };

  static SoundTrack fromJson(Map<String, dynamic> j) => SoundTrack(
    id: j['id'] as String,
    nameEn: j['nameEn'] as String,
    nameZh: j['nameZh'] as String,
    emoji: (j['emoji'] as String?) ?? '🎧',
    filePath: j['filePath'] as String?,
  );
}

/// A friend (offline demo data — the real social backend is out of scope).
class Friend {
  const Friend({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastSleepHours,
    required this.bedtimeHour,
    required this.streakDays,
    required this.furnitureIds,
  });

  final String id;
  final String name;
  final String avatar;
  final double lastSleepHours;
  final double bedtimeHour;
  final int streakDays;
  final List<String> furnitureIds;

  /// Friends are "asleep" during the night window.
  bool isSleeping(DateTime now) {
    final h = now.hour + now.minute / 60.0;
    final bed = bedtimeHour;
    final wake = (bed + lastSleepHours) % 24;
    if (bed < wake) return h >= bed && h < wake;
    return h >= bed || h < wake;
  }
}

/// Small helpers used across the app.
class Util {
  static String two(int n) => n.toString().padLeft(2, '0');

  /// Formats minutes-past-midnight as HH:MM.
  static String clock(int minutesPastMidnight) {
    final m = ((minutesPastMidnight % (24 * 60)) + 24 * 60) % (24 * 60);
    return '${two(m ~/ 60)}:${two(m % 60)}';
  }

  /// Formats minutes past 18:00 as HH:MM.
  static String clockFrom18(int slot) => clock(18 * 60 + slot);

  /// Turns a bedtime and wake-up clock time (minutes past midnight) into real
  /// dates for the night that began on the evening of [night].
  ///
  /// A bedtime from 12:00 to 23:59 falls on [night] itself; one from 00:00 to
  /// 11:59 is after midnight, so it falls on the next day. Wake-up is the
  /// first moment at [wakeMin] after bedtime, so a night is never longer
  /// than 24 hours.
  static (DateTime, DateTime) nightTimes(
    DateTime night,
    int bedMin,
    int wakeMin,
  ) {
    final evening = DateTime(night.year, night.month, night.day);
    final bedDay = bedMin < 12 * 60
        ? evening.add(const Duration(days: 1))
        : evening;
    final bed = bedDay.add(Duration(minutes: bedMin));
    var wake = bedDay.add(Duration(minutes: wakeMin));
    if (!wake.isAfter(bed)) wake = wake.add(const Duration(days: 1));
    return (bed, wake);
  }

  /// Formats a bedroom sleep score with a sign and two decimals, e.g. +1.25.
  static String score(double v) =>
      v >= 0 ? '+${v.toStringAsFixed(2)}' : v.toStringAsFixed(2);

  static String hours(double h) {
    final total = (h * 60).round();
    final hh = total ~/ 60;
    final mm = total % 60;
    return mm == 0 ? '${hh}h' : '${hh}h ${two(mm)}m';
  }

  static String dayLabel(DateTime d, String lang) {
    if (lang == 'zh') return '${d.month}月${d.day}日';
    const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${wd[d.weekday - 1]} ${d.day}/${d.month}';
  }

  static String jsonEncode(Object o) => jsonEncode(o);
}
