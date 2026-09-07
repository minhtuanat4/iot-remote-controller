# IoT Remote Controller (Điều khiển máy lạnh)

Flutter Phase 1 scaffold: giao diện remote vật lý mô phỏng, trạng thái AC giả lập, registry mẫu máy, và cài đặt thông báo cục bộ.

## Yêu cầu

- Flutter SDK (stable) ≥ 3.35
- Android Studio / Xcode (tùy nền tảng chạy)

## Chạy ứng dụng

```bash
flutter pub get
flutter run
```

Chạy trên Chrome (web):

```bash
flutter run -d chrome
```

Phân tích tĩnh:

```bash
flutter analyze
```

## Cấu trúc thư mục

```
lib/
  main.dart
  presentation/          # UI
    screens/             # Remote + Settings
    widgets/             # Nút 3D, display, icon chế độ
    theme/
    app_state.dart
  domain/                # Models & contracts
    models/
    services/
  data/                  # Implementations
    models/              # AC model registry stubs
    repositories/        # Simulated AC controller
    services/            # Local notifications + alert monitor
```

## Phase 1 — đã có

- Remote UI dọc, nút nổi 3D có animation nhấn
- Display animated: nhiệt độ / chế độ / quạt / hẹn giờ
- Icon chế độ có chuyển động theo mode
- State mô phỏng: nguồn, nhiệt độ, mode, fan, timer
- Registry mẫu máy: Generic + Daikin stub + Panasonic stub
- Cài đặt thông báo (`flutter_local_notifications`):
  - Máy lạnh bật quá lâu (cấu hình phút)
  - Thời tiết ngoài trời vs setpoint (stub)
  - Cảnh báo hẹn giờ bật/tắt
  - Nhiệt độ thấp + quạt mạnh quá lâu (cấu hình)
- Nhãn giao diện tiếng Việt; mã/comment tiếng Anh
- Thời gian theo đồng hồ thiết bị (local time)

## Chưa có (các phase sau)

- Gửi lệnh IR / MQTT / cloud API thật
- API thời tiết thật
- Background isolate / WorkManager scheduling bền vững
- Pairing thiết bị IoT

## Package

- org: `com.minhtuanat4`
- name: `iot_remote_controller`
