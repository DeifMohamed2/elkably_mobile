import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services Gradle plugin for Firebase
    id("com.google.gms.google-services")
}

android {
    namespace = "com.elkably.mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Unique Application ID for Google Play Store
        applicationId = "com.elkably.mobile"
        // Minimum SDK version
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Multi-dex support for larger apps
        multiDexEnabled = true
    }

    signingConfigs {
        // For release builds, you'll need to create a keystore
        // Run: keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
        // Then create android/key.properties with:
        // storePassword=<password>
        // keyPassword=<password>
        // keyAlias=upload
        // storeFile=<path to keystore>
        
         //Uncomment below after creating keystore:
         create("release") {
             val keystorePropertiesFile = rootProject.file("key.properties")
             val keystoreProperties = Properties()
             if (keystorePropertiesFile.exists()) {
                 keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                 keyAlias = keystoreProperties["keyAlias"] as String
                 keyPassword = keystoreProperties["keyPassword"] as String
                 storeFile = file(keystoreProperties["storeFile"] as String)
                 storePassword = keystoreProperties["storePassword"] as String
             }
         }
    }

    buildTypes {
        release {
            // Enable code shrinking and obfuscation
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Use release signing config
            signingConfig = signingConfigs.getByName("release")
        }
        
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // Enable build config
    buildFeatures {
        buildConfig = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
