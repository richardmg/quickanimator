#include <qglobal.h>

#include <QGuiApplication>
#include <QQuickWindow>
#include <QtGui/qpa/qplatformwindow.h>

#include "webview.h"

#include <Foundation/Foundation.h>

static NSURL *const kUrl = [NSURL URLWithString:@"http://www.google.com/imghp"];

#if defined(Q_OS_IOS)

#include <UIKit/UIKit.h>

@interface WebDelegate : NSObject <UIWebViewDelegate>
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
        navigationType:(UIWebViewNavigationType)navigationType
{
    Q_UNUSED(webView);
    Q_UNUSED(navigationType);

    NSString *script = @"var names = []; var a = document.getElementsByTagName(\"IMG\");for (var i=0, len=a.length; i<len; i++){names.push(document.images[i].src);}String(names);";
    NSString *urls = [self.webView stringByEvaluatingJavaScriptFromString:script];
    NSLog(@"urls:", urls);

//    NSLog(@"req: %@", request.URL.path);
//    NSLog(@"req: %@", request.URL.query);
//    NSLog(@"req: %@", request.URL.relativeString);
    NSLog(@"req: %@", request.HTTPBody);
    NSLog(@"------");

//    NSDictionary *element = [actionInformation objectForKey:@"WebActionElementKey"];
//    NSString *imageUrl = [[element objectForKey:@"WebElementImageURL"] absoluteString];
//    if (imageUrl) {
//        [listener ignore];
//        m_webView->m_imageUrl = QString::fromNSString(imageUrl);
//        emit m_webView->imageUrlChanged();
//        [[sender window] setContentView:static_cast<NSView *>(m_webView->m_qtView)];
//    }
    return YES;
}

@end

void MyWebView::search()
{
    UIView *view = reinterpret_cast<UIView *>(QGuiApplication::focusWindow()->winId());
    if (!m_webView) {
        NSURLRequest *request = [NSURLRequest requestWithURL:kUrl];
        UIWebView *webView = [[UIWebView alloc] initWithFrame:view.bounds];
        m_webView = webView;
        webView.delegate = [[WebDelegate alloc] initWithMyWebView:this];
        [webView loadRequest:request];
    }
    [view addSubview:reinterpret_cast<UIWebView *>(m_webView)];
}

MyWebView::~MyWebView()
{
    UIWebView *webView = reinterpret_cast<UIWebView *>(m_webView);
    WebDelegate *delegate = webView.delegate;
    webView.delegate = nil;
    [delegate release];
    [webView release];
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
        [webView setPolicyDelegate:[[WebDelegate alloc] initWithMyWebView:this]];
    }

    [nsWindow setContentView:reinterpret_cast<WebView *>(m_webView)];
}

MyWebView::~MyWebView()
{
    WebView *webView = reinterpret_cast<WebView *>(m_webView);
    WebDelegate *delegate = [webView policyDelegate];
    [webView setPolicyDelegate:nil];
    [webView release];
    [delegate release];
}

#endif

MyWebView::MyWebView(QQuickItem *parent) :
    QQuickItem(parent)
    , m_qtView(0)
    , m_webView(0)
{
}
