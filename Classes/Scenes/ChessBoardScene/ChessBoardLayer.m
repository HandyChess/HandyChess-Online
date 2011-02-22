//
//  ChessBoardLayer.m
//  HandyChess
//
//  Created by Anton Zemyanov on 19.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChessBoardLayer.h"
#import "ChessBoardScene.h"
#import "ChessSquare.h"
#import "Logger.h"
#import "SoundEngine.h"

#define CHESS_BOARD_LEFT_X		0
#define CHESS_BOARD_BOTTOM_Y	136
#define CHESS_BOARD_WIDTH		320
#define CHESS_BOARD_HEIGHT		320

#define CHESS_BOARD_SQUARE_SIZE	40

#define CHESS_VALID_ORIGIN		YES
#define CHESS_INVALID_ORIGIN	NO
#define CHESS_VALID_DEST			YES
#define CHESS_INVALID_DEST		NO

// Queen has 27 potential moves, max of all pieces
// There will be max 27 potential move marks
#define MAX_POTENTIAL_MOVES		27

#define Z_HIGHLIGHT				11
#define Z_POTENTIAL				10
#define Z_MOVING				2
#define	Z_NORMAL				1
#define Z_REMOVED				0

@interface ChessBoardLayer (Private)
// position to square and vice versa
-(CGPoint)pointForSquare:(ChessSquare*)sq;
-(ChessSquare*)squareForPoint:(CGPoint)pt;
// put/drop piece internal API
-(ChessPiece*)getPieceAt:(ChessSquare*)sq;
-(void)putPiece:(ChessPiece*)piece at:(ChessSquare*)sq withFading:(BOOL)fade;
-(void)movePieceFrom:(ChessSquare*)fromSq to:(ChessSquare*)toSq;
-(void)markRemovedPieceAt:(ChessSquare*)sq;
-(void)hidePieceAt:(ChessSquare*)sq withFading:(BOOL)fade;
// test move validity
-(BOOL)isValidOrigin:(ChessSquare*)orig;
-(BOOL)isValidOrigin:(ChessSquare*)orig destination:(ChessSquare*)dest;
@end


@implementation ChessBoardLayer

@synthesize isWhiteOnBottom;
@synthesize scene;

-(id)init
{
	if(self = [super init])
	{
		// chess Board 
		/*
		chessBoardImage = [Sprite spriteWithFile:@"chess_board_320x320.png"];
		chessBoardImage.position = cpv(CHESS_BOARD_LEFT_X+CHESS_BOARD_WIDTH/2,
									   CHESS_BOARD_BOTTOM_Y+CHESS_BOARD_HEIGHT/2);
		[chessBoardImage setRGB:224 :224 :224];
		[self addChild:chessBoardImage];
		*/
		
		AtlasSpriteManager *cbAtlasManager = [AtlasSpriteManager spriteManagerWithFile:@"chess_board_320x320.pvr"];
		[self addChild:cbAtlasManager];
		
		chessBoardImage = [AtlasSprite spriteWithRect:CGRectMake(10,10,320,320) spriteManager:cbAtlasManager];
		chessBoardImage.position = cpv(CHESS_BOARD_LEFT_X+CHESS_BOARD_WIDTH/2,
									   CHESS_BOARD_BOTTOM_Y+CHESS_BOARD_HEIGHT/2);
		[chessBoardImage setRGB:224 :224 :224];
		[cbAtlasManager addChild:chessBoardImage];
		
		// lines
		/*
		chessBoardLines = [Sprite spriteWithFile:@"chess_board_320x320_mask.png"];
		chessBoardLines.position = cpv(CHESS_BOARD_LEFT_X+CHESS_BOARD_WIDTH/2,
									   CHESS_BOARD_BOTTOM_Y+CHESS_BOARD_HEIGHT/2);
		chessBoardLines.opacity = 0x32;
		//[self add:chessBoardLines];
		*/
		
		// placed and removed pieces
		placedPieces  = [[NSMutableDictionary alloc] init];
		removedPieces = [[NSMutableDictionary alloc] init];
		
		// valid moves
		validMoves    = [[NSMutableArray alloc] init];
		validMovesMap = [[NSMutableDictionary alloc] init];
		
		// marks
		origMark = [Sprite spriteWithFile:@"box40px_hard.png"];
		origMark.visible = NO;
		[self addChild:origMark];
		
		destMark = [Sprite spriteWithFile:@"box40px_hard.png"];
		destMark.visible = NO;
		[self addChild:destMark];
		
		potentialMarks = [[NSMutableArray alloc] init];
		for(int cnt=0; cnt<MAX_POTENTIAL_MOVES; ++cnt)
		{
			Sprite *spr = [Sprite spriteWithFile:@"round40px_bord.png"];
			spr.visible = NO;
			spr.scale = 1.05f;
			[spr setRGB:250:255:0];
			[self addChild:spr z:Z_POTENTIAL];
			[potentialMarks addObject:spr];
		}
		
		// initial orientation
		isWhiteOnBottom = YES;
		
		// initial position
		[self syncPosition:@"rnbqkbnr pppppppp -------- -------- -------- -------- PPPPPPPP RNBQKBNR" 
				 isAnimated:YES];
		
		[self setInGameState:NO];

		isTouchEnabled = YES;
	}
	return self;
}

