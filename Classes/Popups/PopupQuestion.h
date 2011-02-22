//
//  PopupQuestion.h
//  HandyChess
//
//  Created by Anton on 5/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class MessageBox;

typedef enum tagQuestionButtons
{
	kQuestionButtonsYesNo			= 0,
	kQuestionButtonsReconnectCancel = 1,
	kQuestionButtonsAcceptDecline   = 2,
} QuestionButtons;

@interface PopupQuestion : Layer 
{
	Label			    *message;
	NSMutableArray		*menuItems;
	Menu			    *menu;
	MessageBox			*messageBox;

	CallFuncN *onFirst;
	CallFuncN *onSecond;
}

@property (nonatomic, retain) CallFuncN *onFirst;
@property (nonatomic, retain) CallFuncN *onSecond;

+(id)popupWithTitle:(NSString*)title buttons:(QuestionButtons)butts color:(ccColorF)color;
-(id)initWithTitle:(NSString*)title buttons:(QuestionButtons)butts color:(ccColorF)color;

@end
