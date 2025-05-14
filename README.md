# 🔖 Todo With Flutter

A simple todo app built with Flutter and Appwrite

## 🎬 Getting Started

Appwrite is an end-to-end backend server for Web, Mobile, Native, or Backend apps packaged as a set of Docker microservices. Appwrite abstracts the complexity and repetitiveness required to build a modern backend API from scratch and allows you to build secure apps faster.

### 🤘 Install Appwrite

Follow our simple [Installation Guide](https://appwrite.io/docs/installation) to get Appwrite up and running in no time. You can either deploy Appwrite on your local machine or, on any cloud provider of your choice.

```
Note: If you setup Appwrite on your local machine, you will need to create a public IP so that your hosted frontend can access it.
```

We need to make a few configuration changes to your Appwrite server.

1. Add a new Flutter App (Android or iOS or both) in Appwrite:

   ![Console - Add platform](docs/Console%20-%20Add%20platform.png)

   1. Android - `io.appwrite.demo_todo_with_flutter`
   2. iOS/Mac OS - `io.appwrite.demoTodoWithFlutter`

2. Create a project in the Appwrite Console with id `demo-todos`.

3. Use the [Appwrite CLI](https://appwrite.io/docs/command-line) to deploy the required collections.

   ```shell
   appwrite deploy collections
   ```

### 🚀 Run locally

Follow these instructions to run the demo app locally.

```shell
git clone https://github.com/appwrite/demo-todo-with-flutter.git
cd demo-todo-with-flutter
```

Make `lib/constant.dart` using `lib/constants.dart.example` as a template.

Now run the following commands and you should be good to go 💪🏼

```shell
flutter pub get
flutter run
```

### 🛠️ Build, Deploy, and Run

Follow these steps to set up the environment, download the code, and run our project:

#### Prerequisites
Before starting, ensure you have the following installed on your system:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.0 or higher)
  - Follow the official guide to install Flutter for your operating system.
  - Add Flutter to your system's PATH to use the `flutter` command globally.
  - Run the following command to verify the installation:
    ```shell
    flutter doctor
    ```
    Ensure there are no errors in the output.
- [Appwrite](https://appwrite.io/docs/installation) (backend server)
  - Install Appwrite locally or on a cloud provider by following the [Appwrite installation guide](https://appwrite.io/docs/installation).
- [Git](https://git-scm.com/) (for version control)
- [Node.js](https://nodejs.org/) and npm (for managing Appwrite CLI)

#### Download the Project
1. Clone the repository from GitHub:
   ```shell
   git clone https://github.com/supsi-cs-student-projects/C4110Z.1-2025-Team-1
   cd C4110Z.1-2025-Team-1
   ```

#### Install Flutter Dependencies
2. Install the required Flutter dependencies:
   ```shell
   flutter pub get
   ```

#### Configure Appwrite
3. Set up the Appwrite backend:
   - Start the Appwrite server by following the [Appwrite installation guide](https://appwrite.io/docs/installation).
   - Create a new project in the Appwrite console with the ID `demo-todos`.
   - Add Flutter platforms (Android/iOS) with the following IDs:
     - Android: `io.appwrite.demo_todo_with_flutter`
     - iOS: `io.appwrite.demoTodoWithFlutter`
   - Deploy the required collections using the Appwrite CLI:
     ```shell
     appwrite deploy collections
     ```

4. Configure the project:
   - Copy the file `lib/constants.dart.example` to `lib/constants.dart`.
   - Update the file with your Appwrite endpoint and project ID.

#### Running the App
5. Run the app on your local machine:
   ```shell
   flutter run
   ```

#### Building for Production
6. To build the app for production, use the following commands based on your target platform:

- **Android**:
  ```shell
  flutter build apk
  ```
  The APK will be available in the `build/app/outputs/flutter-apk/` directory.

- **iOS**:
  ```shell
  flutter build ios
  ```
  Open the generated Xcode project in the `ios/` directory to deploy.

- **Web**:
  ```shell
  flutter build web
  ```
  The web build will be available in the `build/web/` directory.

- **Windows**:
  ```shell
  flutter build windows
  ```
  The executable will be available in the `build/windows/runner/Release/` directory.

- **MacOS**:
  ```shell
  flutter build macos
  ```
  The app will be available in the `build/macos/Build/Products/Release/` directory.

- **Linux**:
  ```shell
  flutter build linux
  ```
  The executable will be available in the `build/linux/` directory.

#### Deployment
7. Deploy the app to your desired platform or hosting service. For web deployment, upload the contents of the `build/web/` directory to your web server.

## 🤕 Support

If you get stuck anywhere, hop onto one of our [support channels in discord](https://discord.com/invite/GSeTUeA) and we'd be delighted to help you out 🤝
