//
//  ViewController.h
//  USPost
//
//  Created by marujun on 16/5/24.
//  Copyright © 2016年 MaRuJun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "AFNetworking.h"
#import "WebViewJavascriptBridge.h"

@interface NSString (HttpManager)
- (id)object;
@end

@interface NSObject (HttpManager)
- (NSString *)json;
@end

@interface ViewController : NSViewController

@property (weak) IBOutlet NSTextField *textField;
@property (weak) IBOutlet NSProgressIndicator *indicatorView;

@property (weak) IBOutlet WebView *requestWebView;
@property (weak) IBOutlet WebView *responseWebView;

@property WebViewJavascriptBridge *requestBridge;
@property WebViewJavascriptBridge *responseBridge;

@property(nonatomic, strong) AFHTTPSessionManager *sessionManager;


- (IBAction)sendButtonAction:(NSButton *)sender;

@end

