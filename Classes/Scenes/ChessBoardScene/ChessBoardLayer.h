//
//  ChessBoardLayer.h
//  HandyChess
//
//  Created by Anton Zemyanov on 19.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

#import "ChessPiece.h"

@class ChessBoardScene;

@interface ChessBoardLayer : Layer <ChessPieceDelegate>
{
	ChessBoardScene	*scene;
	
	BOOL				isInGame;
	
	BOOL				isWaitMove;
	BOOL				isOriginSelected;
	PieceColor			sideToMove;
	NSMutableArray		*validMoves;
	NSMutableDictionary *validMovesMap;
	ChessSquare			*origSq;
	ChessSquare			*destSq;
	
	// Chess board sprite
	AtlasSprite			*chessBoardImage;
	Sprite				*chessBoardLines;
	
	// Piece sprites
	NSMutableDictionary	*placedPieces;
	NSMutableDictionary *removedPieces;
	
	// Marks
	Sprite				*origMark;
	Sprite				*destMark;
	NSMutableArray		*potentialMarks;
	
	// Board orientation
	BOOL				isWhiteOnBottom;
}

@property (readonly) BOOL isWhiteOnBottom;
@property (nonatomic, assign)  ChessBoardScene	*scene;


// chessboard manipulation
-(void)setInGameState:(BOOL)inGame;
-(void)setOrientation:(BOOL)whiteOnBottom;
-(void)syncPosition:(NSString*)posStyle12 isAnimated:(BOOL)isAnimated;
-(void)movePiece:(NSDictionary*)data;
-(void)getMove:(NSArray*)validMoves;

// marks
-(void)clearOrigMark;
-(void)clearDestMark;
-(void)clearPotentialMarks;
-(void)clearAllMarks;
-(void)setOrigMark:(BOOL)isValidOrig;
-(void)setDestMark:(BOOL)isValidDest;
-(void)setPotentialMarks;
 
@end