-(void)dealloc
{
	[validMoves release];
	[validMovesMap release];
	[potentialMarks release];
	[removedPieces release];
	[placedPieces release];
	[super dealloc];
}

-(void)draw
{
	[super draw];
	
	glColor4f(0.9f, 0.9f, 0.9f, 1.0f);
	// top separator
	drawLine(0, CHESS_BOARD_BOTTOM_Y+CHESS_BOARD_HEIGHT+1, 
			 CHESS_BOARD_WIDTH, CHESS_BOARD_BOTTOM_Y+CHESS_BOARD_HEIGHT+1);
	// bottom separator
	drawLine(0, CHESS_BOARD_BOTTOM_Y-2, 
			 CHESS_BOARD_WIDTH, CHESS_BOARD_BOTTOM_Y-2);
	
	glColor4f(0.5f, 0.5f, 0.5f, 1.0f);
	// top separator
	drawLine(0, CHESS_BOARD_BOTTOM_Y+CHESS_BOARD_HEIGHT, 
			 CHESS_BOARD_WIDTH, CHESS_BOARD_BOTTOM_Y+CHESS_BOARD_HEIGHT);
	// bottom separator
	drawLine(0, CHESS_BOARD_BOTTOM_Y-1, 
			 CHESS_BOARD_WIDTH, CHESS_BOARD_BOTTOM_Y-1);
}

-(void)setInGameState:(BOOL)inGame
{
	isInGame = inGame;
	GLubyte color = inGame ? 255 : 224;
	if(inGame)
	{
		;
	}
	else
	{
		// not in game
		isWaitMove = NO;
		[self clearPotentialMarks];
	}
	
	// board and piece color
	[chessBoardImage setRGB:color:color:color];
	for(NSString *key in placedPieces)
	{
		ChessPiece *pc = [placedPieces objectForKey:key];
		[pc.sprite setRGB:color:color:color];
	}
	for(NSString *key in removedPieces)
	{
		ChessPiece *pc = [removedPieces objectForKey:key];
		[pc.sprite setRGB:color:color:color];
	}
	
	return;
}


-(void)setOrientation:(BOOL)whiteOnBottom
{
	if(isWhiteOnBottom == whiteOnBottom)
		return;
	
	// change orientation
	isWhiteOnBottom = whiteOnBottom;
	
	// reposition pieces
	for(NSString *key in placedPieces)
	{
		ChessPiece *pc = [placedPieces objectForKey:key];
		ChessSquare *sq = pc.square;
		CGPoint pt = [self pointForSquare:sq];
		pc.sprite.position = cpv(pt.x+pc.sprite.contentSize.width/2, 
							 pt.y+pc.sprite.contentSize.height/2);
	}
		
	// reposition marks
	
	return;
}

