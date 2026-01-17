# Architecture Documentation 🏗️

Deep dive into how Snooze Tax works under the hood.

## Architecture Overview

Snooze Tax follows **MVVM (Model-View-ViewModel)** architecture with SwiftUI:

```
┌─────────────────────────────────────────┐
│            Views (SwiftUI)              │
│  ContentView, HomeView, AlarmSetterView │
└──────────────┬──────────────────────────┘
               │ @EnvironmentObject
               │ @Published properties
┌──────────────▼──────────────────────────┐
│         ViewModels (ObservableObject)   │
│   AlarmManager, DebtTracker, NotifMgr   │
└──────────────┬──────────────────────────┘
               │ Business Logic
               │ State Management
┌──────────────▼──────────────────────────┐
│           Models (Structs)              │
│        Alarm, DebtRecord, etc.          │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│        Utilities & Services             │
│   HapticManager, NotificationManager    │
└─────────────────────────────────────────┘
```

## Data Flow

### 1. Setting an Alarm

```
User Action → AlarmSetterView
    ↓
AlarmManager.setAlarm(time:)
    ↓
Create Alarm model
    ↓
Save to UserDefaults
    ↓
Schedule notification via NotificationManager
    ↓
Trigger haptic feedback
    ↓
Update @Published var → SwiftUI rerenders
```

### 2. Snoozing an Alarm

```
User taps Snooze → AlarmAlertView
    ↓
AlarmManager.snoozeAlarm()
    ├─→ Increment snooze count
    ├─→ Calculate new time (+9 min)
    └─→ Reschedule notification
    ↓
DebtTracker.addSnoozeDebt()
    ├─→ Create DebtRecord ($1.99)
    ├─→ Save to UserDefaults
    └─→ Update totalUnpaidDebt
    ↓
Trigger warning haptic
    ↓
Update UI (red glow intensifies)
```

### 3. Paying Debt

```
User taps Pay button → PaymentBanner
    ↓
DebtTracker.openVenmoPayment()
    ↓
Build Venmo deep link URL
    ├─→ venmo://paycharge
    ├─→ recipient=username
    ├─→ amount=weeklyTotal
    └─→ note="Snooze tax"
    ↓
UIApplication.open(venmoURL)
    ↓
(User completes payment in Venmo)
    ↓
User returns, taps "Mark Paid"
    ↓
Update DebtRecords.isPaid = true
```

## Core Components

### Models

#### Alarm
```swift
struct Alarm: Identifiable, Codable {
    let id: UUID
    var time: Date
    var isEnabled: Bool
    var snoozeCount: Int
    var lastSnoozeDate: Date?
}
```

**Responsibilities:**
- Store alarm data
- Track snooze count
- Provide formatted time display

**Key Methods:**
- `canSnooze: Bool` - Returns true if snoozeCount < 3
- `formattedTime: String` - Returns "7:30 AM" format

#### DebtRecord
```swift
struct DebtRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amount: Double
    let alarmTime: String
    var isPaid: Bool
}
```

**Responsibilities:**
- Track individual snooze charges
- Store payment status
- Associate debt with specific alarm

### ViewModels

#### AlarmManager
```swift
class AlarmManager: ObservableObject {
    @Published var currentAlarm: Alarm?
    @Published var isAlarmRinging: Bool
}
```

**Responsibilities:**
- Manage alarm lifecycle
- Handle snooze/dismiss actions
- Coordinate with NotificationManager
- Persist alarm state

**Key Methods:**
- `setAlarm(time:)` - Creates and schedules new alarm
- `snoozeAlarm()` - Snoozes current alarm (+9 min, increment count)
- `dismissAlarm()` - Dismisses alarm, resets for next day
- `deleteAlarm()` - Removes alarm completely

**State Management:**
```swift
// UserDefaults persistence
private func saveAlarm() {
    if let encoded = try? JSONEncoder().encode(alarm) {
        UserDefaults.standard.set(encoded, forKey: "savedAlarm")
    }
}

private func loadAlarm() {
    if let data = UserDefaults.standard.data(forKey: "savedAlarm"),
       let alarm = try? JSONDecoder().decode(Alarm.self, from: data) {
        currentAlarm = alarm
    }
}
```

#### DebtTracker
```swift
class DebtTracker: ObservableObject {
    @Published var debtRecords: [DebtRecord]
    @Published var partnerVenmoUsername: String
}
```

