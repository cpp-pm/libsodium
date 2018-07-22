include(CMakeParseArguments) # cmake_parse_arguments
include(CheckFunctionExists) # check_function_exists

function(libsodium_add_have_macro)
  set(optional "")
  set(one FUNCTION CMAKE_VAR CPP_MACRO)
  set(multiple "")

  # Introduce:
  # * x_FUNCTION
  # * x_CMAKE_VAR
  # * x_CPP_MACRO
  cmake_parse_arguments(x "${optional}" "${one}" "${multiple}" "${ARGV}")

  if(NOT "${x_UNPARSED_ARGUMENTS}" STREQUAL "")
    message(FATAL_ERROR "Unparsed arguments: ${x_UNPARSED_ARGUMENTS}")
  endif()

  if("${x_FUNCTION}" STREQUAL "")
    message(FATAL_ERROR "FUNCTION required")
  endif()

  if("${x_CMAKE_VAR}" STREQUAL "")
    message(FATAL_ERROR "CMAKE_VAR required")
  endif()

  if("${x_CPP_MACRO}" STREQUAL "")
    message(FATAL_ERROR "CPP_MACRO required")
  endif()

  check_function_exists("${x_FUNCTION}" "${x_CMAKE_VAR}")

  if(${x_CMAKE_VAR})
    add_definitions("-D${x_CPP_MACRO}=1")
  endif()
endfunction()
