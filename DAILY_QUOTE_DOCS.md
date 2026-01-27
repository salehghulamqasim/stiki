# 🧠 Smart Daily Quote System - Documentation

## Overview
This system provides a battery-efficient "Daily Quote" on the home screen. It does not use background services. Instead, it checks if the quote is outdated (from a previous day) only when the user opens the app.

## 📂 Key Files Modified

### 1. `lib/pages/home_page.dart`
**Role:** The Brain 🧠
*   **Logic**: Contains `_checkDailyQuote()` which compares today's date with the saved date.
*   **Animation**: `_animateTypewriter()` handles the character-by-character typing effect.
*   **Topics**: The list of topics (Wisdom, Jokes, Motivation) is defined here inside `_checkDailyQuote()`.

**How to Modify Topics:**
Look for this list in `home_page.dart`:
```dart
final topics = [
  "Wise life advice",
  "Funny programming joke", // <--- Add/Remove topics here
  ...
];
```

### 2. `lib/utils/storage_helper.dart`
**Role:** The Memory 💾
*   **Methods**: `saveDailyQuote()` and `getDailyQuote()`.
*   **Storage**: Uses `SharedPreferences` to persist the quote and the date string (e.g., "2024-03-20").

### 3. `lib/services/ai_service.dart`
**Role:** The Creator 🎨
*   **Method**: `fetchQuotes(useDeepMode: true)`.
*   **Engine**: Uses the R1 DeepMode model via your API proxy to generate high-quality text.

---

## ⚙️ How It Works (Flowchart)

1.  **User Opens App** 📱
    *   `HomePage` initializes.
2.  **Date Check** 📅
    *   Is the stored date == Today?
    *   **YES**: Load saved quote instantly. (Zero network, zero cost).
    *   **NO**: Trigger "Refresh" logic.
3.  **Refeshing** 🔄
    *   Pick random topic.
    *   Call `AiService`.
    *   **Animation**: Clear text -> Type new quote character-by-character ⌨️.
4.  **Save** 💾
    *   Save new quote + Today's Date.

## 🔋 Battery Efficiency
*   **Background Usage**: 0% (feature is dormant when app is closed).
*   **Network Usage**: 1 request per day maximum.

---

## 🛠 Common Tasks

**Q: How do I change the typing speed?**
A: In `home_page.dart`, find `_animateTypewriter`. Change `Duration(milliseconds: 50)` to a lower number (faster) or higher (slower).

**Q: I want it to update every hour instead of daily.**
A: In `home_page.dart`, change the date check logic:
*   *Current*: `savedData['date'] == today`
*   *Change to*: Store usage of `DateTime.now().hour` and check if hours differ.

**Q: How to reset it for testing?**
A: Reinstall the app, or clear app storage. This wipes the "saved date", forcing a new fetch.
