//
//  IntroScene.h
//  HandyChess
//
//  Created by Anton Zemyanov on 17.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class IntroStaticLayer;
@class IntroMenu;

@interface IntroScene : Scene 
{
	IntroStaticLayer *staticLayer;
	IntroMenu		 *menuLayer;
}

@end
