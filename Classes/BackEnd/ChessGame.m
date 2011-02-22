//
//  ChessGame.m
//  HandyChess
//
//  Created by Anton Zemyanov on 09.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChessGame.h"
#import "Logger.h"
#import "Polyglot.h"
#import "ChessBackEnd.h"
#import "ChessSquare.h"
#import "ChessPiece.h"
#import "HighResolutionTimer.h"

#include "regex.h"

// my relation to position
#define RELATION_ISOLATED			(-3)
#define RELATION_EXAMINE_OBSERVER	(-2)
#define RELATION_EXAMINER			2
#define RELATION_OPPONENTS_MOVE		(-1)
#define RELATION_MY_MOVE				1
#define RELATION_OBSERVER			0

#define MAX_MATCHES					32
#define RE_MOVE						"^([PNBRQKpnbrpk])/([a-h][1-8])-([a-h][1-8])=?([QRBNqrbn])?$"
#define RE_SHORT_CASTLE				"^o-o$"
#define RE_LONG_CASTLE				"^o-o-o$"


// constants
static BOOL constInitialized = NO;
// regex
static regex_t		reMove;
static regex_t		reShortCastle;
static regex_t		reLongCastle;

// white king
static ChessSquare	 *whKingOrig;
static ChessSquare	 *whKingDestShort;
static ChessSquare	 *whKingDestLong;
// white king rook
static ChessSquare   *whRookOrigShort;
static ChessSquare	 *whRookDestShort;
// white queen rook
static ChessSquare	 *whRookOrigLong;
static ChessSquare	 *whRookDestLong;
// black king
static ChessSquare	 *blKingOrig;
static ChessSquare	 *blKingDestShort;
static ChessSquare	 *blKingDestLong;
// black king rook
static ChessSquare   *blRookOrigShort;
static ChessSquare	 *blRookDestShort;
// black queen rook
static ChessSquare	 *blRookOrigLong;
static ChessSquare	 *blRookDestLong;



@interface ChessGame (Private)
// init constants
-(void)initializeConstants;
// request GUI user to make a move (if moves are available)
-(void)requestUserMove;
// verbose to algebraic move
-(NSDictionary*)verboseToAlgebraic:(NSString*)move color:(NSString*)col;
// get possible moves for current position
-(NSArray*)getLegalMoves:(NSDictionary*)style12Data;
@end


@implementation ChessGame

@synthesize backEnd;

-(id)init
{
	if(self=[super init])
	{
		polyglot = [[Polyglot alloc] init];
		
		state = kGameStateNotInGame;
		
		// timers
		whiteTimer = [[HighResolutionTimer alloc] init];
		blackTimer = [[HighResolutionTimer alloc] init];
		
		// regular expressions
		int status;
		status = regcomp(&reMove, RE_MOVE, REG_EXTENDED);
		if(status)
			[NSException raise:@"GAM" format:@"Cannot compile regex"];
		status = regcomp(&reShortCastle, RE_SHORT_CASTLE, REG_EXTENDED);
		if(status)
			[NSException raise:@"GAM" format:@"Cannot compile regex"];
		status = regcomp(&reLongCastle, RE_LONG_CASTLE, REG_EXTENDED);
		if(status)
			[NSException raise:@"GAM" format:@"Cannot compile regex"];
		
		[self initializeConstants];
	}
	return self;
}

-(void)dealloc
{
	regfree(&reMove);
	regfree(&reShortCastle);
	regfree(&reLongCastle);
	
	[blackTimer release];
	[whiteTimer release];
	
	[polyglot release];
	[super dealloc];
}

