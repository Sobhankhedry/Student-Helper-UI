# 🎓 Student Helper UI

A Flutter-based mobile application for helping university students manage and access their academic schedules.

The application provides a simple Persian-language interface for students and professors to log in, register, and access academic information such as weekly schedules, term courses, course schedules, and examination schedules.

## 🚀 Overview

**Student Helper UI** is the Flutter frontend for the Student Helper application.

The application communicates with a custom **ASP.NET Core Web API** backend to retrieve and manage academic data.

The project was designed with a focus on:

* Simple user experience
* Persian / RTL interface
* Student and professor roles
* Academic schedule management
* Backend API integration

## ✨ Features

### 🔐 Authentication

* User login
* User registration
* Username and password validation
* Student / professor role selection
* University selection
* Major selection
* Password confirmation

### 📅 Academic Schedule

The dashboard provides access to:

* Weekly schedule
* Term schedule
* Course schedule
* Examination schedule

### 👨‍🎓 User Roles

The application supports two main roles:

* **Student**
* **Professor**

The available academic information is adjusted according to the user's role.

### 🌍 Persian / RTL UI

The application is designed primarily for Persian-speaking users and includes:

* Persian UI text
* Right-to-left layouts
* Persian **Vazir** font
* Persian form fields and dropdowns

## 🛠️ Tech Stack

| Technology      | Purpose                     |
| --------------- | --------------------------- |
| **Flutter**     | Cross-platform UI framework |
| **Dart**        | Programming language        |
| **Material UI** | Application UI              |
| **HTTP**        | REST API communication      |
| **JSON**        | Data serialization          |
| **Vazir Font**  | Persian typography          |

The project uses the Dart HTTP package for communication with the backend API.

## 📱 Application Screens

The application currently contains several main screens:

```text
Login
  │
  ├── Register
  │
  ▼
Dashboard
  │
  ├── Weekly Schedule
  │
  ├── Term Schedule
  │
  ├── Course Schedule
  │
  └── Examination Schedule
```

The Flutter project contains dedicated pages for login, registration, dashboard, weekly schedule, term schedule, course schedule, and exam schedule.

## 📁 Project Structure

```text
Student-Helper-UI/
│
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
│
├── assets/
│   └── fonts/
│       └── Vazirmatn/
│
├── lib/
│   │
│   ├── models/
│   │   ├── Course.dart
│   │   ├── User.dart
│   │   └── LoginRequest.dart
│   │
│   ├── services/
│   │   └── api_services.dart
│   │
│   ├── login_page.dart
│   ├── register_page.dart
│   ├── dashboard_page.dart
│   ├── weekly_schedule_page.dart
│   ├── term_schedule_page.dart
│   ├── course_schedule_page.dart
│   ├── exam_schedule_page.dart
│   └── main.dart
│
├── test/
├── pubspec.yaml
└── README.md
```

## 🔌 Backend Integration

The application communicates with the Student Helper ASP.NET Core API through the `ApiService` class.

The API client currently provides methods for:

```text
signUp()
login()
fetchSchedule()
fetchExam()
fetchWeekly()
fetchScheduleByCourseIds()
```

These methods communicate with the backend using HTTP POST requests and JSON payloads.

### Backend Repository

The corresponding backend API is available here:

https://github.com/Sobhankhedry/student-helper-api

## 🔄 Application Architecture

```text
┌─────────────────────────────┐
│       Flutter UI            │
│                             │
│  Login / Register           │
│  Dashboard                  │
│  Schedules                  │
│  Exam Schedule              │
└──────────────┬──────────────┘
               │
               │ HTTP / JSON
               ▼
┌─────────────────────────────┐
│    ASP.NET Core Web API     │
│                             │
│    UsersController          │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       SQL Server            │
└─────────────────────────────┘
```

## ⚙️ Getting Started

### Prerequisites

Install:

* Flutter SDK
* Dart SDK
* Android Studio or another Flutter-compatible IDE
* Android Emulator / physical device

### Clone the repository

```bash
git clone https://github.com/Sobhankhedry/Student-Helper-UI.git
cd Student-Helper-UI
```

### Install dependencies

```bash
flutter pub get
```

### Run the application

```bash
flutter run
```

You can also run the project on a specific platform:

```bash
flutter run -d chrome
```

or:

```bash
flutter run -d windows
```

depending on your Flutter environment.

## 🔗 Backend Configuration

The API base URL is configured inside:

```text
lib/services/api_services.dart
```

The current development configuration uses:

```text
http://10.0.2.2:7007/api/Users
```

`10.0.2.2` is commonly used by Android emulators to access the host machine's localhost.

For a physical device or production environment, the API URL should be changed to the appropriate backend address.

## 🧪 Testing

Flutter's test directory is included in the project.

Run tests with:

```bash
flutter test
```

## 📦 Build

### Android

```bash
flutter build apk
```

### Web

```bash
flutter build web
```

### Windows

```bash
flutter build windows
```

The available targets depend on the Flutter environment and platform configuration.

## 🚧 Current Limitations

This project is currently a learning/academic project and can be improved significantly for production use.

Potential improvements include:

* [ ] Secure token-based authentication
* [ ] Persistent authentication state
* [ ] Secure local storage
* [ ] Better state management
* [ ] Repository pattern for API communication
* [ ] Centralized API error handling
* [ ] Loading and empty states
* [ ] Offline support
* [ ] Improved form validation
* [ ] Unit and widget tests
* [ ] Environment-based API configuration
* [ ] Production API configuration
* [ ] Improved UI/UX
* [ ] App deployment

## 🎯 Learning Goals

This project was created to practice:

* Flutter development
* Dart
* Cross-platform application development
* REST API integration
* HTTP requests
* JSON serialization
* Client/server architecture
* Persian RTL UI development
* Authentication flows
* Consuming ASP.NET Core APIs

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

**Sobhan Khedry**

GitHub:
https://github.com/Sobhankhedry
