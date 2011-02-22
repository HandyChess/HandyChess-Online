//
//  ChessBackEnd.m
//  HandyChess
//
//  Created by Anton Zemyanov on 30.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ChessBackEnd.h"
#import "FICSProtocol.h"
#import "Logger.h"

@implementation ChessBackEnd

@synthesize delegate;
@synthesize settings;
@synthesize realLogin;
@synthesize isRegistred;

@synthesize proto;
@synthesize backThread;

static ChessBackEnd *chessBackEnd = nil;

#pragma mark ********** Singleton stuff **********
+(ChessBackEnd*)sharedChessBackEnd;
{
	@synchronized(self)
	{
		if(chessBackEnd==nil)
		{
			[[self alloc] init]; // assignment not here
		}
	}
	return chessBackEnd;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self)
	{
		if(chessBackEnd==nil)
		{
			chessBackEnd = [super allocWithZone:zone];
			return chessBackEnd;
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

#pragma mark ********** init **********
// init object
- (id)init
{
    if (self = [super init] ) 
	{
		// init instance vars
		proto = [[FICSProtocol alloc] init];
		[proto setDelegate:self];
		state = kBEStateDisconnected;
		
		// init game
		game = [[ChessGame alloc] init];
		game.backEnd = self;
    }
    return self;
}

// dealloc object
- (void)dealloc 
{
	[game release];
	[proto release];
    [super dealloc];
}

//******************************************************************************
// Thread management
//******************************************************************************
-(BOOL)startThread
{
	MsgLog(@"BACK: Starting backend thread");
	backThread = [[NSThread alloc] initWithTarget:self 
										 selector:@selector(backThreadFunc:) object:nil];
	[backThread start];
	while(![backThread isExecuting])
	{
		MsgLog(@"BACK: waiting thread to start");
		usleep(5000);
	}
	return YES;
}

-(BOOL)stopThread
{
	[backThread cancel];
	while([backThread isExecuting])
	{
		MsgLog(@"BACK: waiting thread to exit");
		usleep(5000);
	}
	MsgLog(@"BACK: Backend thread stopped");
	return YES;
}

-(void)backThreadFunc:(void*)obj
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	MsgLog(@"BACK: Starting backend thread function");

	// Run loop 
	NSRunLoop *loop = [NSRunLoop currentRunLoop];
	
	//Create and attach timer
	NSTimer *voidTimer = [NSTimer timerWithTimeInterval:0.2f target:self 
									selector:@selector(timerTick:) userInfo:nil repeats:YES];
	[loop addTimer:voidTimer forMode:NSDefaultRunLoopMode];
	
	while(YES)
	{
		// iterate loop
		//MsgLog(@"BACK: Iteration of backend loop");
		NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
		[loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2f]];
		[pool2 release];
		
		// test cancel is requested
		if( [[NSThread currentThread] isCancelled] )
			break;
	}
	
	MsgLog(@"BACK: Quittting backend thread function");
	[pool release];
	return;
}
	
-(void)timerTick:(id)userInfo
{
	//MsgLog(@"BACK: Timer tick");
}

//******************************************************************************
// BackEndMessages Protocol
//******************************************************************************
-(void)msgConnect:(NSDictionary*)params
{
	MsgLog(@"BACK: msgConnect: host='%@' port=%@, login='%@' password='%@'",
		  [params objectForKey:@"Host"], [params objectForKey:@"Port"],
		  [params objectForKey:@"Login"], [params objectForKey:@"Password"]);
	
	// remember login params
	isDisconnectRequested = NO;
	self.settings = [[NSDictionary dictionaryWithDictionary:params] retain];

	// Initiaize connecting
	state = kBEStateConnecting;
	connState = kBEConnStateConnecting; 
	UInt16 port = atoi([[params objectForKey:@"Port"] UTF8String]);
	[proto FicsMsgConnect:[params objectForKey:@"Host"] port:port];
	
	// send connecting message to GUI
	NSString *text = [NSString stringWithFormat:@"Connecting to %@...",
						[params objectForKey:@"Host"]];
	[self rspStatusInfo:text];

	[params release];
	return;
}

