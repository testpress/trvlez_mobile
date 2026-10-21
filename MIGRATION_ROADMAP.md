# Codebase Architecture & Quality Migration Roadmap

> A phased, step-by-step refactoring plan to align the **TrvlEz Mobile** codebase with the engineering and design standards defined in:
> - [ARCHITECTURE.md](file:///.agents/rules/ARCHITECTURE.md) (Feature-first clean architecture, Riverpod, GoRouter)
> - [DESIGN_SYSTEM.md](file:///.agents/rules/DESIGN_SYSTEM.md) (3-tier tokens, ThemeExtension, component themes)
> - [CODE_STANDARDS.md](file:///.agents/rules/CODE_STANDARDS.md) (Dart 3.x patterns, widget limits, null safety)

---

## 1. Executive Summary & Baseline Audit

### 1.1 Current Status & Milestones
* **Static Analysis:** Passes with zero issues under strict `flutter analyze --fatal-infos`.
* **Test Suite:** 317 tests passing (100% pass rate, mirrored structure under `test/features/` and `test/core/`).
* **CI & Quality Gates:** `./scripts/quality_gates.sh` runs 8 automated checks (formatting, analyzer, test suite, style guard, layer import guard, semantic layout token guard, git cleanliness).
* **Token Coverage:** 100% compliance across 273 files in `lib/` via 3-tier semantic layout tokens (`context.space`, `context.sizes`, `context.shape`, `context.colors`, `context.text`). Legacy `AppSpacing` and `AppRadius` completely retired.

### 1.2 Identified Issues Summary

| Category | Primary Deviations | Metric / Impact |
|---|---|---|
| **Layer Inversion** | Presentation directly imports `data/` instead of `domain/` interfaces | 13 direct `data/` imports across presentation |
| **Cross-Feature Coupling** | Features import internal data layers of other features | `create_reservation_screen` imports `properties/data/` |
| **Missing Abstractions** | No abstract repository interfaces; concrete classes in `data/` | 100% of repositories lack domain contracts |
| **Missing Core Modules** | No `core/widgets/`, no `core/errors/app_exception.dart` | Zero shared buttons, text fields, or loaders |
| **Token System** | 3-tier semantic tokens (`context.space`, `context.sizes`, `context.shape`, `context.colors`, `context.text`) | 100% compliance across 273 files in `lib/`; legacy `AppSpacing`/`AppRadius` retired |
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
   - Initial static `AppSpacing` and `AppRadius` were introduced and subsequently replaced by a comprehensive 3-tier semantic token architecture (`AppSpace`, `AppSize`, `AppShape` ThemeExtensions) in `lib/core/design_tokens/`.
   - `AppMotion` registered in `lib/app/theme/tokens/app_motion.dart`.
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
  - Implement initial `lib/app/theme/tokens/app_spacing.dart` and `lib/app/theme/tokens/app_radius.dart` (subsequently modernized and superseded by 3-tier semantic layout tokens in Phase 10).
  - Implement `lib/app/theme/tokens/app_motion.dart`.
  - Implement `lib/app/theme/theme_extensions.dart` providing `context.colors`, `context.text`, and exporting `core/design_tokens/tokens.dart`.

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

- [x] **Task 2.1: Domain Layer Extraction**
  - Move entities into `lib/features/properties/domain/entities/property.dart`.
  - Define `abstract interface class PropertiesRepository` in `lib/features/properties/domain/repositories/properties_repository.dart`.

- [x] **Task 2.2: Data Layer Restructuring**
  - Move DTOs to `lib/features/properties/data/models/property_dto.dart`.
  - Move remote data source to `lib/features/properties/data/datasources/properties_remote_data_source.dart`.
  - Implement `PropertiesRepositoryImpl` in `lib/features/properties/data/repositories/properties_repository_impl.dart`, mapping Dio exceptions to `AppException`.

- [x] **Task 2.3: Dependency Wiring & Presentation State**
  - Wire providers in `lib/features/properties/presentation/providers/properties_providers.dart`:
    - `propertiesRemoteDataSourceProvider`
    - `propertiesRepositoryProvider` (typed as the domain interface)
  - Create `PropertyDetailNotifier` (`AsyncNotifier<Property>`) to replace the `FutureBuilder` inside the screen.

- [x] **Task 2.4: Deconstruct `property_detail_screen.dart` (1,218 Lines)**
  - Extract private widgets into dedicated files under `lib/features/properties/presentation/widgets/`:
    - `property_header_image.dart`
    - `property_top_bar.dart`
    - `property_content_sheet.dart`
    - `property_room_type_card.dart`
    - `property_amenities_section.dart`
  - Reduce `property_detail_screen.dart` to a clean `ConsumerWidget` under 150 lines.

- [x] **Task 2.5: Replace Inline Styles with Tokens**
  - Remove all inline `Color(0x...)`, `Colors.*`, and raw `TextStyle` in the properties feature.
  - Use `context.colors`, `context.text`, and semantic layout tokens.

- [x] **Task 2.6: Test Alignment**
  - Move and update property tests to `test/features/properties/presentation/` and `test/features/properties/data/`.
  - Ensure all tests pass.

---

### Phase 3: Reservations Feature Migration (`features/reservations`)
> **Goal:** Decouple cross-feature dependencies, split 4 massive screens, and eliminate `initState` future loading.

- [x] **Task 3.1: Decouple Cross-Feature Dependency**
  - Remove direct import of `properties/data/properties_repository.dart` from `create_reservation_screen.dart`.
  - Access properties data via `propertiesRepositoryProvider` interface or domain entity.

- [x] **Task 3.2: Domain & Data 3-Layer Split**
  - Create `domain/repositories/reservation_repository.dart` interface.
  - Move DTOs to `data/models/` and remote sources to `data/datasources/`.
  - Implement `ReservationRepositoryImpl` in `data/repositories/`.

- [x] **Task 3.3: Split Oversized Screens into Sub-Widgets**
  - **`create_reservation_screen.dart` (916 lines):** Extract guest selection, room selection, and price breakdown into `presentation/widgets/`.
  - **`qr_code_screen.dart` (893 lines):** Extract QR card, reservation overview tile, and status badge.
  - **`booking_confirmation_screen.dart` (865 lines):** Extract summary card, instructions card, and action footer.
  - **`reservation_detail_screen.dart` (832 lines):** Move data loading into `ReservationDetailNotifier` and extract UI sections.

- [x] **Task 3.4: Replace Styling with Semantic Tokens**
  - Remove hardcoded colors and spacing across all reservation screens.
  - Replace bespoke buttons with `AppButton`.

- [x] **Task 3.5: Move Tests to Mirror `lib/`**
  - Move tests to `test/features/reservations/`.

---

### Phase 4: Auth & Profile Features Migration (`features/auth`, `features/profile`)
> **Goal:** Clean up authentication flows, standardize onboarding styles, and split setup screens.

- [x] **Task 4.1: Auth Layer Restructuring**
  - Create `domain/repositories/auth_repository.dart` interface.
  - Move DTOs to `data/models/` and data sources to `data/datasources/`.
  - Refactor `login_controller.dart` and `registration_controller.dart` into Riverpod `AsyncNotifier`s in `presentation/providers/`.

- [x] **Task 4.2: Replace Hardcoded Overlay Colors**
  - Replace `Colors.black.withAlpha(90)`, `Colors.white`, and `AppColors.success` in `welcome_screen.dart`, `login_screen.dart`, and `registration_screen.dart` with semantic tokens (`context.colors.surface`, `context.colors.textOnAction`).

- [x] **Task 4.3: Deconstruct `profile_setup_screen.dart` (613 lines)**
  - Extract nationality picker, personal details form, and avatar uploader into `presentation/widgets/`.
  - Create `domain/repositories/profile_repository.dart` interface.

- [x] **Task 4.4: Move Tests to Mirror `lib/`**
  - Relocate tests to `test/features/auth/` and `test/features/profile/`.

---

### Phase 5: Identity & Verification Migration (`features/verification`)
> **Goal:** Extract API client from repository, type raw Maps, eliminate force unwraps, and modularize camera/NFC screens.

- [x] **Task 5.1: Create Remote Data Source**
  - Extract raw `Dio` calls from `VerificationRepository` into `VerificationRemoteDataSource`.
  - Separate S3 pre-signed upload handling into a dedicated network utility.

- [x] **Task 5.2: Eliminate Raw `Map<String, dynamic>` API Responses**
  - Replace `Future<Map<String, dynamic>> getVerificationChallenge()` with a typed `VerificationChallengeDto` / domain model.
  - Replace `confirmMrz(Map<String, dynamic>)` with a typed payload class.

- [x] **Task 5.3: Eliminate Force-Unwraps (`!`)**
  - Audit and replace all bang operators (`!`) in MRZ extraction and passport parser logic with safe null promotion or default fallbacks.

- [x] **Task 5.4: Modularize Capture & Instruction Screens**
  - Split `nfc_scan_screen.dart` (493 lines), `passport_capture_screen.dart` (483 lines), and `verification_notifier.dart` (678 lines) into smaller sub-components.
  - Replace raw color badges in `verification_banner.dart` with `context.colors.feedback*`.

- [x] **Task 5.5: Move Tests to Mirror `lib/`**
  - Relocate verification tests to `test/features/verification/`.

---

### Phase 6: Quality Gates & CI Enforcement
> **Goal:** Ensure the codebase stays clean permanently and regressions are prevented automatically.

- [x] **Task 6.1: Add Automated Style Guard**
  - Add a CI check to disallow raw color references and inline text styles in `lib/features/`:
    ```bash
    ! grep -rnE "Color\(0x|Colors\.(red|blue|green|grey)" lib/features/
    ```

- [x] **Task 6.2: Add Layer Import Guard**
  - Ensure no `presentation/` file imports from `data/`:
    ```bash
    ! grep -rnE "import .*/data/" lib/features/*/presentation/
    ```

- [x] **Task 6.3: Final Analysis & Test Run**
  - Run `dart format --set-exit-if-changed .`
  - Run `flutter analyze --fatal-infos`
  - Run `flutter test` and confirm 100% pass rate.

---

### Phase 7: Elimination of Legacy Re-Export Shims & Dead Exports
> **Goal:** Remove all backward-compatibility shim files and obsolete re-exports, updating all callers to direct canonical paths.

- [x] **Task 7.1: Eliminate App & Core Re-Export Shims**
  - Delete `lib/app/colors.dart`, `lib/app/router.dart`, `lib/app/routes.dart`, `lib/app/theme.dart`, and `lib/core/widgets/widgets.dart`.
  - Update all imports across `lib/` and `test/` to direct canonical paths (`app_colors.dart`, `app_router.dart`, `routes.dart`, `app_theme.dart`).

- [x] **Task 7.2: Eliminate Auth & Profile Re-Export Shims**
  - Delete `features/auth/data/` shims (`auth_remote_data_source.dart`, `auth_repository.dart`, `login_response_dto.dart`, `traveler_signup_dto.dart`), `domain/signup_result.dart`, and `presentation/` controllers (`login_controller.dart`, `registration_controller.dart`).
  - Delete `features/profile/data/` shims (`profile_dto.dart`, `profile_remote_data_source.dart`, `profile_repository.dart`), `domain/profile.dart`, and `presentation/profile_notifier.dart`.
  - Update all callers across `lib/` and `test/` to direct canonical file locations.

- [x] **Task 7.3: Eliminate Properties, Reservations & Verification Re-Export Shims**
  - Delete `features/properties/` shims (`properties_remote_data_source.dart`, `properties_repository.dart`, `property_dto.dart`, `domain/property.dart`).
  - Delete `features/reservations/` shims (`form_dto.dart`, `form_remote_data_source.dart`, `form_repository.dart`, `reservation_dto.dart`, `reservation_remote_data_source.dart`, `reservation_repository.dart`, `domain/form.dart`, `domain/reservation.dart`, `presentation/reservations_notifier.dart`).
  - Delete `features/verification/presentation/verification_providers.dart` shim.
  - Update all callers across `lib/` and `test/` to direct canonical file locations.

- [x] **Task 7.4: Clean Up Transitive Exports & Run Quality Gates**
  - Audit and eliminate unnecessary pass-through `export` statements in providers and repositories that leak layer dependencies.
  - Run `./scripts/quality_gates.sh` (Style guard, Layer import guard, `dart format`, `flutter analyze --fatal-infos`, and `flutter test`).

---

### Phase 8: Architecture & Boundary Decoupling
> **Goal:** Strictly enforce domain purity and cross-feature encapsulation in accordance with `ARCHITECTURE.md`.

- [x] **Task 8.1: Domain Layer Purity in Verification**
  - Extract `NfcError` mapper from `features/verification/domain/nfc_error.dart` to `features/verification/data/services/nfc_error_mapper.dart`.
  - Remove `package:flutter/services.dart` and `package:dmrtd/dmrtd.dart` from `nfc_error.dart` to make domain pure Dart.
  - Relocate UI presentation model `processing_stage.dart` from `domain/` to `features/verification/presentation/models/processing_stage.dart`.
  - Update all verification screens, services, and tests.

- [x] **Task 8.2: Promote Shared KYC Stepper to Core**
  - Move `features/verification/presentation/widgets/kyc_progress_stepper.dart` to `lib/core/widgets/kyc_progress_stepper.dart`.
  - Update all references in `onboarding`, `verification`, and tests.

- [x] **Task 8.3: Promote Traveler Verification State & Providers to Core**
  - Promote `TravelerVerificationState` to `lib/core/domain/traveler_verification_state.dart`.
  - Relocate `travelerVerificationStateProvider` and `isKycVerifiedProvider` to `lib/core/auth/auth_notifier.dart`.
  - Decouple `reservations`, `home`, and `verification` screens/providers to consume core auth/domain providers.

- [x] **Task 8.4: Decouple Cross-Feature Presentation Imports in Home & Reservations**
  - Remove direct cross-feature presentation imports between `reservations` and `properties`/`profile`.
  - Ensure all features interact exclusively through `core/` or domain interfaces.

- [x] **Task 8.5: Verification & Quality Gates**
  - Run `./scripts/quality_gates.sh` to ensure all quality gates, analyzer diagnostics, formatting, and unit/widget tests pass with 0 errors.

---

### Phase 9: Design System & Code Standards Enforcement
> **Goal:** Eliminate inline text styles, magic radius/spacing numbers, unsafe null-unwraps, and modularize oversized screen widgets to comply with `DESIGN_SYSTEM.md` and `CODE_STANDARDS.md`.

- [x] **Task 9.1: Typography & Design System Token Enforcement**
  - Replace all 20 inline `TextStyle(` instances in `lib/features/` with semantic text tokens (`context.text.*?.copyWith(...)`).
  - Migrate literal `BorderRadius.circular(...)` to semantic shape tokens (`context.shape.radius*`).

- [x] **Task 9.2: Data Layer Null-Safety Hardening**
  - Replace all 13 `response.data!` force-unwraps in remote data sources with safe null assertions and `ServerException` mapping.

- [x] **Task 9.3: Screen Deconstruction & Extraction of Private Helpers**
  - Deconstruct oversized screen widgets and convert `_buildX` helper methods to dedicated `StatelessWidget`/`ConsumerWidget` classes in `presentation/widgets/`.

- [x] **Task 9.4: Verification & Quality Gates**
  - Run `./scripts/quality_gates.sh` ensuring 0 analyzer diagnostics, clean formatting, and 100% test pass rate.

---

### Phase 10: Semantic Layout Tokens Migration & Legacy Token Retirement
> **Goal:** Eliminate all raw layout numbers (`EdgeInsets`, `BorderRadius`, `SizedBox`, `Icon(size:)`), migrate the entire codebase to a 3-tier semantic token system (`context.space`, `context.sizes`, `context.shape`), completely retire legacy `AppSpacing`/`AppRadius`, and wire automated CI enforcement.

- [x] **Task 10.1: 3-Tier Semantic Layout Token Architecture**
  - Create `lib/core/design_tokens/primitives.dart` with library-private scale constants (`Prim`).
  - Create `lib/core/design_tokens/space_tokens.dart` implementing `AppSpace` `ThemeExtension` with typed `EdgeInsets` (`insetScreen`, `insetCard`, `insetDialog`, etc.) and structural double gaps (`stackText`, `stackFormField`, `inlineIconLabel`, etc.).
  - Create `lib/core/design_tokens/size_tokens.dart` implementing `AppSize` `ThemeExtension` for control heights, icon sizes, and avatar diameters.
  - Create `lib/core/design_tokens/shape_tokens.dart` implementing `AppShape` `ThemeExtension` with standardized `BorderRadius` shapes (`radiusControl`, `radiusSurface`, `radiusPill`) and border stroke widths.
  - Create `lib/core/design_tokens/tokens_context.dart` exposing `context.space`, `context.sizes`, and `context.shape` accessors.
  - Register all token extensions in `ThemeData` (`lib/app/theme/app_theme.dart`).

- [x] **Task 10.2: Full Codebase Feature Migration (273 Files)**
  - Audit and migrate all 12 feature folders and core widgets:
    - `features/auth/` (11 files)
    - `features/home/` (18 files)
    - `features/profile/` (13 files)
    - `features/properties/` (18 files)
    - `features/reservations/` (29 files)
    - `features/verification/` (36 files)
    - `features/explore/`, `features/favorites/`, `features/inbox/`, `features/onboarding/`, `features/payment/`, `features/trips/` (64 files)
    - `core/widgets/` & `app/` (84 files)
  - 100% compliance across all 273 Dart files in `lib/`.

- [x] **Task 10.3: Automated CI Layout Guard & Quality Gate**
  - Create `scripts/verify_layout_tokens.py` to scan `lib/` for raw layout literals and deprecated token references.
  - Integrate token guard as Step 5 in `scripts/quality_gates.sh`.
  - Integrate token guard into `.github/workflows/ci.yml`.

- [x] **Task 10.4: Complete Retirement of Legacy Layout Classes**
  - Audit zero usage of `AppSpacing` and `AppRadius` across `lib/`.
  - Remove legacy test blocks from `test/core/theme_tokens_test.dart`.
  - Delete `lib/app/theme/tokens/app_spacing.dart` and `lib/app/theme/tokens/app_radius.dart`.
  - Remove deleted files from `ALLOWED_PATHS` in `scripts/verify_layout_tokens.py`.

- [x] **Task 10.5: Engineering Rules & Documentation Alignment**
  - Update `.agents/rules/DESIGN_SYSTEM.md`, `ARCHITECTURE.md`, `CODE_STANDARDS.md`, `flutter-anti-ui-slop.md`, and `SKILL.md` to mandate semantic layout tokens and ban deprecated static classes.
  - Document system architecture in `docs/design_tokens.md`.

---

## 4. Definition of Done for Each Migrated Feature

Every feature migration is considered complete only when:
1. **Zero Data Imports in UI:** `presentation/` only imports `domain/`.
2. **Abstract Repository Interface:** `domain/repositories/` defines the contract; `data/repositories/` implements it.
3. **No Direct HTTP in Screens:** Screens only watch Notifiers or use Riverpod providers.
4. **No Raw Colors or Magic Numbers:** All styles use `context.colors`, `context.text`, `context.space`, `context.sizes`, and `context.shape`. Deprecated `AppSpacing` and `AppRadius` are banned.
5. **File Limits Met:** Every file is ≤ 300 lines; every `build()` method is ≤ 80 lines.
6. **Null & Type Safety:** Zero unnecessary `!` bang operators; zero `dynamic` outside JSON parsing.
7. **Passing Tests:** Unit and widget tests are located in matching `test/features/<feature>/` directories and pass.
