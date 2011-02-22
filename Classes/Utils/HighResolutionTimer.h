//
//  HiResolutionTimer.h
//  HandyChess
//
//  Created by Anton Zemyanov on 3/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HighResolutionTimer : NSObject 
{
	BOOL	isStarted;
	double	startTimestamp;
	float	timeElapsed;
}

@property (readonly) BOOL isStarted;
@property (readonly) float timeElapsed;

// timer management
-(void)start;
-(void)stop;

// timer update
-(void)pump;

@end