-(void)syncPosition:(NSString*)posStyle12 isAnimated:(BOOL)isAnimated
{
	MsgLog(@"CBL: sync position");
	for(int row=CB_ROW_1; row<=CB_ROW_8; ++row)
	{
		for(int col=CB_COL_A; col<=CB_COL_H; ++col)
		{
			NSUInteger chunk = CB_ROW_8-row;
			NSUInteger index = chunk*(CB_ROW_NUMBER+1) + col;
			ChessSquare *sq = [ChessSquare squareWithCol:col row:row];
			ChessPiece *curPiece = [self getPieceAt:sq];
			ChessPiece *newPiece = nil;
			unichar ch = [posStyle12 characterAtIndex:index];
			switch(ch)
			{
				// empty square
				case '-':
					// if there is something, remove it
					if(curPiece)
					{
						[self markRemovedPieceAt:sq];
						[self hidePieceAt:sq withFading:YES];
					}
					break;
				// white pieces
				case 'P':
					if(curPiece.color!=kPieceWhite || curPiece.value!=kPiecePawn)
						newPiece = [[ChessPiece alloc] initWithColor:kPieceWhite value:kPiecePawn];
					break;
						
				case 'R':
					if(curPiece.color!=kPieceWhite || curPiece.value!=kPieceRook)
						newPiece = [[ChessPiece alloc] initWithColor:kPieceWhite value:kPieceRook];
					break;
					
				case 'N':
					if(curPiece.color!=kPieceWhite || curPiece.value!=kPieceKnight)
						newPiece = [[ChessPiece alloc] initWithColor:kPieceWhite value:kPieceKnight];
					break;
					
				case 'B':
					if(curPiece.color!=kPieceWhite || curPiece.value!=kPieceBishop)
						newPiece = [[ChessPiece alloc] initWithColor:kPieceWhite value:kPieceBishop];
					break;
					
				case 'Q':
					if(curPiece.color!=kPieceWhite || curPiece.value!=kPieceQueen)
						newPiece = [[ChessPiece alloc] initWithColor:kPieceWhite value:kPieceQueen];
					break;
					
				case 'K':
					if(curPiece.color!=kPieceWhite || curPiece.value!=kPieceKing)
						newPiece = [[ChessPiece alloc] initWithColor:kPieceWhite value:kPieceKing];
					break;
					
					// black pieces
				case 'p':
					if(curPiece.color!=kPieceBlack || curPiece.value!=kPiecePawn)
						newPiece = [[ChessPiece alloc] initWithColor:kPieceBlack value:kPiecePawn];
					break;
					
				case 'r':
					if(curPiece.color!=kPieceBlack || curPiece.value!=kPieceRook)
						newPiece = [[ChessPiece alloc] initWithColor:kPieceBlack value:kPieceRook];
					break;

				case 'n':
					if(curPiece.color!=kPieceBlack || curPiece.value!=kPieceKnight)
						newPiece = [[ChessPiece alloc] initWithColor:kPieceBlack value:kPieceKnight];
					break;

				case 'b':
					if(curPiece.color!=kPieceBlack || curPiece.value!=kPieceBishop)
						newPiece = [[ChessPiece alloc] initWithColor:kPieceBlack value:kPieceBishop];
					break;

				case 'q':
					if(curPiece.color!=kPieceBlack || curPiece.value!=kPieceQueen)
						newPiece = [[ChessPiece alloc] initWithColor:kPieceBlack value:kPieceQueen];
					break;

				case 'k':
					if(curPiece.color!=kPieceBlack || curPiece.value!=kPieceKing)
						newPiece = [[ChessPiece alloc] initWithColor:kPieceBlack value:kPieceKing];
					break;
					
				default:
					[NSException raise:@"CBL" format:@"Invalid char %c",[posStyle12 characterAtIndex:index]];
					break;
			}
			// if new piece created, put it on board (replace other piece)
			if(newPiece)
			{
				newPiece.delegate = self;
				[newPiece autorelease];
				[self putPiece:newPiece at:sq withFading:YES];
			}
		}
	}
	return;
}

