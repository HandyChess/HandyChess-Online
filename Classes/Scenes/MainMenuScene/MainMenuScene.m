//
//  MainMenuScene.m
//  HandyChess
//
//  Created by Anton Zemyanov on 18.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MainMenuScene.h"
#import "MainMenuStaticLayer.h"
#import "MainMenuMenu.h"

#import <UIKit/UIKit.h>
#import "SoundEngine.h"

#import "Logger.h"

@implementation MainMenuScene

-(id)init
{
	if(self=[super init])
	{
		staticLayer = [MainMenuStaticLayer node];
		[self addChild:staticLayer];
		
		menuLayer = [MainMenuMenu node];
		[self addChild:menuLayer];
		
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

@end
