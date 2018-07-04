
find_package(Qt5Gui REQUIRED)
find_package(Qt5Qml REQUIRED)
find_package(Qt5Quick REQUIRED)
find_package(Qt5Widgets REQUIRED)

add_executable(authenticator-ng
  account.cpp
  account.h
  accountmodel.cpp
  accountmodel.h
  main.cpp
  qrcodereader.cpp
  qrcodereader.h

  qml.qrc
)

target_link_libraries(authenticator-ng
  -Wl,-Bstatic ${AUTH_STATIC_LIBRARIES} -Wl,-Bdynamic
  ${AUTH_DYNAMIC_LIBRARIES}

  Qt5::Core
  Qt5::Gui
  Qt5::Qml
  Qt5::Quick
  Qt5::Widgets

  ${CMAKE_THREAD_LIBS_INIT}
)

install(
  TARGETS authenticator-ng
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
