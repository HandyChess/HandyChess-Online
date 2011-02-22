//
//  LayoutLayer.m
//  HandyChess
//
//  Created by Anton Zemyanov on 17.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Logger.h"
#import "LayoutLayer.h"

#define SCREEN_WIDTH	320
#define SCREEN_HEIGHT	480

@implementation LayoutLayer

-(BOOL)layoutElements:(nodeLayout*)layout number:(NSUInteger)num
{
	// align controls
	for(int cnt=0; cnt<num; ++cnt)
	{
		nodeLayout lay = layout[cnt];
		CocosNode *nd = [self getChildByTag:lay.tag];
		if(nd==nil)
			[NSException raise:@"INT" format:@"cannot retrieve node by tag"];
		// position
		cpVect pos = lay.position;
		CGSize siz = lay.size;
		pos.x = pos.x + siz.width/2;
		pos.y = SCREEN_HEIGHT - pos.y + siz.height/2;
		MsgLog(@"LAY: Node tag=%x position x=%f y=%f", lay.tag, pos.x, pos.y);
		nd.position = pos;
	}
	return YES;
}

@end
