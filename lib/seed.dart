import 'models.dart';

/// ---------------------------------------------------------------------------
/// Static content: furniture catalogue, articles, factor tags, sounds, friends.
/// ---------------------------------------------------------------------------

/// Structural categories may only have one item placed at a time.
const Set<String> kStructuralCategories = {'bed', 'media', 'study', 'door'};

const List<FurnitureDef> kFurniture = [
  // ---------------------------- default starters ----------------------------
  FurnitureDef(
    id: 'bed_basic',
    nameEn: 'Basic Single Bed',
    nameZh: '基础单人床',
    category: 'bed',
    unlockLevel: 1,
    price: 0,
    sleepScore: 1,
    effectEn:
        'A firm, simple bed. Nothing glamorous, but it supports your back and '
        'carries no distractions into the room.',
    effectZh: '结实简单的床。虽然不起眼，但能支撑背部，也不会把杂念带进房间。',
    source: 'Sleep Foundation — sleep environment basics',
    isDefault: true,
    width: 0.42,
    height: 0.26,
  ),
  FurnitureDef(
    id: 'tv_basic',
    nameEn: 'Old Bedroom TV',
    nameZh: '旧卧室电视',
    category: 'media',
    unlockLevel: 1,
    price: 0,
    sleepScore: -2,
    effectEn:
        'A screen in the bedroom invites late-night watching. Blue light and '
        'exciting content both push your sleep time later.',
    effectZh: '卧室里的屏幕会诱发熬夜。蓝光和刺激内容都会推迟你的入睡时间。',
    source: 'Sleep Foundation — electronics in the bedroom',
    isDefault: true,
    width: 0.26,
    height: 0.2,
  ),
  FurnitureDef(
    id: 'desk_basic',
    nameEn: 'Study Desk',
    nameZh: '学习书桌',
    category: 'study',
    unlockLevel: 1,
    price: 0,
    sleepScore: 0,
    effectEn:
        'A tidy desk is neutral for sleep — as long as you study at it instead '
        'of working from your bed.',
    effectZh: '整洁的书桌对睡眠影响中性——前提是你在桌前学习，而不是在床上工作。',
    source: 'Sleep Hygiene practice',
    isDefault: true,
    width: 0.3,
    height: 0.2,
  ),
  FurnitureDef(
    id: 'door_basic',
    nameEn: 'Wooden Door',
    nameZh: '木门',
    category: 'door',
    unlockLevel: 1,
    price: 0,
    sleepScore: 1,
    effectEn:
        'A door you can close buys privacy and quiet — two of the strongest '
        'environmental protectors of sleep.',
    effectZh: '一扇能关上的门意味着隐私与安静——这是保护睡眠最强的两个环境因素。',
    source: 'Sleep Foundation — bedroom environment',
    isDefault: true,
    width: 0.2,
    height: 0.42,
  ),

  // ------------------------------- level 2+ -------------------------------
  FurnitureDef(
    id: 'lamp_warm',
    nameEn: 'Warm Dim Lamp',
    nameZh: '暖光调光灯',
    category: 'light',
    unlockLevel: 2,
    price: 40,
    sleepScore: 2,
    effectEn:
        'Warm, low, dimmable light lets melatonin rise before bed. Bright white '
        'light suppresses it.',
    effectZh: '暖色、低亮度、可调光，有助于睡前褪黑素分泌。白光会抑制褪黑素。',
    source: 'Harvard Health — blue light and melatonin',
    width: 0.14,
    height: 0.24,
  ),
  FurnitureDef(
    id: 'plant_fern',
    nameEn: 'Boston Fern',
    nameZh: '波士顿蕨',
    category: 'plant',
    unlockLevel: 2,
    price: 35,
    sleepScore: 1,
    effectEn:
        'A little greenery raises humidity slightly and makes the room feel '
        'calmer — helpful when exam stress keeps you alert.',
    effectZh: '一点绿植能略微提升湿度，让房间更平静——在考试焦虑时尤其有用。',
    source: 'Journal of Physiological Anthropology — indoor plants and stress',
    width: 0.14,
    height: 0.2,
  ),
  FurnitureDef(
    id: 'rug_wool',
    nameEn: 'Wool Rug',
    nameZh: '羊毛地毯',
    category: 'rug',
    unlockLevel: 3,
    price: 55,
    sleepScore: 1,
    effectEn:
        'Soft flooring absorbs footstep noise and echoes — small, real '
        'improvements to a shared-house bedroom.',
    effectZh: '柔软地面能吸收脚步声与回声——对合租卧室而言是真实的小改善。',
    source: 'Acoustics research — soft furnishings reduce reverberation',
    width: 0.44,
    height: 0.3,
  ),
  FurnitureDef(
    id: 'curtain_blackout',
    nameEn: 'Blackout Curtains',
    nameZh: '遮光窗帘',
    category: 'wall',
    unlockLevel: 3,
    price: 70,
    sleepScore: 3,
    effectEn:
        'Blocking light is one of the highest-impact changes you can make: '
        'later sunrises in summer stop cutting your sleep short.',
    effectZh: '遮光是最有效的手段之一：夏天清晨阳光不再提前打断你的睡眠。',
    source: 'Sleep Foundation — light and circadian rhythm',
    width: 0.3,
    height: 0.3,
  ),
  FurnitureDef(
    id: 'noise_machine',
    nameEn: 'White-noise Machine',
    nameZh: '白噪音机',
    category: 'media',
    unlockLevel: 4,
    price: 60,
    sleepScore: 3,
    effectEn:
        'Steady noise masks housemates, traffic and hallway noise, making it '
        'easier to fall asleep and stay asleep.',
    effectZh: '稳定噪声能掩盖室友、交通与走廊的声音，让你更容易入睡并保持睡眠。',
    source: 'Sleep Medicine Reviews — continuous noise masking',
    width: 0.16,
    height: 0.14,
  ),
  FurnitureDef(
    id: 'bookshelf',
    nameEn: 'Low Bookshelf',
    nameZh: '矮书架',
    category: 'wall',
    unlockLevel: 4,
    price: 50,
    sleepScore: 0,
    effectEn:
        'Storage keeps the room organised. A cluttered bedroom is linked with '
        'later sleep onset in student samples.',
    effectZh: '收纳让房间更整洁。研究显示杂乱的卧室与大学生的入睡延迟有关。',
    source: 'Sleep Health — bedroom clutter and sleep onset',
    width: 0.24,
    height: 0.34,
  ),
  FurnitureDef(
    id: 'reading_chair',
    nameEn: 'Reading Chair',
    nameZh: '阅读椅',
    category: 'chair',
    unlockLevel: 5,
    price: 65,
    sleepScore: 1,
    effectEn:
        'A chair gives you somewhere to wind down that is not your bed, so the '
        'bed stays a strong sleep cue.',
    effectZh: '椅子提供了床以外的放松位置，从而让床保持为强烈的睡眠线索。',
    source: 'CBT-I stimulus control',
    width: 0.2,
    height: 0.22,
  ),
  FurnitureDef(
    id: 'poster_calm',
    nameEn: 'Calming Art Print',
    nameZh: '治愈系画作',
    category: 'wall',
    unlockLevel: 5,
    price: 30,
    sleepScore: 0,
    effectEn:
        'Neutral, low-contrast art keeps the room visually quiet. Avoid loud '
        'or stimulating imagery right where you sleep.',
    effectZh: '中性低对比的画作让房间视觉上更安静。避免在睡眠区放置强烈刺激的图像。',
    source: 'Environmental psychology — visual restfulness',
    width: 0.18,
    height: 0.16,
  ),
  FurnitureDef(
    id: 'lamp_amber_desk',
    nameEn: 'Amber Desk Lamp',
    nameZh: '琥珀色台灯',
    category: 'light',
    unlockLevel: 6,
    price: 75,
    sleepScore: 2,
    effectEn:
        'An amber low-blue desk lamp lets you keep studying late without '
        'wrecking your melatonin curve.',
    effectZh: '琥珀色低蓝光台灯让你能继续学习，同时尽量不破坏褪黑素曲线。',
    source: 'Harvard Health — light wavelength and alertness',
    width: 0.14,
    height: 0.2,
  ),
  FurnitureDef(
    id: 'desk_tidy_dual',
    nameEn: 'Dual-monitor Desk',
    nameZh: '双屏工作站',
    category: 'study',
    unlockLevel: 6,
    price: 90,
    sleepScore: -2,
    effectEn:
        'Great for assignments, dangerous for sleep: a study battle-station in '
        'your bedroom makes it easy to keep working past your bedtime goal.',
    effectZh: '写作业利器，却是睡眠杀手：卧室里的工作站在你睡前仍在诱惑你继续开工。',
    source: 'Sleep Health — work-in-bedroom boundary research',
    width: 0.34,
    height: 0.2,
  ),
  FurnitureDef(
    id: 'air_purifier',
    nameEn: 'Air Purifier',
    nameZh: '空气净化器',
    category: 'media',
    unlockLevel: 7,
    price: 85,
    sleepScore: 2,
    effectEn:
        'Quiet filtration reduces allergens and dust, which helps if a blocked '
        'nose or hay-fever wakes you at night.',
    effectZh: '静音过滤可减少过敏原与粉尘，对鼻塞或花粉症导致的夜间醒来有帮助。',
    source: 'Sleep Medicine — indoor air quality and sleep',
    width: 0.16,
    height: 0.2,
  ),
  FurnitureDef(
    id: 'bed_luxury',
    nameEn: 'Adjustable Sleeping Bed',
    nameZh: '可调节高级床',
    category: 'bed',
    unlockLevel: 8,
    price: 130,
    sleepScore: 3,
    effectEn:
        'A supportive mattress with an adjustable base reduces pressure points '
        'and makes two people sharing a room sleep better.',
    effectZh: '支撑度更好的床垫与可调节床架能减少压迫点，也让合住的人睡得更好。',
    source: 'Sleep — mattress quality and sleep quality studies',
    isDefault: false,
    width: 0.44,
    height: 0.28,
  ),
  FurnitureDef(
    id: 'beanbag',
    nameEn: 'Beanbag',
    nameZh: '懒人沙发',
    category: 'chair',
    unlockLevel: 9,
    price: 45,
    sleepScore: -1,
    effectEn:
        'Comfy, but easy to fall asleep on mid-evening — then you wake up at '
        '2am and break your rhythm.',
    effectZh: '很舒服，但傍晚容易在上面睡着——结果凌晨两点醒来打乱作息。',
    source: 'Sleep Hygiene practice — napping side effects',
    width: 0.22,
    height: 0.2,
  ),
  FurnitureDef(
    id: 'tv_xl',
    nameEn: '65-inch Wall TV',
    nameZh: '65寸壁挂电视',
    category: 'media',
    unlockLevel: 10,
    price: 110,
    sleepScore: -3,
    effectEn:
        'A cinema in your bedroom. Bigger screen, brighter light, longer '
        'bedtime delay — the single worst furniture choice for sleep.',
    effectZh: '卧室里的影院。屏幕更大、更亮，入睡被推迟得更久——对睡眠最差的家具选择。',
    source: 'Sleep Foundation — screen exposure before bed',
    width: 0.34,
    height: 0.22,
  ),
  FurnitureDef(
    id: 'bed_canopy',
    nameEn: 'Detachable Cot Bed',
    nameZh: '可拆卸围栏儿童床',
    category: 'bed',
    unlockLevel: 11,
    price: 120,
    sleepScore: 2,
    effectEn:
        'A cot with removable rails suits a shared room and keeps a small '
        'child safely asleep while you study.',
    effectZh: '带可拆围栏的儿童床适合合住房间，让孩子安全入睡，你也能安心学习。',
    source: 'Paediatric sleep guidance — safe infant sleep space',
    width: 0.4,
    height: 0.24,
  ),
];

