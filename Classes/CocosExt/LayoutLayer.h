//
//  LayoutLayer.h
//  HandyChess
//
//  Created by Anton Zemyanov on 17.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

// controls layout
typedef struct nodeLayout 
	{
		int		tag;
		cpVect	position;
		CGSize	size;
	}
	nodeLayout;

@interface LayoutLayer : Layer {

}

-(BOOL)layoutElements:(nodeLayout*)layout number:(NSUInteger)num;

@end
