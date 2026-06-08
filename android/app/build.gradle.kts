import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing config is read from android/key.properties (gitignored).
// Absent (e.g. on a fresh clone or CI without secrets) -> release falls back to
// debug signing so `flutter build` still works locally.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.vsh.mylarium"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // The per-build-type `app_name` string (Mylarium vs Mylarium Dev) is injected
    // via resValue, which requires this feature (disabled by default here).
    buildFeatures {
        resValues = true
    }

    defaultConfig {
        applicationId = "com.vsh.mylarium"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // API 26+: the unrar native source uses lutimes(), declared only at
        // API >= 26; the native-assets build targets this minSdk.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        // Local dev builds (debug + profile) install side by side with the
        // Play Store app: a distinct applicationId suffix, a "Mylarium Dev"
        // label, and the dev-badged launcher icon (android/app/src/{debug,
        // profile}/res). The Play Store release keeps the clean id and name.
        getByName("debug") {
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Mylarium Dev")
        }
        getByName("profile") {
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Mylarium Dev")
        }
        release {
            resValue("string", "app_name", "Mylarium")
            // Use the release upload key when key.properties is present;
            // otherwise fall back to debug signing for local builds.
            signingConfig = signingConfigs.getByName(
                if (hasReleaseSigning) "release" else "debug"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
