# game/app specific values
export APP_VERSION="1.2.0"
export ICONSDIR="neo"
export ICONSFILENAME="doom3bfg"
export PRODUCT_NAME="RBDoom3BFG"
export EXECUTABLE_NAME="RBDoom3BFG"
export PKGINFO="APPLRBD3"
export COPYRIGHT_TEXT="DOOM 3 BFG Copyright © 1997-2012 id Software, Inc. All rights reserved."

#constants
source ../MSPScripts/constants.sh

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
/usr/local/bin/cmake -G "Unix Makefiles" -DCMAKE_C_FLAGS_RELEASE="-arch x86_64" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -DSDL2=ON -DFFMPEG=OFF -DBINKDEC=ON -DOPENAL_LIBRARY=/usr/local/opt/openal-soft/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/usr/local/opt/openal-soft/include -DSDL2_INCLUDE_DIRS=/usr/local/opt/sdl2/include/SDL2 -DSDL2_LIBRARIES=/usr/local/opt/sdl2/lib ../neo -Wno-dev

cd ..
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -DSDL2=ON -DFFMPEG=OFF -DBINKDEC=ON -DOPENAL_LIBRARY=/opt/homebrew/opt/openal-soft/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/opt/homebrew/opt/openal-soft/include ../neo -Wno-dev

# perform builds with make
cd ..
cd ${X86_64_BUILD_FOLDER}
make -j$NCPU
mkdir -p ${EXECUTABLE_FOLDER_PATH}
mv ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}

cd ..
cd ${ARM64_BUILD_FOLDER}
make -j$NCPU
mkdir -p ${EXECUTABLE_FOLDER_PATH}
mv ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPScripts/build_app_bundle.sh"

#create any app-specific directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/idlib" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/idlib" || exit 1;
fi

#lipo any app-specific things
lipo ${X86_64_BUILD_FOLDER}/idlib/libidlib.a ${ARM64_BUILD_FOLDER}/idlib/libidlib.a -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/idlib/libidlib.a" -create

"../MSPScripts/sign_and_notarize.sh" "$1"