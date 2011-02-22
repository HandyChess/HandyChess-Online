//
//  main.m
//  HandyChess
//
//  Created by Anton Zemyanov on 17.01.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Logger.h"

int main(int argc, char *argv[]) 
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	OpenLog();
	DbgLog(@"Applcation started");
    int retVal = UIApplicationMain(argc, argv, nil, @"HandyChessAppDelegate");
	DbgLog(@"Applcation finished");
    CloseLog();
	
	[pool release];
    return retVal;
}
