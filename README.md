# Live Call (Flutter + LiveKit)

Live Call is a Flutter project that demonstrates **real-time audio and video calling** using **LiveKit**.  
The project shows how to run a LiveKit server locally, generate access tokens, and connect Flutter clients for live communication.

---

## Tech Stack

- Flutter
- LiveKit
- WebRTC
- LiveKit Server (self-hosted)
- JWT Authentication (LiveKit Access Tokens)

---

## Project Features

- Real-time audio calls
- Real-time video calls
- Room-based communication
- Secure access using LiveKit tokens
- Works on Android & iOS emulators

---

## Prerequisites

Before running the project, make sure you have:

- Flutter SDK installed
- Dart SDK
- LiveKit Server installed
- LiveKit CLI installed

---

## Install Livekit
brew install livekit-cli  

## Run LiveKit Server
 livekit-server --dev --bind 0.0.0.0 

### generate token
lk token create \                                    
  --api-key devkey \
  --api-secret secret \
  --identity user \
  --name user \
  --room test-room \
  --join \
  --valid-for 24h

Follow the official LiveKit installation instructions or install via binary:

```bash
brew install livekit

