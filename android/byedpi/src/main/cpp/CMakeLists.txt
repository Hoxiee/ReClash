cmake_minimum_required(VERSION 3.22.1)

project("byedpi")

add_compile_options(-std=c99 -O2 -fno-exceptions -fvisibility=hidden)

if (NOT "${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    add_compile_options(-g0)
    add_link_options(-Wl,--gc-sections,--strip-all)
endif ()

# Upstream routes its logging to logcat behind this define.
add_compile_definitions(ANDROID_APP)

add_library(${CMAKE_PROJECT_NAME} SHARED
        native-lib.c
        byedpi/conev.c
        byedpi/desync.c
        byedpi/extend.c
        byedpi/main.c
        byedpi/mpool.c
        byedpi/packets.c
        byedpi/proxy.c)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE byedpi)

target_link_libraries(${CMAKE_PROJECT_NAME} log)
