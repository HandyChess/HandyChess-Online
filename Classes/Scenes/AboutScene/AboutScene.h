//
//  MainMenuScene.h
//  HandyChess
//
//  Created by Anton Zemyanov on 18.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class AboutStaticLayer;
@class AboutMenu;

@interface AboutScene : Scene 
{
	AboutStaticLayer *staticLayer;
	AboutMenu *aboutMenu;
}

@end
