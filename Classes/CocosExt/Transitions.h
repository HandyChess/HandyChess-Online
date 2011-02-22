//
//  Transitions.h
//  HandyChess2
//
//  Created by Anton Zemyanov on 14.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface FlipXLeftOver : FlipXTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface FlipXRightOver : FlipXTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface FlipYUpOver : FlipYTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface FlipYDownOver : FlipYTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface FlipAngularLeftOver : FlipAngularTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface FlipAngularRightOver : FlipAngularTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface ZoomFlipXLeftOver : ZoomFlipXTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface ZoomFlipXRightOver : ZoomFlipXTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface ZoomFlipYUpOver : ZoomFlipYTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface ZoomFlipYDownOver : ZoomFlipYTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface ZoomFlipAngularLeftOver : ZoomFlipAngularTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface ZoomFlipAngularRightOver : ZoomFlipAngularTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end

