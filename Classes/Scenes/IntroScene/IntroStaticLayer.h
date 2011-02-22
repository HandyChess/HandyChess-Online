//
//  IntroStaticLayer.h
//  HandyChess
//
//  Created by Anton Zemyanov on 17.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "LayoutLayer.h"

@class Sprite;

@interface IntroStaticLayer : LayoutLayer {
	Sprite	*bgImage;
	Sprite	*logo;
	Label	*introMsg;
	Label	*ficsMsg;
	Label	*regMsg;
	Label	*goMainMsg;
	Label   *checkMsg;
}

@end
