//
//  ChessPiece.h
//  HandyChess
//
//  Created by Anton Zemyanov on 09.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class ChessSquare;

typedef enum tagChessState
{
	kPieceStateNull      = 0, // piece does noy yet or already exists
	kPieceStateStatic    = 1, // piece stays on it's place
	kPieceStateFadingIn  = 2, // piece is appearing on the board
	kPieceStateFadingOut = 3, // piece is disappearing from the board 
	kPieceStateMoving    = 5, // piece is being transferred to another pos
	kPieceStateDeleted   = 6, // piece is deleted
} 
PieceState;

typedef enum tagPieceColor
{
	kPieceWhite = 0,
	kPieceBlack = 1
} 
PieceColor;

typedef enum tagPieceValue 
{
	kPieceNone   = 0,
	kPieceKing   = 1,
	kPieceQueen  = 2,
	kPieceRook   = 3,
	kPieceBishop = 4,
	kPieceKnight = 5,
	kPiecePawn   = 6
} 
PieceValue;

@class ChessPiece;

@protocol ChessPieceDelegate
-(void)ChessPiecePlaced:(ChessPiece*)piece;
-(void)ChessPieceMoved:(ChessPiece*)piece;
-(void)ChessPieceRemoved:(ChessPiece*)piece;
@end

@interface ChessPiece : NSObject 
{
	id<ChessPieceDelegate> delegate;
	
	// piece 
	PieceColor  color;				// piece color
	PieceValue  value;				// value
	
	// current position on board
	ChessSquare *square;
	
	// rendering stuff
	Sprite		*sprite;
}

// properties for renderer
@property (assign)	id<ChessPieceDelegate> delegate;

@property (retain)	 ChessSquare *square;

@property (readonly) PieceColor  color;
@property (readonly) PieceValue  value;
@property (readonly) Sprite 	 *sprite;

// class methods
+(void)setFadingSpeed:(float)fadeSpeed;				// value to decrement/increment
+(void)setMoveSpeed:(float)moveSpeed;				// value to calculate moving speed

-(id)initWithPieceString:(NSString*)str;
-(id)initWithColor:(PieceColor)col value:(PieceValue)val;

-(NSString*)pieceString;

// appear/disappear/promo
-(void)putPieceAt:(CGPoint)pos withFading:(BOOL)fade;	 // piece appearing on board
-(void)removePieceWithFading:(BOOL)fade;				 // piece disappering from board

// moving
-(void)moveTo:(CGPoint)newPos;			// move piece

@end
