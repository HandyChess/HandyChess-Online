//
//  ChesslnitialMenu.h
//  HandyChess
//
//  Created by Anton Zemlyanov on 1/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ChessInitialMenu : Layer 
{
	MenuItemImage	*seek;
	MenuItemImage	*rematch;
	MenuItemImage	*match;
	MenuItemImage	*options;
	Menu			*menu;
}

-(void)seekPressed:(id)item;
-(void)matchPressed:(id)item;
-(void)rematchPressed:(id)item;
-(void)optionsPressed:(id)item;

@end
