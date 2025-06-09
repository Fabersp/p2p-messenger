
# SecureChat

SecureChat is a peer-to-peer (P2P) messaging application designed for secure and private communication across devices in the same network. It uses **MultipeerConnectivity** for peer discovery and **CryptoKit** for digital signature-based verification, ensuring authenticity of all messages.

![SecureChat Screenshot](Simulator%20Screenshot%20-%20iPad%20mini%20(A17%20Pro)%20-%202025-06-09%20at%2009.48.50.jpeg)

---

## 🚀 Features

✅ **P2P Direct Messaging**  
✅ **Onboarding and Profile Management**  
✅ **Signed Messages** for authenticity and tamper-proof communication  
✅ **User Presence and Online Status**  
✅ **iOS, iPadOS and macOS Compatibility** (SwiftUI)

---

## 🔐 Cryptographic Signing

SecureChat uses **P256** digital signatures for message integrity.  
Here's a simplified example of how it works in the app:

```swift
// Signing a message
let signed = CryptoHelper.shared.sign(message: "Hello", senderName: "Alice")

// Verifying a received message
let isValid = CryptoHelper.verify(signedMessage: signed)
print("Signature valid? \(isValid)")
```

---

## 📸 UI Snapshots

| Onboarding View (Dark Mode)       | Main Chat (Light Mode)         |
|------------------------------------|--------------------------------|
| ![Dark Mode Onboarding](Screenshot%202025-06-09%20at%2009.47.24%20AM.png) | ![Light Mode Main](Simulator%20Screenshot%20-%20iPad%20mini%20(A17%20Pro)%20-%202025-06-09%20at%2009.45.54.jpeg) |

---

## 📁 Project Structure

- **CryptoHelper.swift**  
  Handles private key storage and message signing.

- **KeychainHelper.swift**  
  Manages secure storage of the private key.

- **PeerManager.swift**  
  Core peer-to-peer communication manager, handling onboarding, message routing, and presence.

- **UserInfo.swift**  
  Data model for storing user info and public keys.

- **ProfileHelper.swift**  
  Stores and retrieves user profile from local storage.

- **SwiftUI Views**  
  - `UserOnboardingView.swift`  
  - `UserListView.swift`  
  - `PrivateChatView.swift`  
  - `SecureChatMainView.swift`  
  - `UserProfileEditView.swift`

---

## ⚙️ How to Run

1. Open the project in **Xcode 15+**.
2. Build and run on your target device or simulator.
3. Make sure devices are on the same network to discover each other.
4. Sign up in the onboarding view and start chatting!

---

## 🛠️ Notes & Recommendations

- ⚠️ **P2P communication works only on local networks** (LAN/WiFi).  
- 🔒 **Private keys are securely stored in the Keychain** (per device).  
- 🚀 Extend with encryption of message content (optional) if desired.

---

## 👥 Contribution

Pull requests are welcome! For major changes, open an issue first to discuss what you would like to change.

---

## 📜 License

[MIT License](LICENSE)

---

## ✍️ Author

**Fabricio Padua**  
[LinkedIn](https://www.linkedin.com/in/fabricio-padua)  
