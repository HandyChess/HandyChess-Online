//
//  FICSProtocol.h
//  HandyChess
//
//  Created by Anton Zemyanov on 30.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FICSSequencer.h"
#import "regex.h" 

@class TCPConnection;
@class FICSSequencer;
@class FICSMatcher;

// FICS requests
@protocol FICSProtocolMessages
-(void)FicsMsgConnect:(NSString*)host port:(UInt16)port;
-(void)FicsMsgDisconnect;
-(void)FicsMsgLogin:(NSString*)login password:(NSString*)password;
-(void)FicsMsgInitialize;
-(void)FicsMsgSeekGame:(NSDictionary*)params;
-(void)FicsMsgUnseekGame;
-(void)FicsMsgMatch:(NSDictionary*)params;
-(void)FicsMsgRematch;
-(void)FicsMsgUnmatch;
-(void)FicsMsgCommand:(NSString*)cmd;
-(void)FicsMsgSendMove:(NSString*)move;
@end

// FICS responses
@protocol FICSProtocolResponses
-(void)FicsRspError:(NSString*)errorMsg;
-(void)FicsRspInfo:(NSString*)info;
-(void)FicsRspPopupInfo:(NSString*)info;
-(void)FicsRspConnected:(NSDictionary*)data;
-(void)FicsRspDisconnected:(NSDictionary*)data;
-(void)FicsRspLoggedIn:(NSString*)realLogin isRegistred:(BOOL)isRegistred;
-(void)FicsRspLoggedOut;
-(void)FicsRspChallenge:(NSDictionary*)data;
-(void)FicsRspOffer:(NSDictionary*)data;
-(void)FicsRspInitialized;
-(void)FicsRspReady;
-(void)FicsRspMatchIssued:(NSDictionary*)data;
-(void)FicsRspMatchDeclined:(NSDictionary*)data;
-(void)FicsRspStartingGame:(NSDictionary*)data;
-(void)FicsRspGameStarted:(NSDictionary*)data;
-(void)FicsRspGameEnded:(NSDictionary*)data;
-(void)FicsRspGameStyle12:(NSDictionary*)data;
@end

typedef enum {
	kFICSStateDisconnected			= 0,
	kFICSStateConnecting 			= 1,
	kFICSStateConnected 			= 2,
	kFICSStateLoggingIn				= 3,
	kFICSStateLoggedIn				= 4,
	kFICSStateInitialize			= 5,
	kFICSStateReady					= 6,
	kFICSStateSeekingGame			= 7,
	kFICSStateMatchIssued			= 8,
	kFICSStateInGame				= 9,
} FICSState;

typedef enum {
	kFICSLoginStateIdle				= 0,
	kFICSLoginStateGotLogin		    = 1, // got login propmt, not yet login data sent
	kFICSLoginStateWaitMessage		= 2, // wait message indicating reg/unreg user
	kFICSLoginStateWaitPassword		= 3, // wait password prompt, if reg user
	kFICSLoginStateWaitEnterAs		= 4, // wait propmt, if unreg
	kFICSLoginStateWaitStartSession	= 5, // wait 'Starting FICS session as ...'
} FICSStateLogin;

typedef enum {
	kFICSInitStateIdle				= 0, // wait prompt to start initialization 
	kFICSInitStateWaitFirstPrompt	= 2, // wait prompt to start initialization 
	kFICSInitStateWaitConfStyle12	= 3, // wait confirmation style 12 set
	kFICSInitStateWaitConfSeeks  	= 4, // wait confirmation seeks off set
	kFICSInitStateWaitConfShouts	= 5, // wait confirmation shouts off set
} FICSStateInitialize;

typedef enum {
	kFICSReadyStateStateIdle  		= 0, // not in game, wait next command
	kFICSReadyStateWaitPrompt		= 1, // wait '%fics'
} FICSStateReady;

typedef enum {
	kFICSSeekStateWaitPrompt  		= 0, // wait '%fics'
	kFICSSeekStateWaitConfTime		= 1, // wait '%fics'
	kFICSSeekStateWaitConfInc    	= 2, // wait '%fics'
	kFICSSeekStateWaitConfFormula  	= 3, // wait '%fics'
	kFICSSeekStateWaitGameStart     = 4, // wait game start 
} FICSStateSeek;

typedef enum {
	kFICSMatchStateWaitPrompt  		= 0, // wait '%fics'
	kFICSMatchStateWaitIssuing      = 1, // wait game start 
	kFICSMatchStateWaitGameStart    = 2, // wait game start 
} FICSStateMatch;

typedef enum {
	kFICSGameStateWaitStart 		= 0, // wait game start confirmation
	kFICSGameStateInGame			= 1, // game is started
	kFICSGameStateWaitPrompt		= 2, // wait '%fics'
} FICSStateInGame;

@interface FICSProtocol : NSObject <FICSProtocolMessages, FICSSequencerDelegate> {
	// delagate, chess backend usually
	id<FICSProtocolResponses>	delegate;
	
	// hierarchial state machine
	FICSState			state;
	FICSStateLogin		stateLogin;
	FICSStateInitialize	stateInitialize;
	FICSStateReady		stateReady;
	FICSStateSeek		stateSeek;
	FICSStateSeek		stateMatch;
	FICSStateInGame		stateInGame;

	// sequencer and connection (tcp network proxy)
	TCPConnection		*connection;
	FICSSequencer		*sequencer;
	FICSMatcher			*matcher;
	
	// cached chess values
	NSMutableDictionary *chessData;
	NSDictionary		*seekData;
	NSDictionary		*matchData;
	BOOL				isRegistred;
	
	// fics merged line
	regex_t				mergedPrompt;
}

@property (nonatomic, assign) id<FICSProtocolResponses>	delegate;

-(void)setState:(FICSState)newState;
-(void)processLine:(NSString*)line;

-(NSString*)prepareFormula;

@end
