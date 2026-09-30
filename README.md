# 💰 Expense Tracker - Flutter Mobile App

A clean, responsive, and robust Expense Tracker mobile application developed with **Flutter** and powered by **Google Firebase (Firestore & Authentication)**. 

Built for the **Flutter Developer Internship Practical Assessment** at **CyphLab**.

---

## 📱 Features Implemented

### 🌟 Core Requirements
- **Create Expenses**: Add new expenses with Title, Amount, Category, Date, and optional Notes.
- **Edit Expenses**: Update existing transaction records seamlessly with pre-filled forms.
- **Delete Expenses**: Delete records with instant UI feedback and an undo action SnackBar.
- **Category Selection**: Choose from organized categories (Food, Transport, Shopping, Bills, Entertainment, Health, Education, Other) with distinct visual badges and icons.
- **Firebase Firestore Integration**: Real-time cloud persistence with reactive `StreamBuilder` and automatic synchronization.
- **Current & Selected Month Spending Total**: Financial hero balance card with quick period selectors (Today, This Week, Current Month, Last Month, All Time).
- **Expense History / List**: Chronological stream of transactions with category avatars and formatted dates.
- **Filtering & Search**:
  - Filter by category and date ranges.
  - Case-insensitive search across transaction titles and notes.
- **Form Validation**: Comprehensive checks for required fields, non-zero positive amounts, and date pickers.
- **State Handling**: Dedicated views for **Loading** (with skeleton loaders), **Empty States**, and **Error States** (with retry buttons).

### 🚀 Additional / Bonus Features
- **Spending Analytics & Donut Chart**: Interactive category breakdown visualization using Flutter `CustomPainter`, including average spending and top expenditure insights.
- **Dynamic Dark & Light Mode**: Curated Material 3 design system supporting dynamic theme toggling.
- **Firebase Authentication**:
  - Email & Password registration and login.
  - Password reset via email.
  - One-tap Guest / Anonymous sign-in for instant app preview.
  - User session isolation (`users/{uid}/expenses`).
  - Client-side security protections (real-time password strength meter, anti-brute-force rate limiting).
- **Automated Unit & Widget Testing**: Comprehensive test coverage for models, business logic calculations, and UI components.

---

## 🛠️ Architecture & Project Structure

The project adheres to **Clean Architecture** and OOP principles (Single Responsibility, Encapsulation, Separation of Concerns):

```
lib/
├── firebase_options.dart        # Auto-generated Firebase platform configuration
├── main.dart                    # Application entry point & theme initialization
├── models/
│   └── expense.dart             # Immutable Expense data model with serialization
├── screens/
│   ├── add_edit_expense_screen.dart # Screen container for adding/editing transactions
│   ├── auth_gate.dart           # Reactive auth state router (Gatekeeper)
│   ├── auth_screen.dart         # Authentication screen (Sign In, Sign Up, Guest, Reset)
│   └── home_screen.dart         # Main dashboard with curved bottom navigation & tabs
├── services/
│   ├── auth_service.dart        # Firebase Auth wrapper & error handler
│   └── expense_service.dart     # Firestore CRUD, streams & business logic calculations
├── theme/
│   └── app_theme.dart           # Curated Light & Dark themes & ThemeNotifier
└── widgets/
    ├── empty_state.dart         # Reusable empty list illustration & messaging
    ├── error_view.dart          # Error presentation widget with retry trigger
    ├── expense_card.dart        # Transaction list card with category colors & menu
    ├── expense_form.dart        # Validated input form for expenses
    ├── expense_summary_chart.dart # Donut chart & spending analytics
    ├── filter_bottom_sheet.dart # Modal filter sheet
    └── loading_view.dart        # Centered loading spinner & skeleton placeholders
test/
└── widget_test.dart             # Unit tests for models, services & UI widgets
```

---

## 📦 Technologies & Packages Used

| Package | Version | Purpose |
| :--- | :--- | :--- |
| **Flutter SDK** | `^3.12.0` | Cross-platform UI toolkit |
| **Dart** | `^3.0.0` | Programming language |
| **firebase_core** | `^4.15.0` | Core Firebase app initialization |
| **cloud_firestore** | `^6.10.0` | Cloud database for real-time document sync |
| **firebase_auth** | `^6.7.0` | User authentication & session management |
| **cupertino_icons** | `^1.0.8` | Cupertino icon assets |
| **flutter_lints** | `^6.0.0` | Static analysis & code style enforcement |

---

## 🤖 AI Tools Used & Reflection

In accordance with CyphLab's submission guidelines, AI tools were leveraged during the design and development phases:

- **AI Tools Used**: Google Gemini, GitHub Copilot.
- **How They Helped**:
  - **Color Palette & Design Tokens**: Rapidly generating harmonious HSL color combinations and Material 3 design tokens for both light and dark modes.
  - **Regex & Validation Logic**: Drafting RFC-compliant email validation and password complexity regex checkers.
  - **Test Generation**: Scaffolding unit tests for edge-case calculation methods in `ExpenseService`.
- **Validation & Refactoring**: Every piece of AI-assisted logic was thoroughly reviewed, manually verified, debugged, and refined to adhere to Flutter idioms and Clean Architecture standards.

---

## 🚀 Setup & Installation Instructions

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.12.0 or higher)
- [Android Studio](https://developer.android.com/studio) or VS Code with Flutter extension
- An Android Device / Emulator or iOS Simulator

### Steps
1. **Clone the Repository**:
   ```bash
   git clone <YOUR_PUBLIC_GITHUB_REPO_URL>
   cd expense_tracker
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify Code Analysis**:
   ```bash
   flutter analyze
   ```

4. **Run Unit & Widget Tests**:
   ```bash
   flutter test
   ```

5. **Run the Application**:
   ```bash
   flutter run
   ```

---

## 🧪 Testing

Run automated tests via the Flutter CLI:
```bash
flutter test
```
All unit tests for models (`Expense`), calculations (`ExpenseService`), and widget render states are located in `test/widget_test.dart`.

---

## 📄 Submission Deliverables
- **GitHub Repository**: https://github.com/Mumsif/expense_tracker
- **App and Code Demonstration Video**: https://drive.google.com/file/d/1cvzy5f3gR07gBqf4m9eH5elswT0R3Zv0/view?usp=sharing
- **Release APK**: https://github.com/Mumsif/expense_tracker/releases/tag/v-0.0.1
