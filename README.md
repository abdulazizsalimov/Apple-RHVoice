# Compiling RHVoice Apple App

## System Requirements and Tools

- iOS 16.0 or newer  
- macOS 12.5 or newer to build  
- macOS 13.2 or newer to run  
- SwiftLint (required for code style checks and static analysis)  
  https://github.com/realm/SwiftLint

## Getting the Sources

### Option 1: One-line clone

```bash
git clone --recursive https://github.com/louderpages/Apple-RHVoice.git
```

### Option 2: Step by step

```bash
git clone https://github.com/louderpages/Apple-RHVoice.git
git submodule update --init --recursive --remote
```

## Running the App

### Simulator

1. Open `RHVoice.xcodeproj`
1. Select an iOS Simulator as the destination
1. Run the project

### Physical Device

1. Open `RHVoice.xcodeproj`
1. Select your iOS or macOS device as the destination
1. Fix code signing:
   - Sign in to your Apple Developer account
   - Select your team for:
     - `RHVoiceApp`
     - `RHVoiceExtension`
   - In the **Signing & Capabilities** tab
1. Update bundle identifiers

Edit the following file:

```
RHVoice/BuildScripts/Configs/Regular/common.xcconfig
```

Update these values:

```bash
APP_BUNDLE_IDENTIFIER = com.example.RHVoice
SHARED_DATA_GROUP_ID = group.example.rhvoice.shared.data
```

1. Clean & Run `RHVoiceApp`

## Building the Package

```bash
./RHVoice/BuildScripts/BuildApp.sh $BUILD_MINOR_NUMBER
```

## Notes

- SwiftLint must be installed and available in your PATH.
- Bundle identifiers must be unique and associated with your Apple Developer account.