const List<Article> kArticles = [
  Article(
    id: 'a1',
    icon: '🧠',
    titleEn: 'Why your brain needs sleep',
    titleZh: '为什么大脑需要睡眠',
    readingMinutes: 3,
    bodyEn:
        'While you sleep, the brain replays and files the day\'s learning. '
        'Memory consolidation happens mostly in deep sleep, and skipping it '
        'means the hours you studied lose their grip.\n\n'
        'Practical takeaway: the last 90 minutes before bed are not "extra" '
        'study time — they are when your brain decides what to keep.\n\n'
        'If you must trade something, trade the late-night phone scroll, not '
        'the sleep that cements your study.',
    bodyZh:
        '睡眠时，大脑会回放并归档当天的学习内容。记忆巩固主要发生在深睡阶段，'
        '跳过深睡意味着你学过的内容留不住。\n\n'
        '实用建议：睡前最后 90 分钟并不是"额外的"学习时间——大脑正是在此时决定要保留什么。\n\n'
        '如果一定要牺牲什么，牺牲深夜刷手机，而不是那些能巩固你学习成果的睡眠。',
  ),
  Article(
    id: 'a2',
    icon: '☕',
    titleEn: 'Caffeine has a long tail',
    titleZh: '咖啡因的半衰期很长',
    readingMinutes: 2,
    bodyEn:
        'Caffeine has a half-life of roughly 5–6 hours. A 3pm coffee still '
        'leaves a quarter of its punch at 3am.\n\n'
        'Students often report falling asleep fine but waking at 3am — that is '
        'classic caffeine. Try a 2pm cutoff for a week before exams.',
    bodyZh:
        '咖啡因半衰期约为 5–6 小时。下午三点的一杯咖啡到凌晨三点仍有约四分之一的效力。\n\n'
        '很多学生说"能睡着但会凌晨三点醒"——这是典型咖啡因效应。考前一周试试把咖啡截止时间提前到下午两点。',
  ),
  Article(
    id: 'a3',
    icon: '📱',
    titleEn: 'Screens and melatonin',
    titleZh: '屏幕与褪黑素',
    readingMinutes: 3,
    bodyEn:
        'Bright light in the evening delays the release of melatonin, the '
        'hormone that tells your body it is night.\n\n'
        'Turn on night-shift, dim the screen, and put the last hour of scrolling '
        'before you get into bed. If you keep a screen in the bedroom, treat it '
        'as a deliberate choice rather than a default.',
    bodyZh:
        '夜间强光会推迟褪黑素（向身体发出"夜晚"信号的激素）的释放。\n\n'
        '开启夜间模式、降低亮度，并把刷手机留在上床之前。如果卧室里保留屏幕，'
        '请把它当作一个"有意为之"的选择，而不是默认配置。',
  ),
  Article(
    id: 'a4',
    icon: '🏃',
    titleEn: 'Exercise helps sleep — if you time it right',
    titleZh: '运动有助于睡眠——前提是时间对',
    readingMinutes: 2,
    bodyEn:
        'Daytime exercise deepens slow-wave sleep and lowers stress. But a hard '
        'session within 2 hours of bed raises your core temperature and '
        'adrenaline, delaying sleep.\n\n'
        'Finish vigorous training by early evening; light stretching or a walk '
        'is fine closer to bedtime.',
    bodyZh:
        '白天运动能加深慢波睡眠并降低压力。但睡前两小时内的剧烈运动会提高核心体温与肾上腺素，'
        '从而推迟入睡。\n\n'
        '高强度训练请在傍晚前结束；睡前可以选择轻度拉伸或散步。',
  ),
  Article(
    id: 'a5',
    icon: '🧘',
    titleEn: 'The 3-2-1 wind-down rule',
    titleZh: '3-2-1 入睡准备法则',
    readingMinutes: 2,
    bodyEn:
        'A simple rule that survives exam week: 3 hours before bed stop '
        'working, 2 hours before bed stop eating heavy meals, 1 hour before bed '
        'stop screens.\n\n'
        'You do not need perfect adherence. Aiming for it already shifts your '
        'bedtime earlier.',
    bodyZh:
        '一个在考试周也能执行的简单法则：睡前 3 小时停止工作，睡前 2 小时停止大餐，'
        '睡前 1 小时远离屏幕。\n\n'
        '不必完美执行，仅仅是"朝着它努力"就已经能让入睡时间提前。',
  ),
  Article(
    id: 'a6',
    icon: '😴',
    titleEn: 'Naps: short and early',
    titleZh: '小睡：要短，要早',
    readingMinutes: 2,
    bodyEn:
        'A 20-minute nap before 3pm restores alertness without stealing from '
        'your night sleep. Long or late naps reduce "sleep pressure" so you lie '
        'awake at midnight.\n\n'
        'If you cannot sleep at night, drop the afternoon nap for a week and '
        'see what changes.',
    bodyZh:
        '下午三点前的小睡 20 分钟能恢复警觉性，又不会侵占夜间睡眠。过长或过晚的小睡会降低"睡眠压力"，'
        '导致你午夜辗转难眠。\n\n'
        '如果夜里睡不着，先停掉午睡一周，看看有什么变化。',
  ),
];

