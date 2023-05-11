# Part of the work taken from
# * https://github.com/jedisct1/libsodium/pull/156
# * https://github.com/jedisct1/libsodium/pull/181
# * https://github.com/Cyberunner23/libsodium-CMake

cmake_minimum_required(VERSION 3.2) # minimal for Hunter

include("cmake/HunterGate.cmake")
HunterGate(
    URL "https://github.com/cpp-pm/hunter/archive/v0.24.16.tar.gz"
    SHA1 "09668c254f01afeca1b3d3d2e4692ed5e0e39dcc"
)

project(libsodium VERSION 1.0.16)

find_package(Threads REQUIRED)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake/module")

include(libsodium_add_c_flag)
include(libsodium_add_have_macro)
include(libsodium_try_compile)

include(TestBigEndian) # test_big_endian
include(CheckIncludeFile) # check_include_file

option(
    LIBSODIUM_ENABLE_BLOCKING_RANDOM
    "Enable this switch only if /dev/urandom is totally broken on the target platform."
    OFF
)

option(
    LIBSODIUM_ENABLE_MINIMAL_BUILD
    "Only compile the minimum set of functions required for the high-level API."
    OFF
)

option(LIBSODIUM_ENABLE_TESTS "Enable testing." OFF)

if(EMSCRIPTEN)
  set(default YES)
else()
  set(default NO)
endif()

option(
    LIBSODIUM_DISABLE_ASM "Disable AMD64 assembly implementations." ${default}
)

option(LIBSODIUM_DISABLE_SSP "Do not compile with -fstack-protector." NO)

if(MSVC)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4146")
endif()

if(LIBSODIUM_DISABLE_ASM)
  set(LIBSODIUM_AMD64_ASM FALSE)
else()
  libsodium_try_compile(
      SOURCE amd64_asm.c
      CMAKE_VAR LIBSODIUM_AMD64_ASM
      CPP_MACRO HAVE_AMD64_ASM
  )

  if(LIBSODIUM_AMD64_ASM)
    enable_language(ASM)
  endif()
endif()

if(MSVC)
  if(MSVC_VERSION GREATER 1900)
    set(LIBSODIUM_MSVC_BROKEN FALSE)
  else()
    # Visual Studio 14 2015 internal compiler error
    set(LIBSODIUM_MSVC_BROKEN TRUE)
  endif()
else()
  set(LIBSODIUM_MSVC_BROKEN FALSE)
endif()

if(NOT LIBSODIUM_MSVC_BROKEN)
  libsodium_try_compile(
      SOURCE avxintrin.c
      CMAKE_VAR LIBSODIUM_HAVE_AVXINTRIN_H
      CPP_MACRO HAVE_AVXINTRIN_H
  )
endif()

libsodium_try_compile(
    SOURCE avx_asm.c
    CMAKE_VAR LIBSODIUM_HAVE_AVX_ASM
    CPP_MACRO HAVE_AVX_ASM
)

if(LIBSODIUM_HAVE_AVX_ASM)
  enable_language(ASM)
endif()

libsodium_try_compile(
    SOURCE native_client.c
    CMAKE_VAR LIBSODIUM_NATIVE
)

# Variables from configure.ac {

set(SODIUM_LIBRARY_VERSION_MAJOR 10)
set(SODIUM_LIBRARY_VERSION_MINOR 1)
set(SODIUM_LIBRARY_VERSION_PATCH 0) # ???

set(SODIUM_LIBRARY_VERSION "24:0:1")

if(LIBSODIUM_ENABLE_MINIMAL_BUILD)
  set(SODIUM_LIBRARY_MINIMAL_DEF "#define SODIUM_LIBRARY_MINIMAL 1")
  add_definitions("-DMINIMAL=1")
else()
  set(SODIUM_LIBRARY_MINIMAL_DEF "")
endif()

# }

set(VERSION ${PROJECT_VERSION})

# Use:
# * SODIUM_LIBRARY_MINIMAL_DEF
# * SODIUM_LIBRARY_VERSION_MAJOR
# * SODIUM_LIBRARY_VERSION_MINOR
# * VERSION
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/src/libsodium/include/sodium/version.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/generated/sodium/version.h
)

test_big_endian(LIBSODIUM_BIG_ENDIAN)

if(LIBSODIUM_BIG_ENDIAN)
  set(libsodium_endian_macro "-DNATIVE_BIG_ENDIAN=1")
else()
  set(libsodium_endian_macro "-DNATIVE_LITTLE_ENDIAN=1")