// move piece from/to
-(void)movePiece:(NSDictionary*)data;
{
	NSString *from = [data objectForKey:@"From"]; 
	NSString *to   = [data objectForKey:@"To"];
	BOOL isMarked  = [[data objectForKey:@"IsMarked"] boolValue];
	
	SInt8 fromCol  = [from characterAtIndex:0]-'a';
	SInt8 fromRow  = [from characterAtIndex:1]-'1';
	SInt8 toCol    = [to characterAtIndex:0]-'a';
	SInt8 toRow    = [to characterAtIndex:1]-'1';

	[self movePieceFrom:[ChessSquare squareWithCol:fromCol row:fromRow] 
					 to:[ChessSquare squareWithCol:toCol row:toRow]];
	
	if(isMarked)
	{
		[self clearAllMarks];
		[origSq release];
		[destSq release];
		origSq = [[ChessSquare alloc] initWithCol:fromCol row:fromRow];
		destSq = [[ChessSquare alloc] initWithCol:toCol row:toRow];
		[self setOrigMark:YES];
		[self setDestMark:YES];
	}
	return;
}

// getMove
-(void)getMove:(NSArray*)valMoves
{
	// Valid moves array and moves map
	[validMoves removeAllObjects];
	[validMovesMap removeAllObjects];
	for(NSMutableDictionary *move in valMoves)
	{
		[validMoves addObject:move];
		NSString *from = [move objectForKey:@"From"];
		NSMutableArray *arr = [validMovesMap objectForKey:from];
		if(arr==nil)
		{
			arr = [NSMutableArray array];
			[validMovesMap setObject:arr forKey:from];
		}
		[arr addObject:move];
	}
	
	// set isWaitMove flag
	isWaitMove = YES;
	isOriginSelected = NO;
	
	// Which side is to move
	NSDictionary *firstMove = [valMoves objectAtIndex:0];
	if(firstMove)
	{
		ChessPiece *pc = [placedPieces objectForKey:[firstMove objectForKey:@"From"]];
		if(pc==nil)
			[NSException raise:@"CBL" format:@"cannot determine side to move"];
		sideToMove = pc.color;
		MsgLog(@"CBL: side to move:%@", sideToMove==kPieceWhite ? @"kPieceWhite" : @"kPieceBlack" );
	}
	
	[origSq release];
	origSq = nil;
	[destSq release];
	destSq = nil;
	
	// clear orig/dest marks
	// bad idea - no need to erase opponents last move
	//[self clearAllMarks];
	
	return;
}

#pragma mark  *********************************** private ***********************************
// position to square and vice versa
// private aux method
-(CGPoint)pointForSquare:(ChessSquare*)sq
{
	CGPoint pt;
	if(isWhiteOnBottom)
	{
		pt.x = CHESS_BOARD_LEFT_X   + sq.col*CHESS_BOARD_SQUARE_SIZE;
		pt.y = CHESS_BOARD_BOTTOM_Y + sq.row*CHESS_BOARD_SQUARE_SIZE;
	}
	else
	{
		pt.x = CHESS_BOARD_LEFT_X   + (CB_COL_H-sq.col)*CHESS_BOARD_SQUARE_SIZE;
		pt.y = CHESS_BOARD_BOTTOM_Y + (CB_ROW_8-sq.row)*CHESS_BOARD_SQUARE_SIZE;
	}
		
	return pt;
}

// private aux method
-(ChessSquare*)squareForPoint:(CGPoint)pt
{
	SInt8 col = -1;
	SInt8 row = -1;
	int ptx = (int)(roundf(pt.x));
	int pty = (int)(roundf(pt.y));
	
	for(SInt8 curCol=CB_COL_A; curCol<=CB_COL_H; ++curCol)
	{
		int left  = CHESS_BOARD_LEFT_X+curCol*CHESS_BOARD_SQUARE_SIZE;
		int right = CHESS_BOARD_LEFT_X+(curCol+1)*CHESS_BOARD_SQUARE_SIZE;
		if(ptx>=left && ptx<right)
		{
			col = curCol;
			break;
		}
	}

	for(SInt8 curRow=CB_ROW_1; curRow<=CB_ROW_8; ++curRow)
	{
		int bottom = CHESS_BOARD_BOTTOM_Y+curRow*CHESS_BOARD_SQUARE_SIZE;
		int top    = CHESS_BOARD_BOTTOM_Y+(curRow+1)*CHESS_BOARD_SQUARE_SIZE;
		if(pty>=bottom && pty<top)
		{
			row = curRow;
			break;
		}
	}
	
	if(!isWhiteOnBottom)
	{
		col = CB_COL_H-col;
		row = CB_ROW_8-row;
	}
	
	return [ChessSquare squareWithCol:col row:row];
}

			
// private aux method
// get piece internal API
-(ChessPiece*)getPieceAt:(ChessSquare*)sq
{
	ChessSquare *square = sq;
	NSString *sqKey = [square description];
	
	return [placedPieces objectForKey:sqKey];
}
			
