/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import <SenTestingKit/SenTestingKit.h>

#import "CDVWebViewTest.h"
#import "CDVViewController.h"
#import "AppDelegate.h"

@interface CDVStartPageTestViewController : UIViewController
@property (strong, nonatomic) CDVViewController* vc1;
@property (strong, nonatomic) CDVViewController* vc2;
@property (strong, nonatomic) CDVViewController* vc3;
@end

@implementation CDVStartPageTestViewController
@synthesize vc1 = _vc1, vc2 = _vc2, vc3 = _vc3;

- (void)loadView
{
    _vc1 = [[CDVViewController alloc] init];
    _vc1.wwwFolderName = @"www";
    _vc1.startPage = @"index.html";
    [self addChildViewController:_vc1];

    _vc2 = [[CDVViewController alloc] init];
    _vc2.wwwFolderName = @"www";
    _vc2.startPage = @"index.html?delta=true";
    [self addChildViewController:_vc2];
    
    _vc3 = [[CDVViewController alloc] init];
    _vc3.wwwFolderName = @"file://some/file/path";
    _vc3.startPage = @"index.html";
    [self addChildViewController:_vc3];

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView* contentView = [[UIView alloc] initWithFrame:applicationFrame];

    CGRect sub1, sub2, sub3;
    CGRectDivide(applicationFrame, &sub1, &sub2, applicationFrame.size.height / 3, CGRectMinYEdge);
    [_vc1.view setBounds:sub1];
    [_vc2.view setBounds:sub2];
    [_vc3.view setBounds:sub3];

    [contentView addSubview:_vc1.view];
    [contentView addSubview:_vc2.view];
    [contentView addSubview:_vc3.view];

    self.view = contentView;
}

@end

@interface CDVStartPageTest : CDVWebViewTest
@end

@implementation CDVStartPageTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testParametersInStartPage
{
    CDVStartPageTestViewController* rootVc = [[CDVStartPageTestViewController alloc] init];

    self.appDelegate.window.rootViewController = rootVc;

    NSString* geHREF = @"window.location.href";
    [self waitForConditionName:@"getting href" block:^{
        return (BOOL)(rootVc.vc1.webView.request != nil && rootVc.vc1.webView.request != nil);
    }];

    NSString* href = [rootVc.vc1.webView stringByEvaluatingJavaScriptFromString:geHREF];
    STAssertTrue([href hasSuffix:@"index.html"], @"href should point to index.html");

    href = [rootVc.vc2.webView stringByEvaluatingJavaScriptFromString:geHREF];
    STAssertTrue([href hasSuffix:@"index.html?delta=true"], @"href should point to index.html?delta=true");
    
    href = [rootVc.vc3.webView stringByEvaluatingJavaScriptFromString:geHREF];
    STAssertTrue([href hasPrefix:@"file://some/file/path"], @"href should point to file://some/file/path/index.html");
}

@end
