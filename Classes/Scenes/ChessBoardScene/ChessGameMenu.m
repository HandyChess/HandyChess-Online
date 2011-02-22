//
//  ChessGameMenu.m
//  HandyChess
//
//  Created by Anton on 4/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ChessGameMenu.h"
#import "SoundEngine.h"
#import "ChessBoardScene.h"

#define MENU_PAD_X	2
#define MENU_PAD_Y	4

@implementation ChessGameMenu

-(id)init
{
	if(self = [super init])
	{
		offerDraw = [MenuItemImage itemFromNormalImage:@"button_draw_100px_normal.png" 
									selectedImage:@"button_draw_100px_pressed.png" 
									disabledImage:@"button_draw_100px_pressed.png" 
										   target:self selector:@selector(offerDrawPressed:)];
		resign = [MenuItemImage itemFromNormalImage:@"button_resign_100px_normal.png" 
									   selectedImage:@"button_resign_100px_pressed.png" 
									   disabledImage:@"button_resign_100px_pressed.png" 
											  target:self selector:@selector(resignPressed:)];
		/*
		adjourn = [MenuItemImage itemFromNormalImage:@"button_draw_100px_normal.png" 
									 selectedImage:@"button_76x44_adjourn_pressed.png" 
									 disabledImage:@"button_76x44_adjourn_pressed.png" 
											target:self selector:@selector(adjournPressed:)];
		*/
		options = [MenuItemImage itemFromNormalImage:@"button_options_100px_normal.png" 
									   selectedImage:@"button_options_100px_pressed.png" 
									   disabledImage:@"button_options_100px_pressed.png" 
											  target:self selector:@selector(optionsPressed:)];
		
		menu = [Menu menuWithItems:offerDraw,resign,options,nil];
		[self addChild:menu];
		
		CGSize sz = [[Director sharedDirector] winSize];
		float width  = sz.width;
		float height = sz.height;
		float y = MENU_PAD_Y-height/2+[offerDraw contentSize].height/2-3;
		
		// button 1
		float x1 = MENU_PAD_X-width/2+0*([offerDraw contentSize].width+2*MENU_PAD_X)+[offerDraw contentSize].width/2+4;
		offerDraw.position = cpv(x1,y);
		
		// button 2
		float x2 = MENU_PAD_X-width/2+1*([resign contentSize].width+2*MENU_PAD_X)+[resign contentSize].width/2+4;
		resign.position = cpv(x2,y);
		
		// button 3
		//float x3 = MENU_PAD_X-width/2+2*([adjourn contentSize].width+2*MENU_PAD_X)+[adjourn contentSize].width/2;
		//adjourn.position = cpv(x3,y);
		
		// button 4
		float x4 = MENU_PAD_X-width/2+2*([options contentSize].width+2*MENU_PAD_X)+[options contentSize].width/2+4;
		options.position = cpv(x4,y);
		
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

-(void)offerDrawPressed:(id)item
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	ChessBoardScene *sc = (ChessBoardScene*)[[Director sharedDirector] runningScene];
	[sc offerDrawPressed];
}

-(void)resignPressed:(id)item
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	ChessBoardScene *sc = (ChessBoardScene*)[[Director sharedDirector] runningScene];
	[sc resignPressed];
}

-(void)adjournPressed:(id)item
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	ChessBoardScene *sc = (ChessBoardScene*)[[Director sharedDirector] runningScene];
	[sc adjournPressed];
}

-(void)optionsPressed:(id)item
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	ChessBoardScene *sc = (ChessBoardScene*)[[Director sharedDirector] runningScene];
	[sc gameOptionsPressed];
}



@end