const List<FactorTag> kFactorTags = [
  FactorTag(
    id: 'caffeine',
    emoji: '☕',
    labelEn: 'Caffeine',
    labelZh: '咖啡因',
    harmful: true,
    tipEn: 'Half-life of 5–6 h. Try a 2pm cutoff.',
    tipZh: '半衰期 5–6 小时，试试下午两点截止。',
  ),
  FactorTag(
    id: 'phone',
    emoji: '📱',
    labelEn: 'Phone in bed',
    labelZh: '床上玩手机',
    harmful: true,
    tipEn: 'Blue light + exciting content delay sleep onset.',
    tipZh: '蓝光与刺激内容都会推迟入睡。',
  ),
  FactorTag(
    id: 'latework',
    emoji: '📚',
    labelEn: 'Late-night study',
    labelZh: '熬夜学习',
    harmful: true,
    tipEn: 'Work raises arousal; stop 1 h before bed if you can.',
    tipZh: '学习会提高警觉度；尽量睡前 1 小时停下。',
  ),
  FactorTag(
    id: 'stress',
    emoji: '😰',
    labelEn: 'Stress / deadline',
    labelZh: '压力 / 截止日',
    harmful: true,
    tipEn: 'Write a 5-min brain-dump list so your mind can let go.',
    tipZh: '花 5 分钟写"清空清单"，让大脑放下未完成的事。',
  ),
  FactorTag(
    id: 'alcohol',
    emoji: '🍺',
    labelEn: 'Alcohol',
    labelZh: '饮酒',
    harmful: true,
    tipEn: 'Helps you fall asleep but fragments REM later.',
    tipZh: '容易入睡，却会打碎后半夜的 REM 睡眠。',
  ),
  FactorTag(
    id: 'bigmeal',
    emoji: '🍜',
    labelEn: 'Heavy late meal',
    labelZh: '睡前大餐',
    harmful: true,
    tipEn: 'Digestion competes with sleep. Aim to finish 2 h before bed.',
    tipZh: '消化与睡眠相互竞争，尽量睡前 2 小时吃完。',
  ),
  FactorTag(
    id: 'exercise',
    emoji: '🏃',
    labelEn: 'Exercise (daytime)',
    labelZh: '白天运动',
    harmful: false,
    tipEn: 'Great for deep sleep — just keep it away from bedtime.',
    tipZh: '有助于深睡——只要别安排在睡前就好。',
  ),
  FactorTag(
    id: 'nap',
    emoji: '😴',
    labelEn: 'Nap',
    labelZh: '小睡',
    harmful: false,
    tipEn: 'Keep it under 30 min and before 3pm.',
    tipZh: '控制在 30 分钟内，且不晚于下午三点。',
  ),
];

