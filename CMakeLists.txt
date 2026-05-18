cmake_minimum_required(VERSION 3.20)

project(
  InternFortranPlayground
  VERSION 0.1.0
  DESCRIPTION "A small Fortran/CMake project for interns to explore"
  LANGUAGES Fortran
)

include(CTest)

option(PLAYGROUND_WARNINGS_AS_ERRORS "Treat compiler warnings as errors" OFF)

set(CMAKE_Fortran_MODULE_DIRECTORY "${CMAKE_BINARY_DIR}/modules")

function(playground_enable_warnings target)
  if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    target_compile_options(
      ${target}
      PRIVATE
        -Wall
        -Wextra
        -fbacktrace
        "$<$<CONFIG:Debug>:-fcheck=all>"
    )
    if(PLAYGROUND_WARNINGS_AS_ERRORS)
      target_compile_options(${target} PRIVATE -Werror)
    endif()
  elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
    target_compile_options(${target} PRIVATE -warn all)
    if(PLAYGROUND_WARNINGS_AS_ERRORS)
      target_compile_options(${target} PRIVATE -diag-error warn)
    endif()
  endif()
endfunction()

add_library(
  playground_core
  src/config_mod.f90
  src/field_mod.f90
  src/logger_mod.f90
  src/path_mod.f90
  src/vtk_writer_mod.f90
)
target_include_directories(
  playground_core
  PUBLIC "${CMAKE_Fortran_MODULE_DIRECTORY}"
)
playground_enable_warnings(playground_core)

add_executable(diffusion_playground app/diffusion_playground.f90)
target_link_libraries(diffusion_playground PRIVATE playground_core)
playground_enable_warnings(diffusion_playground)

if(BUILD_TESTING)
  add_executable(test_config tests/test_config.f90)
  target_link_libraries(test_config PRIVATE playground_core)
  playground_enable_warnings(test_config)

  add_executable(test_field tests/test_field.f90)
  target_link_libraries(test_field PRIVATE playground_core)
  playground_enable_warnings(test_field)

  add_test(
    NAME config-reader
    COMMAND test_config "${CMAKE_SOURCE_DIR}/examples/default/simulation.ini"
  )

  add_test(NAME field-update COMMAND test_field)

  add_test(
    NAME example-run
    COMMAND
      diffusion_playground
      "${CMAKE_SOURCE_DIR}/examples/default/simulation.ini"
      "${CMAKE_BINARY_DIR}/playground-output"
  )
  set_tests_properties(
    example-run
    PROPERTIES
      PASS_REGULAR_EXPRESSION "Wrote VTK"
  )
endif()

install(TARGETS diffusion_playground RUNTIME DESTINATION bin)
