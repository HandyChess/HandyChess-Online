//
//  ChessPiece.m
//  HandyChess
//
//  Created by Anton Zemyanov on 09.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ChessPiece.h"
#import "ChessSquare.h"
#import "Logger.h"

// static members
static float moveSpeed		= 0.001f;	// seconds per pixel
static float fadingSpeed	= 0.3f;		// seconds from 0 to 255

@interface ChessPiece (Private)
-(void)createSprite;
@end

@implementation ChessPiece
@synthesize delegate;
@synthesize square;

@synthesize color;
@synthesize value;
@synthesize sprite;

// class methods
+(void)setFadingSpeed:(float)fadeSpeed
{
	fadingSpeed = fadeSpeed;
}

+(void)setMoveSpeed:(float)mvSpeed
{
	moveSpeed = mvSpeed;
}

// init
-(id)initWithPieceString:(NSString*)str
{
	unichar ch = [str characterAtIndex:0];
	PieceColor clr = isupper(ch) ? kPieceWhite : kPieceBlack;
	PieceValue val = kPieceNone;
	switch(tolower(ch))
	{
		case 'p':
			val = kPiecePawn;
			break;
		case 'n':
			val = kPieceKnight;
			break;
		case 'b':
			val = kPieceBishop;
			break;
		case 'r':
			val = kPieceRook;
			break;
		case 'q':
			val = kPieceQueen;
			break;
		case 'k':
			val = kPieceKing;
			break;
		default:
			[NSException raise:@"CPC" format:@"Invalid chess Piece"];
			break;
	}
	
	return [self initWithColor:clr value:val];
}


// init
-(id)initWithColor:(PieceColor)col value:(PieceValue)val
{
	if (self = [super init] ) 
	{
		color = col;
		value = val;
		
		// create sprite
		[self createSprite];
		[sprite retain];
		
		// sprite is hidden by default
		sprite.opacity = 0;
	}
	return self;
}

-(void)dealloc
{
	[sprite release];
	[super dealloc];
}

// create sprite
-(void)createSprite
{
	if(color==kPieceWhite)
	{
		switch(value)
		{
			case kPiecePawn:
				sprite = [Sprite spriteWithFile:@"wh_p_40px.png"];
				break;
			case kPieceKnight:
				sprite = [Sprite spriteWithFile:@"wh_n_40px.png"];
				break;
			case kPieceBishop:
				sprite = [Sprite spriteWithFile:@"wh_b_40px.png"];
				break;
			case kPieceRook:
				sprite = [Sprite spriteWithFile:@"wh_r_40px.png"];
				break;
			case kPieceQueen:
				sprite = [Sprite spriteWithFile:@"wh_q_40px.png"];
				break;
			case kPieceKing:
				sprite = [Sprite spriteWithFile:@"wh_k_40px.png"];
				break;
			default:
				[NSException raise:@"PC" format:@"invalid white piece"];
				break;
		}
	} 
	else 
	{
		switch(value)
		{
			case kPiecePawn:
				sprite = [Sprite spriteWithFile:@"bl_p_40px.png"];
				break;
			case kPieceKnight:
				sprite = [Sprite spriteWithFile:@"bl_n_40px.png"];
				break;
			case kPieceBishop:
				sprite = [Sprite spriteWithFile:@"bl_b_40px.png"];
				break;
			case kPieceRook:
				sprite = [Sprite spriteWithFile:@"bl_r_40px.png"];
				break;
			case kPieceQueen:
				sprite = [Sprite spriteWithFile:@"bl_q_40px.png"];
				break;
			case kPieceKing:
				sprite = [Sprite spriteWithFile:@"bl_k_40px.png"];
				break;
			default:
				[NSException raise:@"PC" format:@"invalid black piece"];
				break;
		}
	}
	return;
}

// piece in character notation
-(NSString*)pieceString
{
	char pc = '\0';
	switch(value)
	{
		case kPiecePawn:
			pc = 'p';
			break;
		case kPieceKnight:
			pc = 'n';
			break;
		case kPieceBishop:
			pc = 'n';
			break;
		case kPieceRook:
			pc = 'n';
			break;
		case kPieceQueen:
			pc = 'n';
			break;
		case kPieceKing:
			pc = 'n';
			break;
		default:
			[NSException raise:@"PC" format:@"invalid piece"];
			break;
	}
	
	if(color==kPieceWhite)
		pc = toupper(pc);
	
	return [NSString stringWithFormat:@"%c",pc];
}


// appear/disappear/promo
-(void)putPieceAt:(CGPoint)pos withFading:(BOOL)fade
{
	// where to put
	sprite.position = cpv(pos.x+sprite.contentSize.width/2,
						  pos.y+sprite.contentSize.height/2);
	
	// with/without fading
	if(fade)
	{
		CallFuncN *cb = [CallFuncN actionWithTarget:self selector:@selector(onPlaced:)];
		Sequence *seq = [Sequence actions:[FadeTo actionWithDuration:fadingSpeed opacity:255],cb,nil];
		[sprite runAction:seq];
	}
	else
	{
		sprite.opacity = 255;
		[delegate ChessPiecePlaced:self];
	}
	
	return;
}

// remove
-(void)removePieceWithFading:(BOOL)fade
{
	if(fade)
	{
		CallFuncN *cb = [CallFuncN actionWithTarget:self selector:@selector(onRemoved:)];
		Sequence *seq = [Sequence actions:[FadeTo actionWithDuration:fadingSpeed opacity:0],cb,nil];
		[sprite runAction:seq];
	}
	else
	{
		sprite.opacity = 0;
		[delegate ChessPieceRemoved:self];
	}
	return;
}

// moving
-(void)moveTo:(CGPoint)newPos
{
	// calculate distance
	CGPoint from = CGPointMake(sprite.position.x,sprite.position.y);
	CGPoint to = newPos;
	CGFloat dist = sqrtf((to.x-from.x)*(to.x-from.x)+(to.y-from.y)*(to.y-from.y));
	
	CGFloat duration = dist * moveSpeed;
	
	CallFuncN *cb = [CallFuncN actionWithTarget:self selector:@selector(onMoved:)];
	Sequence *seq = [Sequence actions:[MoveTo actionWithDuration:duration 
							position:cpv(newPos.x+sprite.contentSize.width/2,
										 newPos.y+sprite.contentSize.height/2)],cb,nil];
	[sprite runAction:seq];
	
	return;
}

// callbacks
-(void)onPlaced:(id)obj
{
	//MsgLog(@"PC: onPlaced called");
	[delegate ChessPiecePlaced:self];
}

-(void)onMoved:(id)obj
{
	//MsgLog(@"PC: onMoved called");
	[delegate ChessPieceMoved:self];
}

-(void)onRemoved:(id)obj
{
	//MsgLog(@"PC: onRemoved called");
	[delegate ChessPieceRemoved:self];
}

@end
