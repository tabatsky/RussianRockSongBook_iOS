buildscript {
    repositories {
        gradlePluginPortal()
    }

    dependencies {
        classpath("dev.icerock.moko:resources-generator:0.26.0")
    }
}

plugins {
    //trick: for the same plugin versions in all sub-modules
    id("com.android.application").version("8.1.0").apply(false)
    id("com.android.library").version("8.1.0").apply(false)
    kotlin("android").version("2.1.0").apply(false)
    kotlin("multiplatform").version("2.1.0").apply(false)
    kotlin("plugin.serialization").version("2.1.0").apply(false)
    id("com.squareup.sqldelight").version("1.5.5").apply(false)
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}

allprojects {
    repositories {
        mavenCentral()
        google()
    }
}
