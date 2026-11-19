# CPR VR Trainer

A standalone Flutter app for a **CPR training manikin**. The trainee performs CPR on the manikin, the app reads
the manikin's sensors over **Bluetooth LE**, scores the session, and **streams every compression and rescue breath
live to a server** so a **VR headset** can mirror the session in real time. When the 60 seconds are over the app
shows the result.

There is no login, no quiz and no other game: **Splash → Dashboard → Bluetooth devices → CPR game**.

---

## How it works

```
┌──────────────┐  BLE notifications   ┌──────────────┐  HTTPS POST /VrEvent   ┌────────────┐
│ CPR manikin  │ ───────────────────▶ │   This app   │ ─────────────────────▶ │ VR server  │ ─▶ VR headset
│ (sensors)    │  "p,right,left,air"  │ count + score│  live events (JSON)    │            │
└──────────────┘                      └──────────────┘                        └────────────┘
```

1. **Dashboard** – choose the manikin type (Adult / Child / Neonatal) and tap **Play**. The choice is remembered.
2. **Bluetooth devices** – nearby named devices are listed (CT manikins first). Tap **Connect** to open the game.
3. **CPR game** – the top bar shows a green **Connected** / red **Disconnected** label and a settings menu with the
   **With Air Blow** option (on: breaths are measured; off: only a prompt is shown; remembered). A 60 s countdown runs. Every press on the chest is counted as correct or incorrect; after 30, 60 and
   90 compressions the *rescue breath* dialog appears. The session ends when time runs out or 120 compressions
   are reached, and the **result dialog** (total / correct / incorrect, Retry / Exit) is shown.
4. **VR stream** – every counted compression, every rescue breath and the final result are sent to the VR server.

### Manikin data (BLE)

The manikin notifies a comma separated ASCII string on the characteristic configured in `.env`:

```
pressure , rightCompression , leftCompression , airBlow
   0-10        0 = wrong          0 = wrong       > 1.25 = breath
```

* A press is remembered at its deepest point and counted when the chest is released: depth ≥ 8 is **correct**,
  3-7 is **incorrect**.
* `rightCompression` / `leftCompression` = 0 means that side is being pressed wrongly (red dot) and counts as incorrect.
* The session is a **success** when more than 100 correct compressions were counted.

### VR events

POSTed as JSON to `VR_BASE_URL + VR_EVENT_PATH`:

| `eventType` | Meaning | Important fields |
|---|---|---|
| `0` | Compression counted | `pressure`, `count`, `timeLeft`, `isCorrect` (1/0) |
| `1` | Rescue breath counted | `count` (1 or 2), `timeLeft` |
| `2` | Final result | `correctCompression`, `inCorrectCompression` |

Delivery rules (`VrEventService`): live events keep only the **latest** state while a request is in flight (the VR
side never gets a backlog); the **final result** has its own slot, is sent first and is retried until accepted;
failed requests retry with a growing delay. The game screen shows the live **VR server ping**.

### Connection loss and resume

If Bluetooth drops mid-game the countdown **pauses**, a dialog offers **Exit** or **Retry**, and the game **resumes
automatically** when the manikin comes back (or when Retry succeeds). Packets received while the app is in the
background are ignored, so nothing is counted by accident.

---

## Architecture

Feature-first **clean architecture**, the same layout as the Fitness app:

| Concern | Choice |
|---|---|
| State management | `provider` (`ChangeNotifier`) |
| Dependency injection | `get_it` (`lib/core/di/injection.dart`) |
| Routing | `go_router` (`lib/core/routes`) |
| Configuration | `flutter_dotenv` (`.env` → `AppEnv`) |
| Local storage | `shared_preferences` behind `StorageService` |
| Bluetooth | `flutter_blue_plus` behind `BleService` |
| HTTP | `http` behind `VrEventService` |

