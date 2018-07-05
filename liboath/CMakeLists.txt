
add_library(liboath STATIC
  aux.c
  aux.h
  errors.c
  hotp.c
  hotp.h
  oath.h
  totp.c
)

target_link_libraries(liboath
  ${CMAKE_THREAD_LIBS_INIT}
)


add_subdirectory(tests)

set(COVERAGE_TEST_TARGETS
  ${COVERAGE_TEST_TARGETS}
  PARENT_SCOPE
)
