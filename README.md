# Quản Lý Phiếu Nhập Kho (Form 01-VT)

Dự án bài test tuyển dụng **Quản Lý Phiếu Nhập Kho** (mẫu Form 01-VT) bao gồm 2 phần độc lập: **Backend REST API** và **Flutter Mobile Frontend**.

---

## 📁 Cấu Trúc Thư Mục Hệ Thống

```
.
├── backend/                  # RESTful API Backend Service
│   ├── src/                  # Mã nguồn TypeScript (Route, Controller, Service, Repository)
│   ├── database/             # File schema.sql CSDL PostgreSQL Neon
│   ├── docs/                 # Tài liệu API.md và DATABASE.md
│   ├── tests/                # Jest Unit & Integration Test Suite
│   ├── package.json          # Node.js dependencies & scripts
│   ├── tsconfig.json         # TypeScript configuration
│   ├── jest.config.js        # Jest configuration
│   └── .env                  # Biến môi trường CSDL & Port
│
└── mobile/                   # Flutter Mobile Frontend Application
    ├── lib/                  # Mã nguồn Flutter Dart (Core, Data, Features, Screens, Providers)
    ├── test/                 # Flutter Unit & Widget Test Suite
    ├── ios/                  # Cấu hình dự án iOS (Xcode)
    ├── android/              # Cấu hình dự án Android (Gradle)
    ├── pubspec.yaml          # Flutter dependencies
    └── .env                  # Cấu hình API_BASE_URL cho Flutter
```

---

## 🚀 1. Hướng Dẫn Chạy Backend (`backend/`)

1. **Di chuyển vào thư mục backend**:
   ```bash
   cd backend
   ```

2. **Cài đặt thư viện**:
   ```bash
   npm install
   ```

3. **Khởi tạo bảng trên Neon PostgreSQL (Migration)**:
   ```bash
   npm run db:migrate
   ```

4. **Chạy Development Server (Auto reload)**:
   ```bash
   npm run dev
   ```

5. **Build & Test**:
   ```bash
   npm run build
   npm test
   ```

👉 **Swagger UI Interface**: [http://localhost:3000/swagger](http://localhost:3000/swagger)

---

## 📱 2. Hướng Dẫn Chạy Flutter Mobile (`mobile/`)

1. **Di chuyển vào thư mục mobile**:
   ```bash
   cd mobile
   ```

2. **Tải các gói dependencies**:
   ```bash
   flutter pub get
   ```

3. **Kiểm tra chất lượng code (Analyze)**:
   ```bash
   flutter analyze
   ```

4. **Chạy tất cả Unit & Widget Test**:
   ```bash
   flutter test
   ```

5. **Khởi chạy trên iOS Simulator**:
   ```bash
   flutter run -d iphone
   ```
