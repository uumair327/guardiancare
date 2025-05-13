<p align="center">  
  <a href="https://github.com/uumair327/guardiancare/releases">
    <img width="240" height="240" alt="GuardianCare" src="https://github.com/user-attachments/assets/cb305108-c53e-4d9f-914a-7179fee18654">
  </a>
</p>
<h1 align="center">GuardianCare</h1> <br>
<h3 align="center">Helping to make every step forward a leap towards a brighter and safer future for children.</h3>

<p align="center">
  A Flutter-based cross-platform mobile application that provides resources, reporting mechanisms, and support to combat online sexual exploitation of children.
</p>

<p align="center">
    <br />
   <a href="https://github.com/uumair327/guardiancare/releases/download/guardiancare/app-release.apk">Download APK</a>
    ·
    <a href="https://github.com/uumair327/guardiancare/issues">Report Bug / Request Feature</a> 
   - 
   <a href="https://appdistribution.firebase.dev/i/2dc0d93759150b3f">Click here to become a tester</a> 
</p>

<br>

## Overview

GuardianCare is a mobile application aimed at educating and protecting children from online sexual exploitation. The app provides educational content, reporting mechanisms, and a support forum for both parents and children.

### Key Features

- **Educational Content**: Information on the risks of online sexual exploitation, warning signs, and preventive measures.
- **Reporting Mechanism**: Direct links to hotlines, emergency contact information, and anonymous reporting options.
- **Support Forum**: A safe space for children to communicate with volunteers and peers about online safety issues.

### Problem Statement

Online sexual exploitation of children is a significant and growing concern. There is a need for accessible tools that provide education, reporting mechanisms, and support to combat this issue effectively.

### Solution

GuardianCare offers a comprehensive mobile application with educational resources, direct reporting links to child protection agencies, and a moderated forum for support. This helps both parents and children stay informed and connected to essential services.

### Impact

The app aims to centralize critical information and resources, empowering communities to protect children from online sexual exploitation. By providing easy access to help and support, GuardianCare enhances the safety and well-being of children online.

### Architecture

The app features a user-friendly design with secure login, multimedia educational content, real-time reporting capabilities, and a moderated forum for support. The backend utilizes Firebase for authentication, real-time database management, and secure data storage.

## Web Deployment

GuardianCare can be deployed as a web application to GitHub Pages. Here's how to deploy it:

### Prerequisites

- Flutter SDK (with web support enabled)
- GitHub account
- Firebase project with Web app configured

### Deployment Steps

1. **Build the web version**:
   ```bash
   flutter build web --release --base-href "/guardiancare/"
   ```

2. **Deploy to GitHub Pages**:
   - Push your code to a GitHub repository
   - Go to the repository Settings > Pages
   - Set the source to deploy from the `gh-pages` branch
   - Set the folder to `/ (root)`

3. **Configure Firebase for Web**:
   - Add your web app in Firebase Console
   - Update the Firebase configuration in `web/index.html`
   - Enable Google Sign-In in the Firebase Console

4. **Custom Domain (Optional)**:
   - Add a `CNAME` file in the `web` directory with your domain
   - Configure your domain's DNS settings to point to GitHub Pages

### Development

To run the web version locally:

```bash
flutter run -d chrome --web-hostname localhost --web-port 3000
```

### Technology Stack

- **Frontend**: Flutter
- **Backend**: Firebase (Authentication, Firestore, Cloud Functions, Crashlytics)

### Future Steps

**Potential Scaling**:

- Direct integration with government and non-governmental organizations (NGOs) for broader outreach.
- Advanced AI models for more sophisticated content filtering and reporting mechanisms.

### Scaling

To scale further, we plan to keep the user interface minimal, implement automation for faster build and release cycles, and ensure accessibility across all devices.

## Getting Started

### Prerequisites

