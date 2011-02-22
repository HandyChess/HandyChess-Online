//
//  RoundedFilledRect.h
//  HandyChess
//
//  Created by Anton Zemlyanov on 1/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface RoundedFilledRect : TextureNode 
{
	CGSize		rectSize;
	CGFloat		roundRadius;
	ccColorF	strokeColor;
	ccColorF	fillColor;
}

+(id)rectWithSize:(CGSize)sz radius:(CGFloat)rad strokeColor:(ccColorF)stroke fillColor:(ccColorF)fill; 
-(id)initWithSize:(CGSize)sz radius:(CGFloat)rad strokeColor:(ccColorF)stroke fillColor:(ccColorF)fill; 

@end
