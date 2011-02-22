//
//  PopupActivity.m
//  HandyChess
//
//  Created by Anton Zemyanov on 16.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PopupActivity.h"
#import "Logger.h"
#import "SoundEngine.h"
#import "MessageBox.h"

#define POPUP_COLOR_FRAME			{0.1, 0.1, 0.1, 1.0};
#define POPUP_COLOR_BACKGROUND		{0.8, 0.95, 0.95, 0.98};

@interface PopupActivity (Private)
-(void)cancelPressed:(id)obj;
@end

@implementation PopupActivity
@synthesize onCancel;
@synthesize message;
@synthesize activity;

+(id)popupWithTitle:(NSString*)title titleSize:(CGSize)sz color:(ccColorF)color;
{
	return [[[self alloc] initWithTitle:title titleSize:sz color:color] autorelease];
}

-(id)initWithTitle:(NSString*)title titleSize:(CGSize)sz color:(ccColorF)color
{
	if( self = [super init] )
	{
		// custom init
		// activity indicator
		activity = [Sprite spriteWithFile:@"activity_indicator_50x50.png"];
		activity.scale = 0.75f;
		[activity runAction:[RepeatForever actionWithAction:
					   [Sequence actions:[DelayTime actionWithDuration:0.05],
						[RotateBy actionWithDuration:0.0 angle:30.0f],nil]]];
		[self addChild:activity];
		
		// message 
		message = [Label labelWithString:title dimensions:sz alignment:UITextAlignmentLeft
								fontName:@"ArialMT" fontSize:20];
		[message setRGB:0 :0 :0];
		[self addChild:message];
		
		// menu buttons
		menuItems = [[NSMutableArray alloc] init];
		[menuItems addObject:[MenuItemImage itemFromNormalImage:@"button_cancel_100px_normal.png" 
												  selectedImage:@"button_cancel_100px_pressed.png"
														 target:self
													   selector:@selector(cancelPressed:)]];
		menu = [Menu menuWithItems:[menuItems objectAtIndex:0],nil];
		[self addChild:menu];
		
		// message box frame and aligner
		ccColorF frCol = POPUP_COLOR_FRAME;
		ccColorF bgCol = POPUP_COLOR_BACKGROUND;
		messageBox = [MessageBox boxWithLabel:message icon:activity buttons:menuItems 
								   frameColor:frCol backgroundColor:bgCol];
		[self addChild:messageBox z:-1];
		
	}
	return self;
}

-(void)dealloc
{
	[menuItems release];
	[super dealloc];
}

-(void)cancelPressed:(id)obj
{
	DbgLog(@"POP: Activity popup cancel pressed");
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	// call client callback
	if(onCancel)
		[self runAction:onCancel];
	
	return;
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
