//
//  MainMenuStaticLayer.h
//  HandyChess
//
//  Created by Anton Zemyanov on 18.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutLayer.h"

@interface MainMenuStaticLayer : LayoutLayer 
{
	Sprite	*bgImage;
	Sprite	*logo;
	Label	*titleMsg;
	Label	*fics1Msg;
	Label	*fics2Msg;
}

@end
