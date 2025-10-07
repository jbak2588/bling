import java.util.regex.Pattern

// api_keys.dart 파일에서 API 키를 파싱하는 로직
val keysFile = rootProject.file("../lib/api_keys.dart")
var apiKey = ""
if (keysFile.exists()) {
    val content = keysFile.readText(Charsets.UTF_8)
    // ✅ class 구조를 정확히 읽을 수 있도록 정규식을 수정합니다.
    val pattern = Pattern.compile("static const googleApiKey\\s*=\\s*'([^']*)'")
    val matcher = pattern.matcher(content)
    if (matcher.find()) {
        apiKey = matcher.group(1)
    }
}


plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.bling_app"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
       jvmTarget = "11"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.example.bling_app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
        
        // ✅ 위에서 제대로 읽어온 apiKey 변수를 사용하여 플레이스홀더를 설정합니다.
        manifestPlaceholders["googleMapsApiKey"] = apiKey
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.1.1"))
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
    implementation("com.google.firebase:firebase-appcheck-playintegrity") // 운영(릴리즈)용
    debugImplementation("com.google.firebase:firebase-appcheck-debug")   // 개발(디버그)용
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    kotlinOptions {
        jvmTarget = "11"
    }
}
