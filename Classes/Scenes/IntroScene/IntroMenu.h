//
//  IntroMenu.h
//  HandyChess
//
//  Created by Anton Zemyanov on 17.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "LayoutLayer.h"

@interface IntroMenu : Layer 
{
	MenuItemImage	*reg;
	MenuItemImage	*goMain;
	
	MenuItemToggle	*checkBox;
	MenuItemImage	*checkBoxUnchecked;
	MenuItemImage	*checkBoxChecked;
	
	Menu			*menu;
}

-(void)registerPressed:(id)obj;
-(void)goMainPressed:(id)obj;
-(void)checkboxPressed:(id)obj;

@end
