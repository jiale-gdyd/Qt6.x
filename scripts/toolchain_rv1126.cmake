cmake_minimum_required(VERSION 3.16)
include_guard(GLOBAL)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 8.3.0)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_C_COMPILER /opt/toolchain/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf/bin/arm-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER /opt/toolchain/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf/bin/arm-linux-gnueabihf-g++)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DQT_USE_RGA -DQT_FB_DRM_ARGB32 -DQT_CONFIG_ROCKCHIP")
set(CMAKE_CXX_FLAGS "-Wno-psapi ${CMAKE_C_FLAGS}")

set(QT_COMPILER_FLAGS "-march=armv7-a -mcpu=cortex-a7 -mfpu=neon -DQT_USE_RGA -DQT_FB_DRM_ARGB32 -DQT_CONFIG_ROCKCHIP")
set(QT_COMPILER_FLAGS_RELEASE "-O2 -pipe -DQT_USE_RGA -DQT_FB_DRM_ARGB32 -DQT_CONFIG_ROCKCHIP")
set(QT_LINKER_FLAGS "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

set(DRM_INC_DIR /opt/toolchain/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf/include)
set(Libdrm_INCLUDE_DIR ${DRM_INC_DIR})
set(Libdrm_LIBRARY /opt/toolchain/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf/lib/libdrm.so)
