# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

"Whose Turn" is a native iOS app (SwiftUI + SwiftData) that tracks whose turn it is to pay when going out with friends. No social features, no login, no backend — purely local storage. iOS 17+.

## Build & Run

Open `WhoseTurn/WhoseTurn.xcodeproj` in Xcode, select a simulator or device, and hit Cmd+R. No dependencies to install, no codegen steps.

## Architecture

**SwiftUI + SwiftData** with zero external dependencies. The entire app is 9 Swift files.

**Models** (`Models/`):
- `Friend` — `@Model` with name, photoData (external storage), createdAt. Has a `@Relationship(deleteRule: .cascade)` to transactions. Computed properties `lastTransaction` and `whoseTurn`.
- `Transaction` — `@Model` with friend reference, desc, date, whoPaid enum, createdAt.
- `WhoPaid` — enum with `.user` and `.friend` cases, stored as Codable string.

**Views** (`Views/`):
- `FriendsListView` — Main screen. Tap friend → detail. Swipe left → edit/delete.
- `FriendDetailView` — Shows friend info, turn badge, recent transactions (last 5), history link. Green "+" button opens add transaction sheet.
- `AddTransactionSheet` — Modal form with date picker, description, segmented who-paid picker.
- `AddFriendView` — Sheet with PhotosPicker and name field.
- `EditFriendView` — Sheet for editing name/photo and deleting friend.
- `TransactionHistoryView` — Full chronological transaction list with swipe-to-delete.

**Turn Logic**: `Friend.whoseTurn` returns the opposite of whoever paid in the most recent transaction. Defaults to `.user` when no transactions exist.

## Key Conventions

- Navigation: `NavigationStack` with value-based `navigationDestination`. Sheets for modals (add friend, edit friend, add transaction).
- Photos: `PhotosPicker` (no permissions needed). Photo data stored with `@Attribute(.externalStorage)`.
- Colors: blue = user's turn, orange = friend's turn (consistent across all badges).
- SwiftData container is set up in `WhoseTurnApp.swift` with `modelContainer(for:)`.
- Bundle ID: `com.jeffkeltner.WhoseTurn`
