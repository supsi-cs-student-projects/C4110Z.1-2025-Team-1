# **Third-party code/resources**
The project doesn't use directly any third-party code. It relies only on Flutter's libraries. However it was created starting from the project: https://github.com/appwrite/demo-todo-with-flutter. \
All the assets used in the app, that means all the visual part, is entirely designed by our team.
# **Outline of the file structure and dependencies**
As said before the project uses Flutter framework. All the required libraries and dependecies are listed in the [pubspec](pubspec.yaml) file.\
All the code is in the *lib* directory. This is its structure:
```
.
├── constants.dart
├── constants.dart.example
├── entities
│   ├── streak.dart
│   └── user.dart
├── l10n
│   ├── app_en.arb
│   └── app_it.arb
├── main.dart
├── routes
│   ├── account_page.dart
│   ├── Authentication
│   │   ├── LoginPage.dart
│   │   └── RegisterPage.dart
│   ├── Game
│   │   ├── Alcohol.dart
│   │   └── higher_or_lower.dart
│   ├── homepage.dart
│   └── StreakPage.dart
├── services
│   ├── appwrite.dart
│   ├── auth.dart
│   ├── CustomButton.dart
│   ├── GameService.dart
│   ├── localeProvider.dart
│   ├── MilestoneManager.dart
│   └── streak.dart
└── utilities.dart
```
**entities** contains the models used in the project. Those are classes used only to store the data and the behaviour of some components of the app.\
**l10n** contains the files with the translation of the app, both in English and in Italian.\
**routes** contains the actual widgets displayed in the app.\
**services** contains the code that manages the logic of various app behaviors.\
The app uses Appwrite for storing all the data.
# **Setting up online services and database**
In order to connect an external personal databes to this project the [constans](/lib/constants.dart) file needs to be changed with the updated Appwrite database settings.\
Collections used in the project are the following:
- games
   - higherLower (Integer)
   - xp (Integer)
   - milestones (Integer[])
- streak
   - streak (Integer)
   - updated_at (Datetime)
