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

// Fix for old plugins that don't specify a namespace (required by AGP 8+).
// flutter_windowmanager 0.2.0 has this issue.
subprojects {
    plugins.withId("com.android.library") {
        val androidExt = extensions.getByType(com.android.build.gradle.LibraryExtension::class.java)
        if (androidExt.namespace.isNullOrEmpty()) {
            val manifest = file("src/main/AndroidManifest.xml")
            if (manifest.exists()) {
                val pkg = javax.xml.parsers.DocumentBuilderFactory.newInstance()
                    .newDocumentBuilder()
                    .parse(manifest)
                    .documentElement
                    .getAttribute("package")
                if (pkg.isNotEmpty()) {
                    androidExt.namespace = pkg
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
