import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load release signing properties if available
val keyPropsFile = rootProject.file("key.properties")
val keyProps = if (keyPropsFile.exists()) {
    Properties().apply { load(FileInputStream(keyPropsFile)) }
} else {
    null
}

android {
    namespace = "com.mhad.mhad"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications for Java 8 API on older Android
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.mhad.mhad"
        // Delegate SDK levels to the Flutter Gradle plugin. With Flutter 3.44.x
        // (project pin), these resolve to: minSdk = 24 (Android 7.0 Nougat —
        // required by sqlcipher_flutter_libs + nfc_manager), targetSdk = 35
        // (Android 15), compileSdk = 35. Raising minSdk explicitly here
        // would let us drop legacy compatibility shims; lowering would break
        // SQLCipher. Material 3 is supported from minSdk 21+, so we're fine.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keyProps != null) {
            create("release") {
                // To sign release builds, create android/key.properties with:
                //   storeFile=path/to/keystore.jks
                //   storePassword=...
                //   keyAlias=...
                //   keyPassword=...
                storeFile = file(keyProps.getProperty("storeFile"))
                storePassword = keyProps.getProperty("storePassword")
                keyAlias = keyProps.getProperty("keyAlias")
                keyPassword = keyProps.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keyProps != null) {
                signingConfigs.getByName("release")
            } else {
                // Fall back to debug signing when key.properties not present
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
