cmake_minimum_required(VERSION 3.16)
include_guard(GLOBAL)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 10.3.1)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_FIND_ROOT_PATH /opt/toolchain/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf)
set(CMAKE_C_COMPILER ${CMAKE_FIND_ROOT_PATH}/bin/arm-none-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER ${CMAKE_FIND_ROOT_PATH}/bin/arm-none-linux-gnueabihf-g++)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DQT_CONFIG_IMX6ULL")
set(CMAKE_CXX_FLAGS "-Wno-psapi ${CMAKE_C_FLAGS}")

set(QT_COMPILER_FLAGS "-Wno-psapi -march=armv7-a -mcpu=cortex-a7 -mfpu=neon -mfloat-abi=hard -DQT_CONFIG_IMX6ULL")
set(QT_COMPILER_FLAGS_RELEASE "-O2 -Wno-psapi -pipe -DQT_CONFIG_IMX6ULL")
set(QT_LINKER_FLAGS "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
