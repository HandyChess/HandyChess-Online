//
//  Polyglot.m
//  HandyChess
//
//  Created by Anton Zemyanov on 18.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Polyglot.h"
#import "Logger.h"

#import "PolyglotBridge.h"

#define MAX_FEN_STRING_SIZE		256

@interface Polyglot (Private)
-(BOOL)style12ToFen:(NSDictionary*)style12Data buffer:(char*)buff;
@end

@implementation Polyglot

-(id)init
{
	if(self = [super init])
	{
		bridge_init();
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

-(NSArray*)legalMovesForPosition:(NSDictionary*)style12Data
{
	MsgLog(@"POL: legalMovesForPosition");
	NSMutableArray *retArr = [NSMutableArray array];
	
	//build FEN from style12 data
	char fen_string[MAX_FEN_STRING_SIZE];
	memset(fen_string, 0, sizeof(fen_string));
	[self style12ToFen:style12Data buffer:fen_string];
	
	// Log FEN string
	MsgLog(@"POL: FEN is '%s'",fen_string);
	
	// FEN to move list
	char buff[1024];
	int movesNumber = bridge_get_move_list(fen_string, buff);
	MsgLog(@"POL: legal_moves=%d list='%s'", movesNumber, buff);
	
	// Parse movelist
	if(movesNumber==0)
		return nil;
	NSArray *moveList = [[NSString stringWithUTF8String:buff] componentsSeparatedByString:@"|"];
	//MsgLog(@"POL: Moves array=%@", moveList);
	
	for(NSString *mv in moveList)
	{
		NSString *fr = [mv substringWithRange:NSMakeRange(0, 2)];
		NSString *to = [mv substringWithRange:NSMakeRange(2, 2)];
		[retArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:fr,@"From",to,@"To",nil]];
	}
	//MsgLog(@"POL: returned array:%@", retArr);
	
	return [NSArray arrayWithArray:retArr];
}

/*
-(BOOL)isCaptureMove:(NSString*)move;
-(BOOL)isPromoteMove:(NSString*)move;
-(BOOL)isEnPassantMove:(NSString*)move;
-(BOOL)isCastleMov:(NSString*)move;
*/
 
-(BOOL)style12ToFen:(NSDictionary*)style12Data buffer:(char*)buff
{
	char *fen = buff;
	
	// Fen position
	NSUInteger empty = 0;
	NSString *pos = [style12Data objectForKey:@"Board"];
	for(int ind=0; ind<[pos length]; ++ind)
	{
		unichar ch = [pos characterAtIndex:ind];
		
		// is '-'?
		if(ch=='-')
		{
			++empty;
			if(ind==[pos length]-1)
			{
				// last char in position, flush it
				*fen++ = empty + '0';
			}
			continue;
		}
		
		// not '-' character or last char
		if(empty)
		{
			*fen++ = empty + '0';
			empty = 0;
		}
		
		if(ch==' ')
			*fen++ = '/';
		else
			*fen++ = (char)ch;
	}
	
	// Fen side to move
	*fen++ = ' ';
	*fen++ = [[style12Data objectForKey:@"IsWhiteMove"] isEqualToString:@"W"] ? 'w' : 'b';
	
	// Castle startus
	BOOL isEmpty = YES;
	*fen++ = ' ';
	if([[style12Data objectForKey:@"CanWhiteCastleShort"] boolValue])
	{
		*fen++ = 'K';
		isEmpty = NO;
	}
	if([[style12Data objectForKey:@"CanWhiteCastleLong"] boolValue])
	{
		*fen++ = 'Q';
		isEmpty = NO;
	}
	if([[style12Data objectForKey:@"CanBlackCastleShort"] boolValue])
	{
		*fen++ = 'k';
		isEmpty = NO;
	}
	if([[style12Data objectForKey:@"CanBlackCastleLong"] boolValue])
	{
		*fen++ = 'q';
		isEmpty = NO;
	}
	if(isEmpty)
		*fen++ = '-';
	
	// EnPassant
	int enCol = [[style12Data objectForKey:@"EnPassantCol"] intValue];
	*fen++ = ' ';
	if(enCol>=0)
	{
		// to be fixed
		*fen++ = 'a'+enCol;
		if( [[style12Data objectForKey:@"IsWhiteMove"] isEqualToString:@"W"] )
			*fen++ = '6';
		else
			*fen++ = '3';
	}
	else
	{
		*fen++ = '-';
	}
	
	// halfmove/fullmove
	int half = [[style12Data objectForKey:@"MovesSinceIrreversible"] intValue];
	int full = [[style12Data objectForKey:@"MoveNumber"] intValue];
	sprintf(fen," %d %d", half, full);

	return YES; 
}


@end
