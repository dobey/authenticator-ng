TEMPLATE = subdirs

load(ubuntu-click)

SUBDIRS += app

UBUNTU_TRANSLATION_DOMAIN="authenticator"

UBUNTU_TRANSLATION_SOURCES+= \
    $$files(app/*.qml,true) \
    $$files(app/*.js,true)

UBUNTU_PO_FILES+=$$files(po/*.po)
