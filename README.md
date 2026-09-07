# IoT Remote Controller (Dieu khien may lanh)

Flutter Phase 1 scaffold: giao dien remote vat ly mo phong, trang thai AC gia lap, registry mau may, thong bao cuc bo, va **thoi tiet ngoai troi that** qua Open-Meteo + GPS.

## Yeu cau

- Flutter SDK (stable) >= 3.35
- Android Studio / Xcode (tuy nen tang chay)

## Chay ung dung

```bash
flutter pub get
flutter run
```

Chay tren Chrome (web):

```bash
flutter run -d chrome
```

Phan tich tinh / test:

```bash
flutter analyze
flutter test
```

## Cau truc thu muc

```
lib/
  main.dart
  presentation/          # UI
    screens/             # Remote + Settings
    widgets/             # Nut 3D, display, icon che do
    theme/
    app_state.dart
  domain/                # Models & contracts
    models/
    services/
  data/                  # Implementations
    models/              # AC model registry stubs
    repositories/        # Simulated AC controller
    services/            # Notifications, alert monitor, weather, location
```

## Thoi tiet ngoai troi (Open-Meteo)

- API mien phi, **khong can API key**: `https://api.open-meteo.com/v1/forecast`
- Lay `temperature_2m` va `relative_humidity_2m` theo lat/lon tu GPS thiet bi
- Bat trong **Cai dat -> Thoi tiet ngoai troi vs setpoint**
- Khi bat: xin quyen vi tri, tai thoi tiet, hien thi tren remote display
- Canh bao cuc bo khi **ngoai troi < setpoint** (va may dang bat)
- Lam moi: keo xuong (pull-to-refresh), nut tren AppBar / Cai dat, hoac dinh ky ~15 phut
- Fallback gia lap `34C` khi tu choi quyen / tat GPS / mat mang

### Quyen nen tang

**Android** (`android/app/src/main/AndroidManifest.xml`):

- `INTERNET`
- `ACCESS_COARSE_LOCATION`
- `ACCESS_FINE_LOCATION`
- `POST_NOTIFICATIONS` (da co)

**iOS** (`ios/Runner/Info.plist`):

- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription` (mo ta; app chi dung when-in-use)

## Phase 1 - da co

- Remote UI doc, nut noi 3D co animation nhan
- Display animated: nhiet do / che do / quat / hen gio / ngoai troi
- Icon che do co chuyen dong theo mode
- State mo phong: nguon, nhiet do, mode, fan, timer
- Registry mau may: Generic + Daikin stub + Panasonic stub
- Cai dat thong bao (`flutter_local_notifications`):
  - May lanh bat qua lau (cau hinh phut)
  - Thoi tiet ngoai troi vs setpoint (Open-Meteo + GPS)
  - Canh bao hen gio bat/tat
  - Nhiet do thap + quat manh qua lau (cau hinh)
- Nhan giao dien tieng Viet; ma/comment tieng Anh
- Thoi gian theo dong ho thiet bi (local time)

## Chua co (cac phase sau)

- Gui lenh IR / MQTT / cloud API that
- Background isolate / WorkManager scheduling ben vung
- Pairing thiet bi IoT

## Package

- org: `com.minhtuanat4`
- name: `iot_remote_controller`
