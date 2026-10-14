#!/usr/bin/env bash
set -e

echo "=== Running Jarvis Android Gradle Patch ==="

# 1. Update Kotlin to 2.1.0 in settings.gradle
if [ -f "android/settings.gradle" ]; then
  sed -i 's/id "org.jetbrains.kotlin.android" version "[^"]*"/id "org.jetbrains.kotlin.android" version "2.1.0"/' android/settings.gradle || true
  sed -i 's/id "org.jetbrains.kotlin.android" version .*/id "org.jetbrains.kotlin.android" version "2.1.0" apply false/' android/settings.gradle || true
  echo "Updated Kotlin version to 2.1.0 in settings.gradle"
fi

# 2. Force Kotlin stdlib alignment in root android/build.gradle
cat << 'EOF' >> android/build.gradle

allprojects {
    configurations.all {
        resolutionStrategy {
            force 'org.jetbrains.kotlin:kotlin-stdlib:2.1.0'
            force 'org.jetbrains.kotlin:kotlin-stdlib-jdk8:2.1.0'
            force 'org.jetbrains.kotlin:kotlin-stdlib-jdk7:2.1.0'
            force 'org.jetbrains.kotlin:kotlin-stdlib-common:2.1.0'
        }
    }
}
EOF

# 3. Ensure local.properties has all flutter SDK versions
echo "flutter.compileSdkVersion=34" >> android/local.properties
echo "flutter.minSdkVersion=26" >> android/local.properties
echo "flutter.targetSdkVersion=34" >> android/local.properties

# 4. Ensure gradle.properties has AndroidX and Kotlin optimizations
echo "android.useAndroidX=true" >> android/gradle.properties
echo "android.enableJetifier=true" >> android/gradle.properties
echo "org.gradle.jvmargs=-Xmx4G" >> android/gradle.properties
echo "kotlin.version=2.1.0" >> android/gradle.properties

# 5. Patch ALL speech_to_text build.gradle files in pub-cache
for file in $(find /home/runner/.pub-cache -wholename "*/speech_to_text*/android/build.gradle"); do
  echo "Found and patching speech_to_text gradle at: $file"
  cat > "$file" << 'EOF'
group 'com.csdcorp.speech_to_text'
version '1.0-SNAPSHOT'

rootProject.allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'

android {
    namespace 'com.csdcorp.speech_to_text'
    compileSdk 34

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = '11'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        minSdkVersion 21
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }
    lintOptions {
        disable 'InvalidPackage'
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.12.0'
}
EOF
  echo "Successfully patched: $file"
done

echo "=== Gradle Patch Completed ==="
