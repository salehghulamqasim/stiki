# Stiki Rotation Logic: The "Ultra-Smart" Fix 🧠

This document explains the critical logic update made to the Stiki widget rotation system. It is designed to be easy to understand, even if you aren't an expert coder!

---

## 1. How It Was (The Bug 🐞)

The old system worked like a **Train Schedule** attached to the **Creation Time** of the widget. This caused a major issue we call the "Lag Bug".

### The Scenario:
You create a widget at **12:00 PM** and choose **Quote #9** (out of 10). You set it to rotate **Hourly**.

**The Old Logic Thinking Process:**
1.  **1:00 PM Arrives (1 Hour later):**
    *   The app asks: *"How long has it been since 12:00 PM?"* -> **Answer: 1 Hour.**
    *   The app calculates: *"1 Hour means we should be at Quote #1."*
    *   The app checks: *"We are currently at Quote #9. Is 1 greater than 9?"* -> **NO.**
    *   **Result:** It does NOTHING. It waits for 8 more hours until the "Time passed" catches up to the quote number.

```text
[12:00 PM] Created (Start at Quote #9)
    |
    | (1 Hour Passes)
    v
[01:00 PM] App checks: "Should I be at Quote 1?" 
           Reality: "I'm already at Quote 9!" -> ❌ STOP. DO NOTHING.
    |
    | (Wait... Wait... Wait...)
    v
[09:00 PM] App checks: "Should I be at Quote 9?" -> "Yes, finally caught up."
```
**Problem:** Your widget looked broken/stuck for 9 hours!

---

## 2. How It Is Now ( The Solution ⚡)

I replaced the "Train Schedule" with a **Stopwatch**.

We added a new memory field called `lastUpdated`. Every time the widget changes or is created, we hit "Reset" on the stopwatch.

### The New Scenario:
You create a widget at **12:00 PM** and choose **Quote #9**. Set to **Hourly**.

**The New Logic Thinking Process:**
1.  **Stopwatch Starts** at 12:00 PM.
2.  **1:00 PM Arrives:**
    *   The app asks: *"What does the stopwatch say?"* -> **Answer: 1 Hour.**
    *   The app checks: *"Is 1 Hour >= 1 Hour frequency?"* -> **YES.**
    *   **Action:** Move to **Next Quote** (Quote #10).
    *   **RESET STOPWATCH.**

```text
[12:00 PM] Created (Quote #9) -> ⏱️ Stopwatch Reset
    |
    | (1 Hour Passes)
    v
[01:00 PM] Stopwatch says 1 Hr. -> Move to Quote #10 -> ⏱️ Stopwatch Reset
    |
    | (1 Hour Passes)
    v
[02:00 PM] Stopwatch says 1 Hr. -> Back to Quote #1 -> ⏱️ Stopwatch Reset
```
**Result:** It works instantly, every time, starting from ANY quote.

---

## 3. The Code I Added 💻

### A. The "Memory" (Model)
I added a `lastUpdated` timestamp to the widget. This is the "Reset Button" for our stopwatch.

```dart
// lib/models/widget_model.dart
class QuoteWidget {
  // ... existing fields ...
  final DateTime lastUpdated; // <--- The New "Stopwatch" Memory
}
```

### B. The "Brain" (Background Service)
This is the logic that runs in the background.

```dart
// lib/services/background_services.dart

// 1. Check the StopWatch
final timeSinceLastUpdate = now.difference(widget.lastUpdated);

// 2. Compare against your setting
if (timeSinceLastUpdate >= interval) {
    
    // 3. Move forward one step sequentially
    int nextIndex = (widget.currentIndex + 1) % widget.quotes.length;
    
    // 4. Update the screen & Reset the Stopwatch
    await StorageHelper.saveQuote(..., lastUpdated: now); 
}
```

---

## 4. How to Test & Modify Frequency 🛠️

In the future, if you want to test this quickly (e.g., make it rotate every **15 minutes** instead of Hours), you only need to change one file.

**File:** `lib/services/background_services.dart`

**Find this section:**
```dart
          // Determine the required interval
          Duration interval;
          if (widget.frequency == 'hourly') {
            interval = const Duration(hours: 1); // <--- CHANGE THIS
          } else if (widget.frequency == 'daily') {
            interval = const Duration(days: 1);
          }
```

**To Test Rapidly (e.g., 15 Minutes):**
Change `Duration(hours: 1)` to `Duration(minutes: 15)`.

```dart
          if (widget.frequency == 'hourly') {
            // interval = const Duration(hours: 1); // Old
            interval = const Duration(minutes: 15); // New Test Mode
          }
```

**Important:** 
Android and iOS limit background tasks to run roughly every **15 minutes** minimum to save battery. You cannot reliably test intervals faster than 15 minutes (like 10 seconds) in the background.

---

**Summary:**
- **Efficient?** Yes, it only wakes up once an hour.
- **Battery Safe?** Yes, extremely light math.
- **Fixed?** Yes, the "Lag Bug" is gone forever.
