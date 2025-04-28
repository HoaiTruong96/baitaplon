plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.baitaplon"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // (Fix lỗi NDK)

    defaultConfig {
        applicationId = "com.example.baitaplon"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Thêm desugaring libraries mới
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")

    // Các dependency khác nếu cần
}
