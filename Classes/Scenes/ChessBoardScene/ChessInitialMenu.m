//
//  ChesslnitialMenu.m
//  HandyChess
//
//  Created by Anton Zemlyanov on 1/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChessInitialMenu.h"
#import "SoundEngine.h"
#import "ChessBoardScene.h"

#define MENU_PAD_X	2
#define MENU_PAD_Y	4

@implementation ChessInitialMenu

-(id)init
{
	if(self = [super init])
	{
		seek = [MenuItemImage itemFromNormalImage:@"button_seek_100px_normal.png" 
									selectedImage:@"button_seek_100px_pressed.png" 
									disabledImage:@"button_seek_100px_pressed.png" 
										   target:self selector:@selector(seekPressed:)];
		/*
		rematch = [MenuItemImage itemFromNormalImage:@"button_76x44_rematch_norm.png" 
									selectedImage:@"button_76x44_rematch_pressed.png" 
									disabledImage:@"button_76x44_rematch_pressed.png" 
										   target:self selector:@selector(rematchPressed:)];
		*/
		match = [MenuItemImage itemFromNormalImage:@"button_match_100px_normal.png" 
									   selectedImage:@"button_match_100px_pressed.png" 
									   disabledImage:@"button_match_100px_pressed.png" 
											  target:self selector:@selector(matchPressed:)];
		options = [MenuItemImage itemFromNormalImage:@"button_options_100px_normal.png" 
									 selectedImage:@"button_options_100px_pressed.png" 
									 disabledImage:@"button_options_100px_pressed.png" 
											target:self selector:@selector(optionsPressed:)];
		
		menu = [Menu menuWithItems:seek,match,options,nil];
		[self addChild:menu];
		
		CGSize sz = [[Director sharedDirector] winSize];
		float width  = sz.width;
		float height = sz.height;
		float y = MENU_PAD_Y-height/2+[seek contentSize].height/2-3;
		
		// button 1
		float x1 = MENU_PAD_X-width/2+0*([seek contentSize].width+2*MENU_PAD_X)+[seek contentSize].width/2+4;
		seek.position = cpv(x1,y);

		// button 2
		float x2 = MENU_PAD_X-width/2+1*([seek contentSize].width+2*MENU_PAD_X)+[seek contentSize].width/2+4;
		match.position = cpv(x2,y);

		// button 3
		//float x3 = MENU_PAD_X-width/2+2*([seek contentSize].width+2*MENU_PAD_X)+[seek contentSize].width/2;
		//rematch.position = cpv(x3,y);

		// button 4
		float x4 = MENU_PAD_X-width/2+2*([seek contentSize].width+2*MENU_PAD_X)+[seek contentSize].width/2+4;
		options.position = cpv(x4,y);
		
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

-(void)seekPressed:(id)item
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	ChessBoardScene *sc = (ChessBoardScene*)[[Director sharedDirector] runningScene];
	[sc seekPressed];
}

-(void)matchPressed:(id)item
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	ChessBoardScene *sc = (ChessBoardScene*)[[Director sharedDirector] runningScene];
	[sc matchPressed];
}

-(void)rematchPressed:(id)item
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	ChessBoardScene *sc = (ChessBoardScene*)[[Director sharedDirector] runningScene];
	[sc rematchPressed];
}

-(void)optionsPressed:(id)item
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	ChessBoardScene *sc = (ChessBoardScene*)[[Director sharedDirector] runningScene];
	[sc optionsPressed];
}


@end
