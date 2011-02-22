//
//  SoundEngine.m
//  HandyChess2
//
//  Created by Anton Zemyanov on 13.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Logger.h"
#import "SoundEngine.h"
#import <AudioToolbox/AudioToolbox.h>

NSString *soundMap[] = 
{
	@"sample1.wav",
	@"tick.wav",
	@"piece_down.wav",
	@"beep.wav"
};

//@interface SoundEngine (private)
//@end

static SoundEngine *soundEngine = nil;

@implementation SoundEngine

/******************************  Singleton stuff ******************************/
+(SoundEngine*)sharedSoundEngine
{
	@synchronized(self)
	{
		if(soundEngine==nil)
		{
			[[self alloc] init]; // assignment not here
		}
	}
	return soundEngine;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self)
	{
		if(soundEngine==nil)
		{
			soundEngine = [super allocWithZone:zone];
			return soundEngine;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain 
{
	return self;
}

- (unsigned)retainCount 
{
	return UINT_MAX;
}

- (void)release 
{
}

- (id)autorelease 
{
	return self;
}

/****************************** Init ******************************/
-(id)init
{
	if( self=[super init])
	{
		isEnabled = YES;
		sounds = [[NSMutableDictionary alloc] initWithCapacity:32];
		SystemSoundID sysId;
		for(int cnt=0; cnt<sizeof(soundMap)/sizeof(NSString*); ++cnt)
		{
			MsgLog(@"SND: loading %@", soundMap[cnt]);
			NSString *name = [soundMap[cnt] stringByDeletingPathExtension];
			NSString *ext  = [soundMap[cnt] pathExtension];
			NSString *path1 = [[NSBundle mainBundle] pathForResource:name ofType:ext];
			AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path1], &sysId);
			MsgLog(@"SND: system id is %d",sysId);
			[sounds setObject:[NSNumber numberWithUnsignedInt:sysId] forKey:soundMap[cnt]];
		}
	}
	return self;
}

-(void)enableSound
{
	isEnabled = YES;
}

-(void)disableSound
{
	isEnabled = NO;
}


/****************************** Play/Stop ******************************/
-(void)playSound:(NSString*)soundName
{
	if(!isEnabled)
		return;
	
	NSNumber *sysId = [sounds objectForKey:soundName];
	if( !sysId )
		return;
	
	AudioServicesPlaySystemSound([sysId unsignedIntValue]);
	return;
}

-(void)stopSound
{
	return;
}

@end

