#include <QDir>
#include <QApplication>
#include <QQmlEngine>
#include <QQuickView>
#include <QQmlContext>
#include <QQmlApplicationEngine>

#include "fileio.h"
#include "webview.h"

int main(int argc, char* argv[])
{
    QApplication app(argc,argv);

    qmlRegisterType<FileIO>("FileIO", 1, 0, "FileIO");
    qmlRegisterType<MyWebView>("WebView", 1, 0, "WebView");

#ifdef Q_OS_OSX
    QDir bundleRoot = qApp->applicationDirPath();
    bundleRoot.cd(QLatin1String("../Resources"));
    QDir::setCurrent(bundleRoot.absolutePath());
#endif

    QQmlApplicationEngine engine;
#if TARGET_IPHONE_SIMULATOR
    engine.rootContext()->setContextProperty("simulator", true);
#else
    engine.rootContext()->setContextProperty("simulator", false);
#endif

    engine.load("qml/main.qml");
    return app.exec();
}