endif()

add_definitions(${libsodium_endian_macro})

if(MSVC)
  add_definitions("-DUNICODE")
  add_definitions("-D_UNICODE")
endif()

libsodium_try_compile(
    SOURCE ti_mode.c
    CMAKE_VAR LIBSODIUM_TI_MODE
    CPP_MACRO HAVE_TI_MODE
    COMPILE_DEFINITIONS ${libsodium_endian_macro}
)

libsodium_try_compile(
    SOURCE weak_symbols.c
    CMAKE_VAR LIBSODIUM_HAVE_WEAK_SYMBOLS
    CPP_MACRO HAVE_WEAK_SYMBOLS
)

libsodium_try_compile(
    SOURCE cpuid.c
    CMAKE_VAR LIBSODIUM_HAVE_CPUID
    CPP_MACRO HAVE_CPUID
)

libsodium_try_compile(
    SOURCE limit_macros.c
    CMAKE_VAR LIBSODIUM_LIMIT_MACROS_NOT_NEEDED
)

if(LIBSODIUM_LIMIT_MACROS_NOT_NEEDED)
  # If this works then we dont need to define __STDC_LIMIT_MACROS
  # and __STDC_CONSTANT_MACROS.
else()
  add_definitions("-D__STDC_LIMIT_MACROS")
  add_definitions("-D__STDC_CONSTANT_MACROS")
endif()

if(NOT LIBSODIUM_MSVC_BROKEN)
  libsodium_try_compile(
      SOURCE emmintrin.c
      CMAKE_VAR LIBSODIUM_HAVE_EMMINTRIN_H
      CPP_MACRO HAVE_EMMINTRIN_H
  )

  libsodium_try_compile(
      SOURCE pmmintrin.c
      CMAKE_VAR LIBSODIUM_HAVE_PMMINTRIN_H
      CPP_MACRO HAVE_PMMINTRIN_H
  )

  libsodium_try_compile(
      SOURCE tmmintrin.c
      CMAKE_VAR LIBSODIUM_HAVE_TMMINTRIN_H
      CPP_MACRO HAVE_TMMINTRIN_H
  )

  libsodium_try_compile(
      SOURCE smmintrin.c
      CMAKE_VAR LIBSODIUM_HAVE_SMMINTRIN_H
      CPP_MACRO HAVE_SMMINTRIN_H
  )

  libsodium_try_compile(
      SOURCE wmmintrin.c
      CMAKE_VAR LIBSODIUM_HAVE_WMMINTRIN_H
      CPP_MACRO HAVE_WMMINTRIN_H
  )
endif()

libsodium_try_compile(
    SOURCE memset.c
    CMAKE_VAR LIBSODIUM_HAVE_MEMSET_S
    CPP_MACRO HAVE_MEMSET_S
)

if(NOT LIBSODIUM_MSVC_BROKEN)
  libsodium_try_compile(
      SOURCE avx2intrin.c
      CMAKE_VAR LIBSODIUM_HAVE_AVX2INTRIN_H
      CPP_MACRO HAVE_AVX2INTRIN_H
  )
endif()

libsodium_try_compile(
    SOURCE avx512fintrin.c
    CMAKE_VAR LIBSODIUM_HAVE_AVX512FINTRIN_H
    CPP_MACRO HAVE_AVX512FINTRIN_H
)

libsodium_try_compile(
    SOURCE rdrand.c
    CMAKE_VAR LIBSODIUM_HAVE_RDRAND
    CPP_MACRO HAVE_RDRAND
)

libsodium_try_compile(
    SOURCE xgetbv.c
    CMAKE_VAR LIBSODIUM_HAVE__XGETBV
    CPP_MACRO HAVE__XGETBV
)

libsodium_try_compile(
    SOURCE atomic_ops.c
    CMAKE_VAR LIBSODIUM_HAVE_ATOMIC_OPS
    CPP_MACRO HAVE_ATOMIC_OPS
)

libsodium_add_have_macro(
    FUNCTION arc4random
    CMAKE_VAR LIBSODIUM_HAVE_ARC4RANDOM
    CPP_MACRO HAVE_ARC4RANDOM
)

libsodium_add_have_macro(
    FUNCTION explicit_bzero
    CMAKE_VAR LIBSODIUM_HAVE_EXPLICIT_BZERO
    CPP_MACRO HAVE_EXPLICIT_BZERO
)

libsodium_add_have_macro(
    FUNCTION madvise
    CMAKE_VAR LIBSODIUM_HAVE_MADVISE
    CPP_MACRO HAVE_MADVISE
)

