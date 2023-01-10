#!/bin/bash

SUDO_CMD=
NEED_ROOT_MKDIR="True"

if [ "$NEED_ROOT_MKDIR"x = "True"x ]; then
    SUDO_CMD=sudo
fi

CUR_DIR=${PWD}
source ${CUR_DIR}/funcDefine.sh

export CPU_CORES=$(grep -c processor /proc/cpuinfo)

QT6_VERSION=6.4.2

CMAKE_BIN=/usr/bin/cmake
CMAKE_VERSION=$(${CMAKE_BIN} --version)

HOST_INSTALL_PATH=/opt/Qt${QT6_VERSION}_host
RV1126_INSTALL_PATH=/opt/Qt${QT6_VERSION}_rv1126

QT6_SRC_PATH=${CUR_DIR}/..

CMAKE_TOOLCHAIN_FILE=${CUR_DIR}/toolchain_rv1126.cmake
TOOLS_ROOT=/opt/toolchain/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf
RV1126_CROSS_COMPILE=${TOOLS_ROOT}/bin/arm-linux-gnueabihf-

BUILD_HOST_TEMPDIR=qt6_build_host_tmpdir
BUILD_RV1126_TEMPDIR=qt6_build_rv1126_tmpdir

cmake_version_min='3190'
cmake_version=$(cmake --version | grep 'cmake version' | awk -F ' ' '{print $3}')
cmake_version_num=${cmake_version//./}
echo "cmake ${cmake_version} ${cmake_version_num}"

function host_install_dep()
{
    sudo apt-get install -g libdrm-dev libnss3-dev libmd4c-dev libmd4c-html0-dev
    sudo apt-get install -g libxcomposite-dev libxcursor-dev libxrandr-dev libxshmfence-dev libsecret-1-dev
    sudo apt-get install -g make build-essential llvm libclang-dev ninja-build libcups2-dev libxkbfile-dev
    sudo apt-get install -g gcc git bison python3 gperf pkg-config libfontconfig1-dev libfreetype6-dev
    sudo apt-get install -g libx11-dev libx11-xcb-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev
    sudo apt-get install -g libxcb1-dev libxcb-glx0-dev libxcb-keysyms1-dev libxcb-image0-dev libxcb-shm0-dev
    sudo apt-get install -g libxcb-icccm4-dev libxcb-sync-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev
    sudo apt-get install -g libxcb-render-util0-dev libxcb-util-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev
    sudo apt-get install -g libxkbcommon-x11-dev libatspi2.0-dev libgl1-mesa-dev libglu1-mesa-dev freeglut3-dev
}

function build_qt6_host()
{
    begin=$(get_timestamp)
    type=$(uname)
    distro=$(get_linux_distro)
    version=$(get_general_version)
    echo "Platform type: "${type}" "${distro}" "${version}

    print_info "ready configure Qt${QT6_VERSION} for host ......"

    if [ -d "${BUILD_HOST_TEMPDIR}" ]; then
        rm -rf ${BUILD_HOST_TEMPDIR}
    fi

    mkdir ${BUILD_HOST_TEMPDIR}
    cd ${BUILD_HOST_TEMPDIR}

    ${CMAKE_BIN} ${QT6_SRC_PATH} -GNinja -DCMAKE_BUILD_TYPE=Release -DBUILD_qtwebengine=OFF -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=${HOST_INSTALL_PATH}
    if [ $? -ne 0 ]; then
        error_exit "cmake ${QT6_SRC_PATH} -GNinja -DCMAKE_BUILD_TYPE=Release -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=${HOST_INSTALL_PATH} failed"
    fi

    read -r -p "Starting compiling Qt${QT6_VERSION} for host? [Y/n] " start_compile
    case $start_compile in
    [yY][eE][sS] | [yY])
        print_info "compiling Qt${QT6_VERSION} for host ......"
        ;;

    [nN][oO] | [nN])
        print_warn "you quit compiling Qt${QT6_VERSION} for host"
        exit 1
        ;;

    *)

        error_exit "Invalid input ......"
        ;;
    esac

    ${CMAKE_BIN} --build . --parallel ${CPU_CORES}
    if [ $? -ne 0 ]; then
        error_exit "${CMAKE_BIN} --build . --parallel ${CPU_CORES} failed"
    fi

    print_info "${CMAKE_BIN} Qt${QT6_VERSION} for host successful ......"

    read -r -p "Starting install Qt${QT6_VERSION} for host? [Y/n] " start_install
    case $start_install in
    [yY][eE][sS] | [yY])
        print_info "installing Qt${QT6_VERSION} for host ......"
        ;;

    [nN][oO] | [nN])
        print_warn "you quit install Qt${QT6_VERSION} for host"
        ;;

    *)

        error_exit "Invalid input ......"
        ;;
    esac

    if [ ! -d "${HOST_INSTALL_PATH}" ]; then
        print_info "${HOST_INSTALL_PATH} not exists and {SUDO_CMD} mkdir -p ${HOST_INSTALL_PATH} now"

        ${SUDO_CMD} mkdir -p ${HOST_INSTALL_PATH}
        if [ $? -ne 0 ]; then
            error_exit "{SUDO_CMD} mkdir -p ${HOST_INSTALL_PATH} failed"
        fi
    fi

    print_info "ready to install Qt${QT6_VERSION} to ${HOST_INSTALL_PATH} ......"

    ${SUDO_CMD} ${CMAKE_BIN} --install .
    if [ $? -ne 0 ]; then
        error_exit "${CMAKE_BIN} --install . Qt${QT6_VERSION} for host failed"
    fi

    print_info "build Qt${QT6_VERSION} for host finished"
    cd ..

    end=`get_timestamp`
    second=`expr ${end} - ${begin}`
    min=`expr ${second} / 60`
    echo "It takes "${min}" minutes, and "${second} "seconds"
}

