//
//  FramedLabel.m
//  HandyChess
//
//  Created by Anton Zemlyanov on 1/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FramedLabel.h"


@implementation FramedLabel

-(void)draw
{
	[super draw];
	drawLine(0, 0, 0, self.contentSize.height);
	drawLine(0, self.contentSize.height, self.contentSize.width, self.contentSize.height);
	drawLine(self.contentSize.width, self.contentSize.height, self.contentSize.width, 0);
	drawLine(self.contentSize.width, 0, 0, 0);
}

@end
