// tursd/android/build.gradle.kts
import com.android.build.api.dsl.ApplicationExtension
import org.gradle.api.JavaVersion
import org.gradle.api.artifacts.dsl.RepositoryHandler
import org.gradle.api.file.Directory
import org.gradle.api.tasks.Delete

// Define los repositorios de forma centralizada para que todos los subproyectos los usen
fun RepositoryHandler.commonRepositories() {
    google()
    mavenCentral()
}

// Bloque de plugins para el nivel de proyecto
plugins {
    // Estos son los plugins que probablemente ya tienes o que son estándar de Flutter
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false
    id("dev.flutter.flutter-gradle-plugin") apply false // Este ya lo tenías implícitamente

    // ¡Añade esta línea! Es el plugin de Google Services para el nivel de proyecto
    id("com.google.gms.google-services") version "4.3.15" apply false // Usa la versión que te dio Firebase, o la más reciente
}

allprojects {
    repositories {
        commonRepositories() // Usa la función para definir los repositorios
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    // Asegúrate de que los subproyectos también usen los repositorios comunes
    repositories {
        commonRepositories()
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}