######################################################################
# Automatically generated by qmake (3.0) Fri May 24 19:47:31 2013
######################################################################

TEMPLATE = app
TARGET = animstudio
INCLUDEPATH += .
QT += quick qml widgets
QMAKE_INFO_PLIST = Info.plist

# Input
HEADERS += fileio.h
SOURCES += fileio.cpp main.cpp

qml.files = $$PWD/qml
dummy.files = $$PWD/dummy.jpeg
QMAKE_BUNDLE_DATA += qml dummy

OTHER_FILES += qml/*.qml \
    qml/ControlPanelSubMenu.qml
