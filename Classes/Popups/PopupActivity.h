//
//  PopupActivity.h
//  HandyChess
//
//  Created by Anton Zemyanov on 16.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MessageBoxActivity.h"
#import "cocos2d.h"

@class MessageBox;

@interface PopupActivity : Layer 
{
	Sprite			    *activity;
	Label			    *message;
	NSMutableArray		*menuItems;
	Menu			    *menu;
	MessageBox			*messageBox;

	CallFuncN *onCancel;
}

@property (nonatomic, retain) CallFuncN *onCancel;

@property (readonly)	Label  *message;
@property (readonly)	Sprite *activity;

+(id)popupWithTitle:(NSString*)title titleSize:(CGSize)sz color:(ccColorF)color;
-(id)initWithTitle:(NSString*)title titleSize:(CGSize)sz color:(ccColorF)color;

@end