// init constants
-(void)initializeConstants
{
	if(constInitialized)
		return;
	
	// white
	whKingOrig		= [[ChessSquare alloc] initWithCol:CB_COL_E row:CB_ROW_1];
	whKingDestShort	= [[ChessSquare alloc] initWithCol:CB_COL_G row:CB_ROW_1];
	whKingDestLong	= [[ChessSquare alloc] initWithCol:CB_COL_C row:CB_ROW_1];

	whRookOrigShort	= [[ChessSquare alloc] initWithCol:CB_COL_H row:CB_ROW_1];
	whRookDestShort	= [[ChessSquare alloc] initWithCol:CB_COL_F row:CB_ROW_1];

	whRookOrigLong	= [[ChessSquare alloc] initWithCol:CB_COL_A row:CB_ROW_1];
	whRookDestLong	= [[ChessSquare alloc] initWithCol:CB_COL_D row:CB_ROW_1];

	// black
	blKingOrig		= [[ChessSquare alloc] initWithCol:CB_COL_E row:CB_ROW_8];
	blKingDestShort	= [[ChessSquare alloc] initWithCol:CB_COL_G row:CB_ROW_8];
	blKingDestLong	= [[ChessSquare alloc] initWithCol:CB_COL_C row:CB_ROW_8];

	blRookOrigShort	= [[ChessSquare alloc] initWithCol:CB_COL_H row:CB_ROW_8];
	blRookDestShort	= [[ChessSquare alloc] initWithCol:CB_COL_F row:CB_ROW_8];

	blRookOrigLong	= [[ChessSquare alloc] initWithCol:CB_COL_A row:CB_ROW_8];
	blRookDestLong	= [[ChessSquare alloc] initWithCol:CB_COL_F row:CB_ROW_8];
	
	// regular expressions
	
	constInitialized = YES;
	return;
}

// game init/end calls
-(void)startingGame:(NSDictionary*)param
{
	MsgLog(@"GAM: starting game");
	
	// cache data
	[startingParams release];
	startingParams = [param retain];
	
	return;
}

-(void)gameStarted:(NSDictionary*)param
{
	MsgLog(@"GAM: state=kGameStateWaitStyle12");
	state = kGameStateWaitStyle12;
	
	// extend param with data from startingParams
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:param];
	[dict setValue:startingParams forKey:@"StartingParams"];
	
	// start timer pump
	pumpTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
							target:self selector:@selector(pump:) userInfo:self repeats:YES];

	// game timers are stopped
	[whiteTimer stop];
	[blackTimer stop];
	
	// notify about game start
	[backEnd rspGameStarted:dict];
	
	return;
}

-(void)gameEnded:(NSDictionary*)param;
{
	MsgLog(@"GAM: state=kGameStateNotInGame");
	state = kGameStateNotInGame;
	
	// game timers are stopped
	[whiteTimer stop];
	[blackTimer stop];

	// stop timer pump
	[pumpTimer invalidate];
	
	// notify about game end
	[backEnd rspGameEnded:param];
	
	return;
}

