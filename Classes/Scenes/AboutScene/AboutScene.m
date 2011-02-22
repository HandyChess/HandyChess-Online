//
//  MainMenuScene.m
//  HandyChess
//
//  Created by Anton Zemyanov on 18.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AboutScene.h"
#import "AboutStaticLayer.h"
#import "AboutMenu.h"

@implementation AboutScene

-(id)init
{
	if(self=[super init])
	{
		staticLayer = [AboutStaticLayer node];
		[self addChild:staticLayer];
		
		aboutMenu = [AboutMenu node];
		[self addChild:aboutMenu];
		
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

@end
