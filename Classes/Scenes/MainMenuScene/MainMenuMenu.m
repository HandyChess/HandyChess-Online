//
//  MainMenuMenu.m
//  HandyChess
//
//  Created by Anton Zemyanov on 18.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GlobalConfig.h"
#import "MainMenuMenu.h"
#import "MainMenuScene.h"
#import "cocos2d.h"
#import "SoundEngine.h"
#import "Transitions.h"

#import "AboutScene.h"
#import "ChessBoardScene.h"
#import "SettingsScene.h"

@implementation MainMenuMenu

-(id)init
{
	if(self = [super init])
	{
		// play online button
		playOnline = [MenuItemImage itemFromNormalImage:@"main_playchess_normal.png" 
								   selectedImage:@"main_playchess_pressed.png" 
										  target:self 
										selector:@selector(playOnlinePressed:)];
		playOnline.position = cpv(-75,70);

		// settings button
		settings = [MenuItemImage itemFromNormalImage:@"main_settings_normal.png" 
										  selectedImage:@"main_settings_pressed.png" 
												 target:self 
											   selector:@selector(settingsPressed:)];
		settings.position = cpv(75,70);
		 
		// disable sound control
		soundDisable = [MenuItemImage itemFromNormalImage:@"main_sound_on_normal.png" 
											selectedImage:@"main_sound_on_pressed.png"]; 
		soundEnable = [MenuItemImage itemFromNormalImage:@"main_sound_off_normal.png" 
										   selectedImage:@"main_sound_off_pressed.png"]; 
		
		sound = [MenuItemToggle itemWithTarget:self selector:@selector(soundTogglePressed:) 
										 items:soundDisable, soundEnable, nil];
		sound.position = cpv(-75,-85);

		// current sound status
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		BOOL isEnabled = [defs boolForKey:@"SoundEnabled"];
		sound.selectedIndex= isEnabled ? 0 : 1;

		// about button
		about = [MenuItemImage itemFromNormalImage:@"main_about_normal.png" 
										selectedImage:@"main_about_pressed.png" 
											   target:self 
											 selector:@selector(aboutPressed:)];
		about.position = cpv(75,-85);
		
		menu = [Menu menuWithItems:playOnline,settings,sound,about,nil];
		[self addChild:menu];
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

-(void)playOnlinePressed:(id)obj
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];

	ChessBoardScene *boardScene = [ChessBoardScene node];
	TransitionScene *tr = [FadeTransition transitionWithDuration:FADE_TRANSITION_TIME scene:boardScene];
	tr.onFinish = [CallFuncN actionWithTarget:boardScene selector:@selector(didTransitIn:)];
	[[Director sharedDirector] replaceScene:tr];
}

-(void)settingsPressed:(id)obj
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];

	SettingsScene *settingsScene = [SettingsScene node];
	TransitionScene *tr = [FadeTransition transitionWithDuration:FADE_TRANSITION_TIME scene:settingsScene];
	tr.onFinish = [CallFuncN actionWithTarget:settingsScene selector:@selector(showSettingsView:)];
	[[Director sharedDirector] replaceScene:tr];
	
}

-(void)soundTogglePressed:(id)obj
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	if(sound.selectedIndex==0)
	{
		[[SoundEngine sharedSoundEngine] enableSound];
		[defs setBool:YES forKey:@"SoundEnabled"];
	}
	else
	{
		[[SoundEngine sharedSoundEngine] disableSound];
		[defs setBool:NO forKey:@"SoundEnabled"];
	}
	
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	return;
}

-(void)aboutPressed:(id)obj
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	AboutScene *aboutScene = [AboutScene node];
	//[[Director sharedDirector] replaceScene:[ZoomFlipXLeftOver transitionWithDuration:0.3f scene:aboutScene]];
	[[Director sharedDirector] replaceScene:[FadeTransition transitionWithDuration:FADE_TRANSITION_TIME scene:aboutScene]];
}

@end

