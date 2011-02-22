//
//  ChessGameResultPopup.m
//  HandyChess
//
//  Created by Anton Zemyanov on 3/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PopupGameResult.h"
#import "RoundedFilledRect.h"
#import "Logger.h"
#import "SoundEngine.h"

#define FRAME_ROUNDING_RADIUS	20
#define FRAME_PADDING			12
#define VERT_OFFSET				56

#define POPUP_WIDTH				300
#define POPUP_HEIGHT				126
#define BORDER_STROKE_COLOR		{0.0f, 0.0f, 0x00, 0xFF}

@interface PopupGameResult (Private)
-(void)okPressed:(id)obj;
-(void)rematchPressed:(id)obj;
-(void)remove;
@end

@implementation PopupGameResult

@synthesize onOk;
@synthesize onRematch;

+(id)popupWithColor:(ccColorF)clr result:(NSString*)res
{
	return [[[self alloc] initWithColor:clr result:res] autorelease];
}

-(id)initWithColor:(ccColorF)clr result:(NSString*)res
{
	if( self = [super init] )
	{
		isTouchEnabled = YES;
		
		CGSize sz = [[Director sharedDirector] winSize];
		self.transformAnchor = cpv(sz.width/2.0f, sz.height/2.0f+VERT_OFFSET);
		
		// rounded frame node
		ccColorF stroke = BORDER_STROKE_COLOR; 
		filledRect = [RoundedFilledRect rectWithSize:CGSizeMake(POPUP_WIDTH,POPUP_HEIGHT) radius:FRAME_ROUNDING_RADIUS 
								   strokeColor:stroke fillColor:clr];
		filledRect.position = cpv(sz.width/2.0f, sz.height/2.0f+VERT_OFFSET);
		[self addChild:filledRect];

		// result label
		CGSize lsz = [res sizeWithFont:[UIFont fontWithName:@"ArialMT" size:20] 
					  constrainedToSize:CGSizeMake(POPUP_WIDTH-20,400) lineBreakMode:UILineBreakModeWordWrap];  
		result = [Label labelWithString:res dimensions:lsz alignment:UITextAlignmentCenter 
								fontName:@"ArialMT" fontSize:20];
		result.position = cpv(sz.width/2.0f, sz.height/2.0f+VERT_OFFSET+25);
		[result setRGB:0:0:0];
		[self addChild:result];
		
		// ok button
		MenuItemImage *okButton = [MenuItemImage itemFromNormalImage:@"button_ok_100px_normal.png" 
													selectedImage:@"button_ok_100px_pressed.png"
														   target:self
														   selector:@selector(okPressed:)];
		// rematch button
		MenuItemImage *rematchButton = [MenuItemImage itemFromNormalImage:@"button_rematch_100px_normal.png" 
													   selectedImage:@"button_rematch_100px_pressed.png"
															  target:self
															selector:@selector(rematchPressed:)];
		menu = [Menu menuWithItems:okButton,rematchButton,nil];
		okButton.position = cpv(-54, 0+VERT_OFFSET-30);
		rematchButton.position = cpv(54, 0+VERT_OFFSET-30);
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
-(void)okPressed:(id)obj
{
	DbgLog(@"POP: ok pressed");
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	// call client callback
	if(onOk)
		[self runAction:onOk];
	
	return;
}

-(void)rematchPressed:(id)obj
{
	DbgLog(@"POP: rematch pressed");
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	// call client callback
	if(onRematch)
		[self runAction:onRematch];
	
	return;
}


-(void)remove
{
	DbgLog(@"POP: Remove self from parent node");
	
	isTouchEnabled = NO;
	[self.parent removeChild:self cleanup:YES];
	return;
}

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
