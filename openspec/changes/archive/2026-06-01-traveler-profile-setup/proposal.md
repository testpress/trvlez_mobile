# Traveler Profile Setup Feature - Proposal

## Overview

Build the traveler profile setup flow allowing users to provide personal information required for onboarding and verification. This feature allows users to set up or update their profile, including phone number, nationality, gender, and date of birth.

## Goals

- ✅ Provide a premium, responsive profile setup screen matching TrvlEz design
- ✅ Implement pre-population of form fields if existing profile data is already present
- ✅ Enforce comprehensive client-side form validation (required fields, phone format, valid age range)
- ✅ Add gender selection field to capture traveler identity
- ✅ Integrate with backend endpoints (`GET /traveler/profile` and `PATCH /traveler/profile`)
- ✅ Handle network/API loading states and errors gracefully with clear user feedback
- ✅ Follow Clean Architecture guidelines with decoupled Data, Domain, and Presentation layers
- ✅ Leverage sound state management using `ChangeNotifier` (`ProfileNotifier`)

## Non-Goals

- Government ID upload and identity document scanning (handled in a future onboarding step)
- SMS verification/OTP for phone number updates (handled at a higher security boundary)
- Profile picture uploads and image hosting (future feature phase)

## Problem Statement

During onboarding and identity verification, users need to provide critical traveler information (phone, nationality, gender, date of birth) before they can perform bookings. Without a dedicated profile setup screen, users cannot complete onboarding or keep their details up-to-date. Additionally, if the profile already has saved information, forcing users to re-enter it from scratch is a poor user experience; the system must load and display existing data.

## Solution

Build a feature-specific profile setup flow under `lib/features/profile/`:
1. Form fields for phone number, nationality, gender, and date of birth.
2. A retrieval flow using `GET /traveler/profile` inside `initState` to fetch existing user profile data and pre-fill the input fields automatically.
3. Interactive date picker for date of birth and dropdown select field for gender.
4. Input validation (e.g. phone number digits, required fields).
5. State-driven submit action executing `PATCH /traveler/profile` via `ProfileRemoteDataSource` and `ApiClient`.
6. Informative error banner and custom loading screens to keep the user engaged.

## Benefits

- **User Convenience**: Existing data is loaded and displayed immediately, preventing redundant inputs.
- **Robust Architecture**: Separation of remote data fetching, repository abstraction, and presentation states.
- **Type Safety**: Avoids raw string mapping, leveraging proper DTOs (`ProfileDto`) and domain models (`Profile`).
- **Flexible UI**: Follows responsive Flutter design principles.

## Implementation Status

✅ **COMPLETED** - Traveler profile setup flow is fully implemented and tested.