function build_iconv_rv1126()
{
    begin=$(get_timestamp)
    type=$(uname)
    distro=$(get_linux_distro)
    version=$(get_general_version)
    echo "Platform type: "${type}" "${distro}" "${version}

    print_info "ready configure libconv for rv1126 ......"

    if [ -d "./build_iconv" ]; then
        rm -rf build_iconv
    fi

    mkdir build_iconv
    cd build_iconv

    cp -a ${QT6_SRC_PATH}/libiconv libiconv
    cd libiconv

    ./configure \
        --prefix=${CUR_DIR}/iconv \
        --host=arm-linux-gnueabihf \
        CC=${RV1126_CROSS_COMPILE}gcc

    if [ $? -ne 0 ]; then
        rm -rf build_iconv
        error_exit "configure libiconv for rv1126 failed"
    fi

    read -r -p "Starting compiling libiconv for rv1126? [Y/n] " start_compile
    case $start_compile in
    [yY][eE][sS] | [yY])
        print_info "compiling libiconv for rv1126 ......"
        ;;

    [nN][oO] | [nN])
        rm -rf build_iconv
        print_warn "you quit compiling libiconv for rv1126"
        exit 1
        ;;

    *)

        rm -rf build_iconv
        error_exit "Invalid input ......"
        ;;
    esac

    make -j${CPU_CORES}
    if [ $? -ne 0 ]; then
        error_exit "make -j${CPU_CORES} failed"
    fi

    print_info "make libiconv for rv1126 successful ......"

    read -r -p "Starting install libiconv for rv1126? [Y/n] " start_install
    case $start_install in
    [yY][eE][sS] | [yY])
        print_info "installing libiconv for rv1126 ......"
        ;;

    [nN][oO] | [nN])
        rm -rf build_iconv
        print_warn "you quit install libiconv for rv1126"
        exit 1
        ;;

    *)

        rm -rf build_iconv
        error_exit "Invalid input ......"
        ;;
    esac

    if [ ! -d "${CUR_DIR}/iconv" ]; then
        print_info "${CUR_DIR}iconv not exists and mkdir -p ${CUR_DIR}/iconv now"

        mkdir -p ${CUR_DIR}/iconv
        if [ $? -ne 0 ]; then
            rm -rf build_iconv
            error_exit "mkdir -p ${CUR_DIR}/iconv failed"
        fi
    fi

    print_info "ready to install libiconv to ${CUR_DIR}/iconv ......"

    make install
    if [ $? -ne 0 ]; then
        rm -rf build_iconv
        error_exit "make install libiconv for rv1126 failed"
    fi

    print_info "build libiconv for rv1126 finished and ready copy iconv to ${RV1126_INSTALL_PATH}"
    ${SUDO_CMD} cp -a ${CUR_DIR}/iconv ${RV1126_INSTALL_PATH}

    rm -rf ${CUR_DIR}/build_iconv
    rm -rf ${CUR_DIR}/iconv
    cd ../../

    end=`get_timestamp`
    second=`expr ${end} - ${begin}`
    min=`expr ${second} / 60`
    echo "It takes "${min}" minutes, and "${second} "seconds"
}

