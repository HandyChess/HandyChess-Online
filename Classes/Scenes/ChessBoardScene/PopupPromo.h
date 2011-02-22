//
//  PopupPromo.h
//  HandyChess
//
//  Created by Anton on 4/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ChessPiece.h"

@class RoundedFilledRect;

@interface PopupPromo : Layer <CocosNodeOpacity>
{
	GLubyte		opacity;
	CallFuncN	*onButton;
	
	RoundedFilledRect *filledRect;
	Label			  *prompt;
	
	MenuItemImage	  *queen;
	MenuItemImage	  *rook;
	MenuItemImage	  *bishop;
	MenuItemImage	  *knight;
	Menu			  *menu;
	
	NSString		  *pieceSelected;
}

@property (nonatomic, retain) CallFuncN *onButton;

@property (readonly) MenuItemImage	  *queen;
@property (readonly) MenuItemImage	  *rook;
@property (readonly) MenuItemImage	  *bishop;
@property (readonly) MenuItemImage	  *knight;

@property (readonly) NSString *pieceSelected;

+(id)popupWithPieceColor:(PieceColor)color;
-(id)initWithPieceColor:(PieceColor)color;
-(void)dismiss;

@end
