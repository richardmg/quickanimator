#ifndef WEBVIEW_H
#define WEBVIEW_H

#include <QQuickItem>

class MyWebView : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QString imageUrl READ imageUrl NOTIFY imageUrlChanged)

public:
    explicit MyWebView(QQuickItem *parent = 0);
    ~MyWebView();

    QString imageUrl() {
        return m_imageUrl;
    }

    void *m_qtView;
    void *m_webView;
    QString m_imageUrl;

signals:
    void imageUrlChanged();

public slots:
    void search();
};

#endif // WEBVIEW_H
