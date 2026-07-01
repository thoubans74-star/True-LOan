allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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

subprojects {
    val configureAndroidNamespace = {
        val isAndroid = plugins.hasPlugin("com.android.application") || 
                        plugins.hasPlugin("com.android.library")
        if (isAndroid) {
            val android = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            if (android != null && android.namespace == null) {
                var manifestPackage: String? = null
                val manifestFile = projectDir.resolve("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val manifestText = manifestFile.readText()
                    val match = Regex("""package\s*=\s*"([^"]+)"""").find(manifestText)
                    manifestPackage = match?.groupValues?.get(1)
                }
                android.namespace = manifestPackage ?: "com.example.${project.name.replace("-", ".")}"
            }
        }
    }

    if (project.state.executed) {
        configureAndroidNamespace()
    } else {
        project.afterEvaluate {
            configureAndroidNamespace()
        }
    }
}
