//
//  PopupQuestion.m
//  HandyChess
//
//  Created by Anton on 5/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#define POPUP_COLOR_FRAME			{0.1, 0.1, 0.1, 1.0};
#define POPUP_COLOR_BACKGROUND		{0.8, 0.95, 0.95, 0.98};

#import "PopupQuestion.h"
#import "Logger.h"
#import "SoundEngine.h"
#import "MessageBox.h"

@interface PopupQuestion (Private)
-(void)firstPressed:(id)obj;
-(void)secondPressed:(id)obj;
//-(void)remove;
@end

@implementation PopupQuestion

@synthesize onFirst;
@synthesize onSecond;
//@synthesize onRemoved;

+(id)popupWithTitle:(NSString*)title buttons:(QuestionButtons)butts color:(ccColorF)color;
{
	return [[[self alloc] initWithTitle:title buttons:butts color:color] autorelease];
}

-(id)initWithTitle:(NSString*)title buttons:(QuestionButtons)butts color:(ccColorF)color;
{
	if( self = [super init] )
	{
		// message 
		CGSize sz = [title sizeWithFont:[UIFont fontWithName:@"ArialMT" size:20] 
					  constrainedToSize:CGSizeMake(290,400) lineBreakMode:UILineBreakModeWordWrap];  
		message = [Label labelWithString:title dimensions:sz alignment:UITextAlignmentCenter
								fontName:@"ArialMT" fontSize:20];
		[message setRGB:0 :0 :0];
		[self addChild:message];
		
		// menu buttons
		menuItems = [[NSMutableArray alloc] init];
		NSString *firstNormal   = @"button_ok_100px_normal.png";
		NSString *firstPressed  = @"button_ok_100px_pressed.png";
		NSString *secondNormal  = @"button_cancel_100px_normal.png";
		NSString *secondPressed = @"button_cancel_100px_pressed.png";
		switch(butts)
		{
			case kQuestionButtonsYesNo:
				firstNormal   = @"button_yes_100px_normal.png";
				firstPressed  = @"button_yes_100px_pressed.png";
				secondNormal  = @"button_no_100px_normal.png";
				secondPressed = @"button_no_100px_pressed.png";
				break;
			default:
				break;
		}
		[menuItems addObject:[MenuItemImage itemFromNormalImage:firstNormal 
												  selectedImage:firstPressed
														 target:self
													   selector:@selector(firstPressed:)]];
		[menuItems addObject:[MenuItemImage itemFromNormalImage:secondNormal 
												  selectedImage:secondPressed
														 target:self
													   selector:@selector(secondPressed:)]];
		menu = [Menu menuWithItems:[menuItems objectAtIndex:0],[menuItems objectAtIndex:1],nil];
		[menu alignItemsHorizontally];
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

-(void)firstPressed:(id)obj
{
	DbgLog(@"POP: Question popup first pressed");
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	// call client callback
	if(onFirst)
		[self runAction:onFirst];
	
	return;
}

-(void)secondPressed:(id)obj
{
	DbgLog(@"POP: Question popup second pressed");
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	// call client callback
	if(onSecond)
		[self runAction:onSecond];
	
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

