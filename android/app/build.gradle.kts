import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.tesis.tursd1"
    compileSdk = 34
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Este bloque carga tus contraseñas y alias del archivo key.properties
    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties") // key.properties DEBE ESTAR EN LA RAÍZ DEL PROYECTO

    if (keystorePropertiesFile.exists()) {
        println("DEBUG: key.properties ENCONTRADO en: ${keystorePropertiesFile.absolutePath}")
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
        println("DEBUG: storeFile de properties: ${keystoreProperties.getProperty("storeFile")}")
        println("DEBUG: keyAlias de properties: ${keystoreProperties.getProperty("keyAlias")}")
    } else {
        println("ERROR: key.properties NO ENCONTRADO en: ${keystorePropertiesFile.absolutePath}")
        throw GradleException("El archivo key.properties no se encontró en la raíz del proyecto. Asegúrate de que esté en ${rootProject.projectDir}/key.properties")
    }

    signingConfigs {
        create("release") {
            // ¡CORRECCIÓN AQUÍ! Eliminados los paréntesis extra al final de la línea
            storeFile = file(keystoreProperties.getProperty("storeFile") ?: throw GradleException("storeFile no encontrado en key.properties"))
            storePassword = keystoreProperties.getProperty("storePassword") ?: throw GradleException("storePassword no encontrado en key.properties")
            keyAlias = keystoreProperties.getProperty("keyAlias") ?: throw GradleException("keyAlias no encontrado en key.properties")
            keyPassword = keystoreProperties.getProperty("keyPassword") ?: throw GradleException("keyPassword no encontrado en key.properties")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            // Otros ajustes de release
        }
    }

    defaultConfig {
        applicationId = "com.tesis.tursd1"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.16.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.android.gms:play-services-auth:21.2.0")
    implementation("com.google.firebase:firebase-firestore")
}