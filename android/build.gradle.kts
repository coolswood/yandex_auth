group = "com.coolswood.yandex_auth"
version = "1.0-SNAPSHOT"

buildscript {
    val kotlinVersion = "2.2.21"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.13.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
    id("kotlin-android")
}

android {
    namespace = "com.coolswood.yandex_auth"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
        // Yandex authsdk требует подстановку YANDEX_CLIENT_ID в манифесте.
        // Это запасное значение нужно только для юнит-тестов самой библиотеки
        // (app-level manifestPlaceholders при этом неизвестны); при сборке
        // приложения приоритет имеет значение из build.gradle приложения.
        manifestPlaceholders["YANDEX_CLIENT_ID"] = "unit_test_client_id"
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.useJUnitPlatform()

                it.outputs.upToDateWhen { false }

                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}

dependencies {
    implementation("com.yandex.android:authsdk:3.2.1")
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.23.0")
}
