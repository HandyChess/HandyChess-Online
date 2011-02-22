//
//  IntroStaticLayer.m
//  HandyChess
//
//  Created by Anton Zemyanov on 17.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "IntroStaticLayer.h"
#import "cocos2d.h"
#import "LayoutLayer.h"

// nodes tags
//#define INTRO_NODE_BGIMAGE		0x00010001
#define INTRO_NODE_LOGO			0x00010002
#define INTRO_NODE_INTRO_MSG	0x00010003
#define INTRO_NODE_FICS_MSG		0x00010004
#define INTRO_NODE_REG_MSG		0x00010005
#define INTRO_NODE_GOMAIN_MSG	0x00010006
#define INTRO_NODE_CHECK_MSG	0x00010007

nodeLayout introStaticLayouts[] = 
{
	//{INTRO_NODE_BGIMAGE,	{0,480},  {320,480}},
	{INTRO_NODE_LOGO,		{10,82},  {300,92}},
	{INTRO_NODE_INTRO_MSG,	{5,140},  {310,59}},
    {INTRO_NODE_FICS_MSG,	{5,175},  {310,41}},
    {INTRO_NODE_REG_MSG,	{5,238},  {310,59}},
	{INTRO_NODE_GOMAIN_MSG,	{5,358},  {310,59}},
	{INTRO_NODE_CHECK_MSG,	{104,478}, {236,41}},
};

@implementation IntroStaticLayer

-(id)init
{
	if(self = [super init])
	{
		// background
		/*
		bgImage = [Sprite spriteWithFile:@"bg2_320x480.png"];
		bgImage.tag = INTRO_NODE_BGIMAGE;
		[self addChild:bgImage];
		*/
		 
		AtlasSpriteManager *bgAtlasManager = [AtlasSpriteManager spriteManagerWithFile:@"bg2_320x480.pvr"];
		[self addChild:bgAtlasManager];
		
		bgImage = [AtlasSprite spriteWithRect:CGRectMake(5,5,320,480) spriteManager:bgAtlasManager];
		//bgImage.tag = BOARD_NODE_BGIMAGE;
		bgImage.position = cpv(160,240);
		[bgAtlasManager addChild:bgImage];
		

		// logo
		logo = [Sprite spriteWithFile:@"logo_300x59.png"];
		logo.tag = INTRO_NODE_LOGO;
		[self addChild:logo];
		
		// Intro message
		introMsg = [Label labelWithString:@"Play chess on the largest free internet chess server" 
									 dimensions:CGSizeMake(310,59) 
									 alignment:UITextAlignmentCenter 
									 fontName:@"TimesNewRomanPSMT" fontSize:22];
		introMsg.tag = INTRO_NODE_INTRO_MSG;
		[introMsg setRGB:0:0:0];
		[self addChild:introMsg];

		// FICS
		ficsMsg = [Label labelWithString:@"www.freechess.org (FICS)" 
							   dimensions:CGSizeMake(310,41) 
							   alignment:UITextAlignmentCenter 
							   fontName:@"Arial-BoldMT" fontSize:23];
		ficsMsg.tag = INTRO_NODE_FICS_MSG;
		[ficsMsg setRGB:0:00:80];
		[self addChild:ficsMsg];

		// Register message
		regMsg = [Label labelWithString:@"You may want to register on the FICS to play rated games" 
							  dimensions:CGSizeMake(310,59) 
							   alignment:UITextAlignmentCenter 
								fontName:@"TimesNewRomanPSMT" fontSize:22];
		regMsg.tag = INTRO_NODE_REG_MSG;
		[regMsg setRGB:0:00:0];
		[self addChild:regMsg];

		// Go main menu message
		regMsg = [Label labelWithString:@"If you already have account or want to play unrated games" 
							 dimensions:CGSizeMake(310,59) 
							  alignment:UITextAlignmentCenter 
							   fontName:@"TimesNewRomanPSMT" fontSize:22];
		regMsg.tag = INTRO_NODE_GOMAIN_MSG;
		[regMsg setRGB:0:0:0];
		[self addChild:regMsg];

		// CheckBox message
		regMsg = [Label labelWithString:@"Do not show intro again" 
							 dimensions:CGSizeMake(310,59) 
							  alignment:UITextAlignmentLeft 
							   fontName:@"TimesNewRomanPSMT" fontSize:22];
		regMsg.tag = INTRO_NODE_CHECK_MSG;
		[regMsg setRGB:0:0:0];
		[self addChild:regMsg];
		
		// layout children
		[self layoutElements:introStaticLayouts number:sizeof(introStaticLayouts)/sizeof(nodeLayout)];
	}
	return self;
}

-(void)dealloc
{
	[bgImage release];
	[super dealloc];
}

@end
