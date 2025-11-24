# OpenEP4CE6-C FPGA Development Board

Welcome to the official repository for the **OpenEP4CE6-C FPGA Development Board** by Waveshare. This repository contains resources, guides, and example projects for utilizing the **Altera Cyclone IV EP4CE6** chip, making it ideal for FPGA development and peripheral expansion.

## 🚀 Features

- **FPGA Chip**: Altera Cyclone IV EP4CE6
- **Onboard Interfaces**:
  - **I2C**, **SPI**, **UART**
  - **PS/2**, **VGA**, **LCD**, **SD Card**
  - **USB**, **Ethernet**, and more!
- **Pinout and Schematics**: [View Pinout](https://www.waveshare.com/wiki/OpenEP4CE6-C)

---

## 📖 Quick Start

To get started with your OpenEP4CE6-C board:

1. Follow the steps in the user manual to power up and configure the device.
2. Download the example code provided in this repository for immediate testing.

---

## 💡 Example Projects

Here are some exciting projects you can try with the OpenEP4CE6-C FPGA development board:

1. **LED Blink Demo**  
   A simple demo to test the basic functionality of the board by blinking LEDs.
   
2. **Joystick Control**  
   Use the onboard joystick to interact with the FPGA and control a visual or other output.
   
3. **Push Button Interface**  
   A demo using 8 push buttons to send inputs to the FPGA.

4. **7-Segment Display**  
   Display numbers or characters on the 7-segment LED display.

5. **4x4 Keypad Demo**  
   Use a 4x4 keypad to send input to the FPGA and perform actions.

6. **Temperature Sensor Demo**  
   Interface with the **DS18B20** temperature sensor to read and display temperature data.

7. **Buzzer Control**  
   Trigger the onboard buzzer with FPGA logic for audio feedback.

8. **PS/2 Keyboard Interface**  
   Capture input from a **PS/2 keyboard** and display or use it in your project.

9. **VGA Display Demo**  
   Connect to a VGA monitor to display graphics or text from the FPGA.

10. **LCD1602 & LCD12864 Demos**  
   Display text or graphics on **LCD1602** or **LCD12864** screens.

11. **USB Communication**  
   Set up USB communication for data transfer between your FPGA and external USB devices.

12. **SD Card Interface**  
   Read and write data from an SD card using the FPGA.

13. **Ethernet Control**  
   Send and receive data over Ethernet for networked FPGA projects.

14. **I2C EEPROM Interface**  
   Use **I2C** to read from and write to an EEPROM for simple data storage.

---

## 🔧 Resources

- **User Manual**: [OpenEP4CE6-C User Manual](https://www.waveshare.com/wiki/OpenEP4CE6-C_User_Manual)
- **Pinout Diagram & Schematics**: [OpenEP4CE6-C Schematics](https://www.waveshare.com/wiki/OpenEP4CE6-C)
- **Datasheets**: Available on the [product wiki](https://www.waveshare.com/wiki/OpenEP4CE6-C)

---

## 📑 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

## 🛠️ Contributing

We welcome contributions to this project! If you'd like to contribute:

1. Fork the repository.
2. Create a new branch for your feature or fix.
3. Commit your changes and push them to your fork.
4. Create a pull request to the main repository.

Please make sure your code follows the project style guide and passes the basic tests before submitting a pull request.

---

## ⚡ Support

If you encounter issues or need help with setup, feel free to reach out:

- **Waveshare Support Portal**: [Submit a Ticket](https://service.waveshare.com)
- **Support Hours**: Monday - Friday, 9 AM - 6 PM GMT+8

# 💡 Example Projects – Реальный статус выполнения

Ниже приведён полный список примеров для платы **OpenEP4CE6-C**, с честной отметкой их состояния.

### 🟢 Легенда:

* ✔️ — **Полностью выполнено**
* ❓ — **Частично / обсуждалось**
* ❌ — **Не выполнялось**
* ➕ — **Планируется добавить / легко реализовать**

---

## ✔️ Выполненные и оформленные примеры (14/19)

### ✔️ **1. LED Blink Demo**

Простой рабочий пример + полная документация.

### ✔️ **2. 8 Push Buttons / Joystick Demo**

Переделано под 8 кнопок, исправлены ошибки, оформлено.

### ✔️ **3. Push Button Interface**

Полностью реализовано.

### ✔️ **4. 7-Segment Display (4-digit)**

Рабочий мультиплексор, декодер, документация.

### ✔️ **5. External 8-SEG LED Board**

Готовый пример + README.

### ✔️ **6. 4×4 Keypad Demo**

Код прокомментирован, готовый пример.

### ✔️ **7. Buzzer (FMQ) Demo**

Работает, всё оформлено.

### ✔️ **8. VGA Display Demo**

Объяснены тайминги, PLL, поведение на HD-мониторе.

### ✔️ **9. LCD1602 Demo**

Полностью переписанная и документированная версия.

### ✔️ **10. LCD12864 Demo**

FSM разобран, пример оформлен.

### ✔️ **11. I2C EEPROM AT24CXX**

Полностью восстановлен и прокомментирован китайский код.
Работающий пример с записью и чтением.

### ✔️ **12. Extra 8-SEG LED Board (внутренний модуль)**

Полностью оформлено.

### ✔️ **13. Enhanced Buttons / Joystick Example**

Добавлено объяснение конструкций Verilog.

### ✔️ **14. Полная документация по структуре Quartus проекта**

Описаны файлы `.v`, `.qsf`, `.qpf`, `.sof`, `.pof`, `.jdi`, папки `db/`, `incremental_db/`, `.qsys_edit/`.

---

## ❓ Частично сделано / обсуждалось

### ❓ **15. DS18B20 Temperature Sensor**

Только обсуждали — кода нет.

### ❓ **16. PS/2 Keyboard Interface**

Есть обсуждение — пример не сделан.

---

## ❌ Не выполнялось (но возможно)

### ❌ **17. USB Communication**

Не реализовывали (требует внешнего IP-ядра).

### ❌ **18. SD Card (SPI + FAT)**

Не делали (нужен FAT-парсер).

### ❌ **19. Ethernet (MAC/PHY)**

Не выполнялось (сложный стек).

---

## ➕ Планируется добавить (или можно сделать при необходимости)

### ➕ **DS18B20 Temp Sensor (One-Wire)**

Лёгкий в реализации, простая FSM.

### ➕ **PS/2 Keyboard**

Можно реализовать с простым сдвиговым регистром (11-битные фреймы).

### ➕ **SD Card (SPI)**

Можно начать с режима RAW-секторов.

### ➕ **UART (RX/TX)**

Полноценный учебный пример.

### ➕ **PWM / Servo control**

Популярный пример, легко добавить.

### ➕ **SPI Flash / W25Q64**

Тоже популярный учебный модуль.

---

# 📊 Таблица статусов

| №  | Проект                | Статус |
| -- | --------------------- | ------ |
| 1  | LED Blink             | ✔️     |
| 2  | 8 Buttons / Joystick  | ✔️     |
| 3  | Push Button Interface | ✔️     |
| 4  | 7-Segment (4-digit)   | ✔️     |
| 5  | External 8-SEG        | ✔️     |
| 6  | 4×4 Keypad            | ✔️     |
| 7  | Buzzer                | ✔️     |
| 8  | VGA                   | ✔️     |
| 9  | LCD1602               | ✔️     |
| 10 | LCD12864              | ✔️     |
| 11 | I2C EEPROM (AT24CXX)  | ✔️     |
| 12 | Extra 8-SEG           | ✔️     |
| 13 | Enhanced Buttons Demo | ✔️     |
| 14 | Документация Quartus  | ✔️     |
| 15 | DS18B20               | ❓ / ➕  |
| 16 | PS/2 Keyboard         | ❓ / ➕  |
| 17 | USB                   | ❌      |
| 18 | SD Card               | ❌      |
| 19 | Ethernet              | ❌      |

---
