// Fix for AGP AndroidLocationsException when both ANDROID_PREFS_ROOT and ANDROID_USER_HOME env vars are set
try {
    val envClass = Class.forName("java.lang.ProcessEnvironment")
    val field = envClass.getDeclaredField("theEnvironment")
    field.isAccessible = true
    @Suppress("UNCHECKED_CAST")
    val map = field.get(null) as MutableMap<String, String>
    map.remove("ANDROID_PREFS_ROOT")

    val caseInsensitiveField = envClass.getDeclaredField("theCaseInsensitiveEnvironment")
    caseInsensitiveField.isAccessible = true
    @Suppress("UNCHECKED_CAST")
    val caseInsensitiveMap = caseInsensitiveField.get(null) as MutableMap<String, String>
    caseInsensitiveMap.remove("ANDROID_PREFS_ROOT")
} catch (e: Throwable) {
    println("Failed to clear env var: $e")
}

pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.4.4") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.4.20" apply false
}

include(":app")
