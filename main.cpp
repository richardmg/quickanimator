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

    QQmlApplicationEngine engine("qml/main.qml");
//    engine.rootContext()->setContextProperty("WebView", new MyWebView());
    return app.exec();
}

