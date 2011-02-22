//
//  AboutMenu.m
//  HandyChess
//
//  Created by Anton on 3/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AboutMenu.h"
#import "SoundEngine.h"
#import "Transitions.h"
#import "MainMenuScene.h"
#import "GlobalConfig.h"

@implementation AboutMenu

-(id)init
{
	if(self = [super init])
	{

		// write us
		writeUs = [MenuItemImage itemFromNormalImage:@"button_writeus_280x50_normal.png" 
									   selectedImage:@"button_writeus_280x50_pressed.png" 
											  target:self 
											selector:@selector(pressedWriteUs:)];
		writeUs.position = cpv(0,+15);

		// register button
		registerAtFics = [MenuItemImage itemFromNormalImage:@"button_register_280x50_normal.png" 
								   selectedImage:@"button_register_280x50_pressed.png" 
										  target:self 
										selector:@selector(pressedRegisterAtFics:)];
		registerAtFics.position = cpv(0,-95);

		
		/*
		cocosLogo = [MenuItemImage itemFromNormalImage:@"cocos2d_52x52.png" 
										 selectedImage:@"cocos2d_52x52.png" 
										 disabledImage:@"cocos2d_52x52.png" 
												target:self selector:@selector(pressedCocosLogo:)];
		cocosLogo.position = cpv(0, -150);
		*/

		// go main menu button
		goToMainMenu = [MenuItemImage itemFromNormalImage:@"button_gomain_280x50_normal.png" 
									  selectedImage:@"button_gomain_280x50_pressed.png" 
											 target:self 
										   selector:@selector(pressedGoMainMenu:)];
		goToMainMenu.position = cpv(0,-208);
		menu = [Menu menuWithItems:registerAtFics,writeUs,goToMainMenu,nil];
		[self addChild:menu];
		
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

-(void)pressedCocosLogo:(id)item
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	[[UIApplication sharedApplication] openURL:
			[NSURL URLWithString:@"http://code.google.com/p/cocos2d-iphone/"]];
	return;
}

-(void)pressedRegisterAtFics:(id)item
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	[[UIApplication sharedApplication] openURL:
			[NSURL URLWithString:@"http://www.freechess.org/Register/index.html"]];
	return;
}

-(void)pressedWriteUs:(id)item
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	[[UIApplication sharedApplication] openURL:
			[NSURL URLWithString:@"mailto:handychess@gmail.com?subject=iPhone%20HandyChess%20Feedback"]];
	return;
}

-(void)pressedGoMainMenu:(id)item
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	MainMenuScene *mainMenu = [MainMenuScene node];
	TransitionScene *tr = [FadeTransition transitionWithDuration:FADE_TRANSITION_TIME scene:mainMenu];
	[[Director sharedDirector] replaceScene:tr];
	return;
}

@end