// private aux method
// put/drop piece internal API
-(void)putPiece:(ChessPiece*)piece at:(ChessSquare*)sq withFading:(BOOL)fade
{
	ChessSquare *square = sq;
	NSString *sqKey = [square description];

	// lower and hide piece that already there
	[self markRemovedPieceAt:sq];
	[self hidePieceAt:sq withFading:fade];
	
	// add to layer, placed pieces and show visually
	[self addChild:piece.sprite z:Z_NORMAL];
	[placedPieces setObject:piece forKey:sqKey];
	piece.square = sq;
	
	[piece putPieceAt:[self pointForSquare:sq] withFading:fade];
	
	return;
}

// private aux method
-(void)movePieceFrom:(ChessSquare*)fromSq to:(ChessSquare*)toSq
{
	ChessSquare *fromSquare = fromSq;
	ChessSquare *toSquare   = toSq;
	NSString *fromKey = [fromSquare description];
	NSString *toKey = [toSquare description];
	
	// test from square has a piece
	if(![placedPieces objectForKey:fromKey])
	{
		//[NSException raise:@"CBL" format:@"try to move missing piece from %@ to %@",fromKey, toKey];
		MsgLog(@"CBL: movePieceFrom:to: from %@ to %@ is impossible, ignore",fromKey, toKey);
		
		// notify controller
		NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"-", @"To", nil];
		[scene pieceMoved:ret];
		
		return;
	}
	
	// if there is dest piece, lower it
	if([placedPieces objectForKey:toKey])
		[self markRemovedPieceAt:toSquare];
	
	// move it
	ChessPiece *pc = [placedPieces objectForKey:fromKey];
	[placedPieces setObject:pc forKey:toKey];
	[placedPieces removeObjectForKey:fromKey];
	pc.square = toSq;
	
	// move on screen
	[self reorderChild:pc.sprite z:Z_MOVING];
	[pc moveTo:[self pointForSquare:toSquare]];
}

// private aux method
// transfer piece from placed to deleted
-(void)markRemovedPieceAt:(ChessSquare*)sq
{
	ChessSquare *square = sq;
	NSString *sqKey = [square description];
	
	// if there is something in removed pieces - remove it now
	ChessPiece *rm = [removedPieces objectForKey:sqKey];
	if(rm)
	{
		[self removeChild:rm.sprite cleanup:YES];
		[removedPieces removeObjectForKey:sqKey];
	}
	
	ChessPiece *pc = [placedPieces objectForKey:sqKey];
	if(pc==nil)
		return;
	
	[self reorderChild:pc.sprite z:Z_REMOVED];
	[removedPieces setObject:pc forKey:sqKey];
	[placedPieces removeObjectForKey:sqKey];
	
	return;
}

// private aux method
// hide piece from removed array
-(void)hidePieceAt:(ChessSquare*)sq withFading:(BOOL)isFaded;
{
	ChessSquare *square = sq;
	NSString *sqKey = [square description];

	if([removedPieces objectForKey:sqKey]==nil)
		return;
	
	// fade piece
	[[removedPieces objectForKey:sqKey] removePieceWithFading:isFaded];
	
	return;
}

#pragma mark *********************************** piece delegate ***********************************
-(void)ChessPiecePlaced:(ChessPiece*)piece
{
	MsgLog(@"CBL: ChessPiecePlaced");
	return;
}