libsodium_add_have_macro(
    FUNCTION mlock
    CMAKE_VAR LIBSODIUM_HAVE_MLOCK
    CPP_MACRO HAVE_MLOCK
)

libsodium_add_have_macro(
    FUNCTION mmap
    CMAKE_VAR LIBSODIUM_HAVE_MMAP
    CPP_MACRO HAVE_MMAP
)

libsodium_add_have_macro(
    FUNCTION mprotect
    CMAKE_VAR LIBSODIUM_HAVE_MPROTECT
    CPP_MACRO HAVE_MPROTECT
)

libsodium_add_have_macro(
    FUNCTION posix_memalign
    CMAKE_VAR LIBSODIUM_HAVE_POSIX_MEMALIGN
    CPP_MACRO HAVE_POSIX_MEMALIGN
)

# Update CMAKE_C_FLAGS {

libsodium_add_c_flag(-std=c99)
libsodium_add_c_flag(-D_FORTIFY_SOURCE=2)

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
  libsodium_add_c_flag(-Wno-unknown-warning-option)
endif()

if(MSYS OR MINGW OR CYGWIN)
  libsodium_add_c_flag(-Wl,--dynamicbase)
  libsodium_add_c_flag(-Wl,--nxcompat)
endif()

libsodium_add_c_flag(-Wall)
libsodium_add_c_flag(-Wextra)
libsodium_add_c_flag(-fno-strict-aliasing)

libsodium_add_c_flag(-fno-strict-overflow available)

# If -fno-strict-overflow is not available, try with -fwrapv.
if(NOT available)
  libsodium_add_c_flag(-fwrapv)
endif()

if(NOT LIBSODIUM_DISABLE_SSP)
  libsodium_add_c_flag(-fstack-protector)
endif()

libsodium_add_c_flag(-Winit-self)
libsodium_add_c_flag(-Wwrite-strings)
libsodium_add_c_flag(-Wdiv-by-zero)
libsodium_add_c_flag(-Wsometimes-uninitialized)
libsodium_add_c_flag(-Wbad-function-cast)
libsodium_add_c_flag(-Wcast-align)
libsodium_add_c_flag(-Wcast-qual)
libsodium_add_c_flag(-Wchar-subscripts)
libsodium_add_c_flag(-Wcomment)
libsodium_add_c_flag(-Wfloat-equal)
libsodium_add_c_flag(-Wformat=2)
libsodium_add_c_flag(-Wimplicit)
libsodium_add_c_flag(-Wmissing-declarations)
libsodium_add_c_flag(-Wmissing-prototypes)
libsodium_add_c_flag(-Wnormalized=id)
libsodium_add_c_flag(-Woverride-init)
libsodium_add_c_flag(-Wparentheses)
libsodium_add_c_flag(-Wpointer-arith)
libsodium_add_c_flag(-Wredundant-decls)
libsodium_add_c_flag(-Wstrict-prototypes)
libsodium_add_c_flag(-Wswitch-enum)
libsodium_add_c_flag(-Wvariable-decl)

if(NOT WIN32 AND NOT APPLE)
  libsodium_add_c_flag(-Wl,-z,relro)
  libsodium_add_c_flag(-Wl,-z,now)
  libsodium_add_c_flag(-Wl,-z,noexecstack)
endif()

# }

if(LIBSODIUM_ENABLE_BLOCKING_RANDOM)
  add_definitions("-DUSE_BLOCKING_RANDOM")
endif()

# Collect sources {

hunter_add_package(sugar)
find_package(sugar CONFIG REQUIRED)

# Use:
# * LIBSODIUM_AMD64_ASM
# * LIBSODIUM_MSVC_BROKEN
# * LIBSODIUM_ENABLE_MINIMAL_BUILD
# * LIBSODIUM_HAVE_AVX_ASM
# * LIBSODIUM_NATIVE
# Out:
# * LIBSODIUM_SOURCES
# * LIBSODIUM_TESTS_SOURCES
sugar_include(src/libsodium)
sugar_include(test/default)

# }

if(MSVC AND BUILD_SHARED_LIBS)
  configure_file(
      "src/msvc/resource.rc.in"
      "${CMAKE_CURRENT_BINARY_DIR}/generated/resource.rc"
      @ONLY
  )

  # Use:
  # * SODIUM_LIBRARY_VERSION_MAJOR
  # * SODIUM_LIBRARY_VERSION_MINOR
  # * SODIUM_LIBRARY_VERSION_PATCH
  configure_file(
      "src/msvc/resource.h"
      "${CMAKE_CURRENT_BINARY_DIR}/generated/resource.h"
      COPYONLY
  )

  # append resource to DLL
  list(
      APPEND
      LIBSODIUM_SOURCES
      "${CMAKE_CURRENT_BINARY_DIR}/generated/resource.rc"
  )
