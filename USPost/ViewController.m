//
//  ViewController.m
//  USPost
//
//  Created by marujun on 16/5/24.
//  Copyright © 2016年 MaRuJun. All rights reserved.
//

#import "ViewController.h"

@implementation NSString (HttpManager)
- (id)object
{
    id object = nil;
    @try {
        NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];;
        object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"%s [Line %d] JSON字符串转换成对象出错了-->\n%@",__PRETTY_FUNCTION__, __LINE__,exception);
    }
    @finally {
    }
    return object;
}
@end
@implementation NSObject (HttpManager)
- (NSString *)json
{
    NSString *jsonStr = @"";
    @try {
        if ([NSJSONSerialization isValidJSONObject:self]) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0  error:nil];
            jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }else{
            NSLog(@"data was not a proper JSON object, check All objects are NSString, NSNumber, NSArray, NSDictionary, or NSNull !!!!!");
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%s [Line %d] 对象转换成JSON字符串出错了-->\n%@",__PRETTY_FUNCTION__, __LINE__,exception);
    }
    return jsonStr;
}
@end

@interface DMJSONResponseSerializer : AFJSONResponseSerializer
@end

@implementation DMJSONResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
    [super responseObjectForResponse:response data:data error:error];
    
    if (data && [data length]) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return @"";
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [_textField setFont:[NSFont systemFontOfSize:13]];
    [_textView setFont:[NSFont systemFontOfSize:13]];
    
    _textField.placeholderString = @"http://api.us.com/chat?uid=101";
    [_textView setString:@"{\n     \n}"];
    
    DMJSONResponseSerializer *responseSerializer = [DMJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = nil;
    responseSerializer.removesKeysWithNullValues = NO;
    
    _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
    _sessionManager.responseSerializer = responseSerializer;
    
    self.requestBridge = [WebViewJavascriptBridge bridgeForWebView:_requestWebView];
    self.responseBridge = [WebViewJavascriptBridge bridgeForWebView:_responseWebView];
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"jsonview"];
    NSURL* fileURL = [NSURL fileURLWithPath:filePath];
    NSURLRequest* request = [NSURLRequest requestWithURL:fileURL];
    
    [self.indicatorView startAnimation:nil];
    self.indicatorView.hidden = YES;
    
    [[_requestWebView mainFrame] loadRequest:request];
    [[_responseWebView mainFrame] loadRequest:request];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
// Update the view, if already loaded.
}

- (IBAction)sendButtonAction:(NSButton *)sender
{
//    NSString *url = AFPercentEscapedStringFromString(_textField.stringValue);
    
    NSString *url = _textField.stringValue;
    url = [url stringByReplacingOccurrencesOfString:@"”" withString:@"\""];
    url = [url stringByReplacingOccurrencesOfString:@"“" withString:@"\""];
    url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _textField.stringValue = url;
    
    NSDictionary *body = [_textView.string object];
    
    if (!url || !url.length || ![NSURL URLWithString:url]) {
        [self.requestBridge callHandler:@"json_view" data:@{@"error":@"URL为空或者格式不正确"}];
        return;
    }
    
    if (_textView.string.length && !body) {
        [self.requestBridge callHandler:@"json_view" data:@{@"error":@"Body格式不正确，请重新输入"}];
        return;
    }
    
    if (_sessionManager.dataTasks.count) {
        [[_sessionManager.dataTasks lastObject] cancel];
    }
    
    NSMutableURLRequest *request;
    if (body && body.count) {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:0 error:nil]];
    }
    else {
        AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
        request = [serializer requestWithMethod:@"GET" URLString:url parameters:nil error:nil];
    }
    [request setTimeoutInterval:20];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    NSMutableDictionary *queryDic = [NSMutableDictionary dictionary];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
    NSArray *queryItems = urlComponents.queryItems;
    for (NSURLQueryItem *item in queryItems) {
        [queryDic setValue:item.value forKey:item.name];
    }
    [self.requestBridge callHandler:@"json_view" data:_textView.string];
    
    NSLog(@"request url: %@",request.URL.absoluteString);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.indicatorView.hidden = NO;
        [self.responseBridge callHandler:@"hide_view" data:nil];
    });
    
    NSURLSessionDataTask *dataTask = [_sessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"responseObject: %@",responseObject);
        if (error) NSLog(@"error: %@",error);
        
        if (responseObject && [responseObject object]) {
            [self.responseBridge callHandler:@"json_view" data:responseObject];
        }
        else if (responseObject && [responseObject length]) {
            [self.responseBridge callHandler:@"json_view" data:@{@"error":responseObject}];
        }
        else {
            [self.responseBridge callHandler:@"json_view" data:@{@"error":error.description}];
        }
        self.indicatorView.hidden = YES;
    }];
    [dataTask resume];
}

@end
