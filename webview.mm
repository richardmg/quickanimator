#include <qglobal.h>

#include <QGuiApplication>
#include <QQuickWindow>
#include <QtGui/qpa/qplatformwindow.h>

#include "webview.h"

#if defined(Q_OS_IOS)

#include <UIKit/UIKit.h>

void MyWebView::search(const QString &url)
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url.toNSString()]];
    UIView *view = reinterpret_cast<UIView *>(QGuiApplication::focusWindow()->winId());
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    [webView loadRequest:request];
    [view addSubview:webView];
}

#elif defined(Q_OS_OSX)

#include <WebKit/WebKit.h>
#include <Cocoa/Cocoa.h>

@interface WebDelegate : NSObject
{
    MyWebView *m_webView;
}
@end

@implementation WebDelegate

- (id)initWithMyWebView:(MyWebView *)webView
{
    self = [super init];
    if (self) {
        m_webView = webView;
    }
    return self;
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener
{
    Q_UNUSED(request);
    Q_UNUSED(frame);

    NSDictionary *element = [actionInformation objectForKey:@"WebActionElementKey"];
    NSString *imageUrl = [[element objectForKey:@"WebElementImageURL"] absoluteString];
    if (imageUrl) {
        [listener ignore];
        m_webView->m_imageUrl = QString::fromNSString(imageUrl);
        emit m_webView->imageUrlChanged();
        [[sender window] setContentView:static_cast<NSView *>(m_webView->m_qtView)];
    } else {
        [listener use];
    }
}

@end

void MyWebView::search()
{
    NSWindow *nsWindow = [reinterpret_cast<NSView *>(QGuiApplication::focusWindow()->winId()) window];
    if (!m_webView) {
        m_qtView = [nsWindow contentView];
        WebView *webView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, 800, 600) frameName:nil groupName:nil];
        m_webView = webView;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com/imghp"]];
        [[webView mainFrame] loadRequest:request];
        WebDelegate *delegate = [[WebDelegate alloc] initWithMyWebView:this];
        [webView setPolicyDelegate:delegate];
    }

    [nsWindow setContentView:reinterpret_cast<WebView *>(m_webView)];
}

#endif

MyWebView::MyWebView(QQuickItem *parent) :
    QQuickItem(parent)
    , m_qtView(0)
    , m_webView(0)
{
}

MyWebView::~MyWebView()
{
    [reinterpret_cast<WebView *>(m_webView) release];
}
