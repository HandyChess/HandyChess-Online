//
//  TestAlertLayer.h
//  HandyChess
//
//  Created by Anton Zemlyanov on 1/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cocos2D.h"

#import "RoundedFilledRect.h"

@interface MessageBox : CocosNode <CocosNodeOpacity>
{
	// input data
	Label		*label;
	Sprite		*icon;
	NSArray		*buttons;
	ccColorF	frameColor;
	ccColorF	bgColor;
	
	// metrics
	CGFloat		width;
	CGFloat		height;
	CGFloat		maxOfIconOrLabelHeight;
	GLuint		opacity;
	
	// own nodes
	RoundedFilledRect *rect;
	Menu			  *menu;
}

@property (readonly, nonatomic)	Label		*label;
@property (readonly, nonatomic)	Sprite		*icon;
@property (readonly, nonatomic)	NSArray		*buttons;
@property (readonly, nonatomic)	ccColorF	frameColor;
@property (readonly, nonatomic)	ccColorF	bgColor;

+(id)boxWithLabel:(Label*)lab icon:(Sprite*)ic buttons:(NSArray*)buttons 
		frameColor:(ccColorF)frColor backgroundColor:(ccColorF)bgColor;

-(id)initWithLabel:(Label*)lab icon:(Sprite*)ic buttons:(NSArray*)buttons 
		frameColor:(ccColorF)frColor backgroundColor:(ccColorF)bgColor;

@end
