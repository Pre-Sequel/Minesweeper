//
//  AppDelegate.h
//  Minesweeper
//
//  Created by Steve McQueen on 07.02.2018.
//  Copyright © 2018 Steve McQueen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

