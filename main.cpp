#include <QDir>
#include <QApplication>
#include <QQmlEngine>
#include <QQuickView>
#include <QQmlComponent>

#include "fileio.h"

int main(int argc, char* argv[])
{
    QApplication app(argc,argv);

    qmlRegisterType<FileIO>("FileIO", 1, 0, "FileIO");

#ifdef Q_OS_OSX
    QDir bundleRoot = qApp->applicationDirPath();
    bundleRoot.cd(QLatin1String("../../"));
    QDir::setCurrent(bundleRoot.absolutePath());
#endif

    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.loadUrl(QUrl("qml/main.qml"));
    if ( !component.isReady() ) {
        qWarning("%s", qPrintable(component.errorString()));
        return -1;
    }

    QObject *topLevel = component.create();
    QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);
    window->showFullScreen();

    return app.exec();
}

