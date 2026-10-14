#!/usr/bin/env bash
set -e

echo "=== Running Jarvis Android Gradle Patch ==="

# 1. Ensure local.properties has all flutter SDK versions
echo "flutter.compileSdkVersion=34" >> android/local.properties
echo "flutter.minSdkVersion=26" >> android/local.properties
echo "flutter.targetSdkVersion=34" >> android/local.properties

# 2. Ensure gradle.properties has AndroidX
echo "android.useAndroidX=true" >> android/gradle.properties
echo "android.enableJetifier=true" >> android/gradle.properties
echo "org.gradle.jvmargs=-Xmx4G" >> android/gradle.properties

# 3. Patch ALL speech_to_text build.gradle files in pub-cache
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
