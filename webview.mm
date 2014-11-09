#include <qglobal.h>

#include <QGuiApplication>
#include <QQuickWindow>
#include <QtGui/qpa/qplatformwindow.h>

#include "webview.h"

#if defined(Q_OS_IOS)

#include <UIKit/UIKit.h>

static NSURL *const kUrl = [NSURL URLWithString:@"http://www.google.com/imghp"];

void MyWebView::search()
{
    UIView *view = reinterpret_cast<UIView *>(QGuiApplication::focusWindow()->winId());
    if (!m_webView) {
        NSURLRequest *request = [NSURLRequest requestWithURL:kUrl];
        UIWebView *webView = [[UIWebView alloc] initWithFrame:view.frame];
        m_webView = webView;
        [webView loadRequest:request];
    }
    [view addSubview:reinterpret_cast<UIWebView *>(m_webView)];
}

MyWebView::~MyWebView()
{
    [reinterpret_cast<UIWebView *>(m_webView) release];
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
        NSURLRequest *request = [NSURLRequest requestWithURL:kUrl];
        [[webView mainFrame] loadRequest:request];
        WebDelegate *delegate = [[WebDelegate alloc] initWithMyWebView:this];
        [webView setPolicyDelegate:delegate];
    }

    [nsWindow setContentView:reinterpret_cast<WebView *>(m_webView)];
}

MyWebView::~MyWebView()
{
    [reinterpret_cast<WebView *>(m_webView) release];
}

#endif

MyWebView::MyWebView(QQuickItem *parent) :
    QQuickItem(parent)
    , m_qtView(0)
    , m_webView(0)
{
}