const List<SoundTrack> kBuiltInSounds = [
  SoundTrack(
    id: 's_campfire',
    nameEn: 'Campfire',
    nameZh: '篝火声',
    emoji: '🔥',
    assetPath: 'assets/audio/campfire.ogg',
  ),
  SoundTrack(
    id: 's_night_crickets',
    nameEn: 'Night Crickets',
    nameZh: '夜间虫鸣',
    emoji: '🦗',
    assetPath: 'assets/audio/night_crickets.ogg',
  ),
  SoundTrack(
    id: 's_wind_chimes',
    nameEn: 'Wind Chimes',
    nameZh: '风铃',
    emoji: '🎐',
    assetPath: 'assets/audio/wind_chimes.ogg',
  ),
  SoundTrack(
    id: 's_rainfall',
    nameEn: 'Rainfall',
    nameZh: '雨声',
    emoji: '🌧️',
    assetPath: 'assets/audio/rainfall.ogg',
  ),
  SoundTrack(
    id: 's_gentle_stream',
    nameEn: 'Gentle Stream',
    nameZh: '轻柔溪流',
    emoji: '🏞️',
    assetPath: 'assets/audio/gentle_stream.ogg',
  ),
  SoundTrack(
    id: 's_garden_birds',
    nameEn: 'Garden Birds',
    nameZh: '花园鸟鸣',
    emoji: '🐦',
    assetPath: 'assets/audio/garden_birds.ogg',
  ),
];

