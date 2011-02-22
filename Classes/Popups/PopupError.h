//
//  PopupError.h
//  HandyChess
//
//  Created by Anton Zemyanov on 16.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageBox.h"
#import "cocos2d.h"

@interface PopupError : Layer
{
	Label			    *message;
	NSMutableArray		*menuItems;
	Menu			    *menu;
	MessageBox			*messageBox;
	
	CallFuncN *onCancel;
}

@property (nonatomic, retain) CallFuncN *onCancel;

+(id)popupWithTitle:(NSString*)title color:(ccColorF)color;
-(id)initWithTitle:(NSString*)title color:(ccColorF)color;

@end

