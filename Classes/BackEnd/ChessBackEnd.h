//
//  ChessBackEnd.h
//  HandyChess
//
//  Created by Anton Zemyanov on 30.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FICSProtocol.h"
#import "ChessGame.h"

// requests from GUI to chess backend
@protocol BackEndMessages
-(void)msgConnect:(NSDictionary*)params;
-(void)msgDisconnect;
-(void)msgSeekGame:(NSDictionary*)params;
-(void)msgUnseekGame;
-(void)msgMatch:(NSDictionary*)params;
-(void)msgRematch;
-(void)msgUnmatch;
-(void)msgCommand:(NSString*)cmd;
-(void)msgPlayerMove:(NSDictionary*)move;
-(void)msgPieceMoved:(NSDictionary*)data;
-(void)msgPromoPiece:(NSDictionary*)data;
@end

// responses and notifications from backend to GUI
@protocol BackEndResponses
-(void)rspError:(NSString*)errMsg;
-(void)rspConnected:(NSDictionary*)params;
-(void)rspDisconnected:(NSDictionary*)params;
-(void)rspMatchIssued:(NSDictionary*)params;
-(void)rspMatchDeclined;
-(void)rspChallenge:(NSDictionary*)params;
-(void)rspGameStarted:(NSDictionary*)params;
-(void)rspGameEnded:(NSDictionary*)params;
-(void)rspStatusInfo:(NSString*)info;
-(void)rspPopupInfo:(NSString*)info;
-(void)rspUpdateTime:(NSDictionary*)time;
-(void)rspSideToMove:(NSDictionary*)params;
-(void)rspSyncPosition:(NSString*)posStyle12;
-(void)rspMovePiece:(NSDictionary*)data;
-(void)rspGetMove:(NSArray*)validMoves;
-(void)rspGetPromoPiece:(NSDictionary*)data;
-(void)rspShowMove:(NSDictionary*)data;
-(void)rspOffer:(NSDictionary*)data;
@end

// State machine for chess game start
typedef enum {
	kBEStateDisconnected = 0,
	kBEStateConnecting   = 1,
	kBEStateReady        = 2,
	kBEStateSeeking      = 3,
	kBEStateMatchIssued  = 4,
} BEState;

// State machine for chess game start
typedef enum {
	kBEConnStateDisconnected  = 0,
	kBEConnStateConnecting    = 1,
	kBEConnStateLoggingIn	  = 2,
	kBEConnStateInitializing  = 3,
	kBEConnStateInitialized   = 4,
} BEConnState;

// State machine for game seek
typedef enum {
	kBESeekStateSeeking       = 0,
} BESeekState;

// State machine for game seek
typedef enum {
	kBEMatchStateWaitAnswer   = 0,
} BEMatchState;

@interface ChessBackEnd : NSObject <BackEndMessages, BackEndResponses, FICSProtocolResponses>
{
	BEState		 state;
	BEConnState connState;
	BESeekState seekState;
	BEMatchState matchState;
	FICSProtocol *proto;
	
	NSObject<BackEndResponses> *delegate;

	BOOL		 isDisconnectRequested;
	
	NSDictionary *settings;
	NSString	 *realLogin;
	BOOL		 isRegistred;

	
	// move generator
	ChessGame	 *game;
	
	NSThread	 *backThread;
}

@property (assign) NSObject<BackEndResponses> *delegate;
@property (retain) NSDictionary *settings;
@property (retain) NSString *realLogin;
@property (assign) BOOL     isRegistred;

@property (readonly) FICSProtocol *proto;
@property (readonly) NSThread *backThread;


+(ChessBackEnd*)sharedChessBackEnd;

-(BOOL)startThread;
-(BOOL)stopThread;
-(void)backThreadFunc:(void*)obj;
-(void)timerTick:(id)userInfo;

@end
