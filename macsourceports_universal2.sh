# game/app specific values
export APP_VERSION="1.2.0"
export ICONSDIR="neo"
export ICONSFILENAME="doom3bfg"
export PRODUCT_NAME="RBDoom3BFG"
export EXECUTABLE_NAME="RBDoom3BFG"
export PKGINFO="APPLRBD3"
export COPYRIGHT_TEXT="DOOM 3 BFG Copyright © 1997-2012 id Software, Inc. All rights reserved."

# non-app speficic values
export WRAPPER_EXTENSION="app"
export WRAPPER_NAME="${PRODUCT_NAME}.${WRAPPER_EXTENSION}"
export CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
export EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
export BUILT_PRODUCTS_DIR="release"
export ICONS="${ICONSFILENAME}.icns"
export BUNDLE_ID="com.macsourceports.${PRODUCT_NAME}"

# For parallel make on multicore boxes...
NCPU=`sysctl -n hw.ncpu`

if [ -d build ]; then
rm -rf build
fi
mkdir build
cd build 

# create makefiles with cmake
mkdir build-x86_64
cd build-x86_64
/usr/local/bin/cmake -G "Unix Makefiles" -DCMAKE_C_FLAGS_RELEASE="-arch x86_64" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -DSDL2=ON -DFFMPEG=OFF -DBINKDEC=ON -DOPENAL_LIBRARY=~/Documents/GitHub/MSPStore/opt/openal-soft/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=~/Documents/GitHub/MSPStore/opt/openal-soft/include -DSDL2_INCLUDE_DIRS=/usr/local/opt/sdl2/include/SDL2 -DSDL2_LIBRARIES=/usr/local/opt/sdl2/lib ../../neo -Wno-dev

cd ..
mkdir build-arm64
cd build-arm64
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -DSDL2=ON -DFFMPEG=OFF -DBINKDEC=ON -DOPENAL_LIBRARY=~/Documents/GitHub/MSPStore/opt/openal-soft/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=~/Documents/GitHub/MSPStore/opt/openal-soft/include ../../neo -Wno-dev

# perform builds with make
echo "making x86_64..."
cd ..
cd build-x86_64
make -j$NCPU

echo "making arm64..."
cd ..
cd build-arm64
make -j$NCPU

cd ../..

# create the app bundle

# remove any existing app bundle
rm -rf "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"

# make the app bundle directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" || exit 1;
fi
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/idlib" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/idlib" || exit 1;
fi
if [ ! -d "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" || exit 1;
fi

lipo build/build-x86_64/${EXECUTABLE_NAME} build/build-arm64/${EXECUTABLE_NAME} -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -create
lipo build/build-x86_64/idlib/libidlib.a build/build-arm64/idlib/libidlib.a -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/idlib/libidlib.a" -create

cp ~/Documents/GitHub/MSPStore/lib/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
cp ~/Documents/GitHub/MSPStore/Cellar/openal-soft/1.21.1/lib/libopenal.1.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"

cp ${ICONSDIR}/${ICONS} "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}" || exit 1;
echo -n ${PKGINFO} > "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/PkgInfo" || exit 1;

# use install_name tool to point executable to bundled resources (probably wrong long term way to do it)
#modify x86_64
install_name_tool -change /usr/local/opt/sdl2/lib/libSDL2-2.0.0.dylib @executable_path/libSDL2-2.0.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
install_name_tool -change /usr/local/opt/openal-soft/lib/libopenal.1.dylib @executable_path/libopenal.1.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
#modify arm64
install_name_tool -change /opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib @executable_path/libSDL2-2.0.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
install_name_tool -change /opt/homebrew/opt/openal-soft/lib/libopenal.1.dylib @executable_path/libopenal.1.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}

# create Info.Plist
PLIST="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${EXECUTABLE_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>${ICONSFILENAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${PRODUCT_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${APP_VERSION}</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>${APP_VERSION}</string>
    <key>CGDisableCoalescedUpdates</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>10.7</string>
    <key>LSMinimumSystemVersionByArchitecture</key>
    <dict>
        <key>x86_64</key>
        <string>10.7</string>
        <key>arm64</key>
        <string>11.0</string>
    </dict>
	<key>NSHumanReadableCopyright</key>
    <string>${COPYRIGHT_TEXT}</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <false/>
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
</dict>
</plist>
"
echo "${PLIST}" > "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"

echo "bundle done."

"../MSPScripts/sign_and_notarize.sh" "$1"