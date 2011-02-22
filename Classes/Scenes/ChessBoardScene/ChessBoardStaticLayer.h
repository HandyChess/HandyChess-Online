//
//  ChessBoardStaticLayer.h
//  HandyChess
//
//  Created by Anton Zemyanov on 18.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutLayer.h"

@interface ChessBoardStaticLayer : LayoutLayer {
	AtlasSprite	*bgImage;
	
	Label	*topTime;
	Label	*topName;
	Label	*topMove;
	Label	*topRating;

	Label	*botTime;
	Label	*botName;
	Label	*botMove;
	Label	*botRating;
	
	Label	*info1;
	Label	*info2;
	//Label	*info3;
}

@property (readonly) Label	*topTime;
@property (readonly) Label	*topName;
@property (readonly) Label	*topMove;
@property (readonly) Label	*topRating;

@property (readonly) Label	*botTime;
@property (readonly) Label	*botName;
@property (readonly) Label	*botMove;
@property (readonly) Label	*botRating;

@property (readonly) Label	*info1;
@property (readonly) Label	*info2;
//@property (readonly) Label	*info3;


@end
