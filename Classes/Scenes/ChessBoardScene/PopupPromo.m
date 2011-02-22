//
//  PopupPromo.m
//  HandyChess
//
//  Created by Anton on 4/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PopupPromo.h"
#import "RoundedFilledRect.h"
#import "SoundEngine.h"
#import "Logger.h"

#define FRAME_ROUNDING_RADIUS	20
#define FRAME_PADDING			12
#define VERT_OFFSET				56

#define POPUP_WIDTH				300
#define POPUP_HEIGHT				100
#define BACKGROUND_COLOR			{0.99f, 0.99f, 0.99f, 0.99f};
#define BORDER_STROKE_COLOR		{0.20f, 0.20f, 0.20f, 1.00f};


@implementation PopupPromo

@synthesize onButton;
@synthesize queen;
@synthesize rook;
@synthesize bishop;
@synthesize knight;

@synthesize pieceSelected;

+(id)popupWithPieceColor:(PieceColor)color
{
	return [[[self alloc] initWithPieceColor:color] autorelease];
}

-(id)initWithPieceColor:(PieceColor)color
{
	if( self = [super init] )
	{
		isTouchEnabled = YES;
		
		CGSize sz = [[Director sharedDirector] winSize];
		self.transformAnchor = cpv(sz.width/2.0f, sz.height/2.0f+VERT_OFFSET);
		
		// rounded frame node
		ccColorF stroke = BORDER_STROKE_COLOR; 
		ccColorF clr = BACKGROUND_COLOR;
		filledRect = [RoundedFilledRect rectWithSize:CGSizeMake(POPUP_WIDTH,POPUP_HEIGHT) radius:FRAME_ROUNDING_RADIUS 
										 strokeColor:stroke fillColor:clr];
		filledRect.position = cpv(sz.width/2.0f, sz.height/2.0f+VERT_OFFSET);
		[self addChild:filledRect];
		
		// prompt label
		prompt = [Label labelWithString:@"Piece to promote pawn to" 
							 dimensions:CGSizeMake(POPUP_WIDTH-20,24) alignment:UITextAlignmentCenter 
							   fontName:@"ArialMT" fontSize:20];
		prompt.position = cpv(sz.width/2.0f, sz.height/2.0f+VERT_OFFSET+28);
		[prompt setRGB:0:0:0];
		[self addChild:prompt];
		
		// queen button
		NSString *qName = color==kPieceWhite ? @"wh_q_40px.png" : @"bl_q_40px.png"; 
		queen = [MenuItemImage itemFromNormalImage:qName 
									selectedImage:qName
												target:self
												selector:@selector(buttonPressed:)];

		// rook button
		NSString *rName = color==kPieceWhite ? @"wh_r_40px.png" : @"bl_r_40px.png"; 
		rook = [MenuItemImage itemFromNormalImage:rName 
									 selectedImage:rName
											target:self
										  selector:@selector(buttonPressed:)];
		
		// bishop button
		NSString *bName = color==kPieceWhite ? @"wh_b_40px.png" : @"bl_b_40px.png"; 
		bishop = [MenuItemImage itemFromNormalImage:bName 
									selectedImage:bName
										   target:self
										 selector:@selector(buttonPressed:)];
		// knight button
		NSString *kName = color==kPieceWhite ? @"wh_n_40px.png" : @"bl_n_40px.png"; 
		knight = [MenuItemImage itemFromNormalImage:kName 
									selectedImage:kName
										   target:self
										 selector:@selector(buttonPressed:)];
		
		// menu
		menu = [Menu menuWithItems:queen,rook,bishop,knight,nil];
		queen.position  = cpv(-90, 0+VERT_OFFSET-12);
		rook.position   = cpv(-30, 0+VERT_OFFSET-12);
		bishop.position = cpv(30, 0+VERT_OFFSET-12);
		knight.position = cpv(90, 0+VERT_OFFSET-12);
		[self addChild:menu];
	}
	return self;
}

-(void)dismiss
{
	DbgLog(@"POP: dismiss requested");
	[self runAction:
	 [Sequence actions:[FadeTo actionWithDuration:0.2f opacity:0],
	  [CallFunc actionWithTarget:self selector:@selector(remove)],nil]];
	
}

#pragma mark private
-(void)buttonPressed:(id)obj
{
	DbgLog(@"POP: Error popup cancel pressed");
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	if(obj==self.rook)
		pieceSelected = @"r";
	else if(obj==self.bishop)
		pieceSelected = @"b";
	else if(obj==self.knight)
		pieceSelected = @"n";
	else 
		pieceSelected = @"q";
	
	// call client callback
	if(onButton)
		[self runAction:onButton];
	
	//[self dismiss];
	
	return;
}


-(void)remove
{
	DbgLog(@"POP: Remove promo from parent node");
	
	isTouchEnabled = NO;
	[self.parent removeChild:self cleanup:YES];
	return;
}

#pragma mark CocosNodeOpacity protocol
-(GLubyte) opacity
{
	return opacity;
}

/** sets the opacity of the layer */
-(void) setOpacity: (GLubyte) opac
{
	opacity       = opac;
	//filledRect.opacity  = opac;
}

- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//DbgLog(@"MSB: ccTouchesBegan");
	if(isTouchEnabled)
		return kEventHandled;
	return kEventIgnored;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//DbgLog(@"MSB: ccTouchesMoved");
	if(isTouchEnabled)
		return kEventHandled;
	return kEventIgnored;
}

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//DbgLog(@"MSB: ccTouchesEnded");
	if(isTouchEnabled)
		return kEventHandled;
	return kEventIgnored;
}

- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	//DbgLog(@"MSB: ccTouchesCancelled");
	if(isTouchEnabled)
		return kEventHandled;
	return kEventIgnored;
}


@end
