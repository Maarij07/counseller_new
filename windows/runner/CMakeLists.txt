cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)
set(WINDOWS_APP_ICON "runner/resources/app_icon.ico")

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
# Force static CRT to match Firebase prebuilt libs
#if (MSVC)
# foreach(flag_var 
#     CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
#    CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE)
#  string(REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}" )
#  endforeach()
#endif()

# ... אח"כ הקוד הקיים שלך:
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

if (MSVC)
  target_link_options(${BINARY_NAME} PRIVATE "/IGNORE:4099")
endif()

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app
 # ספריות מערכת בסיסיות
  kernel32.lib
  user32.lib
  gdi32.lib
  advapi32.lib
  shell32.lib
  ole32.lib
  oleaut32.lib
  uuid.lib
  comdlg32.lib
  dwmapi.lib

  # C-runtime סטטי
  libcmt.lib
  legacy_stdio_definitions.lib
  legacy_stdio_wide_specifiers.lib

  # ספריות רשת ו־crypto (ל־grpc / protobuf / Firestore)
  ws2_32.lib
  iphlpapi.lib
  userenv.lib
  bcrypt.lib
  crypt32.lib
  normaliz.lib
  shlwapi.lib
  psapi.lib

  # (אופציונלי) אם יש פונקציות זמן:
  winmm.lib

  # …
  # CRT סטטי (כבר אמור להיכנס עם /MT, אבל אם חסר)
  libcmt.lib
  # לעיתים צריך גם:
  legacy_stdio_definitions.lib
  legacy_stdio_wide_specifiers.lib
)

target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)
