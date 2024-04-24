plugins {
    kotlin("multiplatform")
    kotlin("plugin.serialization")
    id("com.android.library")
    id("com.squareup.sqldelight")
    id("dev.icerock.mobile.multiplatform-resources")
}

@OptIn(org.jetbrains.kotlin.gradle.ExperimentalKotlinGradlePluginApi::class)
kotlin {
    targetHierarchy.default()

    androidTarget {
        compilations.all {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
    }
    
    listOf(
        iosX64(),
        iosArm64(),
        iosSimulatorArm64()
    ).forEach {
        it.binaries.framework {
            baseName = "shared"

            export("com.arkivanov.decompose:decompose:2.2.2")
            export("com.arkivanov.essenty:lifecycle:1.3.0")

            export("com.arkivanov.essenty:state-keeper:1.3.0")
            export("com.arkivanov.essenty:instance-keeper:1.3.0")
            export("com.arkivanov.essenty:back-handler:1.3.0")

            export("com.arkivanov.parcelize.darwin:runtime:0.2.4")
        }
    }

    val coroutinesVersion = "1.7.1"
    val sqlDelightVersion = "1.5.5"

    sourceSets {
        val commonMain by getting {
            dependencies {
                implementation("org.jetbrains.kotlin:kotlin-stdlib-common")
                api("dev.icerock.moko:resources:0.23.0")
                implementation(platform("org.kotlincrypto.hash:bom:0.2.3"))
                implementation("org.kotlincrypto.hash:md5")
                implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0-RC")
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:$coroutinesVersion")
                implementation("com.squareup.sqldelight:runtime:$sqlDelightVersion")
                implementation(platform("io.ktor:ktor-bom:2.3.4"))
                implementation("io.ktor:ktor-client-core")
                implementation("io.ktor:ktor-client-json")
                implementation("io.ktor:ktor-client-content-negotiation")
                implementation("io.ktor:ktor-client-serialization")
                implementation("io.ktor:ktor-serialization-kotlinx-json")
                implementation("com.arkivanov.decompose:decompose:2.2.2")

                api("com.arkivanov.decompose:decompose:2.2.2")
                api("com.arkivanov.essenty:lifecycle:1.3.0")

                api("com.arkivanov.essenty:state-keeper:1.3.0")
                api("com.arkivanov.essenty:instance-keeper:1.3.0")
                api("com.arkivanov.essenty:back-handler:1.3.0")

                api("com.arkivanov.parcelize.darwin:runtime:0.2.4")
            }
        }
        val commonTest by getting {
            dependencies {
                implementation(kotlin("test"))
            }
        }
        val androidMain by getting {
            dependencies {
                implementation("com.squareup.sqldelight:android-driver:$sqlDelightVersion")
            }
        }
        val iosMain by getting {
            dependencies {
                implementation("com.squareup.sqldelight:native-driver:$sqlDelightVersion")
                implementation(platform("io.ktor:ktor-bom:2.3.4"))
                implementation("io.ktor:ktor-client-ios")
            }
        }
    }
}

android {
    namespace = "jatx.russianrocksongbook"
    compileSdk = 34
    defaultConfig {
        minSdk = 24
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

sqldelight {
    database("AppDatabase") {
        packageName = "jatx.russianrocksongbook.db"
    }
}

multiplatformResources {
    multiplatformResourcesPackage = "jatx.russianrocksongbook"
    multiplatformResourcesVisibility = dev.icerock.gradle.MRVisibility.Public
}