// process next position
-(void)processStyle12:(NSDictionary*)style12Data
{
	MsgLog(@"GAM: process style12 data");
	/*
	for(NSString *key in style12Data)
	{
		MsgLog(@"GAM:   key=%@ value=%@",key,[style12Data objectForKey:key]);
	}
	*/
	
	// cache style12
	[lastStyle12 release];
    lastStyle12 = [style12Data retain];
	
	// check it's my or opponents move
	int relation = [[style12Data objectForKey:@"Relation"] intValue];
	if( relation!=RELATION_MY_MOVE && relation!=RELATION_OPPONENTS_MOVE)
	{
		[NSException raise:@"GAM" format:@"Relation to position is invalid"];
		return;
	}
	
	// syncronize clocks with data from server
	whiteTime = [[style12Data objectForKey:@"WhiteTime"] floatValue];
	blackTime = [[style12Data objectForKey:@"BlackTime"] floatValue];
	
	// switch running timer side
	if(![[style12Data objectForKey:@"VerboseMove"] isEqualToString:@"none"])
	{
		// last move is not none
		if([[style12Data objectForKey:@"IsWhiteMove"] isEqualToString:@"W"])
		{
			// white's time is ticking
			[whiteTimer start];
			[blackTimer stop];
		}
		else
		{
			// white's time is ticking
			[whiteTimer stop];
			[blackTimer start];
		}
	}
	
	// update GUI
	SInt32   num       = [[style12Data objectForKey:@"MoveNumber"] intValue];
	NSString *verbMove = [style12Data objectForKey:@"VerboseMove"];
	NSString *pretMove = [style12Data objectForKey:@"PrettyMove"];
	NSString *color    = [style12Data objectForKey:@"IsWhiteMove"];
	NSString *oppColor = [color isEqualToString:@"W"] ? @"B" : @"W";
	MsgLog(@"VerboseMove='%@' color='%@'",verbMove, oppColor);
	
	NSMutableDictionary *showMove = [NSMutableDictionary dictionary];
	if([color isEqualToString:@"W"])
	   num -= 1;
	[showMove setObject:[NSString stringWithFormat:@"%d",num] forKey:@"MoveNumber"];
	[showMove setObject:pretMove forKey:@"PrettyMove"];
	[showMove setObject:verbMove forKey:@"VerboseMove"];
	[showMove setObject:oppColor forKey:@"PieceColor"];
	[backEnd rspShowMove:showMove];
	
	// side to move
	NSMutableDictionary *sidePars = [NSMutableDictionary dictionary];
	[sidePars setObject:color forKey:@"Color"];
	[backEnd rspSideToMove:sidePars];
	
	if(relation==RELATION_MY_MOVE)
	{
		// make a move that opponent made, if any
		if(![[style12Data objectForKey:@"VerboseMove"] isEqualToString:@"none"])
		{
			MsgLog(@"GAM: state=kGameStateMakingOppMove");
			state = kGameStateMakingOppMove;
				
			// if not a castle, only one piece is moved
			piecesToMove = 1;
			piecesMoved  = 0;
			NSMutableDictionary *algMove = [NSMutableDictionary dictionaryWithDictionary:
					[self verboseToAlgebraic:verbMove color:oppColor]];
			[algMove setObject:@"1" forKey:@"IsMarked"];
			[backEnd rspMovePiece:algMove];
			//[backEnd rspSyncPosition:[style12Data objectForKey:@"Board"]];
		}
		else
		{
			[backEnd rspSyncPosition:[style12Data objectForKey:@"Board"]];
			[self requestUserMove];
		}
	}
	else
	{
		// this is opponent move, just sync board position
		[backEnd rspSyncPosition:[style12Data objectForKey:@"Board"]];
		
		MsgLog(@"GAM: state=kGameStateWaitStyle12");
		state = kGameStateWaitStyle12;
	}
	return;
}

// responses from GUI
-(void)playerMove:(NSDictionary*)move
{
	MsgLog(@"GAM: player move=%@",move);
	
	BOOL isPlayerWhite = NO;
	if( [[lastStyle12 objectForKey:@"IsWhiteMove"] isEqualToString:@"W"] )
		isPlayerWhite = YES;

	MsgLog(@"GAM isPlayerWhite=%d", isPlayerWhite);
	ChessPiece *pc = [[[ChessPiece alloc] initWithPieceString:[move objectForKey:@"Piece"]] autorelease];
	// Default move state vars
	piecesToMove = 1;
	piecesMoved  = 0;
	[pieceValue release];
	[pieceColor release];
	[orig release];
	[dest release];
	[pieceToRemove release];
	pieceValue = [[[move objectForKey:@"Piece"] uppercaseString] retain];
	pieceColor = [[[move objectForKey:@"Color"] uppercaseString] retain];
	orig = [[ChessSquare squareWithTextNotation:[move objectForKey:@"From"]] retain];
	dest = [[ChessSquare squareWithTextNotation:[move objectForKey:@"To"]] retain];
	pieceToRemove = nil;
	isPromoMove = NO;

	switch(pc.value)
	{
		case kPiecePawn:
		{
			// simple move, capture or en-passant capture
			int enPassCol = [[lastStyle12 objectForKey:@"EnPassantCol"] intValue];
			if( enPassCol>=CB_COL_A && dest.col==enPassCol )
			{
				// en-passant capture
				if(pc.color==kPieceWhite)
					// remove black piece at rank 5
					pieceToRemove = [[ChessSquare squareWithCol:enPassCol row:CB_ROW_5] retain];
				else
					// remove white piece at rank 4
					pieceToRemove = [[ChessSquare squareWithCol:enPassCol row:CB_ROW_4] retain];
			}
			// make a move on board
			state = kGameStateMakingMyMove;
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
								  [orig description],@"From",[dest description],@"To",nil];
			[backEnd rspMovePiece:dict];
			break;
		}
			
		case kPieceKing:
		{
			// just simple move or capture
			// make a move on board
			state = kGameStateMakingMyMove;
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
								  [orig description],@"From",[dest description],@"To",nil];
			[backEnd rspMovePiece:dict];
			break;
		}
		case kPieceKnight:
		case kPieceBishop:
		case kPieceRook:
		case kPieceQueen:
		{
			// just simple move or capture
			// make a move on board
			state = kGameStateMakingMyMove;
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
								  [orig description],@"From",[dest description],@"To",nil];
			[backEnd rspMovePiece:dict];
			
			break;
		}
		default:
		{
			[NSException raise:@"GAM" format:@"Why I am here"];
			break;
		}
	}
}

