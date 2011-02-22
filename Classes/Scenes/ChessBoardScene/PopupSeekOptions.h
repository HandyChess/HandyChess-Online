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

@interface PopupSeekOptions : Layer <CocosNodeOpacity>
{
	GLuint	opacity;
	
	BOOL	isRegistred;
	
	NSMutableDictionary *seekParams;
	NSArray		*times;
	NSArray		*incs;
	NSArray		*ratings;
	
	PickerController *picker;
	
	// Title
	Label			    *title;
	
	// GameTime
	Label				*gameTime;
	Label				*gameTimeFrom;
	Label				*gameTimeTo;
	Label				*gameTimeMin;
	Label				*gameTimeMax;
	MenuItemImage		*gameTimeMinButton;
	MenuItemImage		*gameTimeMaxButton;

	// GameInc
	Label				*gameInc;
	Label				*gameIncFrom;
	Label				*gameIncTo;
	Label				*gameIncMin;
	Label				*gameIncMax;
	MenuItemImage		*gameIncMinButton;
	MenuItemImage		*gameIncMaxButton;
	
	// Piece Color
	Label				*pieceColor;
	Label				*pieceColorLabelAny;
	Label				*pieceColorLabelWhite;
	Label				*pieceColorLabelBlack;
	MenuItemImage		*pieceColorAny;
	MenuItemImage		*pieceColorWhite;
	MenuItemImage		*pieceColorBlack;
	
	// Rate type
	BOOL				isRateTypeEnabled;
	Label				*rateType;
	Label				*rateTypeLabelAny;
	Label				*rateTypeLabelRated;
	Label				*rateTypeLabelUnrated;
	MenuItemImage		*rateTypeAny;
	MenuItemImage		*rateTypeRated;
	MenuItemImage		*rateTypeUnrated;
	
	// Rate value
	BOOL				isRateValEnabled;
	Label				*rateVal;
	Label				*rateValFrom;
	Label				*rateValTo;
	Label				*rateValMin;
	Label				*rateValMax;
	MenuItemImage		*rateValMinButton;
	MenuItemImage		*rateValMaxButton;
	
	// Checkbox
	BOOL				isCheckBoxEnabled;
	MenuItemImage		*checkBoxUnchecked;
	MenuItemImage		*checkBoxChecked;
	MenuItemToggle		*checkBox;
	Label				*checkBoxPrompt;
	
	// Menu
	NSMutableArray		*menuItems;
	Menu			    *menu;
	
	// Box
	RoundedFilledRect	*roundedRect;
	
	CallFuncN *onSeek;
	CallFuncN *onCancel;
}

@property (nonatomic, retain) PickerController *picker;

@property (nonatomic, retain) CallFuncN *onSeek;
@property (nonatomic, retain) CallFuncN *onCancel;

-(void)nodeDidAppeared;
-(void)nodeWillDisappear;

-(void)enableRateType:(BOOL)isEnabled;
-(void)enableRateValue:(BOOL)isEnabled;
-(void)enableAllowUnregistred:(BOOL)isEnabled;

-(void)setTimeMin:(NSString*)val;
-(void)setTimeMax:(NSString*)val;
-(void)setIncMin:(NSString*)val;
-(void)setIncMax:(NSString*)val;
-(void)setPieceColor:(NSString*)val;
-(void)setRatingType:(NSString*)val;
-(void)setRatingMin:(NSString*)val;
-(void)setRatingMax:(NSString*)val;
-(void)setAllowUnregistred:(NSString*)val;

+(id)popupWithRegisteredStatus:(BOOL)isReg;
-(id)initWithRegisteredStatus:(BOOL)isReg;

@end

