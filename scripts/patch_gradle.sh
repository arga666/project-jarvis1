#!/usr/bin/env bash
set -e

echo "=== Running Jarvis Android Gradle Patch ==="

# 1. Update Kotlin to 2.0.21 in settings.gradle and build.gradle
if [ -f "android/settings.gradle" ]; then
  sed -i 's/id "org.jetbrains.kotlin.android" version "[^"]*"/id "org.jetbrains.kotlin.android" version "2.0.21"/' android/settings.gradle || true
  sed -i 's/id "org.jetbrains.kotlin.android" version .*/id "org.jetbrains.kotlin.android" version "2.0.21" apply false/' android/settings.gradle || true
  echo "Updated Kotlin version to 2.0.21 in settings.gradle"
fi

# 2. Ensure local.properties has all flutter SDK versions
echo "flutter.compileSdkVersion=34" >> android/local.properties
echo "flutter.minSdkVersion=26" >> android/local.properties
echo "flutter.targetSdkVersion=34" >> android/local.properties

# 3. Ensure gradle.properties has AndroidX and Kotlin optimizations
echo "android.useAndroidX=true" >> android/gradle.properties
echo "android.enableJetifier=true" >> android/gradle.properties
echo "org.gradle.jvmargs=-Xmx4G" >> android/gradle.properties
echo "kotlin.version=2.0.21" >> android/gradle.properties

# 4. Patch ALL speech_to_text build.gradle files in pub-cache
for file in $(find /home/runner/.pub-cache -wholename "*/speech_to_text*/android/build.gradle"); do
  echo "Found and patching speech_to_text gradle at: $file"
  cat > "$file" << 'EOF'
group 'com.csdcorp.speech_to_text'
version '1.0-SNAPSHOT'

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
    }
}

apply plugin: 'com.android.library'

android {
    namespace "com.csdcorp.speech_to_text"
    compileSdkVersion 34

    defaultConfig {
        minSdkVersion 21
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.12.0'
}
EOF
  echo "Successfully patched: $file"
done

echo "=== Gradle Patch Completed ==="
