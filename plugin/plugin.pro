TEMPLATE = lib
TARGET = nymea-client
QT += qml quick bluetooth charts websockets network
CONFIG += plugin c++11

TARGET = $$qtLibraryTarget($$TARGET)
uri = io.guh.nymea

INCLUDEPATH += ../libnymea-common ../libnymea-app-core

DISTFILES = qmldir

HEADERS += \
    nymeaclientplugin.h

SOURCES += \
    nymeaclientplugin.cpp

LIBS += -lnymea-common -L../libnymea-common/ -lnymea-app-core -L../libnymea-app-core
linux:!android:LIBS += -lavahi-client -lavahi-common

!equals(_PRO_FILE_PWD_, $$OUT_PWD) {
    copy_qmldir.target = $$OUT_PWD/qmldir
    copy_qmldir.depends = $$_PRO_FILE_PWD_/qmldir
    copy_qmldir.commands = $(COPY_FILE) "$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)" "$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)"
    QMAKE_EXTRA_TARGETS += copy_qmldir
    PRE_TARGETDEPS += $$copy_qmldir.target
}

qmldir.files = qmldir
unix {
    installPath = $$[QT_INSTALL_QML]/$$replace(uri, \., /)
    qmldir.path = $$installPath
    target.path = $$installPath
    INSTALLS += target qmldir
}
