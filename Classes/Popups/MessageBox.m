//
//  TestAlertLayer.m
//  HandyChess
//
//  Created by Anton Zemlyanov on 1/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Logger.h"
#import "MessageBox.h"

#define FRAME_ROUNDING_RADIUS	20
#define FRAME_PADDING			12

@interface MessageBox (Private) 
-(CGSize)calculateMessageBoxSize;
-(void)alignNodes;
@end

@implementation MessageBox

@synthesize label;
@synthesize icon;
@synthesize buttons;
@synthesize frameColor;
@synthesize bgColor;

+(id)boxWithLabel:(Label*)lab icon:(Sprite*)ic buttons:(NSArray*)buts 
		 frameColor:(ccColorF)frCol backgroundColor:(ccColorF)bgCol
{
	return [[[self alloc] initWithLabel:lab icon:ic buttons:buts frameColor:frCol backgroundColor:bgCol] autorelease];
}


-(id)initWithLabel:(Label*)lab icon:(Sprite*)ic buttons:(NSArray*)buts 
		 frameColor:(ccColorF)frCol backgroundColor:(ccColorF)bgCol
{
	if(self = [super init])
	{			
		label		= [lab retain];
		icon		= [ic retain];
		buttons		= [buts retain]; 
		frameColor	= frCol;
		bgColor		= bgCol;
		width       = 0;
		height      = 0;
		
		opacity = 255;
		
		// layer in the center of the screen
		CGSize sz = [[Director sharedDirector] winSize];
		position = cpv( sz.width/2, sz.height/2);		

		// calculate message box size
		[self calculateMessageBoxSize];
		
		// rounded frame node
		//MsgLog(@"width=%f height=%f",width,height);
		rect = [RoundedFilledRect rectWithSize:CGSizeMake(width,height) radius:FRAME_ROUNDING_RADIUS 
								   strokeColor:frameColor fillColor:bgColor];
		rect.position = cpv(0,0);
		[self addChild:rect];
		
		// align nodes
		[self alignNodes];
	}
	return self;
}

-(void)dealloc
{
	[label release];
	[icon release];
	[buttons release];
	[super dealloc];
}

// Calculate MessageBox size
-(CGSize)calculateMessageBoxSize
{
	// calculate dialog window size
	CGFloat buttonsWidth = 0;
	CGFloat buttonsHeight = 0;
	int buttonsCount = [buttons count];
	for(MenuItem* item in buttons)
	{
		buttonsWidth += item.contentSize.width;
		if(buttonsHeight < item.contentSize.height)
			buttonsHeight = item.contentSize.height;
	}
	
	CGSize iconSize = CGSizeMake(0,0);
	if(icon)
		iconSize  = icon.contentSize;
	CGSize labelSize = CGSizeMake(0,0);
	labelSize = label.contentSize;
	
	// *** WIDTH ***
	// width of top (Icon and Label area)
	CGFloat widthTop = FRAME_PADDING; // pad left
	if(iconSize.width)
		widthTop += iconSize.width + FRAME_PADDING;
	if(label.contentSize.width)
		widthTop += label.contentSize.width + FRAME_PADDING;
	
	// width of bottom (zero to two buttons)
	CGFloat widthBot = FRAME_PADDING;
	if(buttonsCount)
	{
		widthBot += buttonsWidth + (buttonsCount==0 ? 0 : buttonsCount-1 * FRAME_PADDING) + FRAME_PADDING;
	}
	
	// width
	width  = (widthTop>widthBot ? widthTop : widthBot);
	//MsgLog(@"W=%f wt=%f wb=%f",width, widthTop, widthBot);
	
	// *** HEIGHT *** 
	maxOfIconOrLabelHeight = iconSize.height>labelSize.height ? iconSize.height : labelSize.height;
	height = FRAME_PADDING;
	if(maxOfIconOrLabelHeight)
		height += maxOfIconOrLabelHeight+FRAME_PADDING;
	if(buttonsHeight)
		height += buttonsHeight + FRAME_PADDING;
	
	MsgLog(@"calculated size is w=%f h=%f", width, height);
		
	return CGSizeMake(width,height);
}

// Align nodes to make a Message Box
-(void)alignNodes
{
	// rounded frame node
	CGSize sz = [[Director sharedDirector] winSize];
	CGFloat voff = 0;
	
	if(icon)
	{
		float x = -width/2.0f + FRAME_PADDING + icon.contentSize.width/2.0f;
		float y = voff+height/2.0f - FRAME_PADDING - maxOfIconOrLabelHeight/2.0f;
		MsgLog(@"Icon x=%f y=%f",x,y);
		[icon setPosition:cpv(x+sz.width/2,y+sz.height/2)];
		//[self addChild:icon];
	}
	
	// label
	if(label)
	{
		float x = -width/2.0f + FRAME_PADDING + label.contentSize.width/2.0f;
		if(icon)
			x += icon.contentSize.width + FRAME_PADDING;
		float y = voff+height/2.0f - FRAME_PADDING - maxOfIconOrLabelHeight/2.0f;
		[label setPosition:cpv(x+sz.width/2,y+sz.height/2)];
		//[self addChild:label];
	}
	
	// buttons
	if(buttons)
	{
		// create menu
		/*
		if([buttons count]==1)
			menu = [Menu menuWithItems:[buttons objectAtIndex:0],nil];
		else if([buttons count]==2)
			menu = [Menu menuWithItems:[buttons objectAtIndex:0],[buttons objectAtIndex:0],nil];
		else
			[NSException raise:@"MBX" format:@"too many buttons for message box"];
		*/
		for(MenuItem *item in buttons)
		{
			cpVect pos = item.position;
			pos.y -= height/2 - voff - FRAME_PADDING - item.contentSize.height/2;
			item.position = pos;
		}
		
		//[self addChild:menu];
	}
	
	return;
}


// CocosNodeOpacity protocol
/** returns the opacity
 @return 
 */
-(GLubyte) opacity
{
	return opacity;
}

/** sets the opacity of the layer */
-(void) setOpacity: (GLubyte) opac
{
	opacity       = opac;
	rect.opacity  = opac;
	icon.opacity  = opac;
	label.opacity = opac;
	menu.opacity  = opac; 
}

@end
