# IoT Remote Controller (Điều khiển máy lạnh)

Flutter app: giao diện remote vật lý mô phỏng, trạng thái AC, registry hãng Việt Nam, thông báo cục bộ, **thời tiết ngoài trời (Open-Meteo + GPS)**, và lớp **IR Blaster** (mã hóa lệnh IR theo hãng).

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

Phân tích tĩnh / unit test:

```bash
flutter analyze
flutter test
```

## Cấu trúc thư mục

```
lib/
  main.dart
  presentation/          # UI
    screens/             # Remote + Settings
    widgets/
    theme/
    app_state.dart
  domain/                # Models & contracts
    models/              # AcState, AcTransportKind, IrFrame, …
    services/            # AcController, IrTransmitter, AcIrEncoder
  data/
    ir/                  # Pulse builder + brand encoders
      encoders/          # Daikin, Panasonic, LG, Gree(Casper/Funiki)
    models/              # AC model registry
    repositories/        # Simulated + IrBlaster controllers
    services/            # Local notifications + alert monitor
```

## Phase 1 — đã có

- Remote UI dọc, nút nổi 3D có animation nhấn
- Display animated: nhiệt độ / chế độ / quạt / hẹn giờ
- State mô phỏng: nguồn, nhiệt độ, mode, fan, timer
- Registry mẫu máy VN: Generic, Daikin, Panasonic, LG, Casper, Funiki
- Cài đặt thông báo (`flutter_local_notifications`)
- Nhãn giao diện tiếng Việt; mã/comment tiếng Anh

## IR Blaster (thị trường máy lạnh Việt Nam)

### Cách hoạt động

1. Chọn **Kênh gửi lệnh** trong Cài đặt:
   - **Mô phỏng (không IR)** — chỉ cập nhật UI (giữ nguyên Phase 1).
   - **IR Blaster** — mỗi nút remote cập nhật state **và** mã hóa khung IR.
2. Chọn **Hãng / giao thức IR** (nhãn tiếng Việt): Daikin, Panasonic, LG, Casper, Funiki.
3. Bộ phát hiện tại là **IR giả lập (log)** (`LoggingIrTransmitter`): in khung xung ra console / lưu history — chưa cần phần cứng.

### Hãng & giao thức

| Hãng (VN) | Protocol id   | Nguồn tham chiếu (IRremoteESP8266 / cộng đồng) |
|-----------|---------------|--------------------------------------------------|
| Daikin    | `daikin216`   | `IRDaikin216` — 216-bit, 2 section               |
| Panasonic | `panasonic_ac`| `IRPanasonicAc` — 216-bit / 27 byte              |
| LG        | `lg_ac`       | `IRLgAc` — 28-bit NEC-like                       |
| Casper    | `gree`        | `IRGreeAC` — OEM Gree (phổ biến VN)              |
| Funiki    | `gree`        | `IRGreeAC` — OEM Gree, model nibble khác Casper  |

Encoder comments trích dẫn file nguồn trên [IRremoteESP8266](https://github.com/crankyoldgit/IRremoteESP8266). Timing/bit layout là bản rút gọn đủ ổn định cho unit test và gắn hardware sau; cần calibrate theo model cụ thể khi có blaster thật.

### Kiểm thử không cần blaster

```bash
# Unit test encoder + IrBlaster controller
flutter test test/ir/ir_encoder_test.dart

# Chạy app → Cài đặt → IR Blaster → chọn hãng → bấm Nguồn/°C
# Xem log: [IrTransmitter/logging] IrFrame(...)
# Settings cũng hiện tóm tắt khung IR gần nhất
```

### Bước tiếp theo (hardware)

- **Broadlink RM mini / RM4**: gửi `timingsUs` qua LAN API (raw IR).
- **ESP8266 / ESP32 + IRremoteESP8266**: nhận payload hex hoặc raw µs qua MQTT/HTTP, `sendRaw`.
- **Điện thoại có IR blaster**: Flutter platform channel / plugin phát carrier + pulse train.
- Hook sẵn: implement `IrTransmitter` mới, inject vào `AppState` / registry — không đổi encoder.


## Thời tiết ngoài trời (Open-Meteo)

- API miễn phí, **không cần API key**: `https://api.open-meteo.com/v1/forecast`
- Lấy `temperature_2m` và `relative_humidity_2m` theo lat/lon từ GPS thiết bị
- Bật trong **Cài đặt → Thời tiết ngoài trời vs setpoint**
- Khi bật: xin quyền vị trí, tải thời tiết, hiển thị trên remote display
- Cảnh báo cục bộ khi **ngoài trời < setpoint** (và máy đang bật)
- Làm mới: kéo xuống (pull-to-refresh), nút trên AppBar / Cài đặt, hoặc định kỳ ~15 phút
- Fallback giả lập `34°C` khi từ chối quyền / tắt GPS / mất mạng

### Quyền nền tảng (thời tiết)

**Android**: `INTERNET`, `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION`, `POST_NOTIFICATIONS`

**iOS**: `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`

## Package

- org: `com.minhtuanat4`
- name: `iot_remote_controller`
