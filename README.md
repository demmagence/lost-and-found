# Lost and Found

A responsive Material 3 Flutter application for managing and tracking lost and found items. The application is built using the Model-View-ViewModel (MVVM) architecture pattern, featuring responsive layouts for mobile and desktop viewports, advanced search and filtering capabilities, full CRUD operations, and detailed activity logging.

## Architectural Overview

The project adheres to a clean, layered MVVM architecture:

```
lib/
├── app/
│   └── lost_found_app.dart         # Application entry point and theme configuration
├── core/
│   └── utils/
│       └── date_formatter.dart     # Utility functions for date and time presentation
├── features/
│   └── lost_found/
│       ├── data/
│       │   └── lost_found_repository.dart  # Data access interface and in-memory storage
│       ├── models/
│       │   └── lost_found_models.dart      # Strongly-typed data models and enums
│       ├── viewmodels/
│       │   └── lost_found_view_model.dart  # Business logic and state management
│       └── views/
│           ├── lost_found_display.dart     # Visual extensions and UI display helpers
│           ├── lost_found_home_page.dart   # Responsive layout shell and navigation
│           └── widgets/
│               ├── dashboard_header.dart   # Analytics metrics visualization
│               ├── item_browser.dart       # List/grid browser with filtering and search
│               ├── item_detail_panel.dart   # Interactive item detail panel
│               ├── report_dialog.dart      # Form bottom sheet for creating/updating reports
│               └── shared_widgets.dart     # Reusable UI component library
└── main.dart                       # Application runner
```

### Key Components

*   **Models**: Strongly-typed structures defining `LostFoundItem`, `ActivityLog`, and associated domain enums (`ItemType`, `ItemStatus`, `ItemPriority`, `ItemCategory`).
*   **Repository**: Decoupled interface (`LostFoundRepository`) with an in-memory implementation seeded with mocked initial data.
*   **ViewModel**: Inherits from `ChangeNotifier` to expose state and handle actions (adding, editing, deleting, updating status, and filtering items).
*   **Views**: Declarative UI components that react to state changes in the ViewModel, adapting automatically to different screen sizes.

---

## Features

### 1. Responsive Interface
*   **Desktop Layout**: A dual-pane interface showing the list browser and detail panel side-by-side, accompanied by a top dashboard metrics header.
*   **Mobile Layout**: A bottom-navigation interface with tab views for Home, Found, and Lost items. Details are presented using a full-screen modal bottom sheet.

### 2. Search and Filtering
*   **Full-Text Search**: Live searching across titles, locations, descriptions, and reporter names.
*   **Status Filter**: Filter items by their status (Open, Claimed, Returned, Resolved) using a modal bottom sheet.
*   **Type Filter**: Filter items by type (Found, Lost) using inline chips (desktop) or tab navigation (mobile).
*   **Category Filter**: Filter items by category (Electronics, Documents, Keys, Clothing, Other).

### 3. CRUD Operations
*   **Create**: Add new lost or found reports with validated input fields (Title, Category, Priority, Location, Reporter, Contact, Description). The form is automatically initialized based on the active tab context.
*   **Read**: View comprehensive details including metadata, claims status, and a chronological history timeline.
*   **Update**: Modify existing reports using pre-populated forms. Toggling active tabs is disabled during modification to prevent data mismatch.
*   **Delete**: Permanently delete records after confirming via a system dialog.

### 4. Activity Logs (Audit Trail)
*   Every significant lifecycle event (creation, status update, manual edit) automatically appends a timestamped `ActivityLog` to the item's history, showing who performed the action and when.

---

## Technical Stack

*   **Framework**: Flutter (Material 3 enabled)
*   **Programming Language**: Dart
*   **State Management**: `ListenableBuilder` / `ChangeNotifier`
*   **Typography**: Plus Jakarta Sans (managed via `google_fonts`)
*   **Branding**: Custom launcher logo configured with white background (`com.demma.lostandfound`)

---

## Getting Started

### Prerequisites

Ensure you have the Flutter SDK installed on your machine.
*   Flutter SDK version: `^3.12.0` or higher

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/demmagence/lost-and-found.git
   cd lost-and-found
   ```

2. Fetch package dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

### Running Tests

Execute the widget test suite to verify UI components, state logic, and CRUD flows:
```bash
flutter test
```

### Static Analysis

Run the static analyzer to check for lint issues and code quality:
```bash
flutter analyze
```
