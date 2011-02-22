//
//  ChessGame.h
//  HandyChess
//
//  Created by Anton Zemyanov on 09.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChessBackEnd;
@class Polyglot;
@class ChessSquare;
@class HighResolutionTimer;

typedef enum tagGameState 
{
	kGameStateNotInGame		= 0x0,
	kGameStateWaitStyle12	= 0x1,
	kGameStateMakingOppMove	= 0x2,
	kGameStateGetMove		= 0x3,
	kGameStateGettingPromo	= 0x4,
	kGameStateMakingMyMove	= 0x5,
}
GameState;

@interface ChessGame : NSObject 
{
	GameState	 state;
	
	ChessBackEnd *backEnd;			// weak ref to backend
	Polyglot	 *polyglot;			// move generator
	
	NSTimer		 *pumpTimer;
	HighResolutionTimer *whiteTimer;
	HighResolutionTimer *blackTimer;
	float		 whiteTime;
	float		 blackTime;
	
	NSDictionary *startingParams;
	NSDictionary *lastStyle12;

	BOOL		 isInGame;

	// number of phases on move
	UInt32		piecesToMove;		// 1 piece move or 2 piece move
	UInt32		piecesMoved;		// number of pieces that already moved
	
	// player move state info
	NSString    *pieceValue;
	NSString    *pieceColor;
	ChessSquare *orig;				// move origin
	ChessSquare *dest;				// move dest
	ChessSquare *pieceToRemove;		// piece to remove (en-passant move)
	BOOL		*isPromoMove;		// is move a promotion move
}

@property (assign) ChessBackEnd *backEnd;

// game init/end calls
-(void)startingGame:(NSDictionary*)param;
-(void)gameStarted:(NSDictionary*)param;
-(void)gameEnded:(NSDictionary*)param;

// process next position
-(void)processStyle12:(NSDictionary*)style12Data;

// responses from GUI
-(void)playerMove:(NSDictionary*)move;
-(void)pieceMoved:(NSDictionary*)data;
-(void)promoPiece:(NSDictionary*)data;

// process timer - update players' clock
-(void)pump:(id)obj;

@end