-(void)msgDisconnect
{
	MsgLog(@"BACK: msgDisconnect");
	isDisconnectRequested = YES;
	[proto FicsMsgDisconnect];
	return;
}

-(void)msgSeekGame:(NSDictionary*)params
{
	MsgLog(@"BACK: msgSeekGame");
	state = kBEStateSeeking;
	
	// set preffered time/increment
	seekState = kBESeekStateSeeking;
	[proto FicsMsgSeekGame:params];
	
	[params release];
	return;
}

-(void)msgUnseekGame
{
	MsgLog(@"BACK: msgUnseekGame");
	state = kBEStateReady;
	
	// unseek game
	[proto FicsMsgUnseekGame];
	
	return;	
}

-(void)msgMatch:(NSDictionary*)params
{
	MsgLog(@"BACK: msgMatch %@", params);
	state = kBEStateMatchIssued;
	
	// set preffered time/increment
	matchState = kBEMatchStateWaitAnswer;
	[proto FicsMsgMatch:params];
	
	[params release];
	return;
}

-(void)msgRematch
{
	MsgLog(@"BACK: msgRematch");
	state = kBEStateMatchIssued;
	
	// set preffered time/increment
	matchState = kBEMatchStateWaitAnswer;
	[proto FicsMsgRematch];
	
	return;	
}

-(void)msgUnmatch
{
	MsgLog(@"BACK: msgUnmatch");
	state = kBEStateReady;
	
	[proto FicsMsgUnmatch];
	
	return;	
}

-(void)msgCommand:(NSString*)cmd
{
	MsgLog(@"BACK: msgAdjourn");
	[proto FicsMsgCommand:cmd];
	[cmd release];
	return;
}

-(void)msgPlayerMove:(NSDictionary*)move
{
	MsgLog(@"BACK: msgPlayerMove");
	[game playerMove:move];
	[move release];
	return;
}

-(void)msgPieceMoved:(NSDictionary*)data
{
	MsgLog(@"BACK: msgPieceMoved");
	[game pieceMoved:data];
	[data release];
	return;
}

-(void)msgPromoPiece:(NSDictionary*)data
{
	MsgLog(@"BACK: msgPromoPiece");
	[game promoPiece:data];
	[data release];
	return;
}

//******************************************************************************
// BackEndResponses Protocol
//******************************************************************************
-(void)rspError:(NSString*)errMsg
{
	if(!delegate)
		return;
	[errMsg retain];
	[delegate performSelector:@selector(rspError:) 
					 onThread:[NSThread mainThread] withObject:errMsg waitUntilDone:NO];
	return;
}

-(void)rspConnected:(NSDictionary*)params
{
	if(!delegate)
		return;
	[params retain];
	[delegate performSelector:@selector(rspConnected:)
					 onThread:[NSThread mainThread] withObject:params waitUntilDone:NO];
}

-(void)rspDisconnected:(NSDictionary*)params;
{
	if(!delegate)
		return;
	[params retain];
	[delegate performSelector:@selector(rspDisconnected:)
					onThread:[NSThread mainThread] withObject:params waitUntilDone:NO];
}

-(void)rspMatchIssued:(NSDictionary*)params
{
	if(!delegate)
		return;
	[params retain];
	[delegate performSelector:@selector(rspMatchIssued:)
					 onThread:[NSThread mainThread] withObject:params waitUntilDone:NO];
}

