# OutReach

A reactive mobile app that enables OutReach clients to view their contacts
on the go.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Build environment

To install the flutter SDK on various operating systems you can checkout the links below.
These links will also provide instructions for installing the Android SDK.

* [Windows](https://flutter.io/setup-windows/)
* [MacOS](https://flutter.io/setup-macos/)
* [Linux](https://flutter.io/setup-linux/)

### Prerequisites

To build our app in your environment you will need to install...

```
Flutter
Android SDK (For android development)
XCode (For iOS development, only available on macOS)
VSCode or Android Studio
```

### Add flutter to your path

Adding flutter to your path will enable you to run flutter commands with the CLI. Below is the documentation on how to do this for various operating systems.

* [Windows](https://flutter.io/setup-windows/#update-your-path)
* [MacOS](https://flutter.io/setup-macos/#update-your-path)
* [Linux](https://flutter.io/setup-linux/#update-your-path)

#### IDE Setup

The following links show you how to setup either Android Studio or VS Code to interact with Flutter

* [Android Studio](https://flutter.io/using-ide/)
* [VS Code](https://flutter.io/using-ide-vscode/)

#### Android SDK Installation

If you want to install the SDK platform tools only without downloading Android Studio you can do in
the command line tools only section [here](https://developer.android.com/studio/#downloads).

### Installing the application

Once you have installed flutter and successfuly setup your flutter environment you can run our 
app in the CLI. These commands will work regardless of your environment.

#### Local installation

If you already have the directory on your device just open the CLI and change into the project directory.
Then follow the steps after the repository is cloned.

#### Installing from remote

Open the CLI and change into the directory you wish to work in.
Then run the following command

```
git clone https://isgb.otago.ac.nz/info301/git/301/outreach.git
```

Then change into the directory of the repository and run

```
flutter packages get
```

Followed by

```
flutter doctor
```

If flutter doctor is satistifed with your environment you can run our application on an attached mobile device using the following command in the CLI. In a successful build the CLI will then prompt you with other commands such as hot reloading and so on.

```
flutter run
```

### Releasing

The following details how to create an app release for Android and iOS. Detailed documentation for each platform can be found at these links.

* [android](https://flutter.io/android-release/)
* [iOS](https://flutter.io/ios-release/)

#### Android

To build a release for android run the following command in the project directory

```
flutter build apk
```

#### iOS

To build a release for iOS run the following command in the project directory

```
flutter build ios
```

## Authors

* **Aaron Anderson**
* **Ben Dobbe**
* **James Yee**
* **Sam Kerridge**
* **Callum Crawford**
* **John Poulgrain**

## Acknowledgments

* Sherlock Licorish
* Stack Overflow
* The OutReach team