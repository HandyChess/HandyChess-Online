//
//  HiResolutionTimer.m
//  HandyChess
//
//  Created by Anton Zemyanov on 3/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HighResolutionTimer.h"
#import <sys/time.h>

@implementation HighResolutionTimer

@synthesize isStarted;
@synthesize timeElapsed;

-(id)init
{
	if(self = [super init])
	{
		// init here
		isStarted = NO;
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

// timer management
-(void)start
{
	struct timeval tm;
	gettimeofday(&tm, NULL);
	
	timeElapsed = 0;
	startTimestamp = tm.tv_sec + (tm.tv_usec/1000000.0);
	isStarted = YES;
	
	return;
}

-(void)stop
{
	timeElapsed = 0;
	startTimestamp = 0;
	isStarted = NO;
	
	return;
}

// timer update
-(void)pump
{
	double now;
	
	if(!isStarted)
		return;
	
	struct timeval tm;
	gettimeofday(&tm, NULL);
	now = tm.tv_sec + (tm.tv_usec/1000000.0);
	
	timeElapsed = (float)(now - startTimestamp);
	
	return;
}

@end