```
lib/
├── main.dart                     load .env, register dependencies, runApp
├── app.dart                      MaterialApp.router
├── core/                         shared infrastructure (no feature code)
│   ├── config/app_env.dart       typed access to .env
│   ├── constants/                app constants + asset paths
│   ├── di/injection.dart         get_it registrations
│   ├── routes/                   route names + GoRouter (creates each screen's provider)
│   ├── services/                 navigation, dialogs, snackbar, storage
│   ├── theme/                    colours, text styles, ThemeData
│   ├── utils/                    responsive helpers
│   └── widgets/                  gradient button, scaffold, header, dialogs, sheets
└── features/
    ├── splash/presentation/      logo, then opens the dashboard
    ├── home/presentation/        dashboard: manikin type + Play
    ├── bluetooth/
    │   ├── data/services/        BleService  (permissions, scan, connect, data stream, reconnect)
    │   ├── domain/entities/      BleDeviceItem
    │   └── presentation/         device list page, provider, widgets
    └── cpr/
        ├── domain/entities/      CprType, CprLayout, CprSensorData, CprEvent, CprSettings
        ├── data/                 VrEventService, NetworkMonitorService, CprSettingsRepository
        └── presentation/         CprPage, CprProvider (the game), widgets (gauge, timer, dialogs)
```

### Layers

* **`domain`** – plain Dart: entities and rules (`CprSensorData.fromPacket`, `CprEvent.toJson`). No Flutter, no plugins.
* **`data`** – talks to the outside world: Bluetooth, the VR server, local storage.
* **`presentation`** – `Provider`s hold screen state and call services; pages and widgets only render.

### Rules of the road

* **Providers are created in `AppRouter`**, from `di`, so pages stay free of DI code.
* **No `BuildContext` in providers/services.** Navigation, dialogs and snackbars go through `NavigationService`,
  `DialogService` and `SnackBarService`.
* Widgets receive **data and callbacks**, not whole providers; rebuilds are narrowed with `Selector` / `context.select`.
* **Every deployment-specific value lives in `.env`**, never in code. Secrets and signing keys are never committed.

---

## Configuration (`.env`)

`.env` is bundled into the app as an asset and is **git-ignored**. Create it from the template:

```bash
cp .env.example .env
```

| Key | Default | Purpose |
|---|---|---|
| `VR_BASE_URL` | `https://manikinapi.trueformgames.com:5180/api` | VR server API base URL |
| `VR_EVENT_PATH` | `/VrEvent` | Endpoint live events are POSTed to |
| `VR_REQUEST_TIMEOUT_SECONDS` | `5` | Request timeout before a retry |
| `VR_PING_INTERVAL_SECONDS` | `3` | Link-quality ping interval |
| `BLE_SERVICE_UUID` | `C201` | GATT service of the manikin |
| `BLE_CHARACTERISTIC_UUID` | `483E` | Characteristic the sensor data arrives on |
| `BLE_DEVICE_NAME_KEYWORD` | `CT` | Devices whose name contains this are treated as manikins |

---

## Run and build

```bash
flutter pub get
cp .env.example .env          # then edit if your server differs
flutter run                   # on a real device: Bluetooth LE is not available on emulators
```

Release signing reads **`android/key.properties`** (git-ignored):

```properties
storeFile=C:/path/to/your.jks
storePassword=...
keyAlias=...
keyPassword=...
```

Without that file a release build is signed with the debug key.

**Android toolchain:** Gradle 8.14, Android Gradle Plugin 8.11.1, Kotlin 2.2.20, NDK 28.2.
`kotlin.incremental=false` in `android/gradle.properties` avoids a Kotlin cache error when the project and the pub
cache are on different drives (Windows).

### Permissions

* **Android 12+** – *Nearby devices* (Bluetooth scan + connect). Location is **not** required.
* **Android 11 and older** – Location (needed by Android for BLE scanning).
* **iOS** – Bluetooth usage description (`Info.plist`).

### Troubleshooting

| Symptom | Check |
|---|---|
| No devices listed | Allow *Nearby devices*, switch the manikin on, tap the refresh button. On Android ≤ 11 also allow Location and turn Location on. |
| Game never counts | `BLE_SERVICE_UUID` / `BLE_CHARACTERISTIC_UUID` in `.env` match the manikin firmware. |
| VR does not update | The ping badge on the game screen; `VR_BASE_URL` in `.env`; the server must accept `POST` JSON. |
