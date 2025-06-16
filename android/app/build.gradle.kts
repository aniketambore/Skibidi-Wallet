import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 🔐 Load signing properties from key.properties
val keystoreProperties = Properties().apply {
    val keystorePropertiesFile = rootProject.file("app/keystore.properties")
    if (keystorePropertiesFile.exists()) {
        load(keystorePropertiesFile.inputStream())
    } else {
        throw GradleException("keystore.properties not found")
    }
}

android {
    namespace = "com.example.bitwit_shit"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "org.unitmatrix.wallet"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 🔐 Add signing config
    signingConfigs {
        create("release") {
            val keystoreFile = rootProject.file("app/skibidi_wallet.jks")
            if (!keystoreFile.exists()) {
                throw GradleException("Keystore file not found at ${keystoreFile.absolutePath}")
            }
            storeFile = keystoreFile
            storePassword = keystoreProperties.getProperty("storePassword")
                ?: throw GradleException("storePassword not found in keystore.properties")
            keyAlias = keystoreProperties.getProperty("keyAlias")
                ?: throw GradleException("keyAlias not found in keystore.properties")
            keyPassword = keystoreProperties.getProperty("keyPassword")
                ?: throw GradleException("keyPassword not found in keystore.properties")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}

flutter {
    source = "../.."
}
