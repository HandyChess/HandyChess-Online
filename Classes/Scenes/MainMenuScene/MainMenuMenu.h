//
//  MainMenuMenu.h
//  HandyChess
//
//  Created by Anton Zemyanov on 18.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface MainMenuMenu : Layer {
	MenuItemImage	*playOnline;
	MenuItemImage	*settings;
	MenuItemImage	*about;
	
	MenuItemToggle	*sound;
	MenuItemImage	*soundEnable;
	MenuItemImage	*soundDisable;
	
	Menu			*menu;
}

-(void)playOnlinePressed:(id)obj;
-(void)settingsPressed:(id)obj;
-(void)soundTogglePressed:(id)obj;
-(void)aboutPressed:(id)obj;

@end