-(void)ChessPieceMoved:(ChessPiece*)piece
{
	// hide the removed piece, if any
	MsgLog(@"CBL: ChessPieceMoved to %@", piece.square);
	
	// set zOrder back to Z_NORMAL
	[self reorderChild:piece.sprite z:Z_NORMAL];
	
	// fade captured piece, if any
	ChessSquare *sq = piece.square;
	ChessPiece *pc = [removedPieces objectForKey:[sq description]];
	if( pc )
	{
		MsgLog(@"CBL: It was a direct capture move");
		[pc removePieceWithFading:YES];
	}
	
	// notify controller
	NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
						 [piece.square description], @"To", nil];
	[scene pieceMoved:ret];
	
	return;
}

-(void)ChessPieceRemoved:(ChessPiece*)piece
{
	MsgLog(@"ChessPieceRemoved");
	return;
}

#pragma mark  *********************************** marks handling ***********************************
// marks
-(void)clearOrigMark
{
	origMark.visible = NO;
	return;
}

-(void)clearDestMark
{
	destMark.visible = NO;
	return;
}

-(void)clearPotentialMarks
{
	for(Sprite *spr in potentialMarks)
		spr.visible = NO;
	return;
}

-(void)clearAllMarks
{
	origMark.visible = NO;
	destMark.visible = NO;
	for(Sprite *spr in potentialMarks)
		spr.visible = NO;
	return;
}

-(void)setOrigMark:(BOOL)isValidOrig
{
	if(isValidOrig)
		[origMark setRGB:0:255:0];
	else
		[origMark setRGB:255:0:0];
	CGPoint pt = [self pointForSquare:origSq];
	origMark.position = cpv(pt.x+CHESS_BOARD_SQUARE_SIZE/2, pt.y+CHESS_BOARD_SQUARE_SIZE/2);
	origMark.visible = YES;
	return;
}

-(void)setDestMark:(BOOL)isValidDest
{
	if(isValidDest)
		[destMark setRGB:0:255:0];
	else
		[destMark setRGB:255:0:0];
	CGPoint pt = [self pointForSquare:destSq];
	destMark.position = cpv(pt.x+CHESS_BOARD_SQUARE_SIZE/2, pt.y+CHESS_BOARD_SQUARE_SIZE/2);
	destMark.visible = YES;
	return;
}

-(void)setPotentialMarks
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	if(![defs boolForKey:@"ShowLegalMoves"])
		return;
	
	// find all the moves from origSq position
	NSArray *moves = [validMovesMap objectForKey:[origSq description]];
	if(moves==nil)
	{
		MsgLog(@"CBL: No potential moves from %@",origSq);
		return;
	}
	
	// make visible and reposition potential marks
	int cnt=0;
	for(NSDictionary *move in moves)
	{
		NSString *toSq = [move objectForKey:@"To"];
		MsgLog(@"CBL: Potential move is to %@", toSq);
		ChessSquare *sq = [ChessSquare squareWithTextNotation:toSq];
		Sprite *spr = [potentialMarks objectAtIndex:cnt];
		//spr.position = cpv(CHESS_BOARD_LEFT_X  +CHESS_BOARD_SQUARE_SIZE*sq.col+CHESS_BOARD_SQUARE_SIZE/2, 
		//				   CHESS_BOARD_BOTTOM_Y+CHESS_BOARD_SQUARE_SIZE*sq.row+CHESS_BOARD_SQUARE_SIZE/2);
		CGPoint pt = [self pointForSquare:sq];
		spr.position = cpv(pt.x+CHESS_BOARD_SQUARE_SIZE/2, pt.y+CHESS_BOARD_SQUARE_SIZE/2);
		spr.visible = YES;
		++cnt;
	}
	
	return;
}

#pragma mark  *********************************** move validity tests ***********************************
-(BOOL)isValidOrigin:(ChessSquare*)orig
{
	BOOL ret = NO;
	if( [validMovesMap objectForKey:[orig description]] )
		ret = YES;
	return ret;
}

