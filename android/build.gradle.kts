plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.example.device_security_check"
    compileSdk = 36

    defaultConfig {
        minSdk = 23
    }
}