endif()

add_library(libsodium ${LIBSODIUM_SOURCES})

target_link_libraries(libsodium PUBLIC Threads::Threads)

if(CMAKE_USE_PTHREADS_INIT)
  target_compile_definitions(libsodium PRIVATE "-DHAVE_PTHREAD")
endif()

if(BUILD_SHARED_LIBS)
  target_compile_definitions(libsodium PRIVATE "-DSODIUM_DLL_EXPORT")
else()
  target_compile_definitions(libsodium PUBLIC "-DSODIUM_STATIC")
endif()

target_compile_definitions(libsodium PRIVATE "$<$<CONFIG:Debug>:DEBUG=1>")

check_include_file("sys/mman.h" LIBSODIUM_SYS_MMAN_H)
if(LIBSODIUM_SYS_MMAN_H)
  target_compile_definitions(libsodium PUBLIC $<BUILD_INTERFACE:HAVE_SYS_MMAN_H>)
endif()

target_include_directories(
    libsodium
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/generated>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/generated/sodium>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/libsodium/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/libsodium/include/sodium>
)

### Installation (https://github.com/forexample/package-example) {

# Introduce variables:
# * CMAKE_INSTALL_LIBDIR
# * CMAKE_INSTALL_BINDIR
# * CMAKE_INSTALL_INCLUDEDIR
include(GNUInstallDirs)

set(config_install_dir "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
set(generated_dir "${CMAKE_CURRENT_BINARY_DIR}/generated")
set(version_config "${generated_dir}/${PROJECT_NAME}ConfigVersion.cmake")
set(project_config "${generated_dir}/${PROJECT_NAME}Config.cmake")
set(TARGETS_EXPORT_NAME "${PROJECT_NAME}Targets")
set(namespace "${PROJECT_NAME}::")

include(CMakePackageConfigHelpers)

# Use:
# * PROJECT_VERSION
write_basic_package_version_file(
    "${version_config}" COMPATIBILITY SameMajorVersion
)

# Use:
# * TARGETS_EXPORT_NAME
# * PROJECT_NAME
configure_package_config_file(
    "cmake/template/Config.cmake.in"
    "${project_config}"
    INSTALL_DESTINATION "${config_install_dir}"
)

install(
    DIRECTORY "src/libsodium/include/sodium"
    DESTINATION "include"
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN "*.h.in" EXCLUDE
    REGEX "^${CMAKE_CURRENT_LIST_DIR}/src/libsodium/include/sodium/private/" EXCLUDE
)

install(
    FILES "src/libsodium/include/sodium.h"
    DESTINATION "include"
)

install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/generated/sodium/version.h
    DESTINATION "include/sodium"
)

install(
    FILES "${project_config}" "${version_config}"
    DESTINATION "${config_install_dir}"
)

install(
    EXPORT "${TARGETS_EXPORT_NAME}"
    NAMESPACE "${namespace}"
    DESTINATION "${config_install_dir}"
)

install(
    TARGETS libsodium
    EXPORT "${TARGETS_EXPORT_NAME}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

### }

if(LIBSODIUM_ENABLE_TESTS)
  enable_testing()

  foreach(src ${LIBSODIUM_TESTS_SOURCES})
    get_filename_component(target_name "${src}" NAME_WE)

    add_executable(${target_name} ${src})
    target_link_libraries(${target_name} PUBLIC libsodium)
    target_compile_definitions(
        ${target_name}
        PUBLIC
        "-DTEST_SRCDIR=\"${CMAKE_CURRENT_LIST_DIR}/test/default\""
    )
    if(MSVC)
      target_compile_definitions(
          ${target_name}
          PUBLIC
          "-D_CRT_SECURE_NO_WARNINGS"
      )
    endif()
    target_include_directories(
        ${target_name} PUBLIC ${CMAKE_CURRENT_LIST_DIR}/test/quirks
    )

    add_test(NAME ${target_name} COMMAND ${target_name})
  endforeach()
endif()

# TODO:
# * HAVE_CATCHABLE_ABRT
# * HAVE_CATCHABLE_SEGV
# * HAVE_MMINTRIN_H
