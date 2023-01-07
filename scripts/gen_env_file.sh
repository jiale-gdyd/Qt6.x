#!/bin/bash

if [ $# != 3 ]; then
    echo "Usage: $0 <want to generate file name, e.g: RkEnv.sh> <Qt at your target environment, e.g: /usr/lib/Qt6>"
    exit 1;
fi

envFileName=$1
qtInsRootDir=$2

cat > $envFileName <<EOF
export QT_ROOT=$qtInsRootDir

export PATH=\$PATH:\$QT_ROOT/bin:\$QT_ROOT/iconv/bin
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$QT_ROOT/lib:\$QT_ROOT/usr/lib:\$QT_ROOT/iconv/lib

if [ -f "\$QT_ROOT/iconv/lib/preloadable_libiconv.so" ]; then
    export LD_PRELOAD=\$QT_ROOT/iconv/lib/preloadable_libiconv.so
fi

export QT_QPA_FB_DRM=1
export QT_QPA_PLATFORM=linuxfb:rotation=0
# export QT_QPA_PLATFORM=linuxfb:rotation=0:size=1280x720:rect=0,0,1280,720

# export QT_DEBUG_PLUFINS=1
EOF
