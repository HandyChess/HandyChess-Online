//
//  PopupSeekOptions.h
//  HandyChess
//
//  Created by Anton on 4/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class PickerController;
@class RoundedFilledRect;

@interface PopupMatchOptions : Layer <CocosNodeOpacity, UITextFieldDelegate>
{
	GLuint	opacity;
	
	BOOL	isRegistred;
	
	NSMutableDictionary *matchParams;
	NSArray		*times;
	NSArray		*incs;
	
	PickerController *picker;
	
	// Title
	Label			    *title;
	
	// Opponent name
	Label				*name;
	Sprite				*namePlaceholder;
	UITextField			*nameField;
	
	// GameTime
	Label				*gameTime;
	Label				*gameTimeVal;
	MenuItemImage		*gameTimeButton;

	// GameInc
	Label				*gameInc;
	Label				*gameIncVal;
	MenuItemImage		*gameIncButton;
	
	// Piece Color
	Label				*pieceColor;
	Label				*pieceColorLabelFair;
	Label				*pieceColorLabelWhite;
	Label				*pieceColorLabelBlack;
	MenuItemImage		*pieceColorFair;
	MenuItemImage		*pieceColorWhite;
	MenuItemImage		*pieceColorBlack;
	
	// Rate type
	BOOL				isRateTypeEnabled;
	Label				*rateType;
	Label				*rateTypeLabelRated;
	Label				*rateTypeLabelUnrated;
	MenuItemImage		*rateTypeRated;
	MenuItemImage		*rateTypeUnrated;
			
	// Menu
	NSMutableArray		*menuItems;
	Menu			    *menu;
	
	// Box
	RoundedFilledRect	*roundedRect;
	
	CallFuncN *onMatch;
	CallFuncN *onCancel;
}

@property (nonatomic, retain) PickerController *picker;

@property (nonatomic, retain) CallFuncN *onMatch;
@property (nonatomic, retain) CallFuncN *onCancel;

-(void)nodeDidAppeared;
-(void)nodeWillDisappear;

-(void)enableRateType:(BOOL)isEnabled;

-(void)setName:(NSString*)val;
-(void)setTime:(NSString*)val;
-(void)setInc:(NSString*)val;
-(void)setPieceColor:(NSString*)val;
-(void)setRatingType:(NSString*)val;
 
+(id)popupWithRegisteredStatus:(BOOL)isReg;
-(id)initWithRegisteredStatus:(BOOL)isReg;

@end

