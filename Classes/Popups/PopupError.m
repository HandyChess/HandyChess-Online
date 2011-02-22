//
//  PopupError.m
//  HandyChess
//
//  Created by Anton Zemyanov on 16.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#define POPUP_COLOR_FRAME			{0.1, 0.1, 0.1, 1.0};
#define POPUP_COLOR_BACKGROUND		{0.8, 0.95, 0.95, 0.98};

#import "PopupError.h"
#import "Logger.h"
#import "SoundEngine.h"
#import "MessageBox.h"

@interface PopupError (Private)
-(void)buttonPressed:(id)obj;
//-(void)remove;
@end

@implementation PopupError

@synthesize onCancel;
//@synthesize onRemoved;

+(id)popupWithTitle:(NSString*)title color:(ccColorF)color;
{
	return [[[self alloc] initWithTitle:title color:color] autorelease];
}

-(id)initWithTitle:(NSString*)title color:(ccColorF)color
{
	if( self = [super init] )
	{
		// message 
		CGSize sz = [title sizeWithFont:[UIFont fontWithName:@"ArialMT" size:20] 
					 constrainedToSize:CGSizeMake(260,400) lineBreakMode:UILineBreakModeWordWrap];  
		message = [Label labelWithString:title dimensions:sz alignment:UITextAlignmentCenter
								fontName:@"ArialMT" fontSize:20];
		[message setRGB:0 :0 :0];
		[self addChild:message];
		
		// menu buttons
		menuItems = [[NSMutableArray alloc] init];
		[menuItems addObject:[MenuItemImage itemFromNormalImage:@"button_dismiss_100px_normal.png" 
												  selectedImage:@"button_dismiss_100px_pressed.png"
														 target:self
													   selector:@selector(cancelPressed:)]];
		menu = [Menu menuWithItems:[menuItems objectAtIndex:0],nil];
		[self addChild:menu];
		
		// message box frame and aligner
		ccColorF frCol = POPUP_COLOR_FRAME;
		ccColorF bgCol = color;
		messageBox = [MessageBox boxWithLabel:message icon:nil buttons:menuItems 
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
	DbgLog(@"POP: Error popup cancel pressed");
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

