buildscript {
    repositories {
        google()
        mavenCentral()
    }
    
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.10")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
    
    configurations.all {
        resolutionStrategy {
            // Force specific versions of AndroidX libraries
            force("androidx.core:core:1.9.0")
            force("androidx.core:core-ktx:1.9.0")
            force("androidx.lifecycle:lifecycle-runtime:2.5.1")
            force("androidx.lifecycle:lifecycle-common:2.5.1")
            force("androidx.lifecycle:lifecycle-livedata:2.5.1")
            force("androidx.lifecycle:lifecycle-process:2.5.1")
            force("androidx.fragment:fragment:1.5.5")
            force("androidx.fragment:fragment-ktx:1.5.5")
            force("androidx.appcompat:appcompat:1.6.1")
            
            // Add dependency substitution for common conflicts
            eachDependency {
                when (requested.group) {
                    "androidx.lifecycle" -> useVersion("2.5.1")
                    "androidx.core" -> useVersion("1.9.0")
                    "androidx.fragment" -> useVersion("1.5.5")
                }
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
