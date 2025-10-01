plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Correct placement for Google services plugin
}

android {
    namespace = "com.example.lastpro"

    compileSdk = 36 // Use 'compileSdk' instead of 'compileSdkVersion'
    ndkVersion = "27.0.12077973" // Correctly place the ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.lastpro"
        minSdk = 23 // Use 'minSdk' instead of 'minSdkVersion'
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.." // Path to the Flutter project source
}

apply(plugin = "com.google.gms.google-services")  // Correct syntax for applying the plugin

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))  // Firebase Bill of Materials for version management
    implementation("com.google.firebase:firebase-analytics")  // Firebase Analytics SDK

    // Add other Firebase SDKs as needed, e.g.
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
    // implementation("com.google.firebase:firebase-messaging")
}
