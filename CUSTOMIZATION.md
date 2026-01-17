# Customization Guide 🎨

Make Snooze Tax your own.

## Quick Tweaks

### Change Snooze Price

**File:** `Models/DebtRecord.swift`

```swift
struct DebtRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amount: Double  // Change default here
    let alarmTime: String
    var isPaid: Bool

    init(id: UUID = UUID(), date: Date = Date(),
         amount: Double = 1.99,  // ← Change this
         alarmTime: String, isPaid: Bool = false) {
        // ...
    }
}
```

**Examples:**
- `amount: Double = 0.99` - Gentler nudge
- `amount: Double = 5.00` - Serious deterrent
- `amount: Double = 10.00` - Nuclear option

### Change Snooze Duration

**File:** `ViewModels/AlarmManager.swift`

```swift
func snoozeAlarm() {
    // Line ~32
    let snoozeTime = Calendar.current.date(
        byAdding: .minute,
        value: 9,  // ← Change this
        to: Date()
    ) ?? Date()
}
```

**Examples:**
- `value: 5` - 5 minute snooze
- `value: 10` - 10 minute snooze
- `value: 15` - 15 minute snooze

### Change Maximum Snoozes

**File:** `Models/Alarm.swift`

```swift
var canSnooze: Bool {
    return snoozeCount < 3  // ← Change this
}
```

**Examples:**
- `snoozeCount < 1` - No snoozes allowed!
- `snoozeCount < 5` - More lenient
- `snoozeCount < 999` - Basically unlimited

## Visual Customization

### Change Debt Glow Color

**File:** `Views/Components/DebtGlowView.swift`

```swift
Circle()
    .fill(
        RadialGradient(
            colors: [
                Color.red.opacity(...),  // ← Change .red
                Color.red.opacity(...),  // ← Change .red
                Color.clear
            ],
            // ...
        )
    )
```

**Try:**
- `Color.orange` - Warmer warning
- `Color.purple` - Cooler vibe
- `Color.yellow` - Anxiety-inducing

### Change Button Colors

**File:** `Views/AlarmAlertView.swift`

**Wake Up Button:**
```swift
.background(
    RoundedRectangle(cornerRadius: 24)
        .fill(
            LinearGradient(
                colors: [.green, .green.opacity(0.8)],  // ← Change
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
)
```

**Snooze Button:**
```swift
.background(
    RoundedRectangle(cornerRadius: 24)
        .fill(
            LinearGradient(
                colors: [.red, .red.opacity(0.8)],  // ← Change
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
)
```

### Adjust Animation Speed

**File:** Various view files

**Slower (more dramatic):**
```swift
.animation(
    .spring(response: 0.8, dampingFraction: 0.7),  // Slower
    value: someValue
)
```

**Faster (more snappy):**
```swift
.animation(
    .spring(response: 0.3, dampingFraction: 0.9),  // Faster
    value: someValue
)
```

**Bouncy:**
```swift
.animation(
    .spring(response: 0.5, dampingFraction: 0.5),  // Bouncier
    value: someValue
)
```

### Change Font

**File:** Any view file

**Current:**
```swift
.font(.system(size: 88, weight: .thin, design: .rounded))
```

**Options:**
- `design: .default` - San Francisco (iOS default)
- `design: .serif` - New York (editorial)
- `design: .monospaced` - SF Mono (techy)

## Behavioral Customization

### Auto-Reset Alarm Daily

**File:** `ViewModels/AlarmManager.swift`

```swift
func dismissAlarm() {
    guard let alarm = currentAlarm else { return }

    // Add this to always reset for next day
    var newAlarm = alarm
    newAlarm.snoozeCount = 0
    newAlarm.lastSnoozeDate = nil

    if let tomorrow = Calendar.current.date(
        byAdding: .day,
        value: 1,  // ← Always reset for tomorrow
        to: alarm.time
    ) {
        newAlarm.time = tomorrow
        currentAlarm = newAlarm
        saveAlarm()
        scheduleNotification(for: newAlarm)
    }

    isAlarmRinging = false
    HapticManager.shared.notification(type: .success)
}
```

### Escalating Snooze Prices

**File:** `ViewModels/DebtTracker.swift`

```swift
func addSnoozeDebt(alarmTime: String, snoozeCount: Int = 0) {
    // Progressive pricing
    let basePrice = 1.99
    let escalatedPrice = basePrice * Double(snoozeCount + 1)

    let debt = DebtRecord(
        amount: escalatedPrice,  // $1.99, $3.98, $5.97
        alarmTime: alarmTime
    )

    debtRecords.append(debt)
    saveDebts()
    HapticManager.shared.notification(type: .error)
}
```

Then update the call in `AlarmManager.swift`:
```swift
debtTracker.addSnoozeDebt(
    alarmTime: alarm.formattedTime,
    snoozeCount: alarm.snoozeCount
)
```

### Weekend Mode (Free Snoozes)

