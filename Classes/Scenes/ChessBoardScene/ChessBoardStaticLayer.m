//
//  ChessBoardStaticLayer.m
//  HandyChess
//
//  Created by Anton Zemyanov on 18.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChessBoardStaticLayer.h"
#import "cocos2d.h"
#import "LayoutLayer.h"

#import "FramedLabel.h"
#define FramedLabel Label

// font widths
#define FONT_TIME_WIDTH			0.9f
#define FONT_NAME_WIDTH			0.9f
#define FONT_MOVE_WIDTH			0.85f
#define FONT_RATE_WIDTH			0.85f
#define FONT_INFO_WIDTH			0.85f
#define FONT_INFO_HEIGHT			0.95f

// nodes tags
//#define BOARD_NODE_BGIMAGE		0x00010001
#define BOARD_NODE_TOP_TIME		0x00010002
#define BOARD_NODE_TOP_NAME		0x00010003
#define BOARD_NODE_TOP_MOVE		0x00010004
#define BOARD_NODE_TOP_RATING	0x00010005
#define BOARD_NODE_BOT_TIME		0x00010006
#define BOARD_NODE_BOT_NAME		0x00010007
#define BOARD_NODE_BOT_MOVE		0x00010008
#define BOARD_NODE_BOT_RATING	0x00010009
#define BOARD_NODE_INFO1			0x0001000A
#define BOARD_NODE_INFO2			0x0001000B
//#define BOARD_NODE_INFO3			0x0001000C

nodeLayout boardStaticLayouts[] = 
{
	//{BOARD_NODE_BGIMAGE,	    {  0,480},  {320,480}},

	{BOARD_NODE_TOP_TIME,	    {  2, 24},  { 52, 23}},
	{BOARD_NODE_TOP_NAME,	    { 54, 24},  {157, 23}},
	{BOARD_NODE_TOP_MOVE,	    {211, 24},  { 70, 23}},
	{BOARD_NODE_TOP_RATING,	    {281, 24},  { 39, 23}},

	{BOARD_NODE_BOT_TIME,	    {  2,370},  { 52, 23}},
	{BOARD_NODE_BOT_NAME,	    { 54,370},  {157, 23}},
	{BOARD_NODE_BOT_MOVE,	    {211,370},  { 70, 23}},
	{BOARD_NODE_BOT_RATING,	    {281,370},  { 39, 23}},
	
	{BOARD_NODE_INFO1,			{  4,400},  {320, 24}},
	{BOARD_NODE_INFO2,			{  4,424},  {320, 24}},
	//{BOARD_NODE_INFO3,			{  4,435},  {312, 24}},
};

@implementation ChessBoardStaticLayer

@synthesize topTime;
@synthesize topName;
@synthesize topMove;
@synthesize topRating;

@synthesize botTime;
@synthesize botName;
@synthesize botMove;
@synthesize botRating;

@synthesize info1;
@synthesize info2;
//@synthesize info3;

