//
//  ChessSquare.m
//  HandyChess
//
//  Created by Anton Zemyanov on 17.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChessSquare.h"


@implementation ChessSquare

//@synthesize square;
@synthesize row;
@synthesize col;

+(id)squareWithCol:(SInt8)cl row:(SInt8)rw;
{
	return [[[self alloc] initWithCol:cl row:rw] autorelease];
}

+(id)squareWithTextNotation:(NSString*)txt;
{
	return [[[self alloc] initWithTextNotation:txt] autorelease];
}

-(id)initWithCol:(SInt8)cl row:(SInt8)rw
{
	if(self=[super init])
	{
		col = cl;
		row = rw;
	}
	return self;
}

-(id)initWithTextNotation:(NSString*)txt
{
	if(self=[super init])
	{
		col = (SInt8)([txt characterAtIndex:0] - 'a');
		row = (SInt8)([txt characterAtIndex:1] - '1');
	}
	return self;
}

-(id)copyWithZone:(NSZone *)zone
{
	// make a copy of object
	return [[[self class] allocWithZone:zone] initWithCol:col row:row];
}

-(BOOL)isOnBoard
{
	if(col>=CB_COL_A && col<=CB_COL_H && row>=CB_ROW_1 && row<=CB_ROW_8)
		return YES;
	
	return NO;
}

-(NSString*)description;
{
	char desc[3];
	desc[0] = col + 'a';
	desc[1] = row + '1';
	desc[2] = '\0';
	return [NSString stringWithUTF8String:desc];
}

@end