function build_qt6_rv1126()
{
    build_iconv_rv1126

    begin=$(get_timestamp)
    type=$(uname)
    distro=$(get_linux_distro)
    version=$(get_general_version)
    echo "Platform type: "${type}" "${distro}" "${version}

    print_info "ready configure Qt${QT6_VERSION} for rv1126 ......"

    if [ -d "${BUILD_RV1126_TEMPDIR}" ]; then
        rm -rf ${BUILD_RV1126_TEMPDIR}
    fi

    mkdir ${BUILD_RV1126_TEMPDIR}
    cd ${BUILD_RV1126_TEMPDIR}

    if [ $cmake_version_num \< $cmake_version_min ]; then
        ${QT6_SRC_PATH}/configure \
            -prefix ${RV1126_INSTALL_PATH} \
            -opensource \
            -confirm-license \
            -release \
            -kms \
            -linuxfb \
            -no-opengl \
            -no-eglfs \
            -c++std c++17 \
            -make libs \
            -pch \
            -no-sql-mysql \
            -no-sql-psql \
            -shared \
            -strip \
            -no-cups \
            -no-pkg-config \
            -no-xcb \
            -qt-sqlite \
            -qt-zlib \
            -qt-pcre \
            -no-dbus \
            -system-proxies \
            -no-gtk \
            -no-gstreamer \
            -no-journald \
            -no-separate-debug-info \
            -gui \
            -widgets \
            -make examples \
            -nomake tests \
            -skip qtx11extras \
            -qt-freetype \
            -qt-harfbuzz \
            -qt-libpng \
            -qt-libjpeg \
            -qt-tiff \
            -qt-webp \
            -gif \
            -ico \
            -qt-webp \
            -qt-tiff \
            -no-sse3 \
            -no-ssse3 \
            -no-sse4.1 \
            -no-sse4.2 \
            -no-avx \
            -no-avx2 \
            -no-tslib \
            -no-rpath \
            -no-glib \
            -no-dbus \
            -no-openssl \
            -eventfd \
            -inotify \
            -evdev \
            -I${TOOLS_ROOT}/include \
            -L${TOOLS_ROOT}/lib \
            -optimized-qmake \
            -device linux-arm-rockchip-rv1126-g++ \
            -device-option \
            CROSS_COMPILE=${TOOLS_ROOT}/bin/arm-linux-gnueabihf- -- \
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} \
            -DQT_HOST_PATH=${HOST_INSTALL_PATH} \
            -xplatform linux-arm-rockchip-rv1126-g++ \
            -qt-host-path ${HOST_INSTALL_PATH}
    else
        ${QT6_SRC_PATH}/configure \
            -prefix ${RV1126_INSTALL_PATH} \
            -opensource \
            -confirm-license \
            -release \
            -kms \
            -linuxfb \
            -no-opengl \
            -no-eglfs \
            -c++std c++17 \
            -make libs \
            -pch \
            -no-sql-mysql \
            -no-sql-psql \
            -shared \
            -strip \
            -no-cups \
            -no-pkg-config \
            -no-xcb \
            -qt-sqlite \
            -qt-zlib \
            -qt-pcre \
            -no-dbus \
            -system-proxies \
            -no-gtk \
            -no-gstreamer \
            -no-journald \
            -no-separate-debug-info \
            -gui \
            -widgets \
            -make examples \
            -nomake tests \
            -skip qtx11extras \
            -qt-freetype \
            -qt-harfbuzz \
            -qt-libpng \
            -qt-libjpeg \
            -qt-tiff \
            -qt-webp \
            -gif \
            -ico \
            -qt-webp \
            -qt-tiff \
            -no-sse3 \
            -no-ssse3 \
            -no-sse4.1 \
            -no-sse4.2 \
            -no-avx \
            -no-avx2 \
            -no-tslib \
            -no-rpath \
            -no-glib \
            -no-dbus \
            -no-openssl \
            -eventfd \
            -inotify \
            -evdev \
            -I${TOOLS_ROOT}/include \
            -L${TOOLS_ROOT}/lib \
            -optimized-qmake \
            -device linux-arm-rockchip-rv1126-g++ \
            -device-option \
            CROSS_COMPILE=${TOOLS_ROOT}/bin/arm-linux-gnueabihf- -- \
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} \
            -DQT_HOST_PATH=${HOST_INSTALL_PATH}
    fi

    if [ $? -ne 0 ]; then
        error_exit "Qt${QT6_VERSION} configure for rv1126 failed"
    fi

    read -r -p "Starting compiling Qt${QT6_VERSION} for rv1126? [Y/n] " start_compile
    case $start_compile in
    [yY][eE][sS] | [yY])
        print_info "compiling Qt${QT6_VERSION} for rv1126 ......"
        ;;

    [nN][oO] | [nN])
        print_warn "you quit compiling Qt${QT6_VERSION} for rv1126"
        exit 1
        ;;

    *)

        error_exit "Invalid input ......"
        ;;
    esac

    cmake --build . --parallel ${CPU_CORES}
    if [ $? -ne 0 ]; then
        error_exit "${CMAKE_BIN} --build . --parallel ${CPU_CORES} failed"
    fi

    print_info "${CMAKE_BIN} Qt${QT6_VERSION} for rv1126 successful ......"

    read -r -p "Starting install Qt${QT6_VERSION} for rv1126? [Y/n] " start_install
    case $start_install in
    [yY][eE][sS] | [yY])
        print_info "installing Qt${QT6_VERSION} for rv1126 ......"
        ;;

    [nN][oO] | [nN])
        print_warn "you quit install Qt${QT6_VERSION} for rv1126"
        exit 1
        ;;

    *)

        error_exit "Invalid input ......"
        ;;
    esac

    if [ ! -d "${RV1126_INSTALL_PATH}" ]; then
        print_info "${RV1126_INSTALL_PATH} not exists and {SUDO_CMD} mkdir -p ${RV1126_INSTALL_PATH} now"

        ${SUDO_CMD} mkdir -p ${RV1126_INSTALL_PATH}
        if [ $? -ne 0 ]; then
            error_exit "{SUDO_CMD} mkdir -p ${HOST_INSTALL_PATH} failed"
        fi
    fi

    print_info "ready to install Qt${QT6_VERSION} to ${RV1126_INSTALL_PATH} ......"

    ${SUDO_CMD} cmake --install .
    if [ $? -ne 0 ]; then
        error_exit "${SUDO_CMD} ${CMAKE_BIN} install for rv1126 failed"
    fi

    print_info "install Qt${QT6_VERSION} for rv1126 successful ......"
    cd ..

    if [ -f "${QT6_SRC_PATH}/scripts/gen_env_file.sh" ]; then
        chmod 777 ${QT6_SRC_PATH}/scripts/gen_env_file.sh
        ${QT6_SRC_PATH}/scripts/gen_env_file.sh RkEnv.sh /usr/lib/Qt6
        if [ -f "${QT6_SRC_PATH}/scripts/RkEnv.sh" ]; then
            chmod 777 ${QT6_SRC_PATH}/scripts/RkEnv.sh

            print_info "cp ${QT6_SRC_PATH}/scripts/RkEnv.sh to ${RV1126_INSTALL_PATH}"
            ${SUDO_CMD} cp -a ${QT6_SRC_PATH}/scripts/RkEnv.sh ${RV1126_INSTALL_PATH}
        fi
    fi

    end=`get_timestamp`
    second=`expr ${end} - ${begin}`
    min=`expr ${second} / 60`
    echo "It takes "${min}" minutes, and "${second} "seconds"

    clean
}

function clean()
{
    if [ -d ${BUILD_HOST_TEMPDIR} ]; then
        rm -rf ${BUILD_HOST_TEMPDIR}
    fi

    if [ -d ${BUILD_RV1126_TEMPDIR} ]; then
        rm -rf ${BUILD_RV1126_TEMPDIR}
    fi

    if [ -d  build_iconv ]; then
        rm -rf build_iconv
    fi
}

function help()
{
    echo "Usage: ./build_rv1126_qt6.sh [OPTION]"
    echo "[OPTION]:"
    echo "=========================================================="
    echo "   0   clean                清除构建缓存"
    echo "   1   host_install_dep     构建主机安装依赖"
    echo "   2   build_qt6_host       构建主机目标QT6"
    echo "   3   build_qt6_rv1126     交叉编译目标RV1126上的QT6"
    echo "=========================================================="
}

if [ -z $1 ]; then
    help
else
    $1
fi
