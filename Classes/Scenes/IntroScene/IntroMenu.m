//
//  IntroMenu.m
//  HandyChess
//
//  Created by Anton Zemyanov on 17.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "IntroMenu.h"
#import "SoundEngine.h"
#import "LayoutLayer.h"
#import "Transitions.h"
#import "MainMenuScene.h"
#import "GlobalConfig.h"

@implementation IntroMenu

-(id)init
{
	if(self = [super init])
	{
		// register button
		reg = [MenuItemImage itemFromNormalImage:@"button_register_280x50_normal.png" 
							selectedImage:@"button_register_280x50_pressed.png" 
							target:self 
							 selector:@selector(registerPressed:)];
		reg.position = cpv(0,-20);

		// go main menu button
		goMain = [MenuItemImage itemFromNormalImage:@"button_gomain_280x50_normal.png" 
								   selectedImage:@"button_gomain_280x50_pressed.png" 
										  target:self 
										selector:@selector(goMainPressed:)];
		goMain.position = cpv(0,-140);

		// Checkbox
		checkBoxUnchecked = [MenuItemImage itemFromNormalImage:@"cb_44x44_unchecked.png" 
									  selectedImage:@"cb_44x44_unchecked.png"
														target:self selector:@selector(checkboxPressed:)];
		//checkBoxUnchecked.position = cpv(-120,-200);
		
		checkBoxChecked = [MenuItemImage itemFromNormalImage:@"cb_44x44_checked.png" 
												selectedImage:@"cb_44x44_checked.png"
													target:self selector:@selector(checkboxPressed:)];
		//checkBoxChecked.position = cpv(-120,-200);
		
		checkBox = [MenuItemToggle itemWithTarget:self 
										selector:@selector(checkboxPressed:) 
											items:checkBoxUnchecked, checkBoxChecked, nil];
		checkBox.selectedIndex = 1; 
		checkBox.position = cpv(-120,-200);
		
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		[defs setObject:@"1" forKey:@"SkipIntro"];
		
		menu = [Menu menuWithItems:reg,goMain,checkBox,nil];
		[self addChild:menu];
		
	}
	return self;
}

-(void)dealloc
{
	[reg dealloc];
	[super dealloc];
}

-(void)registerPressed:(id)obj
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.freechess.org/Register/index.html"]];
}

-(void)goMainPressed:(id)obj
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	MainMenuScene *mainMenu = [MainMenuScene node];
	TransitionScene *tr = [FadeTransition transitionWithDuration:FADE_TRANSITION_TIME scene:mainMenu];
	[[Director sharedDirector] replaceScene:tr];
	
}

-(void)checkboxPressed:(id)obj
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	if(checkBox.selectedItem == checkBoxChecked)
		[defs setObject:@"1" forKey:@"SkipIntro"];
	else
		[defs setObject:@"0" forKey:@"SkipIntro"];
	
	return;
}

@end
