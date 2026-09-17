cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
math(EXPR RECLASH_VERSION_YEAR "${FLUTTER_VERSION_BUILD} / 1000000")
math(EXPR RECLASH_VERSION_MONTH "(${FLUTTER_VERSION_BUILD} / 10000) % 100")
math(EXPR RECLASH_VERSION_DAY "(${FLUTTER_VERSION_BUILD} / 100) % 100")
math(EXPR RECLASH_VERSION_COUNT "${FLUTTER_VERSION_BUILD} % 100")
target_compile_definitions(${BINARY_NAME} PRIVATE
  "RECLASH_VERSION_NUMBER=${RECLASH_VERSION_YEAR},${RECLASH_VERSION_MONTH},${RECLASH_VERSION_DAY},${RECLASH_VERSION_COUNT}"
)

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)
