//
//  MainMenuStaticLayer.h
//  HandyChess
//
//  Created by Anton Zemyanov on 18.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutLayer.h"

@interface AboutStaticLayer : LayoutLayer 
{
	Sprite	*bgImage;
	Sprite	*logo;
	
	Label	*titleMsg;
	
	Label	*writtenBy;
	Label	*writtenByName;
	
	Label	*poweredBy;
	Label	*thanksRic;
	
	Label	*needAccount;
	Label	*feedback1;
	Label	*feedback2;
}

@end