-(void)pieceMoved:(NSDictionary*)data
{
	MsgLog(@"GAM: piece moved");
	switch(state)
	{
		case kGameStateMakingOppMove:
			{
				++piecesMoved;
				if(piecesMoved<piecesToMove)
					// not all move phases finished
					break;
				
				// now sync the position
				[backEnd rspSyncPosition:[lastStyle12 objectForKey:@"Board"]];
				
				// request user to make a move (if any or if not mated)
				[self requestUserMove];
			}
			break;
			
		case kGameStateMakingMyMove:
			{
				++piecesMoved;
				if(piecesMoved<piecesToMove)
					// not all move phases finished
					break;
				
				// if move is a promo, ask the new piece value
				// otherwise send move to a server
				if([pieceValue isEqualToString:@"P"] && [pieceColor isEqualToString:@"W"] && dest.row==CB_ROW_8)
				{
					// white pawn is being promoted
					MsgLog(@"GAM: state=kGameStateGettingPromo");
					state = kGameStateGettingPromo;
					[backEnd rspGetPromoPiece:[NSDictionary dictionaryWithObjectsAndKeys:@"W",@"PieceColor",nil]];
				}	
				else if([pieceValue isEqualToString:@"P"] && [pieceColor isEqualToString:@"B"] && dest.row==CB_ROW_1)
				{
					// black pawn is being promoted
					MsgLog(@"GAM: state=kGameStateGettingPromo");
					state = kGameStateGettingPromo;
					[backEnd rspGetPromoPiece:[NSDictionary dictionaryWithObjectsAndKeys:@"B",@"PieceColor",nil]];
				}
				else
				{
					// no promo - send move 'as is'
					NSString *move = [NSString stringWithFormat:@"%@-%@", [orig description], [dest description]];
					MsgLog(@"GAM: sending move %@", move);
					[backEnd.proto FicsMsgSendMove:move];

					MsgLog(@"GAM: state=kGameStateWaitStyle12");
					state = kGameStateWaitStyle12;
				}
			}
			break;
			
		case kGameStateNotInGame:
			// game finished while piece was moving, normal thing
			break;
			
		default:
			[NSException raise:@"GAM" format:@"Invalid state=%d",state];
			break;
	}
}

// got answer from user to which piece to promote
-(void)promoPiece:(NSDictionary*)data
{
	if(state!=kGameStateGettingPromo)
		[NSException raise:@"GAM" format:@"Unxpected promotion"];
	
	// send promotion move - send move 'as is'
	NSString *promoPiece = [data objectForKey:@"PromoteTo"];
	NSString *move = [NSString stringWithFormat:@"promote %@\n%@-%@",  promoPiece, [orig description], [dest description]];
	MsgLog(@"GAM: sending PROMO move %@", move);
	[backEnd.proto FicsMsgSendMove:move];
	
	// wait next style12
	MsgLog(@"GAM: state=kGameStateWaitStyle12");
	state = kGameStateWaitStyle12;
	
	return;
}

