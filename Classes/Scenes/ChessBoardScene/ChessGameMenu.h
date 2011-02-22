//
//  ChessGameMenu.h
//  HandyChess
//
//  Created by Anton on 4/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// ingame menu
//   - offer draw
//   - resign
//   - adjuorn
//   - options

@interface ChessGameMenu : Layer 
{
	MenuItemImage	*offerDraw;
	MenuItemImage	*resign;
	MenuItemImage	*adjourn;
	MenuItemImage	*options;
	Menu			*menu;	
}

-(void)offerDrawPressed:(id)item;
-(void)resignPressed:(id)item;
-(void)adjournPressed:(id)item;
-(void)optionsPressed:(id)item;


@end
