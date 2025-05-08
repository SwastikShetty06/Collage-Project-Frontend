buildscript {
    dependencies {
        classpath("com.android.tools.build:gradle:8.4.0")
        classpath(kotlin("gradle-plugin", version = "1.9.22"))
    }

    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = layout.buildDirectory.dir("../../build").get()
layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(name)
    layout.buildDirectory.set(newSubprojectBuildDir)

    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(layout.buildDirectory)
}
