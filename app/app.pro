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

# Copy qml to build dir for running with qtcreator
qmlfolder.source = app/qml
qmlfolder.target = .
DEPLOYMENTFOLDERS = qmlfolder

include(../deployment.pri)
