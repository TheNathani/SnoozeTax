# Quick Start Guide 🚀

Get Snooze Tax running in 5 minutes.

## Step 1: Create Xcode Project

```bash
# Open Xcode and create new project
# File → New → Project → iOS App
#
# Settings:
# - Product Name: SnoozeTax
# - Team: Your team
# - Organization Identifier: com.yourname
# - Interface: SwiftUI
# - Language: Swift
# - Storage: None (we use UserDefaults)
```

## Step 2: Add All Source Files

Drag the entire `SnoozeTax` folder structure into your Xcode project:

```
SnoozeTax/
├── SnoozeTaxApp.swift
├── Models/
├── ViewModels/
├── Views/
├── Utilities/
└── Info.plist
```

Make sure to:
- ✅ Check "Copy items if needed"
- ✅ Create groups (not folder references)
- ✅ Add to target: SnoozeTax

## Step 3: Configure Info.plist

Replace your project's Info.plist with the one provided, or add these keys manually:

**Critical keys:**
- `LSApplicationQueriesSchemes` → `["venmo"]`
- `NSUserNotificationsUsageDescription` → "We need to send you alarm notifications"
- `UIUserInterfaceStyle` → `Dark`
- `UIBackgroundModes` → `["audio", "processing"]`

## Step 4: Configure Project Settings

### In Xcode Target Settings:

1. **General Tab:**
   - Display Name: `Snooze Tax`
   - Bundle Identifier: `com.yourname.snoozetax`
   - Version: `1.0`
   - Minimum iOS: `16.0`
   - Supported orientations: Portrait only

2. **Signing & Capabilities:**
   - Enable "Automatically manage signing"
   - Select your team
   - Add capability: **Background Modes**
     - Check: "Audio, AirPlay, and Picture in Picture"
     - Check: "Background processing"
   - Add capability: **Push Notifications**

3. **Info Tab:**
   - Verify Info.plist keys are correct
   - Check "Queried URL Schemes" includes `venmo`

## Step 5: Build and Run

```bash
# In Xcode:
# 1. Select iPhone device (not simulator for full features)
# 2. Press Cmd+R to build and run
#
# First launch:
# - Grant notification permissions when prompted
# - Swipe up to set your first alarm
# - Tap gear icon to add partner's Venmo username
```

## Step 6: Test Core Features

### Test Alarm:
1. Swipe up from home screen
2. Set alarm for 1 minute from now
3. Wait for notification
4. Test both Wake Up and Snooze buttons

### Test Debt Tracking:
1. Snooze an alarm
2. Check home screen for red glow
3. Verify debt counter shows $1.99

### Test Venmo Integration:
1. Open settings (gear icon)
2. Enter test Venmo username
3. Tap "Pay" button on home screen
4. Verify Venmo app opens with pre-filled amount

## Common Issues

### Notifications Not Working
- **Solution:** Run on physical device, not simulator
- **Solution:** Check notification permissions in iOS Settings
- **Solution:** Verify Background Modes are enabled in capabilities

### Venmo Deep Link Fails
- **Solution:** Ensure Venmo app is installed
- **Solution:** Check `LSApplicationQueriesSchemes` in Info.plist
- **Solution:** Test with valid Venmo username

### Haptics Not Working
- **Solution:** Run on physical device (simulator doesn't support haptics)
- **Solution:** Check device haptic settings aren't disabled

### Dark Mode Not Forced
- **Solution:** Verify `UIUserInterfaceStyle` = `Dark` in Info.plist
- **Solution:** Check `preferredColorScheme(.dark)` is in ContentView

## File Checklist

Make sure all these files are in your project:

```
✅ SnoozeTaxApp.swift
✅ Models/Alarm.swift
✅ Models/DebtRecord.swift
✅ ViewModels/AlarmManager.swift
✅ ViewModels/DebtTracker.swift
✅ ViewModels/NotificationManager.swift (imported from Utilities)
✅ Views/ContentView.swift
✅ Views/HomeView.swift
✅ Views/AlarmSetterView.swift
✅ Views/AlarmAlertView.swift
✅ Views/SettingsView.swift
✅ Views/Components/DebtGlowView.swift
✅ Utilities/NotificationManager.swift
✅ Utilities/HapticManager.swift
✅ Utilities/ViewModifiers.swift
✅ Info.plist
```

## Next Steps

Once running:
1. **Customize snooze price:** Edit `DebtRecord.swift` line 6 to change `amount: Double = 1.99`
2. **Adjust max snoozes:** Edit `Alarm.swift` line 18 to change `snoozeCount < 3`
3. **Change snooze duration:** Edit `AlarmManager.swift` line 32 to change `value: 9` (minutes)
4. **Tweak animations:** Adjust spring parameters in views for different feel

## Support

If you hit issues:
1. Check this guide again
2. Verify all files are properly added to target
3. Clean build folder (Cmd+Shift+K)
4. Delete derived data
5. Restart Xcode

## You're Done! 🎉

Open the app, swipe up, set an alarm, and try not to snooze tomorrow morning.

Every snooze = $1.99. Worth it? 😴
