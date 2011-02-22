//
//  SoundEngine.h
//  HandyChess2
//
//  Created by Anton Zemyanov on 13.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// sound ids
#define kSound1 	0
#define kSound2  1

@interface SoundEngine : NSObject 
{
	BOOL isEnabled;
	NSMutableDictionary *sounds;
}

// get singleton object
+(SoundEngine*)sharedSoundEngine;

-(void)enableSound;
-(void)disableSound;

// sound playback
-(void)playSound:(NSString*)soundName;
-(void)stopSound;

@end