const List<Friend> kFriends = [
  Friend(
    id: 'f1',
    name: 'Mia',
    avatar: '🦊',
    lastSleepHours: 7.5,
    bedtimeHour: 23.0,
    streakDays: 12,
    furnitureIds: ['bed_basic', 'lamp_warm', 'plant_fern', 'rug_wool'],
  ),
  Friend(
    id: 'f2',
    name: 'Kai',
    avatar: '🐼',
    lastSleepHours: 5.2,
    bedtimeHour: 1.5,
    streakDays: 2,
    furnitureIds: ['bed_basic', 'desk_tidy_dual', 'tv_xl', 'door_basic'],
  ),
  Friend(
    id: 'f3',
    name: 'Priya',
    avatar: '🦉',
    lastSleepHours: 8.1,
    bedtimeHour: 22.5,
    streakDays: 21,
    furnitureIds: [
      'bed_luxury',
      'curtain_blackout',
      'noise_machine',
      'lamp_warm',
    ],
  ),
  Friend(
    id: 'f4',
    name: 'Tom',
    avatar: '🐨',
    lastSleepHours: 6.4,
    bedtimeHour: 0.0,
    streakDays: 5,
    furnitureIds: ['bed_basic', 'beanbag', 'poster_calm', 'door_basic'],
  ),
];