To run the GuardianCare app, you need to configure the environment on your machine. Follow the tutorial provided by Google on the [Flutter website](https://flutter.dev/docs/get-started/install).

- Flutter SDK
- Android Studio (to download Android SDK) [Installation Guide](https://developer.android.com/studio/install)
- Xcode (for iOS development)
- Any IDE with Flutter SDK installed (e.g., IntelliJ, Android Studio, VSCode)

### Flutter

- Clone the repository:

  ```bash
  git clone https://github.com/uumair327/guardiancare.git
  cd guardiancare

  ```

- Install dependencies:
  ```bash
  flutter pub get
  ```
- Run the app:
  ```bash
  flutter run
  ```
- for iOS Simulator (optional):
  ```bash
  open -a simulator
  ```
- to see the Web Output
  ```bash
  flutter run -d chrome --web-renderer html
  ```

<!-- FIREBASE -->

## Firebase

### Firestore Databases

- **users**: Stores user details.

- **forum**: Stores details about individual forum posts.

  - **comments**: Stores details about each individual comment on a forum post.

- **quizes**: Stores names and thumbnail references of all available quizes.

- **questions**: Stores questions, their options, correct option, category and the quiz they belong to.

- **videos**: Stores the titles, categories, thumbnail references and video references for all videos.

- **recommendations**: Stores the details of the videos recommended to users based on their quiz performance.

- **home_images**: Stores references of the images used on the home page.

- **learn**: Stores names and thumbnail references of all available video categories.

### Storage

- **carousel_images**: Stores images to be displayed on the carousel on the home page.

- **learn_thumbnails**: Stores image thumbnails for learn cards.

- **quiz_thumbnails**: Stores image thumbnails for quiz cards.

### Authentication

#### Methods

- Email/Password
- Google
- Anonymous

<!-- SCREENSHOTS -->

## Screenshots of Application [APK]

### Home and Explore Pages

|                                                                                               Home Page                                                                                               |                                                                                                Explore Page                                                                                                 |
| :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| <img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FhomePage.jpg?alt=media&token=8fbcd6eb-69dd-4907-8f68-557f3b20da07" alt="Home Page" width="240"/> | <img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FexplorePage.jpg?alt=media&token=4bef8770-a96b-4e84-9104-071a68fb6367" alt="Explore Page" width="240"/> |

### Forum Page

|                                                                                              Forum Page 1                                                                                               |                                                                                                Forum Page 2                                                                                                |                                                                                                Forum Page 3                                                                                                |
| :-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| <img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FforumPage.jpg?alt=media&token=088b74dd-97d0-4928-af77-10447ed33b24" alt="Forum Page" width="240"/> | <img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FforumPage2.jpg?alt=media&token=bb99b3bb-2cea-4aea-ab3f-a85ab2c96a16" alt="Forum Page 2" width="240"/> | <img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FforumPage3.jpg?alt=media&token=1155cf11-c328-408f-a0b7-4c15619a2747" alt="Forum Page 3" width="240"/> |

### Learn Page

|                                                                                              Learn Page 1                                                                                               |                                                                                                Learn Page 2                                                                                                |                                                                                                Learn Page 3                                                                                                |
| :-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| <img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FlearnPage.jpg?alt=media&token=48e1f85e-04e7-45bb-a2f2-cbc13a86f1cc" alt="Learn Page" width="240"/> | <img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FlearnPage2.jpg?alt=media&token=2f749f94-a9e4-48c9-b299-975ff5b479b3" alt="Learn Page 2" width="240"/> | <img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FlearnPage3.jpg?alt=media&token=c8ed5821-c1bf-4b5d-83e3-d5b1a03b55cf" alt="Learn Page 3" width="240"/> |

### Quiz Page

|                                                                                              Quiz Page 1                                                                                              |                                                                                               Quiz Page 2                                                                                                |
| :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| <img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FquizPage.jpg?alt=media&token=354061bd-7c48-4de6-beb9-11ddaacbc85e" alt="Quiz Page" width="240"/> | <img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FquizPage2.jpg?alt=media&token=7f46c41f-8373-4196-be1c-00c79a58d60b" alt="Quiz Page 2" width="240"/> |

### Emergency Page

|                                                                                                 Emergency Page                                                                                                  |
| :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| <img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FemergencyPage.jpg?alt=media&token=bc2f536c-fedd-4416-a058-19b3e349dd84" alt="Emergency Page" width="240"/> |

### Profile Page

|                                                                                                Profile Page                                                                                                 |
| :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| <img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FprofilePage.jpg?alt=media&token=4f1d2e28-5af5-4a5e-a3c4-a1d2ec04a176" alt="Profile Page" width="240"/> |

### Web View

|                                                                                              Web View                                                                                               |
| :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| <img src="https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/screenshots%2FwebPage.jpg?alt=media&token=6a9e63c1-fe94-4625-98c6-fe613e59aad1" alt="Web View" width="240"/> |

## Testing and Feedback

We value your input and strive to make our app the best it can be. If you're interested in helping us test new features and provide feedback, we invite you to join our list of testers.

By becoming a tester, you'll get the opportunity to experience beta testing and try out upcoming features before they're released to the public. Meanwhile, stable releases can be found in the [Releases section](https://github.com/uumair327/guardiancare/releases/tag/Stable) . You can also contribute by building the app locally and testing specific functionalities to help us find and fix bugs. Alternatively, you can join our testing app group to access beta releases and provide [feedback directly](https://github.com/uumair327/guardiancare/issues).

To join our testing program, click [here](https://appdistribution.firebase.dev/i/2dc0d93759150b3f) and become a part of shaping the future of our app!

## License

This project is licensed under the [MIT License](./LICENSE).

## Acknowledgments

We appreciate the support from the open-source community and look forward to making a positive impact together.
