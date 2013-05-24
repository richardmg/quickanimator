#include <QDir>
#include <QGuiApplication>
#include <QQmlEngine>
#include <QQuickView>
#include <QQmlComponent>

#include "fileio.h"

int main(int argc, char* argv[])
{
    QGuiApplication app(argc,argv);

    qmlRegisterType<FileIO>("FileIO", 1, 0, "FileIO");

    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.loadUrl(QUrl("main.qml"));
    QObject *topLevel = component.create();
    QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);
    window->showFullScreen();

    return app.exec();
}

