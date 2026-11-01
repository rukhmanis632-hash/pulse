#!/usr/bin/env bash
# Builds a signed debug APK using only the Android SDK build-tools
# (aapt2 + javac + d8 + zipalign + apksigner). No Gradle, no Maven deps.
set -euxo pipefail

: "${ANDROID_HOME:=/usr/local/lib/android/sdk}"
export ANDROID_HOME

BT=$(ls -d "$ANDROID_HOME"/build-tools/*/ | sort -V | tail -1)
PLAT_DIR=$(ls -d "$ANDROID_HOME"/platforms/android-*/ | sort -V | tail -1)
JAR="${PLAT_DIR}android.jar"
echo "build-tools: $BT"
echo "android.jar: $JAR"

rm -rf build android/assets
mkdir -p build/gen build/classes build/dex android/assets
cp pulse.html android/assets/pulse.html

# 1. compile resources -> flat files
"${BT}aapt2" compile --dir android/res -o build/res.zip
mkdir -p build/flat
(cd build/flat && unzip -q ../res.zip)

# 2. link resources + manifest + assets -> base.apk and generated R.java
#    (flat files are passed positionally; -R is only for overlays)
"${BT}aapt2" link \
  -o build/base.apk \
  -I "$JAR" \
  --manifest android/AndroidManifest.xml \
  --java build/gen \
  -A android/assets \
  --min-sdk-version 21 \
  --target-sdk-version 34 \
  --version-code 1 \
  --version-name 1.0 \
  $(find build/flat -name '*.flat')

# 3. compile java
javac -source 8 -target 8 -nowarn -classpath "$JAR" -d build/classes \
  $(find android/src build/gen -name '*.java')

# 4. dex
"${BT}d8" --lib "$JAR" --min-api 21 --output build/dex \
  $(find build/classes -name '*.class')

# 5. put the dex into the apk
cp build/base.apk build/unsigned.apk
(cd build/dex && zip -q ../unsigned.apk classes.dex)

# 6. align
"${BT}zipalign" -f -p 4 build/unsigned.apk build/aligned.apk

# 7. sign with a throwaway debug key
if [ ! -f debug.keystore ]; then
  keytool -genkeypair -v -keystore debug.keystore \
    -storepass android -keypass android \
    -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=Android Debug,O=Android,C=US"
fi

"${BT}apksigner" sign \
  --ks debug.keystore \
  --ks-pass pass:android --key-pass pass:android \
  --min-sdk-version 21 \
  --out PULSE.apk build/aligned.apk

"${BT}apksigner" verify --print-certs PULSE.apk | head -4
ls -la PULSE.apk
