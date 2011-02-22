//
//  AboutMenu.h
//  HandyChess
//
//  Created by Anton on 3/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface AboutMenu : Layer 
{
	MenuItemImage	*cocosLogo;
	MenuItemImage	*registerAtFics;
	MenuItemImage	*writeUs;
	MenuItemImage	*goToMainMenu;
	Menu			*menu;
}

-(void)pressedCocosLogo:(id)item;
-(void)pressedRegisterAtFics:(id)item;
-(void)pressedWriteUs:(id)item;
-(void)pressedGoMainMenu:(id)item;

@end