-(void)rspMatchDeclined
{
	if(!delegate)
		return;
	[delegate performSelector:@selector(rspMatchDeclined)
					 onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
}

-(void)rspChallenge:(NSDictionary*)params
{
	if(!delegate)
		return;
	[params retain];
	[delegate performSelector:@selector(rspChallenge:)
					 onThread:[NSThread mainThread] withObject:params waitUntilDone:NO];
}


-(void)rspGameStarted:(NSDictionary*)params
{
	if(!delegate)
		return;
	[params retain];
	[delegate performSelector:@selector(rspGameStarted:)
					 onThread:[NSThread mainThread] withObject:params waitUntilDone:NO];
}

-(void)rspGameEnded:(NSDictionary*)params
{
	if(!delegate)
		return;
	[params retain];
	[delegate performSelector:@selector(rspGameEnded:)
					 onThread:[NSThread mainThread] withObject:params waitUntilDone:NO];
}

-(void)rspStatusInfo:(NSString*)info
{
	if(!delegate)
		return;
	[info retain];
	[delegate performSelector:@selector(rspStatusInfo:) 
					 onThread:[NSThread mainThread] withObject:info waitUntilDone:NO];
	return;
}

-(void)rspPopupInfo:(NSString*)info
{
	if(!delegate)
		return;
	[info retain];
	[delegate performSelector:@selector(rspPopupInfo:) 
					 onThread:[NSThread mainThread] withObject:info waitUntilDone:NO];
	return;
}

-(void)rspUpdateTime:(NSDictionary*)time
{
	if(!delegate)
		return;
	[time retain];
	[delegate performSelector:@selector(rspUpdateTime:) 
					 onThread:[NSThread mainThread] withObject:time waitUntilDone:NO];
	return;
}

-(void)rspSideToMove:(NSDictionary*)params
{
	if(!delegate)
		return;
	[params retain];
	[delegate performSelector:@selector(rspSideToMove:) 
					 onThread:[NSThread mainThread] withObject:params waitUntilDone:NO];
	return;
}

-(void)rspSyncPosition:(NSString*)posStyle12
{
	if(!delegate)
		return;
	[posStyle12 retain];
	[delegate performSelector:@selector(rspSyncPosition:) 
					 onThread:[NSThread mainThread] withObject:posStyle12 waitUntilDone:NO];
}

-(void)rspMovePiece:(NSDictionary*)data
{
	if(!delegate)
		return;
	[data retain];
	[delegate performSelector:@selector(rspMovePiece:) 
					 onThread:[NSThread mainThread] withObject:data waitUntilDone:NO];
}

-(void)rspGetMove:(NSArray*)validMoves
{
	if(!delegate)
		return;
	[validMoves retain];
	[delegate performSelector:@selector(rspGetMove:) 
					 onThread:[NSThread mainThread] withObject:validMoves waitUntilDone:NO];
}

-(void)rspGetPromoPiece:(NSDictionary*)data
{
	if(!delegate)
		return;
	[data retain];
	[delegate performSelector:@selector(rspGetPromoPiece:) 
					 onThread:[NSThread mainThread] withObject:data waitUntilDone:NO];
}

-(void)rspShowMove:(NSDictionary*)data
{
	if(!delegate)
		return;
	[data retain];
	[delegate performSelector:@selector(rspShowMove:) 
					 onThread:[NSThread mainThread] withObject:data waitUntilDone:NO];
}

-(void)rspOffer:(NSDictionary*)data
{
	if(!delegate)
		return;
	[data retain];
	[delegate performSelector:@selector(rspOffer:) 
					 onThread:[NSThread mainThread] withObject:data waitUntilDone:NO];
}


//******************************************************************************
// FICS Protocol 
//******************************************************************************
-(void)FicsRspError:(NSString*)errorMsg;
{
	MsgLog(@"BACK FicsRspError");
	[self rspError:[NSString stringWithFormat:@"FICS Error:%@",errorMsg]];
}

-(void)FicsRspInfo:(NSString*)info
{
	[self rspStatusInfo:info];
	return;
}

-(void)FicsRspPopupInfo:(NSString*)info
{
	[self rspPopupInfo:info];
}

-(void)FicsRspConnected:(NSDictionary*)data
{
	MsgLog(@"BACK FicsRspConnected");
	
	//Connected, now login to FICS
	connState = kBEConnStateLoggingIn;
	[proto FicsMsgLogin:[settings objectForKey:@"Login"] 
			   password:[settings objectForKey:@"Password"]];
	
	return;
}

-(void)FicsRspDisconnected:(NSDictionary*)data
{
	MsgLog(@"BACK FicsRspDisconnected");
	if(state==kBEStateDisconnected)
	{
		MsgLog(@"Already disconnected, skip message to FE");
		return;
	}
	state = kBEStateDisconnected;
	
	NSString *par = isDisconnectRequested ? @"1" : @"0";
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:data];
	[params setObject:par forKey:@"IsSolicited"];
	[self rspDisconnected:params];
	
	return;
}

