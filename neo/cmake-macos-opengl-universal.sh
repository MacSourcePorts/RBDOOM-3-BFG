# For parallel make on multicore boxes...
NCPU=`sysctl -n hw.ncpu`

cd ..
rm -rf build-x86_64
mkdir build-x86_64
cd build-x86_64
/usr/local/bin/cmake -G "Unix Makefiles" -DCMAKE_C_FLAGS_RELEASE="-arch x86_64" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -DSDL2=ON -DFFMPEG=OFF -DBINKDEC=ON -DOPENAL_LIBRARY=/Users/tomkidd/Documents/GitHub/MSPStore/opt/openal-soft/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/Users/tomkidd/Documents/GitHub/MSPStore/opt/openal-soft/include -DSDL2_INCLUDE_DIRS=/usr/local/opt/sdl2/include/SDL2 -DSDL2_LIBRARIES=/usr/local/opt/sdl2/lib ../neo -Wno-dev

cd ..
rm -rf build-arm64
mkdir build-arm64
cd build-arm64
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -DSDL2=ON -DFFMPEG=OFF -DBINKDEC=ON -DOPENAL_LIBRARY=/Users/tomkidd/Documents/GitHub/MSPStore/opt/openal-soft/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/Users/tomkidd/Documents/GitHub/MSPStore/opt/openal-soft/include ../neo -Wno-dev

cd ..
cd build-x86_64
make -j$NCPU

cd ..
cd build-arm64
make -j$NCPU