-(NSDictionary*)verboseToAlgebraic:(NSString*)move color:(NSString*)col
{
	const char *mv = [move UTF8String];
    int length = 0;
    int offset = 0;
	char tmpBuff[256];
	
	regmatch_t matches[MAX_MATCHES];
	NSString *piece = nil;
	NSString *from = nil;
	NSString *to = nil;
	if( 0==regexec(&reMove, mv, MAX_MATCHES, matches, 0) )
	{
		// regular move match
		MsgLog(@"GAM: regular move");
		// piece to move
		offset = matches[1].rm_so;  
		length = matches[1].rm_eo -matches[1].rm_so;
		if(offset>=0)
		{
			strncpy(tmpBuff, &mv[offset], length);
			tmpBuff[length] = '\0';
			piece = [NSString stringWithCString:tmpBuff];
		}
		// from square
		offset = matches[2].rm_so;  
		length = matches[2].rm_eo -matches[2].rm_so;
		if(offset>=0)
		{
			strncpy(tmpBuff, &mv[offset], length);
			tmpBuff[length] = '\0';
			from = [NSString stringWithCString:tmpBuff];
		}
		// to square
		offset = matches[3].rm_so;  
		length = matches[3].rm_eo -matches[3].rm_so;
		if(offset>=0)
		{
			strncpy(tmpBuff, &mv[offset], length);
			tmpBuff[length] = '\0';
			to = [NSString stringWithCString:tmpBuff];
		}
		// promo piece
		char promo = '\0';
		offset = matches[4].rm_so;  
		length = matches[4].rm_eo -matches[4].rm_so;
		if(offset>=0)
		{
			promo = mv[offset];
		}
	}
	else if( 0==regexec(&reShortCastle, [move UTF8String], MAX_MATCHES, matches, 0) )
	{
		MsgLog(@"GAM: short castle");
		if([col isEqualToString:@"W"])
		{
			piece = @"K";
			from  = [whKingOrig description];
			to    = [whKingDestShort description];
		}
		else
		{
			piece = @"k";
			from  = [blKingOrig description];
			to    = [blKingDestShort description];
		}
	}
	else if( 0==regexec(&reLongCastle, [move UTF8String], MAX_MATCHES, matches, 0) )
	{
		MsgLog(@"GAM: long castle");
		if([col isEqualToString:@"W"])
		{
			piece = @"K";
			from  = [whKingOrig description];
			to    = [whKingDestLong description];
		}
		else
		{
			piece = @"k";
			from  = [blKingOrig description];
			to    = [blKingDestLong description];
		}
	}
	else
	{
		NSAssert(YES,@"Why I am here?");
	}
	
	DbgLog(@"GAM: parsed verbose move is piece=%@ from=%@ to=%@", piece, from, to);
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			piece,@"Piece",from,@"From",to,@"To",col,@"Color",nil];
}

// ask GUI user to make a move
-(void)requestUserMove
{
	// generate move list and request move to be made
	NSArray *moves = [self getLegalMoves:lastStyle12];
	
	MsgLog(@"GAM: state=kGameStateGetMove");
	state = kGameStateGetMove;
	[backEnd rspGetMove:moves];
	
	return;
}


// get possible moves for current position
-(NSArray*)getLegalMoves:(NSDictionary*)style12Data
{
	// analyze position and issue getMove message to GUI
	NSArray *moves = [polyglot legalMovesForPosition:style12Data];
	return moves;
}

-(void)pump:(id)obj
{
	static int lastWhiteTime = 0;
	static int lastBlackTime = 0;
	
	[whiteTimer pump];
	[blackTimer pump];
	
	int whTime = (int)(whiteTime - whiteTimer.timeElapsed);
	int blTime = (int)(blackTime - blackTimer.timeElapsed);
	if(whTime==lastWhiteTime && blTime==lastBlackTime)
		return;

	lastWhiteTime = whTime;
	lastBlackTime = blTime;
	NSString *wh = [NSString stringWithFormat:@"%02d:%02d", whTime/60, abs(whTime%60)];
	NSString *bl = [NSString stringWithFormat:@"%02d:%02d", blTime/60, abs(blTime%60)];
	[backEnd rspUpdateTime:
		[NSDictionary dictionaryWithObjectsAndKeys:wh,@"WhiteTime",bl,@"BlackTime",nil]];
	
	return;
}

@end
