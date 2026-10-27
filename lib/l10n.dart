/// ---------------------------------------------------------------------------
/// Tiny hand-rolled localisation table (English / Chinese).
/// A full intl/ARB setup would be overkill for offline demo scope.
/// ---------------------------------------------------------------------------
class L {
  static String lang = 'en';

  static bool get isZh => lang == 'zh';

  static void set(String code) => lang = code == 'zh' ? 'zh' : 'en';

  static String t(String key) {
    final v = _strings[key];
    if (v == null) return key;
    return isZh ? v[1] : v[0];
  }

  static String tr(String key, Map<String, String> args) {
    var s = t(key);
    args.forEach((k, v) => s = s.replaceAll('{$k}', v));
    return s;
  }
}

/// key -> [english, chinese]
const Map<String, List<String>> _strings = {
  // ---------------------------------- brand ----------------------------------
  'app_name': ['TheBedSpace', 'TheBedSpace'],
  'tagline': ['Sleep better. Build a room that helps.', '睡得更香，打造一间帮你的房间。'],
  'login_welcome': ['Welcome back', '欢迎回来'],
  'login_create': ['Create your space', '创建你的空间'],
  'login_sub': [
    'Everything is stored on this device. No account, no server — just your room.',
    '所有数据都保存在本机。无需账号、无需服务器——只有你的房间。',
  ],
  'login_name': ['Your name', '你的名字'],
  'login_name_hint': ['e.g. Alex', '例如：小明'],
  'login_avatar': ['Pick an avatar', '选择头像'],
  'login_start': ['Enter my bedroom', '进入我的卧室'],
  'login_demo': ['Load a demo profile', '载入演示资料'],
  'login_offline': [
    'Offline profile — the online login/signup service is out of scope for the MVP.',
    '离线资料——联网登录/注册服务不在 MVP 范围内。',
  ],

  // --------------------------------- bedroom --------------------------------
  'bedroom': ['Bedroom', '卧室'],
  'tap_bed': ['Tap the bed to log your sleep', '点击床记录睡眠'],
  'tap_tv': ['Tap the TV for sounds & articles', '点击电视播放音频/阅读文章'],
  'tap_desk': ['Tap the desk for settings & stats', '点击书桌查看设置与统计'],
  'tap_door': ['Tap the door for friends', '点击门查看好友'],
  'tap_char': [
    'Tap the bed, TV, desk or door — drag anything to move it',
    '点击床、电视、书桌或门——拖动即可移动',
  ],
  'decorate': ['Decorate', '装扮'],
  'my_level': ['Level', '等级'],
  'coins': ['Coins', '金币'],
  'quick_log': ['Log sleep', '记录睡眠'],
  'tour': ['Show me around', '带我看看'],

  // -------------------------------- sleep log -------------------------------
  'log_sleep': ['Log a night', '记录一夜'],
  'edit_night': ['Edit this night', '编辑这一夜'],
  'bedtime': ['Bedtime', '入睡时间'],
  'wakeup': ['Woke up', '起床时间'],
  'duration': ['Sleep duration', '睡眠时长'],
  'quality': ['How did it feel?', '睡眠感受如何？'],
  'factors_title': ['What was going on before bed?', '睡前发生了什么？'],
  'factors_sub': [
    'Tap any that apply — you will get insights after a week of data.',
    '选择符合的选项——累积一周数据后会生成洞察。',
  ],
  'note': ['Note (optional)', '备注（可选）'],
  'save_night': ['Save this night', '保存这一夜'],
  'log_too_long': [
    'That is {h}, which is longer than a night\'s sleep. Check the bedtime and wake-up time: 11:00 is morning, 23:00 is night.',
    '这样算是 {h}，比一晚的睡眠还长。请检查入睡和起床时间：11:00 是上午，23:00 才是晚上。',
  ],
  'q1': ['Terrible', '很糟'],
  'q2': ['Poor', '较差'],
  'q3': ['Okay', '一般'],
  'q4': ['Good', '不错'],
  'q5': ['Great', '很好'],
  'logged_toast': [
    'Night saved. Your room score is {score}.',
    '已保存。当前房间评分 {score}。',
  ],

  // ---------------------------------- goals ---------------------------------
  'goals': ['Sleep goals', '睡眠目标'],
  'goals_sub': [
    'Goals give the game a trigger: hit them and the rewards unlock.',
    '目标给游戏一个触发器：达成即可解锁奖励。',
  ],
  'target_hours': ['Target sleep per night', '每晚目标睡眠'],
  'target_bedtime': ['Target bedtime', '目标入睡时间'],
  'target_waketime': ['Target wake time', '目标起床时间'],
  'reminders': ['Sleep / wake reminders', '睡眠 / 起床提醒'],
  'reminder_lead': ['Remind me before bed', '睡前提醒'],
  'minutes_before': ['{n} min before', '提前 {n} 分钟'],
  'save_goals': ['Save goals', '保存目标'],
  'goals_saved': ['Goals updated.', '目标已更新。'],

  // ---------------------------------- stats ---------------------------------
  'stats': ['Sleep data', '睡眠数据'],
  'avg_sleep': ['Average sleep', '平均睡眠'],
  'avg_bed': ['Average bedtime', '平均入睡'],
  'avg_wake': ['Average wake', '平均起床'],
  'avg_quality': ['Average quality', '平均感受'],
  'night_count': ['Nights logged', '记录夜数'],
  'last7': ['Last 7 days', '最近 7 天'],
  'last30': ['Last 30 days', '最近 30 天'],
  'trend': ['Duration trend', '时长趋势'],
  'bedtime_chart': ['Bedtime drift', '入睡时间漂移'],
  'quality_chart': ['Quality by night', '每晚睡眠感受'],
  'factor_impact': ['What hurts your sleep', '什么在拖累你的睡眠'],
  'factor_sub': [
    'Counted across the nights that fell short of your goal.',
    '统计在所有未达标的夜晚中出现的情况。',
  ],
  'no_data': [
    'No nights logged yet. Log a few nights, or load demo data in Settings.',
    '还没有睡眠记录。记录几晚，或在"设置"中载入演示数据。',
  ],
  'days_short': ['M', '一'],
  'table_of_sleep': ['Sleep time table', '睡眠时间表'],
  'goal_line': ['Goal', '目标'],

  // --------------------------------- weekly ---------------------------------
  'weekly': ['Weekly summary', '每周小结'],
  'this_week': ['This week', '本周'],
  'nights_logged': ['Nights logged', '记录夜数'],
  'goals_met': ['Goals met', '达成目标'],
  'best_night': ['Best night', '最好的一夜'],
  'worst_night': ['Toughest night', '最艰难的一夜'],
  'week_vs_last': ['vs last week', '与上周相比'],
  'sleep_debt': ['Sleep debt', '睡眠负债'],

  // ------------------------------- recovery ---------------------------------
  'recovery': ['Recovery after a late night', '熬夜后的恢复'],
  'recovery_sub': [
    'You do not need a perfect night to recover — you need the next right step.',
    '恢复不靠完美的一夜，而靠接下来的正确一步。',
  ],
  'general_tips': ['Everyday sleep hygiene', '日常睡眠卫生'],

  // --------------------------------- media ----------------------------------
  'media': ['TV — sounds & articles', '电视——音频与文章'],
  'sounds': ['Sounds', '音频'],
  'articles': ['Articles', '文章'],
  'builtin_sounds': ['Built-in sounds', '内置音频'],
  'my_sounds': ['My uploads', '我上传的'],
  'upload_audio': ['Upload your own audio', '上传你自己的音频'],
  'upload_hint': [
    'Add your own ASMR or sleep recording (m4a / mp3 / wav).',
    '添加你自己的 ASMR 或助眠录音（m4a / mp3 / wav）。',
  ],
  'now_playing': ['Now playing', '正在播放'],
  'play': ['Play', '播放'],
  'pause': ['Pause', '暂停'],
  'stop': ['Stop', '停止'],
  'sleep_timer': ['Sleep timer', '睡眠定时'],
  'timer_off': ['Off', '关闭'],
  'minutes': ['{n} min', '{n} 分钟'],
  'stop_timer': ['Stop timer', '停止定时'],
  'uploaded_toast': ['Added "{name}" to your sounds.', '已把「{name}」添加到音频列表。'],
  'upload_failed': ['Could not read that file.', '无法读取该文件。'],
  'upload_unsupported': [
    'Uploading your own audio needs the mobile or desktop version.',
    '上传音频需要使用手机或桌面版本。',
  ],
  'play_failed': ['Could not play that audio.', '无法播放该音频。'],
  'read_min': ['{n} min read', '阅读 {n} 分钟'],
  'read': ['Read', '阅读'],
  'article_done': ['Marked as read', '已标记为已读'],

  // --------------------------------- decor ----------------------------------
  'decoration': ['Decoration', '装扮'],
  'decor_sub': [
    'Better furniture unlocks as you level up. Drag pieces to arrange your room.',
    '升级可解锁更好的家具。拖动摆件整理你的房间。',
  ],
  'shop': ['Furniture shop', '家具商店'],
  'owned': ['Owned', '已拥有'],
  'place': ['Place', '放置'],
  'placed': ['In room', '已在房间'],
  'remove': ['Put away', '收起'],
  'unlock_at_level': ['Unlocks at level {n}', '等级 {n} 解锁'],
  'buy': ['Buy for {n}', '花费 {n} 购买'],
  'bought': ['Unlocked {name}!', '已解锁 {name}！'],
  'not_enough': ['Not enough coins.', '金币不足。'],
  'room_score': ['Bedroom sleep score', '卧室睡眠评分'],
  'room_score_sub': [
    'Every piece\'s sleep impact added up, then divided by 4. Aim higher, and watch your logged hours.',
    '把每件家具的睡眠影响分加起来，再除以 4。分数越高越好，同时留意你记录的睡眠时长。',
  ],
  'item_score': ['Sleep impact', '睡眠影响'],
  'why_score': ['Why this score?', '为什么是这个分数？'],
  'source': ['Source', '依据'],
  'drag_hint': ['Drag furniture to reposition', '拖动家具改变位置'],
  'reset_room': ['Reset the room', '重置房间'],
  'reset_room_done': ['Room reset to the starting layout.', '房间已重置为初始布局。'],
  'correlation': ['Your room vs your sleep', '房间与睡眠的相关性'],
  'correlation_sub': [
    'Compares each night\'s room score with the hours you logged that night.',
    '对比每一夜记录时的房间评分与当晚睡眠时长。',
  ],
  'corr_positive': [
    'Positive link (r = {r}). Your better-equipped nights line up with longer sleep.',
    '呈正相关（r = {r}）。房间配置更好的夜晚，睡眠时长也更长。',
  ],
  'corr_negative': [
    'Negative link (r = {r}) — unusual, check whether the room changed for another reason.',
    '呈负相关（r = {r}）——比较少见，请确认房间变化是否有其他原因。',
  ],
  'corr_flat': [
    'No clear link yet (r = {r}). Keep logging; {n} more nights will help.',
    '暂无明确相关（r = {r}）。继续记录，再记 {n} 晚会更清晰。',
  ],
  'insufficient': ['Need {n} more nights to compare.', '还需 {n} 晚数据才能对比。'],

  // --------------------------------- friends --------------------------------
  'friends': ['Friends', '好友'],
  'friends_sub': [
    'Demo data — the real friend server is out of scope. Status is simulated locally.',
    '演示数据——真实好友服务器不在范围内，状态由本地模拟。',
  ],
  'sleeping': ['Asleep', '睡眠中'],
  'awake': ['Awake', '清醒'],
  'visit': ['Visit room', '进入房间'],
  'permissions': ['Permissions', '权限'],
  'permissions_sub': [
    'Choose who can view your real room and sleep status. Friends without permission only see the demo view.',
    '设置访问权限。未给予权限的好友无法看到你真实的房间样貌和状态。',
  ],
  'permission_enabled': ['Can view your room and status', '可查看你的房间和状态'],
  'permission_disabled': ['Cannot view your room and status', '无法查看你的房间和状态'],
  'friend_room': ['{name}\'s room', '{name} 的房间'],
  'streak': ['{n}-day streak', '连续 {n} 天'],
  'last_sleep': ['Last night: {h}', '昨晚：{h}'],
  'add_friend': ['Add friend (demo)', '添加好友（演示）'],
  'offline_note': [
    'Tapping add-friend only adds a sample profile — nothing leaves your phone.',
    '点击"添加好友"只会加入一个示例资料——数据不会离开你的手机。',
  ],
  'wake_hint': [
    'A gentle "nudge" reminds your friend to sleep. Remote wake-up calls are intentionally out of scope.',
    '温和地"提醒"好友去睡觉。远程唤醒呼叫已刻意排除在范围之外。',
  ],
  'nudge_sent': ['Nudge sent to {name}.', '已提醒 {name}。'],

  // -------------------------------- settings --------------------------------
  'settings': ['Settings', '设置'],
  'my_profile': ['My profile', '我的资料'],
  'edit_profile': ['Edit profile', '编辑资料'],
  'confirm': ['Confirm', '确认'],
  'display': ['Appearance', '外观'],
  'dark_mode': ['Theme', '主题'],
  'dark_mode_sub': ['A sleep app is used at night.', '助眠应用多在夜晚使用。'],
  'dark_auto': ['Follow system', '跟随系统'],
  'language': ['Language', '语言'],
  'colour': ['Theme colour', '主题色'],
  'auto_theme': ['Auto', '自动'],
  'data': ['Data', '数据'],
  'demo_data': ['Load demo sleep data', '载入演示睡眠数据'],
  'demo_done': ['Loaded 14 demo nights.', '已载入 14 个演示夜晚。'],
  'reset_all': ['Erase everything', '清空所有数据'],
  'reset_all_confirm': [
    'This deletes your profile, sleep logs and room on this device. Continue?',
    '这会删除本机上的资料、睡眠记录与房间。确定继续？',
  ],
  'about': ['About', '关于'],
  'about_body': [
    'TheBedSpace — a student sleep companion for the Software Innovation course. '
        'Everything runs offline; there is no backend. Wellbeing content is '
        'educational and is not medical advice.',
    'TheBedSpace —— 软件创新导论课程的学生睡眠伴侣应用。所有功能离线运行，无后端。'
        '健康内容仅供教育用途，不构成医疗建议。',
  ],
  'notif_unavailable': [
    'Notifications are unavailable on this device.',
    '此设备无法使用通知。',
  ],

  // --------------------------- weekly / recovery ----------------------------
  'week_summary_sub': [
    'Progress against your goals, and how this week compares with the last.',
    '对照目标看进度，并把本周与上周做比较。',
  ],
  'no_week_data': [
    'No nights logged this week yet. Log a night to start your weekly recap.',
    '本周还没有睡眠记录。记录一晚即可开始你的每周小结。',
  ],
  'week_compare_sub': [
    'Average sleep per night this week vs last week.',
    '本周与上周的每晚平均睡眠时长对比。',
  ],
  'insufficient_week': [
    'You need one more week of data before the comparison is meaningful.',
    '还需要一周数据，对比才有意义。',
  ],
  'last_week': ['Last week', '上周'],
  'vs_last_same': ['Same as last week', '与上周持平'],
  'vs_last_up': ['{h} more per night than last week', '每晚比上周多 {h}'],
  'vs_last_down': ['{h} less per night than last week', '每晚比上周少 {h}'],
  'recovery_plan_short': ['Tonight is a rebuild night', '今晚是修复之夜'],
  'recovery_plan_ok': ['You are on track', '你正走在正轨上'],
  'recovery_last_night': [
    'Last night was {h} — short of your goal. Small shifts tonight matter more than a big reset.',
    '昨晚只睡了 {h}，低于目标。今晚的小幅调整比大幅重排更重要。',
  ],
  'recovery_on_track': [
    'Your recent average is {h}. Keep the routine steady and protect the wind-down hour.',
    '近期平均为 {h}。保持规律，并守住睡前的一小时放松时间。',
  ],
  'recovery_steps': ['Steps for tonight', '今晚的几步'],
  'late_title': ['You stayed up late', '你熬夜了'],
  'late_sub': ['Here is how to recover today', '今天这样把睡眠修复回来'],
  'late_summary': [
    'You went to bed at {bed}, {late} after your {goal} goal, and slept {h}.',
    '你 {bed} 才睡，比目标 {goal} 晚了 {late}，一共睡了 {h}。',
  ],
  'late_summary_plain': [
    'You went to bed at {bed} and slept {h}.',
    '你 {bed} 才睡，一共睡了 {h}。',
  ],
  'late_summary_short': [
    ' That is {short} short of your target.',
    '比目标少睡了 {short}。',
  ],
  'late_tip_bed_goal': [
    'Tonight, go to bed at your usual {goal}. One late night does not need a big reset.',
    '今晚按平时的 {goal} 上床。熬一次夜不需要大幅调整作息。',
  ],
  'late_tip_bed_step': [
    'Tonight, aim for {tonight}, one hour earlier than last night. Then keep moving an hour earlier each night until you are back at {goal}.',
    '今晚争取 {tonight} 上床，比昨晚早一小时。之后每晚再提前一小时，直到回到 {goal}。',
  ],
  'late_tip_wake': [
    'Get up at your usual {wake} even if you feel tired. Sleeping in more than an hour pushes tonight\'s bedtime later.',
    '即使很困，也按平时的 {wake} 起床。多睡超过一小时会让今晚更难入睡。',
  ],
  'late_tip_light': [
    'Get outside or sit by a bright window within an hour of waking. Daylight resets your body clock.',
    '起床后一小时内去户外或坐到明亮的窗边。日光能帮生物钟复位。',
  ],
  'late_tip_nap': [
    'You are {short} short. If you need a nap, keep it to 20 minutes and finish before 3 pm.',
    '你少睡了 {short}。如果要补觉，午睡控制在 20 分钟内，并在下午 3 点前结束。',
  ],
  'late_tip_caffeine': [
    'Have coffee or tea only in the morning today and stop by 2 pm, so it has worn off by bedtime.',
    '今天只在上午喝咖啡或茶，下午 2 点后停止，这样睡前它已经代谢掉了。',
  ],
  'late_tip_caffeine_logged': [
    'You logged caffeine last night. Today, have it only in the morning and stop by 2 pm.',
    '你昨晚记录了咖啡因。今天只在上午摄入，下午 2 点后停止。',
  ],
  'late_tip_phone': [
    'You logged phone use last night. Put the phone away at {cutoff}, one hour before tonight\'s bedtime.',
    '你昨晚记录了玩手机。今晚 {cutoff} 就把手机放下，也就是上床前一小时。',
  ],
  'late_tip_wind': [
    'Start winding down at {cutoff}: dim the lights and stop work and screens.',
    '{cutoff} 开始放松：调暗灯光，停下工作和屏幕。',
  ],
  'late_tip_factor': [
    'Last night you logged "{factor}": {tip}',
    '昨晚你记录了「{factor}」：{tip}',
  ],
  'late_tip_room': [
    'Your room is not helping: {name} has a sleep impact of {s}. Think about moving it out of the bedroom.',
    '房间也在拖后腿：{name} 的睡眠影响分是 {s}，可以考虑把它移出卧室。',
  ],
  'late_more': ['Full recovery guide', '完整恢复指南'],
  'late_ok': ['Got it', '知道了'],
  'late_bubble': ['Late night · tap for tips', '熬夜了 · 点我看建议'],
  'late_plan_title': ['Your recovery plan for today', '你今天的修复计划'],
  'general_tips_sub': [
    'The habits that matter most on a normal week.',
    '平常日子里最要紧的几个习惯。',
  ],
  'recovery_disclaimer': [
    'These tips are general wellbeing guidance for a student project, not medical advice.',
    '以上是学生项目的一般健康建议，不构成医疗建议。',
  ],

  // ------------------------------ settings extra ----------------------------
  'theme_light': ['Light', '浅色'],
  'theme_dark': ['Dark', '深色'],
  'data_sub': [
    'Everything lives on this device. Load sample nights to demo, or wipe it all.',
    '数据都保存在本机。可载入示例夜晚用于演示，也可全部清空。',
  ],

  // ------------------------------- decor extra ------------------------------
  'shop_sub': [
    'Level up to unlock better sleep choices, then place them in your room.',
    '升级解锁更有利于睡眠的家具，然后放进你的房间。',
  ],
  'room_verdict_good': [
    'Your room is doing real work for your sleep — keep the screens out and the light warm.',
    '你的房间正在真正帮助你的睡眠——把屏幕请出去，把灯光调暖。',
  ],
  'room_verdict_ok': [
    'A neutral room. One blackout curtain or a warm lamp would push this higher.',
    '中性的房间。加一层遮光窗帘或一盏暖光台灯就能提升评分。',
  ],
  'room_verdict_bad': [
    'The room is working against you — a big screen in the bedroom is the usual culprit.',
    '房间正与你作对——卧室里的大屏幕通常就是元凶。',
  ],

  // -------------------------------- friends extra ---------------------------
  'nudge': ['Nudge', '提醒'],

  // -------------------------------- common ----------------------------------
  'ok': ['OK', '好的'],
  'close': ['Close', '关闭'],
  'back': ['Back', '返回'],
  'save': ['Save', '保存'],
  'cancel': ['Cancel', '取消'],
  'done': ['Done', '完成'],
  'level_up': ['Level up!', '升级啦！'],
  'level_up_body': [
    'You reached level {n}. New furniture may be waiting.',
    '你达到 {n} 级，可能有新家具解锁。',
  ],
  'gained': ['+{xp} XP   +{coins} coins', '+{xp} 经验   +{coins} 金币'],
  'goal_met': ['Goal met', '达成目标'],
  'goal_close': ['Nearly there', '差一点'],
  'goal_missed': ['Missed', '未达标'],
  'today': ['Today', '今天'],
  'yesterday': ['Yesterday', '昨天'],
  'score': ['Score', '评分'],
  'hours_short': ['{h} h', '{h} 小时'],

  // ------------------------------ notifications -----------------------------
  'notif_title': ['Notifications', '消息通知'],
  'notif_sub': [
    'Bedtime and wake-up reminders, delivered on this device only.',
    '睡前与起床提醒，仅在本机推送。',
  ],
  'notif_enable': ['Allow notifications', '允许通知'],
  'notif_request': ['Request permission', '申请通知权限'],
  'notif_granted': ['Notifications enabled.', '已开启通知。'],
  'notif_denied': [
    'Permission denied — you can enable it later in system settings.',
    '权限被拒绝——之后可在系统设置中开启。',
  ],
  'notif_asked': [
    'We will ask for notification permission when you enter your bedroom.',
    '进入卧室时我们会请求通知权限。',
  ],

  // --------------------------------- chat -----------------------------------
  'chat': ['Chat', '聊天'],
  'chat_sub': [
    'Demo chat — replies are canned and stay on this device. The friend server is out of scope.',
    '演示聊天——回复为预设内容，保存在本机。好友服务器不在范围内。',
  ],
  'chat_hint': ['Message {name}', '发消息给 {name}'],
  'chat_send': ['Send', '发送'],
  'chat_you': ['You', '你'],
  'chat_online': ['Online', '在线'],
  'chat_asleep': ['Asleep', '睡眠中'],
  'chat_seed_them': ['How did you sleep?', '你睡得怎么样？'],
  'chat_seed_me': ['Pretty good, thanks!', '还不错，谢谢！'],
  'chat_r1': ['Nice! I am logging mine now.', '真好！我这就去记录。'],
  'chat_r2': ['Trying to sleep before 23:00 tonight.', '今晚争取 23 点前睡。'],
  'chat_r3': ['My room score went up after I added a lamp.', '我加了盏台灯，房间评分变高了。'],
  'chat_r4': ['Ha! Let us compare the weekly summary later.', '哈哈！等会儿比比每周小结。'],
  'chat_r_asleep': [
    '{name} seems to be asleep. Your message will be here when they wake.',
    '{name} 似乎睡着了。消息会留到 ta 醒来时。',
  ],
  'chat_empty': [
    'No messages yet. Say hi to start the demo chat.',
    '还没有消息。打个招呼开始演示聊天吧。',
  ],
  'chat_clear': ['Clear chat', '清空聊天'],
};
