TARGET = ubuntu-authenticator

QT += quick widgets


INCLUDEPATH += ../plugin/OAth
INCLUDEPATH += /usr/include/zbar/
INCLUDEPATH += /usr/include/liboath/

LIBS += /usr/lib/liboath.a /usr/lib/libzbar.a -lv4l2 -ljpeg

SOURCES += main.cpp \
            account.cpp \
            accountmodel.cpp \
            qrcodereader.cpp \

HEADERS += account.h \
            accountmodel.h \
            qrcodereader.h \

RESOURCES += \
    qml.qrc


# Install files into the click package
target.path = /
icon.files = ../ubuntu-authenticator.svg
icon.path = /
desktopfile.files = ../ubuntu-authenticator.desktop
desktopfile.path = /
apparmor.files = ../ubuntu-authenticator.json
apparmor.path = /

INSTALLS += icon desktopfile apparmor target


#This creates the manifest.json file, it is the description file for the
#click package.

#figure out the current build architecture
CLICK_ARCH=$$system(dpkg-architecture -qDEB_HOST_ARCH)

#do not remove this line, it is required by the IDE even if you do
#not substitute variables in the manifest file
UBUNTU_MANIFEST_FILE = $$PWD/../manifest.json.in

# substitute the architecture in the manifest file
manifest_file.output   = manifest.json
manifest_file.CONFIG  += no_link \
                         add_inputs_as_makefile_deps\
                         target_predeps
manifest_file.commands = sed s/@CLICK_ARCH@/$$CLICK_ARCH/g ${QMAKE_FILE_NAME} > ${QMAKE_FILE_OUT}
manifest_file.input = UBUNTU_MANIFEST_FILE
QMAKE_EXTRA_COMPILERS += manifest_file

#installation path of the manifest file
mfile.path = /
mfile.CONFIG += no_check_exist
mfile.files  += $$OUT_PWD/manifest.json
INSTALLS+=mfile