**Responsibilities:**
- Track all debt records
- Calculate totals (daily, weekly, unpaid)
- Store partner Venmo username
- Generate Venmo payment deep links

**Key Methods:**
- `addSnoozeDebt(alarmTime:)` - Creates new $1.99 debt record
- `markWeekAsPaid()` - Marks current week's debts as paid
- `openVenmoPayment()` - Opens Venmo app with pre-filled payment

**Computed Properties:**
```swift
var totalUnpaidDebt: Double {
    debtRecords.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
}

var currentWeekDebt: WeeklyDebt? {
    // Returns debt records for current week
}
```

### Services/Utilities

#### NotificationManager
```swift
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
}
```

**Responsibilities:**
- Request notification permissions
- Schedule alarm notifications
- Handle notification actions (Wake Up/Snooze from notification)
- Manage notification categories

**Key Features:**
- **Critical alerts** for alarm sound
- **Calendar trigger** for daily repeating
- **Actions** for Wake Up/Snooze from notification
- **Delegate** to handle foreground notifications

**Notification Flow:**
```swift
// Schedule
let trigger = UNCalendarNotificationTrigger(
    dateMatching: components,
    repeats: false
)

// Actions
let wakeUpAction = UNNotificationAction(
    identifier: "WAKE_UP",
    title: "Wake Up",
    options: [.foreground]
)
```

#### HapticManager
```swift
class HapticManager {
    static let shared = HapticManager()
    private var engine: CHHapticEngine?
}
```

**Responsibilities:**
- Manage Core Haptics engine
- Provide convenient haptic feedback methods
- Create custom haptic patterns
- Special alarm haptic loop

**Haptic Types:**
- `impact(style:)` - Physical tap feeling
- `notification(type:)` - Success/warning/error
- `selection()` - Lightweight picker feedback
- `startAlarmHaptics()` - Intense repeating pattern

**Alarm Haptics:**
```swift
func startAlarmHaptics() {
    alarmHapticTimer = Timer.scheduledTimer(
        withTimeInterval: 0.5,
        repeats: true
    ) { [weak self] _ in
        self?.impact(style: .heavy)
    }
}
```

## Views Architecture

### View Hierarchy

```
ContentView (Root)
    ├─ HomeView
    │   ├─ DebtGlowView (background)
    │   ├─ Alarm time display
    │   └─ PaymentBanner (conditional)
    │
    ├─ AlarmAlertView (when ringing)
    │   ├─ Alarm time
    │   ├─ Wake Up button
    │   └─ Snooze button (conditional)
    │
    ├─ AlarmSetterView (sheet)
    │   ├─ Time display
    │   ├─ Hour/Minute/AM-PM pickers
    │   └─ Set Alarm button
    │
    └─ SettingsView (sheet)
        ├─ Venmo username input
        ├─ Debt history list
        └─ Save button
```

### State Management in Views

**Environment Objects:**
```swift
struct ContentView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @EnvironmentObject var debtTracker: DebtTracker
    @EnvironmentObject var notificationManager: NotificationManager
}
```

**Local State:**
```swift
struct HomeView: View {
    @Binding var showingAlarmSetter: Bool
    @State private var timeScale: CGFloat = 1.0
}
```

### Animation Strategy

**Spring Animations:**
```swift
.animation(
    .spring(response: 0.6, dampingFraction: 0.8),
    value: alarmManager.isAlarmRinging
)
```

**Transition Effects:**
```swift
.transition(.asymmetric(
    insertion: .scale(scale: 0.8).combined(with: .opacity),
    removal: .scale(scale: 1.2).combined(with: .opacity)
))
```

**Continuous Animations:**
```swift
.onAppear {
    withAnimation(
        .easeInOut(duration: 2.0)
        .repeatForever(autoreverses: true)
    ) {
        timeScale = 1.05
    }
}
```

## Data Persistence

### UserDefaults Keys
- `savedAlarm` - Current alarm (JSON encoded)
- `debtRecords` - Array of debt records (JSON encoded)
- `partnerVenmo` - Partner's Venmo username (String)

### Encoding/Decoding
```swift
// Save
if let encoded = try? JSONEncoder().encode(alarm) {
    UserDefaults.standard.set(encoded, forKey: "savedAlarm")
}

// Load
if let data = UserDefaults.standard.data(forKey: "savedAlarm"),
   let alarm = try? JSONDecoder().decode(Alarm.self, from: data) {
    currentAlarm = alarm
}
```