/// General recovery guidance after a late night.
const List<List<String>> kRecoveryTips = [
  [
    'Go to bed 30–45 minutes earlier tonight instead of a full reset — small shifts stick.',
    '今晚提前 30–45 分钟上床，不要一次大幅调整——小步调整更容易坚持。',
  ],
  [
    'Get bright light within an hour of waking; it anchors your body clock back to normal.',
    '醒来一小时内接触明亮光线，有助于把生物钟拉回正轨。',
  ],
  [
    'Keep caffeine to the morning only, and stop it by 2pm.',
    '咖啡因只在上午摄入，下午两点后停止。',
  ],
  [
    'If you nap, cap it at 20 minutes before 3pm so tonight\'s sleep pressure survives.',
    '如果要小睡，控制在 20 分钟内且不晚于下午三点，保住今晚的睡眠压力。',
  ],
  [
    'Do not try to "repay" the debt with a 12-hour sleep — it shifts your rhythm forward.',
    '不要用一次 12 小时长睡来"还债"——那会把作息进一步推后。',
  ],
  [
    'Protect tonight with the room: blackout light, steady noise, and no screens an hour before bed.',
    '今晚用房间来保护睡眠：遮光、稳定噪音，睡前 1 小时不碰屏幕。',
  ],
];

/// Short encouragement lines when a goal is met / missed.
const Map<String, List<String>> kGoalFeedback = {
  'met': ['Goal hit — your body banked the deposit.', '达成目标——身体存下了一笔健康储蓄。'],
  'close': [
    'So close. Thirty more minutes tomorrow and you are there.',
    '很接近了。明天再多睡 30 分钟就达标。',
  ],
  'missed': [
    'Rough night. Tomorrow is a fresh chance, not a punishment.',
    '这一夜不太好。明天是新机会，而不是惩罚。',
  ],
};
