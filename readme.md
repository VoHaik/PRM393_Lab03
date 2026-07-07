# Journal Trend Analyzer

An academic analytics and publication trend analysis mobile application built with **Flutter and Dart**, powered dynamically by the **OpenAlex API**.

---

## 📖 Table of Contents
1. [🌟 Project Overview (For Everyone)](#-project-overview-for-everyone)
2. [🚀 How to Get Started (Start Source)](#-how-to-get-started-start-source)
3. [📁 Folder & Project Architecture (For Developers)](#-folder--project-architecture-for-developers)
4. [🛠️ Extension Guide: How to Add Features](#-extension-guide-how-to-add-features)
5. [🧩 Module Deep Dive & Business Rules](#-module-deep-dive--business-rules)
6. [💡 Technical Highlights & Caching](#-technical-highlights--caching)

---

## 🌟 Project Overview (For Everyone)

### What is Journal Trend Analyzer?
Research publications are growing extremely fast, making it difficult for researchers, students, and academic administrators to spot emerging trends, identify top experts, or find the most influential journals. 

This app is a **scholarly search engine and analytical dashboard** combined. When you type in a topic (e.g., *Artificial Intelligence* or *Cybersecurity*), the app dynamically retrieves real-time data from **OpenAlex** (a global database containing over 250M+ scholarly works) and outputs:
- **Timeline Analytics**: Interactive charts showing the growth or decline of publication volumes over the years.
- **Top Entities**: Lists of top contributing authors (by paper volume) and top journals publishing on that topic.
- **Key Summary Metrics**: Dashboard highlighting total publications, average citation rates, peak research years, and the most cited (influential) paper.

### Who is this for?
*   **Non-IT Users / Researchers**: Easily explore the landscape of a new research area and find key authors or papers without running database queries.
*   **Frontend/Backend Developers**: A clean, scalable, offline-cached mobile framework ready to be expanded or integrated.

---

## 🚀 How to Get Started (Start Source)

Follow these simple steps to set up and run the source base on your machine.

### Prerequisites (What you need installed)
1.  **Flutter SDK** (version `3.0.0` or higher). [Install Flutter Guide](https://docs.flutter.dev/get-started/install).
2.  **Android Studio** or **VS Code** (with Flutter & Dart extensions installed).
3.  An **Android Emulator** running, or a physical Android device connected in Developer Mode.

### Setup Steps
1.  **Open the project** in your IDE of choice.
2.  **Configure Polite Pool (Optional but highly recommended)**:
    Open [lib/core/constants/api_constants.dart](file:///d:/PRM_CP2/Journal-Trend-Analysis-Mobile-Application/lib/core/constants/api_constants.dart) and replace the contact email with your real email. This places your app requests in the fast-track pool of the OpenAlex server, speeding up load times significantly.
3.  **Fetch Dependencies**:
    Open your terminal in the root directory and run:
    ```bash
    flutter pub get
    ```
4.  **Run Code Lints & Quality Checks**:
    Make sure everything compiles clean:
    ```bash
    flutter analyze
    ```
5.  **Run Unit Tests**:
    ```bash
    flutter test
    ```
6.  **Launch the App**:
    Start the app on your connected device/emulator:
    ```bash
    flutter run
    ```

---

## 📁 Folder & Project Architecture (For Developers)

The project is structured according to **Clean Architecture** principles. Code is split into layers: **Domain** (business logic), **Data** (fetching & serialization), and **Presentation** (UI screens & state management).

```
lib/
├── core/                         # 🛠️ Shared tools, themes, and routers
│   ├── constants/                # API configurations and system keys
│   ├── error/                    # Exception types and Failures definitions
│   ├── navigation/               # GoRouter routing mapping
│   ├── theme/                    # Color styles (Dark Mode first) & Visual tokens
│   └── utils/                    # Common helper utilities (e.g. Abstract Index parser)
├── domain/                       # 🧠 Core Business Logic (Independent Layer)
│   ├── entities/                 # Plain Dart model structures (Author, Publication)
│   ├── repositories/             # Abstract Repository contracts
│   └── usecases/                 # Specific logical actions (SearchPublications)
├── data/                         # 🔌 Remote API & Storage Integration Layer
│   ├── datasources/              # Network requests clients (OpenAlexRemoteDataSource)
│   ├── models/                   # JSON serialization and model mappings
│   └── repositories/             # Concrete implementations of Domain contracts
├── presentation/                 # 📱 UI Rendering Layer
│   ├── bloc/                     # State controllers (Events, States, Blocs)
│   ├── screens/                  # Top-level screen views (Search, Detail, Trends, Dashboard)
│   └── widgets/                  # Shared widgets (Bottom bar shell, placeholders)
├── main.dart                     # 🏁 Entry point of the mobile application
└── injection_container.dart     # 💉 Dependency injection container (GetIt)
```

---

## 🛠️ Extension Guide: How to Add Features

If you want to add new functions (e.g., adding user bookmarking or sorting filters), follow this workflow:

### Step 1: Create a Domain Entity & Usecase
1.  Define a plain Dart object in `lib/domain/entities/`.
2.  Add abstract method contracts in `lib/domain/repositories/publication_repository.dart`.
3.  Write the business usecase class in `lib/domain/usecases/`.

### Step 2: Implement Data Mapping
1.  Create a model class in `lib/data/models/` extending your domain entity, implementing `fromJson`/`toJson`.
2.  Add corresponding API methods in `lib/data/datasources/openalex_remote_data_source.dart`.
3.  Write the actual database/API coordinate logic in `lib/data/repositories/publication_repository_impl.dart`.

### Step 3: Configure BLoC State Management
1.  Add Events and States in `lib/presentation/bloc/`.
2.  Register the new Bloc in [lib/injection_container.dart](file:///d:/PRM_CP2/Journal-Trend-Analysis-Mobile-Application/lib/injection_container.dart).
3.  Provide the Bloc globally in `lib/main.dart` if accessed across multiple screens.

### Step 4: Draw the UI Component
1.  Create the screen layout in `lib/presentation/screens/`.
2.  Route the screen in [lib/core/navigation/router.dart](file:///d:/PRM_CP2/Journal-Trend-Analysis-Mobile-Application/lib/core/navigation/router.dart).
3.  Dispatch events to trigger UI state updates.

---

## 🧩 Module Deep Dive & Business Rules

This section details the inner workings of each key functional module and the logical business rules dictating data processing.

### 1. Search & Autocomplete Module
- **How it Works**: Captures user keyword inputs and queries the `/works` endpoint with `search=<keyword>&sort=cited_by_count:desc&per_page=50`. Quick-chips trigger predefined searches (e.g. *Cybersecurity*, *AI*).
- **Business Rule**: The search is sorted by citation volume (`cited_by_count:desc`) to guarantee that the primary dataset represents the most influential and widely recognized works in the field.

### 2. Analytical Dashboard Module
- **How it Works**: Aggregates statistics locally from the fetched top 50 publications dataset. 
- **Business Rules & Calculations**:
  - **Total Works**: The total count of all existing matching papers on OpenAlex, dynamically read from the metadata counter field `meta.count` (not limited to 50).
  - **Average Citations**: Calculated client-side by summing up `cited_by_count` across the top 50 works and dividing by 50.
  - **Peak Publication Year**: Identifies the year with the highest publication volume by looping through the trend dataset and selecting the year containing the maximum count.
  - **Top Journal Source**: Loops through group-by source items and displays the journal with the highest number of matching papers.
  - **Top Contribution (Author)**: Filters out generic non-author stubs (e.g., `CERTIFICATION EXAM`, `anonymous`) from the authorship group-by list, selects the first valid profile, and makes a live call to `/authors/<id>` to display their ORCID, works count, and affiliation.

### 3. Trend Analysis Carousel Module
- **How it Works**: Uses an infinite swipable PageView controller. Queries three datasets concurrently:
  - **Diagram 1**: `/works?search=<keyword>&group_by=publication_year`
  - **Diagram 3**: `/works?search=<keyword>&group_by=topics.id` (returns key topics, mapped to keywords)
  - **Diagram 7**: `/works?search=<keyword>&group_by=authorships.author.id` (returns top authors list)
- **Business Rule**: The carousel cycles through `Diagram 1 -> Diagram 3 -> Diagram 7` infinitely. When swiping past Diagram 7, it wraps back to Diagram 1 using a modulo-3 index calculation, preventing scroll boundaries.

### 4. Article Detail Module
- **How it Works**: Displays the selected publication metadata (DOI links, publication date, journal info) and reconstructs the abstract.
- **Business Rule (Inverted Index Reconstructor)**: OpenAlex does not return raw abstract text. Instead, it provides `abstract_inverted_index`, a map of words to their list of index positions. The app implements a reconstruction algorithm that rebuilds the paragraph by placing words at their respective indices, restoring human-readable abstracts dynamically.

---

## 💡 Technical Highlights & Caching

-   **Persistent Caching Layer**: The app uses `dio_cache_interceptor` with a Hive database store. Once a topic search or trend is requested, the data remains cached locally for **7 days**. Subsequent queries load instantly and function offline.
-   **Client-Side Analytics Engine**: To avoid sending dozens of separate API calls from a mobile device (which causes lag), the repository downloads a sample of the **top 50 papers** once. It then runs high-speed Dart calculations locally to aggregate stats like *Top Journal*, *Top Author*, and *Average Citations*.
-   **Inverted Abstract Index Resolver**: OpenAlex hides complete abstracts behind copyright-compliant `abstract_inverted_index` maps. The [abstract_parser.dart](file:///d:/PRM_CP2/Journal-Trend-Analysis-Mobile-Application/lib/core/utils/abstract_parser.dart) contains an optimized string builder that reconstructs paragraph abstracts dynamically for the user detail screen.
-   **Swipable Infinite Carousel**: The Trend Analysis screen features a custom infinite-looping `PageView` carousel (`1 -> 3 -> 7 -> 1`) displaying line charts (`fl_chart`), top keywords, and author impact charts, query-loaded concurrently via `Future.wait` in BLoC.
-   **Polished Author Profile Metadata**: Implements a generic term validator to filter out metadata noise (e.g., `CERTIFICATION EXAM`) and queries the `/authors/<id>` endpoint live to display primary affiliation, ORCID identifier, and total publications/citations under the **Top Contribution** dashboard card.

---

## 🛠️ Troubleshooting & Build Guide (Windows/Android)

If you run into compilation or runtime issues while running or building the APK, follow these guidelines:

### 1. "this and base files have different roots" (Kotlin Build Error)
*   **Cause**: Triggered on Windows when the project is on one drive (e.g. `D:`) and the Pub/Gradle cache is on the system drive (e.g. `C:`).
*   **Fix**: Already configured in [gradle.properties](file:///d:/PRM_CP2/Journal-Trend-Analysis-Mobile-Application/android/gradle.properties) by adding:
    ```properties
    kotlin.incremental=false
    ksp.incremental=false
    ```
*   **Process**: Clear the old corrupt caches and rebuild:
    ```bash
    flutter clean
    flutter pub get
    flutter build apk --release
    ```

### 2. "Failed host lookup: 'api.openalex.org'" (Offline/Network Error in Release APK)
*   **Cause**: Missing Internet permission in the production manifest.
*   **Fix**: Already configured in [AndroidManifest.xml](file:///d:/PRM_CP2/Journal-Trend-Analysis-Mobile-Application/android/app/src/main/AndroidManifest.xml) by adding the following tag right under the root `<manifest>` element:
    ```xml
    <uses-permission android:name="android.permission.INTERNET"/>
    ```

### 3. "The class 'IconData' can't be extended" (Compile Error with Flutter 3.44+)
*   **Cause**: In recent Flutter versions, the core `IconData` class was made `final`. Older versions of `font_awesome_flutter` that try to subclass it will fail to compile.
*   **Fix**: Updated `pubspec.yaml` to `font_awesome_flutter: ^11.0.0` which replaces subclasses with `FaIconData` and uses the `FaIcon` widget.

### 4. White Screen / Crash on Flutter Web (Chrome)
*   **Cause**: `path_provider` fails to execute on browser platforms (since it doesn't support directory systems), causing initialization to crash before `runApp` starts.
*   **Fix**: Configured a `kIsWeb` check in [api_client.dart](file:///d:/PRM_CP2/Journal-Trend-Analysis-Mobile-Application/lib/core/network/api_client.dart) to bypass `path_provider` and `HiveCacheStore` on Web, falling back to `MemCacheStore`.
