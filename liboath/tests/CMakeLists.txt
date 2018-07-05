function(add_test_by_name name)
  set(TEST_NAME ${name})
  set(COVERAGE_TEST_TARGETS ${COVERAGE_TEST_TARGETS} ${TEST_NAME} PARENT_SCOPE)
  add_executable (${TEST_NAME} ${TEST_NAME}.c)
  add_test(${TEST_NAME} ${TEST_NAME})
  target_link_libraries(${TEST_NAME}
    liboath
    ${AUTH_DYNAMIC_LIBRARIES}
    ${CMAKE_THREAD_LIBS_INIT}
  )
endfunction()

add_test_by_name(tst_errors)
add_test_by_name(tst_hotp_algo)
add_test_by_name(tst_hotp_validate)
add_test_by_name(tst_totp_algo)
add_test_by_name(tst_totp_validate)

set(COVERAGE_TEST_TARGETS
  ${COVERAGE_TEST_TARGETS}
  PARENT_SCOPE
)
