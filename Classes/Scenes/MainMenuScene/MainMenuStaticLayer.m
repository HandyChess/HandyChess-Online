//
//  MainMenuStaticLayer.m
//  HandyChess
//
//  Created by Anton Zemyanov on 18.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MainMenuStaticLayer.h"
#import "cocos2d.h"
#import "LayoutLayer.h"

// nodes tags
//#define MAINMENU_NODE_BGIMAGE		0x00010001
#define MAINMENU_NODE_LOGO			0x00010002
#define MAINMENU_NODE_TITLE_MSG		0x00010003
#define MAINMENU_NODE_FICS1_MSG		0x00010004
#define MAINMENU_NODE_FICS2_MSG		0x00010005

nodeLayout mainStaticLayouts[] = 
{
	//{MAINMENU_NODE_BGIMAGE,	    {0,480},  {320,480}},
	{MAINMENU_NODE_LOGO,		{10,75},  {300,92}},
	{MAINMENU_NODE_TITLE_MSG,	{10,110}, {300,40}},
	{MAINMENU_NODE_FICS1_MSG,	{10,460}, {300,40}},
	{MAINMENU_NODE_FICS2_MSG,	{10,486}, {300,40}},
};

@implementation MainMenuStaticLayer

-(id)init
{
	if(self = [super init])
	{
		// background
		/*
		bgImage = [Sprite spriteWithFile:@"bg2_320x480.png"];
		bgImage.tag = MAINMENU_NODE_BGIMAGE;
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
		logo.tag = MAINMENU_NODE_LOGO;
		[self addChild:logo];

		// Title
		titleMsg = [Label labelWithString:@"Main Menu" 
							  dimensions:CGSizeMake(310,41) 
							   alignment:UITextAlignmentCenter 
								fontName:@"Arial-BoldMT" fontSize:23];
		titleMsg.tag = MAINMENU_NODE_TITLE_MSG;
		[titleMsg setRGB:0:00:80];
		[self addChild:titleMsg];

		// FICS1
		fics1Msg = [Label labelWithString:@"Chess Client to" 
							  dimensions:CGSizeMake(310,41) 
							   alignment:UITextAlignmentCenter 
								fontName:@"ArialMT" fontSize:23];
		fics1Msg.tag = MAINMENU_NODE_FICS1_MSG;
		[fics1Msg setRGB:0:00:80];
		[self addChild:fics1Msg];

		// FICS2
		fics2Msg = [Label labelWithString:@"Free Internet Chess Server" 
							  dimensions:CGSizeMake(310,41) 
							   alignment:UITextAlignmentCenter 
								fontName:@"Arial-BoldMT" fontSize:23];
		fics2Msg.tag = MAINMENU_NODE_FICS2_MSG;
		[fics2Msg setRGB:0:00:80];
		[self addChild:fics2Msg];
		
		// layout children
		[self layoutElements:mainStaticLayouts number:sizeof(mainStaticLayouts)/sizeof(nodeLayout)];
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

@end

