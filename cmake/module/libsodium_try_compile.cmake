include(CMakeParseArguments) # cmake_parse_arguments

function(libsodium_try_compile)
  set(optional "")
  set(one SOURCE CMAKE_VAR CPP_MACRO COMPILE_DEFINITIONS)
  set(multiple "")

  # Introduce:
  # * x_SOURCE
  # * x_CMAKE_VAR
  # * x_CPP_MACRO
  # * x_COMPILE_DEFINITIONS
  cmake_parse_arguments(x "${optional}" "${one}" "${multiple}" "${ARGV}")

  if(NOT "${x_UNPARSED_ARGUMENTS}" STREQUAL "")
    message(FATAL_ERROR "Unparsed arguments: ${x_UNPARSED_ARGUMENTS}")
  endif()

  if("${x_CMAKE_VAR}" STREQUAL "")
    message(FATAL_ERROR "CMAKE_VAR required")
  endif()

  try_compile(
      ${x_CMAKE_VAR}
      "${CMAKE_CURRENT_BINARY_DIR}/try_compile"
      "${CMAKE_CURRENT_LIST_DIR}/cmake/try_compile/${x_SOURCE}"
      COMPILE_DEFINITIONS "${x_COMPILE_DEFINITIONS}"
  )

  if(${x_CMAKE_VAR} AND NOT "${x_CPP_MACRO}" STREQUAL "")
    add_definitions("-D${x_CPP_MACRO}=1")
  endif()
endfunction()
