# TheBedSpace MVP: code ownership by issue (Iteration 3)

This table maps every open issue on the GitHub Project board "To do list"
(#49–#68) to the code that implements it. The owner of an issue owns the
files and functions listed beside it. Commit work on that code from your own
account, and put the issue number in the commit message (e.g.
`#49 show bedtime in sleep table`).

| Owner | Issues |
|---|---|
| **lisiyi0808** | #49, #50, #51, #52, #53 |
| **xinglindong6-max** | #54, #55, #56, #57, #58 |
| **Crameulro** | #59, #60, #61, #62, #63 |
| **Xuan19493** | #64, #65, #66, #67, #68 |

Some files serve more than one issue (`store.dart`, `seed.dart`,
`bedroom_screen.dart`, `tv_screen.dart`, `friend_room_screen.dart`,
`settings_screen.dart`). For these, the tables below name the exact function,
widget or data list each owner is responsible for. Only edit your own part.

---

## lisiyi0808: sleep records, goals & furniture system

| Issue | Files / code | In `store.dart` / `seed.dart` |
|---|---|---|
| **#49** Check sleeping duration / sleep time table | `screens/sleep_log_sheet.dart`, `screens/stats_screen.dart`, `screens/desk_screen.dart` (hub for the data screens), bar charts in `widgets/charts.dart` | `logSleep`, `deleteEntry`, average-bedtime and worst-factor getters; `kFactorTags` |
| **#50** Set sleeping goals | `screens/goals_screen.dart` | `setGoals`, bedtime-lateness getter; `kGoalFeedback` |
| **#51** Unlock new furniture | `_ShopTile` / `_ActionButton` in `screens/decor_screen.dart` (lock, buy) | `unlocked`, `buyFurniture`, `_grantXp` (XP, coins, level-up); `unlockLevel` and `price` in `kFurniture` |
| **#52** Decorate furniture | `screens/decor_screen.dart` (room preview, place/remove), `widgets/room_scene.dart` (drag & drop, fixed room ratio) | `togglePlaced`, `movePlaced`, `resetRoom` |
| **#53** Furniture scoring | room-score card and correlation section in `decor_screen.dart`; `CorrelationScatter` in `widgets/charts.dart`; `ScoreRing` in `widgets/ui.dart` | `roomScore`, `roomSleepCorrelation`; `sleepScore` / `effect…` / `source` in `kFurniture` |

---

## xinglindong6-max: status display, audio upload, reminders, dark mode, friend status

| Issue | Files / code | In `store.dart` / `seed.dart` |
|---|---|---|
| **#54** Character status display (sleep quality, sleep duration) | `widgets/character.dart` (awake / sleeping figure), `_character()` in `screens/bedroom_screen.dart` (status bubble: 🌙/☀️, last night's hours and quality emoji) | reads `entries.last` |
| **#55** Upload audio file | `_pickAudio()` and the "my sounds" list in `screens/tv_screen.dart`, `services/audio_storage.dart`, `audio_storage_io.dart`, `audio_storage_stub.dart`; file-picker entitlement in `macos/Runner/*.entitlements` | `addUserSound`, `removeUserSound` |
| **#56** Notification (sleep / wake reminders) | `services/notifications.dart`, the reminder switch and `scheduleDaily` calls in `goals_screen.dart`, the notification row in `settings_screen.dart` | — |
| **#57** Dark mode | `theme.dart` (`AppTheme.build` for light & dark), the dark-mode `SegmentedButton` in `settings_screen.dart`, `themeMode` in `main.dart` | `setThemeMode` |
| **#58** Check friend's sleeping status | `screens/friends_screen.dart` (list with sleeping / awake counts), the status header in `screens/friend_room_screen.dart` | `Friend.isSleeping` in `models.dart`; `kFriends` |

---

## Crameulro: sounds, weekly summary & the bedroom

| Issue | Files / code | In `store.dart` / `seed.dart` |
|---|---|---|
| **#59** Play ASMR | `services/audio_service.dart`, `assets/audio/`, the built-in sound player in `screens/tv_screen.dart` | `kBuiltInSounds` |
| **#60** Weekly sleep summary | `screens/weekly_screen.dart` | sleep-debt and "goal met in the last 7 nights" getters |
| **#61** Upgrade furniture | `widgets/furniture_art.dart` (art for every piece, including the upgraded tiers) | upgraded pieces in `kFurniture` (`bed_luxury`, `tv_xl`, `desk_tidy_dual`, `lamp_amber_desk`…); the "one bed / TV / desk / door at a time" replacement rule (`kStructuralCategories` and its branch in `togglePlaced`) |
| **#62** Character interaction | `screens/bedroom_screen.dart`, except `_character()`: home layout, HUD, dragging the character, tapping bed / TV / desk / door to open each feature | — |
| **#63** Chat with friends | `screens/chat_screen.dart` | — |

---

## Xuan19493: accounts, posts & settings

| Issue | Files / code | In `store.dart` / `seed.dart` |
|---|---|---|
| **#64** One-tap remote wake-up for friends | the "Nudge" button in `screens/friend_room_screen.dart` (currently the only wake-up-related code, see gaps) | — |
| **#65** Log in and sign up | `screens/login_screen.dart`, `main.dart` (routing), `models.dart`, `services/kv_store.dart`, `services/kv_file*.dart` | `load`, `createProfile`, `_persist`, `loadDemoData`, `eraseAll` |
| **#66** VR for your bedroom in reality | *(no code yet, see gaps)* | — |
| **#67** Read posts | `screens/articles_screen.dart`, `screens/recovery_screen.dart`, the articles entry in `tv_screen.dart` | `markRead`; `kArticles`, `kRecoveryTips` |
| **#68** Setting: colour / language | `screens/settings_screen.dart` (except the dark-mode and notification rows), `l10n.dart`, `kSeedPalettes` in `theme.dart`, `widgets/ui.dart` (shared look & feel) | `setLang`, `setSeedIndex` |

---

## Gaps and overlaps to sort out on the board

- **#54 and #62 have the same title.** This document splits them into
  *status display* (#54: character figure and status bubble) and
  *interaction* (#62: dragging, tapping furniture, home screen). Rename one
  issue on the board to match.
- **#55 overlaps #59.** #55 covers importing your own audio file. #59 covers
  playing the built-in sounds.
- **#56 overlaps #50.** Reminders belong to #56. #50 only covers setting the
  goal values.
- **#57 overlaps #68.** Dark mode belongs to #57. #68 covers theme colour
  and language.
- **#64 Remote wake-up is not built.** Only a gentle "nudge" exists. Its
  in-app hint says remote wake-up calls were deliberately left out of scope.
  Either build it, or mark #64 as refuted and write a learning card
  explaining why.
- **#66 VR bedroom has no code.** Record it as a future hypothesis, or
  close it with a note.
- **#61 Upgrade furniture has no separate "upgrade" button.** Upgrading
  means buying a higher-tier piece, which replaces the old one in the room.

- **"Recovery tips after staying up late" is a Must in `docs/design/Team.md` but has no issue on the board.** It is now implemented: `isLateNight`, `lateNightReport` and `latestLateNight` in `store.dart`, `LateNightReport` / `RecoveryTip` in `models.dart`, `showLateNightSheet` and `LateNightPlan` in `screens/recovery_screen.dart` (shown automatically after logging a late night, and from the 🩹 link in the character's status bubble). Create an issue for it and give it an owner.
- **Furniture scoring (#53) now follows Ethan's BedScreen prototype:** `bedroomSleepScore` = sum of placed items' scores ÷ 4 (`AppState.kScoreDivisor`), as in `apps/ethan_nguyen/TheBedspace/src/BedScreen.cpp`.

## Tests (`test/widget_test.dart`)

| Test | Owner |
|---|---|
| login screen creates a local profile; profile and sleep data survive a relaunch; erase returns to login…; the real entry point shows login, then the bedroom | Xuan19493 (#65) |
| screens render in Chinese too | Xuan19493 (#68) |
| every seed colour and brightness builds a theme; the dark-mode render tests | xinglindong6-max (#57) |
| logging a night awards XP and keeps the room consistent; empty state does not crash | lisiyi0808 (#49) |
| a stale layout is migrated to the new starting positions | lisiyi0808 (#52) |
| bedroom sleep score is the summed item scores divided by 4 | lisiyi0808 (#53) |
| a night well past the bedtime goal gets a recovery plan; the late-night recovery plan renders | owner of the recovery-tips issue |
| the light-mode render test for each screen | the owner of that screen |

Run `flutter analyze` and `flutter test` before merging. Both must pass.