**File:** `ViewModels/AlarmManager.swift`

```swift
func snoozeAlarm() {
    guard var alarm = currentAlarm, alarm.canSnooze else { return }

    alarm.snoozeCount += 1
    alarm.lastSnoozeDate = Date()

    let snoozeTime = Calendar.current.date(
        byAdding: .minute,
        value: 9,
        to: Date()
    ) ?? Date()
    alarm.time = snoozeTime

    currentAlarm = alarm
    saveAlarm()
    scheduleNotification(for: alarm)
    isAlarmRinging = false

    // Check if weekend
    let calendar = Calendar.current
    let weekday = calendar.component(.weekday, from: Date())
    let isWeekend = weekday == 1 || weekday == 7  // Sunday or Saturday

    if !isWeekend {
        // Only charge on weekdays
        HapticManager.shared.notification(type: .warning)
        // (DebtTracker call happens in AlarmAlertView)
    }
}
```

## Advanced Customization

### Custom Haptic Patterns

**File:** `Utilities/HapticManager.swift`

```swift
func playCustomAlarmPattern() {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

    var events = [CHHapticEvent]()

    // Create a custom pattern
    for i in stride(from: 0, to: 1, by: 0.1) {
        let intensity = CHHapticEventParameter(
            parameterID: .hapticIntensity,
            value: Float(i)
        )
        let sharpness = CHHapticEventParameter(
            parameterID: .hapticSharpness,
            value: Float(i)
        )

        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: i
        )
        events.append(event)
    }

    do {
        let pattern = try CHHapticPattern(events: events, parameters: [])
        let player = try engine?.makePlayer(with: pattern)
        try player?.start(atTime: 0)
    } catch {
        print("Failed to play custom pattern: \(error)")
    }
}
```

### Custom Venmo Message

**File:** `ViewModels/DebtTracker.swift`

```swift
func openVenmoPayment() {
    guard !partnerVenmoUsername.isEmpty else { return }
    guard let weekDebt = currentWeekDebt else { return }

    let amount = weekDebt.totalAmount

    // Custom messages
    let messages = [
        "Snooze tax - worth it? 😴",
        "I hit snooze too much this week 💸",
        "Payment for being lazy 😅",
        "Snooze button debt 🔴",
        "I love sleep more than money 🛏️"
    ]
    let note = messages.randomElement() ?? "Snooze tax"

    // ... rest of function
}
```

### Add Sound to Alarm

**File:** `ViewModels/NotificationManager.swift`

Add a custom sound file to your project, then:

```swift
func scheduleAlarmNotification(for alarm: Alarm) {
    cancelAllNotifications()

    let content = UNMutableNotificationContent()
    content.title = "⏰ Wake Up!"
    content.body = "Time to get up or pay $1.99..."

    // Use custom sound
    content.sound = UNNotificationSound(
        named: UNNotificationSoundName("alarm_sound.wav")
    )
    // Or use critical alert (requires entitlement)
    // content.sound = .defaultCritical

    // ... rest of function
}
```

### Debt Milestones / Achievements

**File:** Create new `AchievementManager.swift`

```swift
class AchievementManager: ObservableObject {
    @Published var achievements: [Achievement] = []

    func checkMilestones(totalDebt: Double) {
        if totalDebt >= 50 {
            unlock("$50 in snoozes - maybe buy an alarm clock?")
        }
        if totalDebt >= 100 {
            unlock("$100 in snoozes - this is getting expensive")
        }
    }

    private func unlock(_ title: String) {
        let achievement = Achievement(title: title)
        if !achievements.contains(where: { $0.title == title }) {
            achievements.append(achievement)
            // Show banner or notification
        }
    }
}

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let date = Date()
}
```

## UI Experiments

### Neumorphism Style (instead of Glass)

```swift
.background(
    RoundedRectangle(cornerRadius: 20)
        .fill(Color.black)
        .shadow(color: .white.opacity(0.1), radius: 10, x: -5, y: -5)
        .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 5)
)
```

### Brutalist Style (minimal, stark)

```swift
// Remove all shadows and gradients
// Use solid colors only
.background(Color.white)
.foregroundColor(.black)
// Sharp corners instead of rounded
.cornerRadius(0)
```

### Glassmorphism Enhancement

```swift
.background(
    RoundedRectangle(cornerRadius: 24)
        .fill(.ultraThinMaterial)
        .background(
            LinearGradient(
                colors: [
                    .white.opacity(0.1),
                    .white.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
)
```

## Testing Your Changes

After customization:

1. **Build & Run** (Cmd+R)
2. **Test alarm flow** end-to-end
3. **Verify haptics** feel right
4. **Check animations** are smooth
5. **Test on device** (not just simulator)

## Share Your Customizations

If you create a cool variant:
1. Fork the project
2. Make your changes
3. Share screenshots
4. Inspire others!

---

**Remember:** The best customization is the one that makes YOU wake up on time.