-(void)FicsRspLoggedIn:(NSString*)realLog isRegistred:(BOOL)isReg
{
	MsgLog(@"BACK FicsRspLoggedIn");
	// Remember real login and registred
	self.realLogin   = [[NSString alloc] initWithString:realLog];
	self.isRegistred = isReg; 
	
	// Start mandatory global initialization
	// shouts off/style 12 is minimum
	connState = kBEConnStateInitializing;
	[proto FicsMsgInitialize];
	//[self rspConnected:realLogin isRegistred:isRegistred];
}

-(void)FicsRspLoggedOut
{
	MsgLog(@"BACK FicsRspLoggedOut");
}

-(void)FicsRspChallenge:(NSDictionary*)data
{
	MsgLog(@"BACK FicsRspChallenge");
	[self rspChallenge:data];
	return;
}

-(void)FicsRspOffer:(NSDictionary*)data
{
	MsgLog(@"BACK FicsRspOffer");
	[self rspOffer:data];
	return;
}

-(void)FicsRspInitialized
{
	MsgLog(@"BACK FicsRspInitialized");
	state = kBEStateReady;
	
	// invoke rspConnected
	NSMutableDictionary *pars = [NSMutableDictionary dictionary];
	[pars setObject:self.realLogin forKey:@"RealLogin"];
	[pars setObject:[NSNumber numberWithBool:self.isRegistred] forKey:@"IsRegistered"];
	[self rspConnected:pars];
	
	return;
}

-(void)FicsRspReady
{
	MsgLog(@"BACK FicsRspReady");
}

-(void)FicsRspMatchIssued:(NSDictionary*)params
{
	[self rspMatchIssued:params];
	return;
}

-(void)FicsRspMatchDeclined:(NSDictionary*)params
{
	[self rspMatchDeclined];
	return;
}


-(void)FicsRspStartingGame:(NSDictionary*)data
{
	MsgLog(@"BACK FicsRspStartingGame");
	for(NSString *key in data)
		MsgLog(@"    Key='%@' Data='%@'", key, [data objectForKey:key]);
	
	// update game status
	[game startingGame:data];
}

-(void)FicsRspGameStarted:(NSDictionary*)data
{
	MsgLog(@"BACK FicsRspGameStarted");
	for(NSString *key in data)
		MsgLog(@"    Key='%@' Data='%@'", key, [data objectForKey:key]);

	// update game status
	[game gameStarted:data];

	// notify about game start
	//[self rspGameStarted:data];
	
	return;
}

-(void)FicsRspGameEnded:(NSDictionary*)data
{
	MsgLog(@"BACK FicsRspGameEnded");
	for(NSString *key in data)
		MsgLog(@"    Key='%@' Data='%@'", key, [data objectForKey:key]);

	// update game status
	[game gameEnded:data];

	// notify about game end
	//[self rspGameStarted:data];
	
	return;
}

-(void)FicsRspGameStyle12:(NSDictionary*)data
{
	MsgLog(@"BACK FicsRspGameStyle12");
	for(NSString *key in data)
		MsgLog(@"    Key='%@' Data='%@'", key, [data objectForKey:key]);
	
	// update game status
	[game processStyle12:data];
	
	return;
}

@end
