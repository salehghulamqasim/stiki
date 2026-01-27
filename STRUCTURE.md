# Stiki - Sticky Notes Widget App Structure

## 📁 Project Organization

Simple and clean Flutter project structure using **Cubit/Bloc** for state management.

```
stiki/
├── lib/
│   ├── main.dart                    # App entry point
│   │
│   ├── models/                      # Data models
│   │   └── note.dart               # Note model (id, title, content, color, timestamp)
│   │
│   ├── repository/                  # Data layer
│   │   ├── notes_repository.dart   # Handle CRUD operations for notes
│   │   └── widget_repository.dart  # Handle home widget updates
│   │
│   ├── cubits/                      # State management (Cubit/Bloc)
│   │   └── notes/
│   │       ├── notes_cubit.dart    # Manages notes state
│   │       └── notes_state.dart    # Notes state classes
│   │
│   ├── pages/                       # Full-page screens
│   │   ├── home_page.dart          # Main screen showing all notes
│   │   ├── add_note_page.dart      # Screen to create new note
│   │   └── edit_note_page.dart     # Screen to edit existing note
│   │
│   ├── components/                  # Reusable UI widgets
│   │   ├── note_card.dart          # Single note card widget
│   │   ├── color_picker.dart       # Color selection widget
│   │   └── empty_state.dart        # Empty state widget
│   │
│   ├── themes/                      # App styling
│   │   ├── app_theme.dart          # Main theme configuration
│   │   ├── app_colors.dart         # Color palette
│   │   └── text_styles.dart        # Text styles
│   │
│   ├── constants/                   # App constants
│   │   ├── strings.dart            # Static text
│   │   └── storage_keys.dart       # SharedPreferences keys
│   │
│   ├── services/                    # External services
│   │   └── storage_service.dart    # SharedPreferences wrapper
│   │
│   └── utils/                       # Helper functions
│       └── date_formatter.dart     # Date formatting utilities
│
├── android/                         # Native Android widget code
├── ios/                            # Native iOS widget code
└── pubspec.yaml                    # Dependencies
```

## 📦 Dependencies

Current packages in your `pubspec.yaml`:

```yaml
dependencies:
  # State management
  equatable: ^2.0.8             # ✅ Installed
  # flutter_bloc: ^8.1.3        # ⚠️ Still need to add
  
  # Storage & Widget
  shared_preferences: ^2.5.4    # ✅ Installed
  home_widget: ^0.8.1          # ✅ Installed
  
  # Utilities
  intl: ^0.20.2                # ✅ Installed (date formatting)
  # uuid: ^4.5.1                # ⚠️ Still need to add (for note IDs)
  
  # Navigation & UI
  go_router: ^17.0.1           # ✅ Installed
  google_fonts: ^7.0.0         # ✅ Installed
  
  # Weather (optional)
  weather: ^3.2.1              # ✅ Installed
```

**Still need to add:**
```bash
flutter pub add flutter_bloc uuid
```

## 🎯 Implementation Order

1. **Models** → `note.dart`
2. **Themes** → `app_colors.dart`, `app_theme.dart`
3. **Constants** → `strings.dart`, `storage_keys.dart`
4. **Services** → `storage_service.dart`
5. **Repository** → `notes_repository.dart`, `widget_repository.dart`
6. **Cubits** → `notes_cubit.dart`, `notes_state.dart`
7. **Components** → `note_card.dart`, `color_picker.dart`, `empty_state.dart`
8. **Pages** → `home_page.dart`, `add_note_page.dart`, `edit_note_page.dart`
9. **Main** → Wire everything with BlocProvider

## 🏗️ Architecture Flow

```
UI (Pages) → Cubit → Repository → Storage Service → SharedPreferences
                                 → Widget Repository → home_widget
```

## 🔑 Key Features

- ✅ CRUD operations for notes
- ✅ Color-coded sticky notes
- ✅ Local storage (SharedPreferences)
- ✅ Home screen widget integration
- ✅ Clean Cubit/Bloc architecture
- ✅ No backend required

---

**Simple. Clean. Ready to build.** 🚀
