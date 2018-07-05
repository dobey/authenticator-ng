project(authenticator-ng LANGUAGES C CXX)
cmake_minimum_required(VERSION 2.8.9)

set(GETTEXT_PACKAGE ${CMAKE_PROJECT_NAME})

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 14)

include(GNUInstallDirs)
if(EXISTS "/etc/debian_version")
    execute_process(
      COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
      OUTPUT_VARIABLE ARCH_TRIPLET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  set(CMAKE_INSTALL_LIBDIR lib/${ARCH_TRIPLET})
  set(CMAKE_INSTALL_LIBEXECDIR "${CMAKE_INSTALL_LIBDIR}")
  set(CMAKE_INSTALL_FULL_LIBEXECDIR "${CMAKE_INSTALL_FULL_LIBDIR}")
  if(CLICK_MODE)
    set(CMAKE_INSTALL_PREFIX /)
    set(CMAKE_INSTALL_BINDIR lib/${ARCH_TRIPLET}/bin)
  endif(CLICK_MODE)
endif(EXISTS "/etc/debian_version")

find_package(Threads REQUIRED)
find_package(PkgConfig REQUIRED)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

pkg_check_modules(AUTH_STATIC REQUIRED
  zbar
)
pkg_check_modules(AUTH_DYNAMIC REQUIRED
  libcrypto
  libjpeg
  libv4l2
)
include_directories(SYSTEM
  ${AUTH_STATIC_INCLUDE_DIRS}
  ${AUTH_DYNAMIC_INCLUDE_DIRS}
)

configure_file(manifest.json.in manifest.json)
if(CLICK_MODE)
  install(FILES
    ${CMAKE_PROJECT_NAME}.desktop
    ${CMAKE_PROJECT_NAME}.svg
    ${CMAKE_PROJECT_NAME}.json
    ${CMAKE_CURRENT_BINARY_DIR}/manifest.json
    DESTINATION .
  )
else(CLICK_MODE)
  install(
    FILES ${CMAKE_PROJECT_NAME}.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
  )
  install(
    FILES ${CMAKE_PROJECT_NAME}.svg
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps
  )
endif(CLICK_MODE)

add_subdirectory(liboath)
add_subdirectory(app)
add_subdirectory(po)

enable_testing()
find_package(CoverageReport)
