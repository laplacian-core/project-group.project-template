#!/usr/bin/env bash

GRADLE_DIR=${SCRIPT_BASE_DIR}/laplacian
GRADLE_BUILD_FILE="$GRADLE_DIR/build.gradle"
GRADLE_SETTINGS_FILE="$GRADLE_DIR/settings.gradle"
DEST_DIR="$PROJECT_BASE_DIR/dest"

publish() {
  trap clean EXIT
  create_build_dir
  create_settings_gradle
  create_build_gradle
  run_gradle
}

create_build_dir() {
  mkdir -p $GRADLE_DIR
}

run_gradle() {
  (cd $GRADLE_DIR
    ./gradlew \
      --stacktrace \
      --build-file build.gradle \
      --settings-file settings.gradle \
      --project-dir $GRADLE_DIR \
      publish
  )
}

create_settings_gradle() {
  cat <<EOF > $GRADLE_SETTINGS_FILE
pluginManagement {
    repositories {
        maven {
            url '${LOCAL_REPO_PATH}'
        }
        maven {
            url '${REMOTE_REPO_PATH}'
        }
        gradlePluginPortal()
        jcenter()
    }
}
rootProject.name = "laplacian.project-group.project-template"
EOF
}

create_build_gradle() {
  cat <<EOF > $GRADLE_BUILD_FILE
plugins {
    id 'maven-publish'
    id 'org.jetbrains.kotlin.jvm' version '1.3.70'
}

group = 'laplacian'
version = '1.0.0'

repositories {
    maven {
        url '${LOCAL_REPO_PATH}'
    }
    maven {
        url '${REMOTE_REPO_PATH}'
    }
    jcenter()
}

task moduleJar(type: Jar) {
    from '${DEST_DIR}'
}

publishing {
    repositories {
        maven {
            url '${LOCAL_REPO_PATH}'
        }
    }
    publications {
        mavenJava(MavenPublication) {
            artifact moduleJar
        }
    }
}
EOF
}

clean() {
  rm -f $GRADLE_BUILD_FILE $GRADLE_SETTINGS_FILE 2> /dev/null || true
}