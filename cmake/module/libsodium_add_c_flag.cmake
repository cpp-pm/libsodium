include(CheckCCompilerFlag) # check_c_compiler_flag

function(libsodium_add_c_flag)
  if("${ARGC}" STREQUAL "1")
    set(flag "${ARGV0}")
    set(var_name "")
  elseif("${ARGC}" STREQUAL "2")
    set(flag "${ARGV0}")
    set(var_name "${ARGV1}")
  else()
    message(FATAL_ERROR "Unexpected: ${ARGC}")
  endif()

  unset(__libsodium_check CACHE)

  message(STATUS "Check flag: '${flag}'")
  check_c_compiler_flag(${flag} __libsodium_check)

  if(__libsodium_check)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${flag}" PARENT_SCOPE)
    set("${var_name}" TRUE PARENT_SCOPE)
  else()
    set("${var_name}" FALSE PARENT_SCOPE)
  endif()

  unset(__libsodium_check CACHE)
endfunction()
