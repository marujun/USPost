//
//  AppDelegate.m
//  USPost
//
//  Created by marujun on 16/5/24.
//  Copyright © 2016年 MaRuJun. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
{
    NSWindowController *newWindowController;
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"menu_open"];
    [menu addItemWithTitle:@"打开新的窗口" action:@selector(openNewWindow:) keyEquivalent: @"N"];
    [menu addItem: [NSMenuItem separatorItem]];
    
    return menu;
}

- (void)openNewWindow:(id)sender
{
    if (newWindowController) return;
    
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    newWindowController = [storyBoard instantiateControllerWithIdentifier:@"MainWindow"];
    [newWindowController showWindow:self];
}

@end
