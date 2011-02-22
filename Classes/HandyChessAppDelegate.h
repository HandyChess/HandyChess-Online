//
//  HandyChessAppDelegate.h
//  HandyChess
//
//  Created by Anton Zemyanov on 17.01.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HandyChessAppDelegate : NSObject <UIApplicationDelegate> 
{
	IBOutlet UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

-(void)precacheScenes;

@end