## External Integrations

### Venmo Deep Linking

**URL Format:**
```
venmo://paycharge?txn=pay&recipients=USERNAME&amount=AMOUNT&note=NOTE
```

**Implementation:**
```swift
var components = URLComponents()
components.scheme = "venmo"
components.host = "paycharge"
components.queryItems = [
    URLQueryItem(name: "txn", value: "pay"),
    URLQueryItem(name: "recipients", value: username),
    URLQueryItem(name: "amount", value: String(format: "%.2f", amount)),
    URLQueryItem(name: "note", value: "Snooze tax - worth it? 😴")
]

if let url = components.url {
    UIApplication.shared.open(url)
}
```

**Fallback:**
```swift
// If Venmo app not installed
let webURL = URL(string: "https://venmo.com/\(username)")!
UIApplication.shared.open(webURL)
```

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading:**
   - Debt history only loads first 10 records
   - Scroll view for longer history

2. **Animation Performance:**
   - Use `.drawingGroup()` for complex animations
   - Limit blur radius for glass morphism
   - Optimize gradient complexity

3. **Memory Management:**
   - Haptic timer uses `[weak self]`
   - Stop alarm haptics when dismissed
   - Cancel notifications when alarm deleted

4. **State Updates:**
   - `@Published` properties trigger minimal redraws
   - Animation values separate from data
   - Conditional rendering for heavy views

## Security & Privacy

### Data Storage
- **Local only** - No cloud sync by default
- **UserDefaults** - Suitable for non-sensitive data
- **No personal info** - Just Venmo username (public)

### Permissions
- **Notifications** - Required for alarms
- **No location** - Not needed
- **No contacts** - Manual username entry
- **No camera/photos** - Not used

### Future Encryption
If adding sensitive features:
```swift
// Could use Keychain for sensitive data
let keychain = KeychainSwift()
keychain.set(venmoUsername, forKey: "venmo")
```

## Testing Strategy

### Unit Tests
```swift
// AlarmManager tests
func testSnoozeIncrementsCount()
func testCanSnoozeUpToThreeTimes()
func testDismissResetsForNextDay()

// DebtTracker tests
func testAddSnoozeDebtCreatesRecord()
func testWeeklyDebtCalculation()
func testMarkWeekAsPaid()
```

### UI Tests
```swift
// Critical paths
func testSetAlarmFlow()
func testSnoozeAlarmFlow()
func testPaymentFlow()
```

### Manual Testing Checklist
- [ ] Set alarm for 1 minute, verify notification
- [ ] Snooze 3 times, verify button disappears
- [ ] Check debt counter updates
- [ ] Verify red glow intensifies with debt
- [ ] Test Venmo deep link opens correctly
- [ ] Verify haptics on each interaction
- [ ] Test animations are smooth (60fps)

## Scalability

### Current Limitations
- Single alarm at a time
- UserDefaults (suitable for < 1MB data)
- No cloud sync
- Manual payment marking

### Future Improvements
1. **SwiftData Migration:**
   ```swift
   @Model
   class Alarm {
       var time: Date
       var snoozeCount: Int
       // Relationships, queries, etc.
   }
   ```

2. **CloudKit Sync:**
   - Sync alarms across devices
   - Share debt with partner
   - Automatic payment verification

3. **Multiple Alarms:**
   - Array of alarms instead of single
   - Separate debt tracking per alarm
   - Smart snooze limits across all alarms

## Design Patterns Used

1. **Singleton:** `HapticManager.shared`, `NotificationManager.shared`
2. **Observer:** `@Published`, `@ObservableObject`, `@EnvironmentObject`
3. **Delegate:** `UNUserNotificationCenterDelegate`
4. **Builder:** URL components for Venmo deep links
5. **Strategy:** Different haptic styles for different actions

## Dependencies

### Apple Frameworks
- **SwiftUI** - UI framework
- **Combine** - Reactive programming
- **UserNotifications** - Local notifications
- **CoreHaptics** - Advanced haptic feedback
- **UIKit** - Haptic generators, URL opening

### Third-Party
- **None!** - Pure Swift/SwiftUI implementation

---

This architecture prioritizes:
- ✅ **Simplicity** over complexity
- ✅ **Performance** over features
- ✅ **Beauty** over functionality
- ✅ **User experience** over technical perfection

The result: A brutally simple app that does one thing incredibly well.