-(id)init
{
	if(self = [super init])
	{
		// background
		/*
		bgImage = [Sprite spriteWithFile:@"bg2_320x480.png"];
		bgImage.tag = BOARD_NODE_BGIMAGE;
		[self addChild:bgImage];
		*/
		
		AtlasSpriteManager *bgAtlasManager = [AtlasSpriteManager spriteManagerWithFile:@"bg2_320x480.pvr"];
		[self addChild:bgAtlasManager];
		
		bgImage = [AtlasSprite spriteWithRect:CGRectMake(5,5,320,480) spriteManager:bgAtlasManager];
		//bgImage.tag = BOARD_NODE_BGIMAGE;
		bgImage.position = cpv(160,240);
		bgImage.opacity = 192;
		[bgAtlasManager addChild:bgImage];
		
		// ----- top line -----
		// top time
		topTime = [FramedLabel labelWithString:@"10:00" dimensions:CGSizeMake(52/FONT_TIME_WIDTH,24) 
							   alignment:UITextAlignmentLeft fontName:@"ArialMT" fontSize:18];
		topTime.tag = BOARD_NODE_TOP_TIME;
		topTime.scaleX = FONT_TIME_WIDTH;
		[topTime setRGB:0:0:0];
		[self addChild:topTime];

		// top name
		topName = [FramedLabel labelWithString:@"Opponent's Name" dimensions:CGSizeMake(157/FONT_NAME_WIDTH,24) 
									 alignment:UITextAlignmentLeft fontName:@"ArialMT" fontSize:18];
		topName.tag = BOARD_NODE_TOP_NAME;
		topName.scaleX = FONT_NAME_WIDTH;
		[topName setRGB:0:0:0];
		[self addChild:topName];

		// top move
		topMove = [FramedLabel labelWithString:@"" dimensions:CGSizeMake(70/FONT_MOVE_WIDTH,24) 
									 alignment:UITextAlignmentLeft fontName:@"ArialMT" fontSize:18];
		topMove.tag = BOARD_NODE_TOP_MOVE;
		topMove.scaleX = FONT_MOVE_WIDTH;
		[topMove setRGB:0:0:0];
		[self addChild:topMove];
		
		// top rating
		topRating = [FramedLabel labelWithString:@"----" dimensions:CGSizeMake(39/FONT_RATE_WIDTH,24) 
									 alignment:UITextAlignmentCenter fontName:@"ArialMT" fontSize:18];
		topRating.tag = BOARD_NODE_TOP_RATING;
		topRating.scaleX = FONT_RATE_WIDTH;
		[topRating setRGB:0:0:0];
		[self addChild:topRating];

		// ----- bot line -----
		// bot time
		botTime = [FramedLabel labelWithString:@"10:00" dimensions:CGSizeMake(52/FONT_TIME_WIDTH,24) 
									 alignment:UITextAlignmentLeft fontName:@"ArialMT" fontSize:18];
		botTime.tag = BOARD_NODE_BOT_TIME;
		botTime.scaleX = FONT_TIME_WIDTH;
		[botTime setRGB:0:0:0];
		[self addChild:botTime];
		
		// bot name
		botName = [FramedLabel labelWithString:@"Your Name" dimensions:CGSizeMake(157/FONT_NAME_WIDTH,24) 
									 alignment:UITextAlignmentLeft fontName:@"ArialMT" fontSize:18];
		botName.tag = BOARD_NODE_BOT_NAME;
		botName.scaleX = FONT_NAME_WIDTH;
		[botName setRGB:0:0:0];
		[self addChild:botName];

		// bot move
		botMove = [FramedLabel labelWithString:@"" dimensions:CGSizeMake(70/FONT_MOVE_WIDTH,24) 
									 alignment:UITextAlignmentLeft fontName:@"ArialMT" fontSize:18];
		botMove.tag = BOARD_NODE_BOT_MOVE;
		botMove.scaleX = FONT_MOVE_WIDTH;
		[botMove setRGB:0:0:0];
		[self addChild:botMove];
		
		// bot rating
		botRating = [FramedLabel labelWithString:@"----" dimensions:CGSizeMake(39/FONT_TIME_WIDTH,24) 
									   alignment:UITextAlignmentCenter fontName:@"ArialMT" fontSize:18];
		botRating.tag = BOARD_NODE_BOT_RATING;
		botRating.scaleX = FONT_RATE_WIDTH;
		[botRating setRGB:0:0:0];
		[self addChild:botRating];
		
		// ----- info lines -----
		// info1
		info1 = [FramedLabel labelWithString:@"Welcome to HandyChess" dimensions:CGSizeMake(320.0/FONT_INFO_WIDTH,24) 
									 alignment:UITextAlignmentLeft fontName:@"ArialMT" fontSize:20];
		info1.tag = BOARD_NODE_INFO1;
		info1.scaleX = FONT_INFO_WIDTH;
		info1.scaleY = FONT_INFO_HEIGHT;
		[info1 setRGB:0:0:96];
		[self addChild:info1];
		// info2
		info2 = [FramedLabel labelWithString:@"Connecting to chess server..." dimensions:CGSizeMake(320.0/FONT_INFO_WIDTH,24) 
								   alignment:UITextAlignmentLeft fontName:@"ArialMT" fontSize:20];
		info2.tag = BOARD_NODE_INFO2;
		info2.scaleX = FONT_INFO_WIDTH;
		info2.scaleY = FONT_INFO_HEIGHT;
		[info2 setRGB:0:0:96];
		[self addChild:info2];
		
		// layout children
		[self layoutElements:boardStaticLayouts number:sizeof(boardStaticLayouts)/sizeof(nodeLayout)];
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

@end

