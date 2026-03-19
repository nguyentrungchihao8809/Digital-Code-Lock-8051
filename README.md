# Digital Code Lock 8051

# Hệ thống Khóa cửa Mật mã Kỹ thuật số (8051-Based Digital Code Lock)

[![Platform: 8051](https://img.shields.io/badge/Platform-8051-blue.svg)](https://en.wikipedia.org/wiki/Intel_MCS-51)
[![Tools: Proteus & KeilC](https://img.shields.io/badge/Tools-Proteus%20%7C%20KeilC-green.svg)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Giới thiệu đề tài
Dự án triển khai hệ thống khóa cửa bảo mật sử dụng vi điều khiển họ **AT89C51**. Hệ thống cho phép người dùng nhập mật mã qua bàn phím ma trận, xác thực và điều khiển chốt cửa (Servo). Điểm nhấn kỹ thuật của dự án là việc quản lý trạng thái bằng **State Machine** và lưu trữ mật mã vĩnh viễn trong **EEPROM**.

## Tính năng chính
- **Xác thực bảo mật:** Nhập mật khẩu qua Keypad 4x4 với chức năng ẩn ký tự.
- **Lưu trữ phi biến:** Sử dụng EEPROM (24C02) để lưu mật mã, không mất dữ liệu khi mất nguồn.
- **Cơ chế chống dò mã:** Tự động khóa hệ thống và phát báo động (Buzzer) sau 3 lần nhập sai.
- **Giao diện trực quan:** Hiển thị hướng dẫn và trạng thái chi tiết trên màn hình LCD 16x2.
- **Điều khiển chính xác:** Sử dụng xung PWM để điều khiển góc quay của Servo Motor (mô phỏng chốt cửa).

## Danh sách linh kiện (Proteus)
| Linh kiện | Keyword | Vai trò |
| :--- | :--- | :--- |
| MCU | `AT89C51` | Trung tâm điều khiển |
| Display | `LM016L` (LCD 16x2) | Hiển thị thông tin giao diện |
| Input | `KEYPAD-SMALLCALC` | Nhập mật mã 4x4 |
| Storage | `24C02` (I2C EEPROM) | Lưu trữ mật mã chủ |
| Actuator | `MOTOR-SERVO` | Cơ cấu chốt cửa vật lý |
| Alert | `BUZZER` | Phát âm thanh cảnh báo |

## Cấu trúc thư mục
```text
/
├── Circuit/          # Chứa file mô phỏng Proteus (.pdsprj)
├── Firmware/         # Mã nguồn Keil C (.c, .h) và file .hex
├── Docs/             # Lưu đồ thuật toán, Datasheet linh kiện
└── Media/            # Hình ảnh sơ đồ và Video demo
