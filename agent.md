# AGENT INSTRUCTIONS: Flutter Favorite Restaurant App (Proyek Akhir Submission)

You are a Senior Flutter Developer Expert. Your task is to implement and complete the "Favorite Restaurant App" Flutter project to ensure it meets all core submission criteria and bonus requirements for a 5-star rating.
Testing has not yet been implemented for this project. However, you might want to review the entire thing.
---

## 1. PROJECT OVERVIEW & ARCHITECTURE
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Local Storage**:
    - SQLite (`sqflite`) for Favorite Restaurants data
    - Shared Preferences (`shared_preferences`) for Theme and Daily Reminder settings
- **Background Tasks & Notifications**: `workmanager` and `flutter_local_notifications`
- **Networking**: `http` or `dio` for fetching Restaurant API data

---

## 2. KEY REQUIREMENTS CHECKLIST (5-STAR TARGET)

### Feature 1: Favorite Restaurant Page & Database
- Implement a dedicated **Favorite Page** displaying saved restaurants using `ListView` / `GridView`.
- Each item card MUST display: **Name, Picture/Image, City, and Rating**.
- Tapping an item navigates to the **Detail Page**.
- Users can **add** or **remove** restaurants from favorites directly on both the Favorite page and Detail page (toggle favorite status).
- Favorites data MUST be persisted using **SQLite**.

### Feature 2: Theme Settings (Light / Dark Mode)
- Add a Theme Switcher inside the Settings Menu.
- Store theme selection in **Shared Preferences** so it persists across app restarts.
- Ensure proper color contrasts for all UI components (Text, Icons, Cards, Backgrounds) in both Light and Dark themes.

### Feature 3: Daily Reminder Feature (Bonus / Advanced Criteria)
- Add a toggle switch in Settings to enable/disable the Daily Reminder.
- Save the toggle state in **Shared Preferences**.
- Schedule a daily notification at **11:00 AM**.
- **Bonus Requirement**: Use `Workmanager` combined with local notifications to fetch a random restaurant from the API and show its details inside the notification card.

### Feature 4: Testing & Quality Assurance
Implement at least **5 test cases** covering **3 different types of testing**:
1. **Unit Testing**:
    - State initial condition of `RestaurantProvider`.
    - Returns restaurant list when API call succeeds.
    - Returns error state/message when API call fails.
2. **Widget Testing**:
    - Verify UI components render properly (e.g., Restaurant card, Loading state, or Error state).
3. **Integration Testing**:
    - Test end-to-end user interaction flow (e.g., navigating to detail or toggling favorites).

### Feature 5: Clean Code & Error Handling
- Remove all unused imports, dead code, and auto-generated comments (`// TODO:` or boilerplate comments).
- Ensure consistent indentation and clean directory structure (Layered architecture: Data, Provider, UI, Utils).
- Show user-friendly error messages (text/illustrations) when internet connection fails or API errors occur.

---

## 3. IMPLEMENTATION STEPS FOR THE AGENT

### Step 1: Database & Persistence Layer
1. Create a `DatabaseHelper` class using `sqflite` for CRUD operations (`insert`, `getFavorites`, `getFavoriteById`, `delete`).
2. Create a `PreferencesHelper` class for managing Light/Dark theme boolean and Daily Reminder boolean via `shared_preferences`.

### Step 2: State Management (Provider)
1. Build `RestaurantProvider` handling API fetching state (`Loading`, `HasData`, `NoData`, `Error`).
2. Build `FavoriteProvider` to manage SQLite sync.
3. Build `ThemeProvider` to handle dynamic `ThemeData` switching.
4. Build `SchedulingProvider` to manage the Workmanager background execution loop.

### Step 3: UI Layer & Navigation
1. Add `FavoriteScreen` with reactive UI based on `FavoriteProvider`.
2. Add `SettingsScreen` with toggles for Theme and Daily Reminder.
3. Update `DetailScreen` to display an interactive Favorite toggle icon (Heart button).

### Step 4: Background Workmanager & Notifications
1. Initialize `Workmanager` and `flutter_local_notifications`.
2. Register a periodic task running daily at 11:00 AM.
3. Inside `Workmanager` callback, fetch restaurant list from API, pick one at random, and display its notification.

### Step 5: Unit, Widget, & Integration Tests
1. Create `test/provider/restaurant_provider_test.dart` (Mock HTTP client using `mockito` or `http/testing`).
2. Create `test/widget/restaurant_card_test.dart` for UI assertion.
3. Create `integration_test/app_test.dart` for end-to-end flow execution.

---

## 4. CODE FORMATTING & QUALITY RULES
- Follow official Dart style guidelines (`flutter analyze` must pass with 0 warnings/errors).
- Use `const` constructors wherever applicable to optimize build performance.
- Include proper error boundary checks (`try-catch`) on all asynchronous and database calls.