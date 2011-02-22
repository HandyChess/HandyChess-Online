//
//  ChessGameResultPopup.h
//  HandyChess
//
//  Created by Anton Zemyanov on 3/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

#define POPUP_WON_COLOR		{0.75, 0.99, 0.75, 0.98};
#define POPUP_LOST_COLOR		{0.99, 0.75, 0.75, 0.98};
#define POPUP_DRAW_COLOR		{0.80, 0.80, 0.75, 0.98};
#define POPUP_OTHER_COLOR	{0.80, 0.80, 0.80, 0.98};

@class RoundedFilledRect;

@interface PopupGameResult : Layer <CocosNodeOpacity>
{
	GLubyte		opacity;
	CallFuncN	*onOk;
	CallFuncN	*onRematch;
	
	RoundedFilledRect *filledRect;
	Label			  *players;
	Label			  *result;
	
	Menu			  *menu;
}

@property (nonatomic, retain) CallFuncN *onOk;
@property (nonatomic, retain) CallFuncN *onRematch;

+(id)popupWithColor:(ccColorF)clr result:(NSString*)res;
-(id)initWithColor:(ccColorF)clr result:(NSString*)res;
-(void)dismiss;

@end
