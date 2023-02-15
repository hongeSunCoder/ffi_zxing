# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(ffi_zxing_library VERSION 0.0.1)

add_library(
  ffi_zxing 
  SHARED
  common.cpp
  native_zxing.cpp
)

set (BUILD_WRITERS ON)

add_subdirectory(../../../cpp/zxing ZXing)

find_library(log-lib log)
target_link_libraries(ffi_zxing ZXing ${log-lib})

# set_target_properties(ffi_zxing PROPERTIES
#   PUBLIC_HEADER ffi_zxing.h
#   OUTPUT_NAME "ffi_zxing"
# )

# target_compile_definitions(ffi_zxing PUBLIC DART_SHARED_LIB)
