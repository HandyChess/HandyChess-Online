//
//  MainMenuStaticLayer.m
//  HandyChess
//
//  Created by Anton Zemyanov on 18.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AboutStaticLayer.h"
#import "cocos2d.h"
#import "LayoutLayer.h"

// nodes tags
//#define ABOUT_NODE_BGIMAGE			0x00010001
#define ABOUT_NODE_LOGO				0x00010002
#define ABOUT_NODE_TITLE_MSG		0x00010003
#define ABOUT_NODE_WRITTEN_BY		0x00010004
#define ABOUT_NODE_WRITTEN_BY_NAME	0x00010005
#define ABOUT_NODE_POWERED_BY   	0x00010006
#define ABOUT_NODE_THANKS_RIC		0x00010007
#define ABOUT_NODE_NEED_ACCOUNT		0x00010008
#define ABOUT_NODE_FEEDBACK1		0x00010009
#define ABOUT_NODE_FEEDBACK2		0x0001000A

nodeLayout aboutStaticLayouts[] = 
{
	//{ABOUT_NODE_BGIMAGE,	     {0,480},  {320,480}},
	{ABOUT_NODE_LOGO,			 {10,75},  {300,92}},
	//{ABOUT_NODE_TITLE_MSG,		 {10,150}, {300,40}},
	{ABOUT_NODE_WRITTEN_BY,		 {10,105}, {300,40}},
	{ABOUT_NODE_WRITTEN_BY_NAME, {10,128}, {300,40}},
	{ABOUT_NODE_POWERED_BY,		 {10,410}, {300,40}},
	{ABOUT_NODE_THANKS_RIC,	     {10,434}, {300,40}},
	{ABOUT_NODE_NEED_ACCOUNT,    {10,320}, {300,40}},
	{ABOUT_NODE_FEEDBACK1,		 {10,185}, {300,40}},
	{ABOUT_NODE_FEEDBACK2,		 {10,210}, {300,40}},
};

@implementation AboutStaticLayer

-(id)init
{
	if(self = [super init])
	{
		// background
		/*
		bgImage = [Sprite spriteWithFile:@"bg2_320x480.png"];
		bgImage.tag = ABOUT_NODE_BGIMAGE;
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
		logo.tag = ABOUT_NODE_LOGO;
		[self addChild:logo];
	
		// Title
		/*
		titleMsg = [Label labelWithString:@"About Scene Title" 
							   dimensions:CGSizeMake(310,41) 
								alignment:UITextAlignmentCenter 
								 fontName:@"Arial-BoldMT" fontSize:23];
		titleMsg.tag = ABOUT_NODE_TITLE_MSG;
		[titleMsg setRGB:0:00:80];
		[self add:titleMsg];
		*/
		 
		// Written by
		writtenBy = [Label labelWithString:@"Designed and programmed by" 
							   dimensions:CGSizeMake(310,40) 
								alignment:UITextAlignmentCenter 
								 fontName:@"TimesNewRomanPSMT" fontSize:22];
		writtenBy.tag = ABOUT_NODE_WRITTEN_BY;
		[writtenBy setRGB:0x00:0x00:0x00];
		[self addChild:writtenBy];
		
		// Written by name
		writtenByName = [Label labelWithString:@"Anton Zemlyanov" 
								dimensions:CGSizeMake(310,40) 
								 alignment:UITextAlignmentCenter 
								  fontName:@"Arial-BoldMT" fontSize:20];
		writtenByName.tag = ABOUT_NODE_WRITTEN_BY_NAME;
		[writtenByName setRGB:0x00:0x00:0x80];
		[self addChild:writtenByName];

		// PoweredBy
		poweredBy = [Label labelWithString:@"Powered by Cocos2D library by" 
									dimensions:CGSizeMake(310,40) 
									 alignment:UITextAlignmentCenter 
									  fontName:@"TimesNewRomanPSMT" fontSize:22];
		poweredBy.tag = ABOUT_NODE_POWERED_BY;
		[poweredBy setRGB:0x00:0x00:0x00];
		[self addChild:poweredBy];

		// Thanks Ric
		thanksRic = [Label labelWithString:@"Ricardo Quesada" 
								dimensions:CGSizeMake(310,40) 
								 alignment:UITextAlignmentCenter 
								  fontName:@"Arial-BoldMT" fontSize:20];
		thanksRic.tag = ABOUT_NODE_THANKS_RIC;
		[thanksRic setRGB:0x00:0x00:0x80];
		[self addChild:thanksRic];

		// Need FICS account
		needAccount = [Label labelWithString:@"No Free Internet Chess Server account?" 
								dimensions:CGSizeMake(310,80) 
								 alignment:UITextAlignmentCenter 
								  fontName:@"TimesNewRomanPSMT" fontSize:22];
		needAccount.tag = ABOUT_NODE_NEED_ACCOUNT;
		[needAccount setRGB:0x00:0x00:0x00];
		[self addChild:needAccount];

		// Feedback 1
		feedback1 = [Label labelWithString:@"Your feedback is important!"
								dimensions:CGSizeMake(310,80) 
								 alignment:UITextAlignmentCenter 
								  fontName:@"Arial-BoldMT" fontSize:20];
		feedback1.tag = ABOUT_NODE_FEEDBACK1;
		[feedback1 setRGB:0x00:0x00:0x80];
		[self addChild:feedback1];

		// Feedback 2
		feedback2 = [Label labelWithString:@"Report technical problems and suggest improvements" 
							   dimensions:CGSizeMake(310,80) 
								alignment:UITextAlignmentCenter 
								 fontName:@"TimesNewRomanPSMT" fontSize:22];
		feedback2.tag = ABOUT_NODE_FEEDBACK2;
		[feedback2 setRGB:0x00:0x00:0x00];
		[self addChild:feedback2];
		
		// layout children
		[self layoutElements:aboutStaticLayouts number:sizeof(aboutStaticLayouts)/sizeof(nodeLayout)];
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

@end