-(BOOL)isValidOrigin:(ChessSquare*)orig destination:(ChessSquare*)dest
{
	BOOL ret = NO;
	NSArray *destMoves = [validMovesMap objectForKey:[orig description]];
	if( dest )
	{
		// scan dest array
		for(NSDictionary *move in destMoves)
		{
			if([[move objectForKey:@"To"] isEqualToString:[dest description]])
			{
				ret = YES;
				break;
			}
		}
	}
	return ret;
}


#pragma mark  *********************************** touches handling ***********************************
-(BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//MsgLog(@"CBR: ccTouchesBegan");
	if(!isWaitMove)
		return kEventIgnored;
	
	// screen coordinates to view coordinates
	UITouch *touch = [touches anyObject];
	CGPoint loc = [touch locationInView:nil];
	loc = [[Director sharedDirector] convertCoordinate:loc];
	
	// square that was touched
	ChessSquare *sq = [self squareForPoint:loc];
	MsgLog(@"CBL: ccTouchesBegan: sq=%@",sq);
	if(![sq isOnBoard])
	{
		MsgLog(@"CBL: out of board, ignored");
		return kEventIgnored;
	}
	
	// Is own piece touched
	BOOL isOwnColor = NO;
	ChessPiece *pc = [placedPieces objectForKey:[sq description]];
	if(pc && pc.color==sideToMove)
		isOwnColor = YES;
	MsgLog(@"CBL: isOwnColor=%d",isOwnColor);
	
	if(!isOriginSelected)
	{
		// Origin
		origSq = [sq retain];
		[self clearAllMarks];
		// see if there are any moves from the origin specified
		if( [self isValidOrigin:origSq] )
		{
			[[SoundEngine sharedSoundEngine] playSound:@"piece_down.wav"];
			[self setOrigMark:CHESS_VALID_ORIGIN];
			[self setPotentialMarks];
			isOriginSelected = YES;
		}
		else
		{
			[[SoundEngine sharedSoundEngine] playSound:@"beep.wav"];
			[self setOrigMark:CHESS_INVALID_ORIGIN];
			isOriginSelected = NO;
		}
	}
	else
	{
		// Destination or another origin
		if( [self isValidOrigin:sq] )
		{
			[[SoundEngine sharedSoundEngine] playSound:@"piece_down.wav"];
			
			// new origin is selected
			[self clearAllMarks];
			// change origin to a new one
			MsgLog(@"New orig selected");
			origSq = [sq retain];
			[self setOrigMark:CHESS_VALID_ORIGIN];
			[self setPotentialMarks];
			isOriginSelected = YES;
		}
		else if( [self isValidOrigin:origSq destination:sq] )
		{
			// this is a valid move
			destSq = [sq retain];
			[self clearPotentialMarks];
			[self setDestMark:CHESS_VALID_DEST];
			// send move
			isWaitMove = NO;
			MsgLog(@"Send move %@ %@",[origSq description], [sq description]);
			ChessPiece *pc = [placedPieces objectForKey:[origSq description]];
			[scene playerMove:[NSDictionary dictionaryWithObjectsAndKeys:
							   [origSq description], @"From",
							   [destSq description], @"To", 
							   [pc pieceString], @"Piece", 
							   pc.color==kPieceWhite?@"W":@"B", @"Color",nil]
						];
		}
		else
		{
			[[SoundEngine sharedSoundEngine] playSound:@"beep.wav"];
			origSq = [sq retain];
			[self clearAllMarks];
			[self setOrigMark:CHESS_INVALID_ORIGIN];
			isOriginSelected = NO;
		}
	}
	
	return kEventHandled;
}

-(BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//MsgLog(@"CBR: ccTouchesMoved");
	if(!isWaitMove)
		return kEventIgnored;

	return kEventHandled;
}

-(BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//MsgLog(@"CBR: ccTouchesEnded");
	if(!isWaitMove)
		return kEventIgnored;

	return kEventHandled;
}

-(BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	//MsgLog(@"CBR: ccTouchesCancelled");
	if(!isWaitMove)
		return kEventIgnored;

	return kEventHandled;
}


@end

