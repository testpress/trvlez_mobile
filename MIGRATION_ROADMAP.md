# Codebase Architecture & Quality Migration Roadmap

> A phased, step-by-step refactoring plan to align the **TrvlEz Mobile** codebase with the engineering and design standards defined in:
> - [ARCHITECTURE.md](file:///.agents/rules/ARCHITECTURE.md) (Feature-first clean architecture, Riverpod, GoRouter)
> - [DESIGN_SYSTEM.md](file:///.agents/rules/DESIGN_SYSTEM.md) (3-tier tokens, ThemeExtension, component themes)
> - [CODE_STANDARDS.md](file:///.agents/rules/CODE_STANDARDS.md) (Dart 3.x patterns, widget limits, null safety)

---

## 1. Executive Summary & Baseline Audit

### 1.1 Current Baseline
* **Static Analysis:** Passes with zero issues under basic `flutter_lints` (strict rules are disabled).
* **Test Suite:** 135 tests passing (all tests currently placed flat in root `test/`).

### 1.2 Identified Issues Summary

| Category | Primary Deviations | Metric / Impact |
|---|---|---|
| **Layer Inversion** | Presentation directly imports `data/` instead of `domain/` interfaces | 13 direct `data/` imports across presentation |
| **Cross-Feature Coupling** | Features import internal data layers of other features | `create_reservation_screen` imports `properties/data/` |
| **Missing Abstractions** | No abstract repository interfaces; concrete classes in `data/` | 100% of repositories lack domain contracts |
| **Missing Core Modules** | No `core/widgets/`, no `core/errors/app_exception.dart` | Zero shared buttons, text fields, or loaders |
| **Token System** | `AppColors` is a static class; no `ThemeExtension`, no `AppSpacing`/`AppRadius` | 45 hex colors, 120 `Colors.*`, 297 inline TextStyles |
| **God Screen Files** | Screen files heavily exceed the 300-line recommended limit | 8 screens range from 500 to 1,218 lines |
| **State in Widgets** | `StatefulWidget` using `initState` + `FutureBuilder` to fetch server data | `PropertyDetailScreen`, `ReservationDetailScreen` |
| **Type & Null Safety** | Repositories return raw Maps; heavy use of force unwraps | 158 `!` bang operators, 110 `dynamic` types |
| **Test Structure** | Tests do not mirror `lib/` directory structure | Flat `test/` directory |

---

## 2. Detailed Issue Catalog

### A. Architectural Issues
1. **No Domain Repository Interfaces:**
   - Concrete repositories (`PropertiesRepository`, `ReservationRepository`, `AuthRepository`) live directly in `data/`.
   - Presentation files depend on concrete implementations instead of abstract interfaces, making unit testing require overrides of entire implementations.
2. **Presentation Importing Data:**
   - [`property_detail_screen.dart`](file:///lib/features/properties/presentation/property_detail_screen.dart#L7) imports `properties_repository.dart`.
   - [`reservation_detail_screen.dart`](file:///lib/features/reservations/presentation/reservation_detail_screen.dart#L11) imports `reservation_repository.dart`.
   - [`create_reservation_screen.dart`](file:///lib/features/reservations/presentation/create_reservation_screen.dart#L10) imports `features/properties/data/properties_repository.dart` (**cross-feature data import**).
3. **Improper Separation of Concerns in UI:**
   - Screens contain business logic, direct API triggering, and local caching rather than delegating to Notifiers.
4. **App Entry Point & Router Layout:**
   - Root `TrvlEzApp` widget is defined directly inside `lib/main.dart` instead of `lib/app/app.dart`.
   - Router files live flat in `lib/app/router.dart` and `lib/app/routes.dart` instead of `lib/app/router/`.
5. **Missing Error Mapping:**
   - Low-level network exceptions bubble up rather than being mapped to a sealed `AppException` hierarchy in the repository layer.

### B. Design System & Token Issues
1. **Colors Not Using `ThemeExtension`:**
   - [`AppColors`](file:///lib/app/colors.dart) is a static class with getters, preventing clean dark mode switching and `context.colors` access.
2. **Missing Token Classes:**
   - `AppSpacing` does not exist (screens use magic numbers like `SizedBox(height: 16)`).
   - `AppRadius` does not exist (screens use ad-hoc `BorderRadius.circular(12)`).
   - `AppMotion` and `AppElevation` do not exist.
3. **Widespread Hardcoded Values in Features:**
   - **45** instances of `Color(0x...)` (e.g. `verification_banner.dart`).
   - **120** instances of `Colors.*` (`Colors.white`, `Colors.black.withAlpha`).
   - **297** instances of inline `TextStyle(` / `GoogleFonts.*` in feature widgets instead of `context.text.*`.
4. **Missing Shared UI Components (`lib/core/widgets/`):**
   - No `AppButton`, `AppTextField`, `AppCard`, `LoadingView`, or `ErrorView`. Every feature hand-crafts its own buttons and cards.

### C. Clean Code & Dart 3 Issues
1. **Oversized Screen Files ("God Screens"):**
   - `property_detail_screen.dart`: **1,218 lines**
   - `create_reservation_screen.dart`: **916 lines**
   - `qr_code_screen.dart`: **893 lines**
   - `booking_confirmation_screen.dart`: **865 lines**
   - `reservation_detail_screen.dart`: **832 lines**
   - `verification_notifier.dart`: **678 lines**
   - `profile_setup_screen.dart`: **613 lines**
   - `properties_listing_screen.dart`: **599 lines**
2. **Null Safety & Force Unwraps:**
   - **158** occurrences of `!` bang operator across models and screens.
3. **Untyped JSON & Raw Maps:**
   - Over **110** occurrences of `dynamic`.
   - `VerificationRepository` returns `Future<Map<String, dynamic>>` for challenges and MRZ confirmation.
4. **Async Lifecycle Safety:**
   - Missing `if (!context.mounted) return;` guards after async operations before using `BuildContext` (e.g., in `onboarding_screen.dart`).

---

## 3. Phased Implementation Roadmap

---

### Phase 1: Foundation (Theme, Core, Errors & Linter)
> **Goal:** Build the bedrock so features have the tokens, shared widgets, and error structures to migrate into without breaking existing flows.

- [x] **Task 1.1: Enable Strict Analysis Rules**
  - Update `analysis_options.yaml` to enforce `prefer_const_constructors: true`, `avoid_print: true`, `directives_ordering: true`, and strict casts.
  - Verify `flutter analyze` passes.

- [x] **Task 1.2: App Shell & Router Organization**
  - Move `TrvlEzApp` from `lib/main.dart` to `lib/app/app.dart`.
  - Move router files to `lib/app/router/app_router.dart` and `lib/app/router/routes.dart`.
  - Keep `lib/main.dart` strictly for initialization and `runApp`.

- [x] **Task 1.3: Design System Tokens Implementation**
  - Create `lib/app/theme/tokens/primitives/palette.dart` (raw hex colors).
  - Convert `AppColors` into a Flutter `ThemeExtension<AppColors>` in `lib/app/theme/tokens/app_colors.dart` with light and dark palettes.
  - Implement `lib/app/theme/tokens/app_spacing.dart` (4-pt grid and semantic aliases like `screenPadding`, `cardPadding`).
  - Implement `lib/app/theme/tokens/app_radius.dart` and `lib/app/theme/tokens/app_motion.dart`.
  - Implement `lib/app/theme/theme_extensions.dart` providing `context.colors` and `context.text`.

- [x] **Task 1.4: Update ThemeData & Component Themes**
  - Register `AppColors` in `ThemeData.extensions`.
  - Create component themes in `lib/app/theme/component_themes/` (`button_theme.dart`, `input_theme.dart`, `card_theme.dart`).

- [x] **Task 1.5: Core Shared Widgets (`lib/core/widgets/`)**
  - Create `AppButton` (with variants: primary, secondary, destructive, and loading state).
  - Create `AppTextField` with standardized border and typography.
  - Create `AppCard`, `LoadingView`, and `ErrorView` (with retry callback).

- [x] **Task 1.6: Core Error Hierarchy**
  - Create `lib/core/errors/app_exception.dart` with sealed classes (`AppException`, `NetworkException`, `UnauthorizedException`, `ServerException`, `ValidationException`).
  - Add `mapDioException(DioException e)` helper in `core/network/`.

---

### Phase 2: Pilot Feature Migration (`features/properties`)
> **Goal:** Fully migrate one complete feature to serve as the reference standard for the codebase.

- [ ] **Task 2.1: Domain Layer Extraction**
  - Move entities into `lib/features/properties/domain/entities/property.dart`.
  - Define `abstract interface class PropertiesRepository` in `lib/features/properties/domain/repositories/properties_repository.dart`.

- [ ] **Task 2.2: Data Layer Restructuring**
  - Move DTOs to `lib/features/properties/data/models/property_dto.dart`.
  - Move remote data source to `lib/features/properties/data/datasources/properties_remote_data_source.dart`.
  - Implement `PropertiesRepositoryImpl` in `lib/features/properties/data/repositories/properties_repository_impl.dart`, mapping Dio exceptions to `AppException`.

- [ ] **Task 2.3: Dependency Wiring & Presentation State**
  - Wire providers in `lib/features/properties/presentation/providers/properties_providers.dart`:
    - `propertiesRemoteDataSourceProvider`
    - `propertiesRepositoryProvider` (typed as the domain interface)
  - Create `PropertyDetailNotifier` (`AsyncNotifier<Property>`) to replace the `FutureBuilder` inside the screen.

- [ ] **Task 2.4: Deconstruct `property_detail_screen.dart` (1,218 Lines)**
  - Extract private widgets into dedicated files under `lib/features/properties/presentation/widgets/`:
    - `property_header_image.dart`
    - `property_top_bar.dart`
    - `property_content_sheet.dart`
    - `property_room_type_card.dart`
    - `property_amenities_section.dart`
  - Reduce `property_detail_screen.dart` to a clean `ConsumerWidget` under 150 lines.

- [ ] **Task 2.5: Replace Inline Styles with Tokens**
  - Remove all inline `Color(0x...)`, `Colors.*`, and raw `TextStyle` in the properties feature.
  - Use `context.colors`, `context.text`, and `AppSpacing`.

- [ ] **Task 2.6: Test Alignment**
  - Move and update property tests to `test/features/properties/presentation/` and `test/features/properties/data/`.
  - Ensure all tests pass.

---

### Phase 3: Reservations Feature Migration (`features/reservations`)
> **Goal:** Decouple cross-feature dependencies, split 4 massive screens, and eliminate `initState` future loading.

- [ ] **Task 3.1: Decouple Cross-Feature Dependency**
  - Remove direct import of `properties/data/properties_repository.dart` from `create_reservation_screen.dart`.
  - Access properties data via `propertiesRepositoryProvider` interface or domain entity.

- [ ] **Task 3.2: Domain & Data 3-Layer Split**
  - Create `domain/repositories/reservation_repository.dart` interface.
  - Move DTOs to `data/models/` and remote sources to `data/datasources/`.
  - Implement `ReservationRepositoryImpl` in `data/repositories/`.

- [ ] **Task 3.3: Split Oversized Screens into Sub-Widgets**
  - **`create_reservation_screen.dart` (916 lines):** Extract guest selection, room selection, and price breakdown into `presentation/widgets/`.
  - **`qr_code_screen.dart` (893 lines):** Extract QR card, reservation overview tile, and status badge.
  - **`booking_confirmation_screen.dart` (865 lines):** Extract summary card, instructions card, and action footer.
  - **`reservation_detail_screen.dart` (832 lines):** Move data loading into `ReservationDetailNotifier` and extract UI sections.

- [ ] **Task 3.4: Replace Styling with Semantic Tokens**
  - Remove hardcoded colors and spacing across all reservation screens.
  - Replace bespoke buttons with `AppButton`.

- [ ] **Task 3.5: Move Tests to Mirror `lib/`**
  - Move tests to `test/features/reservations/`.

---

### Phase 4: Auth & Profile Features Migration (`features/auth`, `features/profile`)
> **Goal:** Clean up authentication flows, standardize onboarding styles, and split setup screens.

- [ ] **Task 4.1: Auth Layer Restructuring**
  - Create `domain/repositories/auth_repository.dart` interface.
  - Move DTOs to `data/models/` and data sources to `data/datasources/`.
  - Refactor `login_controller.dart` and `registration_controller.dart` into Riverpod `AsyncNotifier`s in `presentation/providers/`.

- [ ] **Task 4.2: Replace Hardcoded Overlay Colors**
  - Replace `Colors.black.withAlpha(90)`, `Colors.white`, and `AppColors.success` in `welcome_screen.dart`, `login_screen.dart`, and `registration_screen.dart` with semantic tokens (`context.colors.surface`, `context.colors.textOnAction`).

- [ ] **Task 4.3: Deconstruct `profile_setup_screen.dart` (613 lines)**
  - Extract nationality picker, personal details form, and avatar uploader into `presentation/widgets/`.
  - Create `domain/repositories/profile_repository.dart` interface.

- [ ] **Task 4.4: Move Tests to Mirror `lib/`**
  - Relocate tests to `test/features/auth/` and `test/features/profile/`.

---

### Phase 5: Identity & Verification Migration (`features/verification`)
> **Goal:** Extract API client from repository, type raw Maps, eliminate force unwraps, and modularize camera/NFC screens.

- [ ] **Task 5.1: Create Remote Data Source**
  - Extract raw `Dio` calls from `VerificationRepository` into `VerificationRemoteDataSource`.
  - Separate S3 pre-signed upload handling into a dedicated network utility.

- [ ] **Task 5.2: Eliminate Raw `Map<String, dynamic>` API Responses**
  - Replace `Future<Map<String, dynamic>> getVerificationChallenge()` with a typed `VerificationChallengeDto` / domain model.
  - Replace `confirmMrz(Map<String, dynamic>)` with a typed payload class.

- [ ] **Task 5.3: Eliminate Force-Unwraps (`!`)**
  - Audit and replace all bang operators (`!`) in MRZ extraction and passport parser logic with safe null promotion or default fallbacks.

- [ ] **Task 5.4: Modularize Capture & Instruction Screens**
  - Split `nfc_scan_screen.dart` (493 lines), `passport_capture_screen.dart` (483 lines), and `verification_notifier.dart` (678 lines) into smaller sub-components.
  - Replace raw color badges in `verification_banner.dart` with `context.colors.feedback*`.

- [ ] **Task 5.5: Move Tests to Mirror `lib/`**
  - Relocate verification tests to `test/features/verification/`.

---

### Phase 6: Quality Gates & CI Enforcement
> **Goal:** Ensure the codebase stays clean permanently and regressions are prevented automatically.

- [ ] **Task 6.1: Add Automated Style Guard**
  - Add a CI check to disallow raw color references and inline text styles in `lib/features/`:
    ```bash
    ! grep -rnE "Color\(0x|Colors\.(red|blue|green|grey)" lib/features/
    ```

- [ ] **Task 6.2: Add Layer Import Guard**
  - Ensure no `presentation/` file imports from `data/`:
    ```bash
    ! grep -rnE "import .*/data/" lib/features/*/presentation/
    ```

- [ ] **Task 6.3: Final Analysis & Test Run**
  - Run `dart format --set-exit-if-changed .`
  - Run `flutter analyze --fatal-infos`
  - Run `flutter test` and confirm 100% pass rate.

---

## 4. Definition of Done for Each Migrated Feature

Every feature migration is considered complete only when:
1. **Zero Data Imports in UI:** `presentation/` only imports `domain/`.
2. **Abstract Repository Interface:** `domain/repositories/` defines the contract; `data/repositories/` implements it.
3. **No Direct HTTP in Screens:** Screens only watch Notifiers or use Riverpod providers.
4. **No Raw Colors or Magic Numbers:** All styles use `context.colors`, `context.text`, `AppSpacing`, and `AppRadius`.
5. **File Limits Met:** Every file is ≤ 300 lines; every `build()` method is ≤ 80 lines.
6. **Null & Type Safety:** Zero unnecessary `!` bang operators; zero `dynamic` outside JSON parsing.
7. **Passing Tests:** Unit and widget tests are located in matching `test/features/<feature>/` directories and pass.
