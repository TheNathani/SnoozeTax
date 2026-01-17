# Snooze Tax 💤💸

A brutally simple iOS alarm app that makes snoozing expensive.

## Core Concept

**Simple Rule:** Snooze = $1.99 to your partner.

- Set an alarm
- When it goes off, choose: Wake Up (free) or Snooze ($1.99)
- After 3 snoozes, only Wake Up remains
- Pay your partner via Venmo at the end of each week

## Features

### The Alarm
- Gorgeous fluid time picker (like the old iOS wheel, but beautiful)
- Two giant buttons when alarm rings:
  - **Wake Up** - Dismiss, no charge
  - **Snooze** - 9 minutes, costs $1.99
- Maximum 3 snoozes per alarm

### Payment System
- **Dead simple:** Just enter partner's Venmo username once in settings
- App tracks your debt automatically
- Weekly "Pay [Partner]" button opens Venmo with amount pre-filled
- Tap confirm in Venmo, done

### UI Philosophy - Liquid/Fluid/2025
- **Minimal visible UI** - mostly gestures and fluid animations
- **Home screen:** Just your next alarm time, floating in space
- **Swipe up:** Opens buttery smooth time picker
- **Debt counter:** Subtle red glow that intensifies as you owe more
- **Physics-based animations:** Everything feels alive
- **Glass morphism:** Depth, shadows, and materials that feel real
- **Dark mode only:** Deep blacks with subtle gradients
- **Haptic feedback:** Feel every interaction

## Technical Stack

- **SwiftUI** for modern, declarative UI
- **Local Notifications** for reliable alarms
- **UserDefaults** for data persistence
- **Core Haptics** for rich feedback
- **Venmo URL Scheme** for seamless payments

## Project Structure

```
SnoozeTax/
├── SnoozeTaxApp.swift              # App entry point
├── Models/
│   ├── Alarm.swift                 # Alarm data model
│   └── DebtRecord.swift            # Debt tracking models
├── ViewModels/
│   ├── AlarmManager.swift          # Alarm state management
│   ├── DebtTracker.swift           # Debt tracking & Venmo integration
│   └── NotificationManager.swift   # Local notifications
├── Views/
│   ├── ContentView.swift           # Main navigation container
│   ├── HomeView.swift              # Floating alarm display
│   ├── AlarmSetterView.swift      # Fluid time picker
│   ├── AlarmAlertView.swift       # Wake Up / Snooze screen
│   ├── SettingsView.swift         # Venmo username settings
│   └── Components/
│       └── DebtGlowView.swift     # Animated red glow effect
├── Utilities/
│   ├── HapticManager.swift        # Haptic feedback system
│   └── ViewModifiers.swift        # Custom UI modifiers
└── Info.plist                     # App configuration
```

## Key Components

### AlarmManager
Handles all alarm logic:
- Setting new alarms
- Snoozing (up to 3 times)
- Dismissing alarms
- Scheduling local notifications

### DebtTracker
Manages financial tracking:
- Records each snooze charge ($1.99)
- Calculates weekly totals
- Stores partner's Venmo username
- Opens Venmo with pre-filled payment

### NotificationManager
iOS notification system:
- Requests notification permissions
- Schedules alarm notifications
- Handles notification actions
- Plays critical alert sounds

### HapticManager
Rich haptic feedback:
- Selection haptics for picker scrolling
- Impact haptics for buttons
- Custom alarm vibration pattern
- Success/warning/error notifications

## Setup Instructions

### 1. Create Xcode Project
1. Open Xcode
2. Create new project: **iOS App**
3. Product Name: **Snooze Tax**
4. Interface: **SwiftUI**
5. Language: **Swift**

### 2. Add Source Files
Copy all `.swift` files from this directory into your Xcode project:
- Maintain the folder structure (Models, ViewModels, Views, Utilities)
- Replace the default `ContentView.swift` and app file

### 3. Configure Info.plist
Add required permissions and settings:
- Copy `Info.plist` or manually add:
  - Venmo URL scheme query
  - Notification permission description
  - Force dark mode interface style
  - Background modes for audio

### 4. Configure Capabilities
In Xcode project settings:
1. **Signing & Capabilities** tab
2. Add **Background Modes**
   - Enable: Audio, AirPlay, and Picture in Picture
   - Enable: Background processing
3. Add **Push Notifications** (for critical alerts)

### 5. Test Notifications
- Run on **physical device** (simulator has limited notification support)
- Grant notification permissions when prompted
- Test critical alert sounds (requires device, not simulator)

### 6. Venmo Integration Testing
- Install Venmo app on test device
- Enter test partner username in settings
- Verify deep link opens Venmo correctly
- Test payment flow (don't actually pay during testing!)

## Usage

### Setting an Alarm
1. Open app
2. Swipe up anywhere on screen
3. Scroll to select time
4. Tap "Set Alarm"

### When Alarm Rings
1. App shows two giant buttons
2. **Wake Up** - Free, dismisses alarm
3. **Snooze** - Costs $1.99, gives 9 more minutes
4. After 3 snoozes, only Wake Up shows

### Paying Your Debt
1. Tap the red payment banner on home screen
2. Venmo opens with amount pre-filled
3. Confirm payment in Venmo
4. Return to app, tap "Mark as Paid" (optional)

### Settings
- Tap gear icon (top right)
- Enter partner's Venmo username (without @)
- View debt history
- See paid vs unpaid charges

## Design Principles

### Steve Jobs Would Love It
- **Immediately obvious** what it does
- **Zero learning curve** - pure intuition
- **Looks like nothing else** - unique aesthetic
- **Feels magical** - physics and animations
- **Emotional feedback** - red glow intensifies with debt

### Animation Philosophy
- Animations over features
- Beauty over complexity
- Every interaction feels alive
- Physics-based movement
- Smooth 60fps minimum

### Visual Language
- **Deep blacks** for OLED displays
- **Subtle gradients** for depth
- **Glass morphism** for modern feel
- **Red** for debt/consequences
- **Green** for wake up/success
- **White** for primary actions

## Future Enhancements (Not Implemented)

### Potential Features
- [ ] Automatic Venmo payment (requires OAuth)
- [ ] Custom snooze prices
- [ ] Partner app to receive notifications
- [ ] Weekly/monthly debt charts
- [ ] Multiple alarm support
- [ ] Custom alarm sounds
- [ ] Widget showing next alarm
- [ ] Apple Watch companion
- [ ] Share debt stats (for shame/motivation)

### Technical Improvements
- [ ] SwiftData instead of UserDefaults
- [ ] CloudKit sync between devices
- [ ] Unit tests for alarm logic
- [ ] UI tests for critical flows
- [ ] Accessibility improvements
- [ ] Localization support

## Requirements

- **iOS 16.0+** (for latest SwiftUI features)
- **iPhone only** (portrait orientation)
- **Physical device recommended** (for full notification/haptic testing)
- **Venmo app** (for payment integration)

## License

MIT License - Build whatever you want with this!

## Credits

Built with:
- SwiftUI for gorgeous, declarative UI
- Core Haptics for rich feedback
- Local Notifications for reliable alarms
- Love for simple, beautiful software

---

**Remember:** Every snooze costs $1.99. Worth it? 😴💸
