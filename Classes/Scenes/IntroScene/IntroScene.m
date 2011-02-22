//
//  IntroScene.m
//  HandyChess
//
//  Created by Anton Zemyanov on 17.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "IntroScene.h"
#import "IntroStaticLayer.h"
#import "IntroMenu.h"

#import "Logger.h"

@implementation IntroScene

-(id)init
{
	if(self = [super init])
	{
		MsgLog(@"Create intro scene");
		staticLayer = [[IntroStaticLayer alloc] init];
		[self addChild:staticLayer];
		
		menuLayer = [[IntroMenu alloc] init];
		[self addChild:menuLayer];
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

@end
