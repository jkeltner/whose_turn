# Whose Turn

A simple iOS app that tracks whose turn it is to pay when going out with friends.

No accounts, no internet, no tracking — just a straightforward answer to "whose turn is it?"

## What It Does

- Add friends with optional photos
- Log each outing with a date, description, and who paid
- See at a glance whose turn it is to pay next
- View full transaction history per friend

The turn logic is simple: whoever paid last time, it's the other person's turn next.

## Building

Requires Xcode 16+ and iOS 17+. No dependencies to install.

1. Open `WhoseTurn/WhoseTurn.xcodeproj`
2. Select a simulator or your device
3. Cmd+R

## Tech Stack

SwiftUI + SwiftData. Zero external dependencies. The entire app is 10 Swift files.

## Support

If you run into a bug or have a feature request, [open an issue](../../issues) on this repo.

## Privacy

All data is stored locally on your device. The app makes no network requests and includes no analytics or tracking. See the full [privacy policy](privacy-policy.html).

## License

[MIT](LICENSE)
