//
//  HandyChessAppDelegate.m
//  HandyChess
//
//  Created by Anton Zemyanov on 17.01.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "HandyChessAppDelegate.h"

#import "Director.h"
#import "SoundEngine.h"

#import "IntroScene.h"
#import "MainMenuScene.h"
#import "ChessBoardScene.h"
#import "SettingsScene.h"
#import "ChessBackEnd.h"

#import "PopupSeekOptions.h"

@implementation HandyChessAppDelegate
@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    
	// Settings.plist is default settings
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
	NSDictionary *defSettings = [NSDictionary dictionaryWithContentsOfFile:path];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defSettings];
	
	// Sound settings
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	BOOL isEnabled = [defs boolForKey:@"SoundEnabled"];
	if(isEnabled)
		[[SoundEngine sharedSoundEngine] enableSound];
	else
		[[SoundEngine sharedSoundEngine] disableSound];
	
	// Director defaults
	[[Director sharedDirector] attachInWindow:window];
	[[Director sharedDirector] setLandscape:NO];
	[Director sharedDirector].displayFPS = NO;
	[window makeKeyAndVisible];
	
	// ChessBackEnd singleton
	[ChessBackEnd sharedChessBackEnd];

	// Precache scenes
	[self precacheScenes];
	
	// Start sound
	[[SoundEngine sharedSoundEngine] playSound:@"sample1.wav"];
	
	if( [[NSUserDefaults standardUserDefaults] boolForKey:@"SkipIntro"] )
	{
		// run Main menu scene
		MainMenuScene *scene = [MainMenuScene node];
		[[Director sharedDirector] runWithScene:scene];
	}
	else
	{
		// run Intro scene
		IntroScene *scene = [IntroScene node];
		[[Director sharedDirector] runWithScene:scene];
	}
	
	
	return;
}

- (void)dealloc {
    [super dealloc];
}

-(void)precacheScenes
{
	// autorelease scenes
	[MainMenuScene   node];
	[ChessBoardScene node];
	//[SettingsScene   node];
	
	// popup buttons
	[Sprite spriteWithFile:@"button_ok_100px_normal.png"];
	[Sprite spriteWithFile:@"button_ok_100px_pressed.png"];
	[Sprite spriteWithFile:@"button_cancel_100px_normal.png"];
	[Sprite spriteWithFile:@"button_cancel_100px_pressed.png"];
	
}

@end
