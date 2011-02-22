//
//  ChessBoardController.m
//  HandyChess
//
//  Created by Anton Zemyanov on 27.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GlobalConfig.h"
#import "ChessBoardController.h"
#import "ChessBoardScene.h"
#import "ChessBoardLayer.h"

#import "ChessBackEnd.h"
#import "Logger.h"

#define WHITE_ON_BOTTOM	YES
#define BLACK_ON_BOTTOM NO

@implementation ChessBoardController

@synthesize isConnected;
@synthesize isRegistred;
@synthesize state;
@synthesize scene;
//@synthesize chessBoard;

-(id)init
{
	if(self=[super init])
	{
		backEnd = [ChessBackEnd sharedChessBackEnd];
		backEnd.delegate = self;
		
		isConnected = NO;
		
		realLogin = [[NSMutableString alloc] initWithString:@""];
	}
	return self;
}

-(void)dealloc
{
	backEnd.delegate = nil;
	[realLogin release];
	[super dealloc];
}

-(BOOL)startBackend
{
	MsgLog(@"CTL: start backend");
	return [backEnd startThread];
}

-(BOOL)stopBackend
{
	MsgLog(@"CTL: stop backend");
	return [backEnd stopThread];
}

-(BOOL)connect
{
	MsgLog(@"CTL: connect to chess server");
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[defs objectForKey:@"Host"]		forKey:@"Host"];
	[dict setObject:[defs objectForKey:@"Port"]		forKey:@"Port"];
	[dict setObject:[defs objectForKey:@"Login"]	forKey:@"Login"];
	[dict setObject:[defs objectForKey:@"Password"] forKey:@"Password"];
	[self msgConnect:dict];
	
	return YES;
}

-(BOOL)disconnect
{
	backEnd.delegate = nil;
	[self msgDisconnect];
	return YES;
}

//******************************************************************************
// BackEndMessage retranslators
//******************************************************************************
-(void)msgConnect:(NSDictionary*)params
{
	MsgLog(@"CTL: state=CBStateConnecting");
	state = CBStateConnecting;
	
	//[scene createConnect];
	//[scene changeConnectText:@"Starting Chess Engine"];
	
	[scene connectPopupShow];
	[scene connectPopupSetText:@"Starting Chess Engine"];

	MsgLog(@"CTL: send msgConnect");
	[params retain];
	[backEnd performSelector:@selector(msgConnect:) 
					onThread:backEnd.backThread withObject:params waitUntilDone:NO];
	return;
}

-(void)msgDisconnect
{
	[backEnd performSelector:@selector(msgDisconnect) 
					onThread:backEnd.backThread withObject:nil waitUntilDone:NO];
	return;
}

-(void)msgSeekGame:(NSDictionary*)params
{
	MsgLog(@"CTL: state=CBStateSeeking");
	state = CBStateSeeking;
	
	MsgLog(@"CTL show wait game dialog");
	[scene waitGamePopupShow:@"Seeking for an opponent..."];

	MsgLog(@"CTL: send msgmsgSeekGame");
	[params retain];
	[backEnd performSelector:@selector(msgSeekGame:) 
					onThread:backEnd.backThread withObject:params waitUntilDone:NO];
	return;
}

-(void)msgUnseekGame
{
	MsgLog(@"CTL: state=CBStateReady");
	state = CBStateNotInGame;

	//MsgLog(@"CTL remove wait game dialog");
	//[scene waitGamePopupDismiss];
	MsgLog(@"CTL: send msgUnseekGame");
	[backEnd performSelector:@selector(msgUnseekGame) 
					onThread:backEnd.backThread withObject:nil waitUntilDone:NO];
	
	return;
}

-(void)msgMatch:(NSDictionary*)params
{
	MsgLog(@"CTL: state=CBStateMatchOffered");
	state = CBStateMatchOffered;
	
	MsgLog(@"CTL: send msgMatch");
	[params retain];
	[backEnd performSelector:@selector(msgMatch:) 
					onThread:backEnd.backThread withObject:params waitUntilDone:NO];
	return;
}

-(void)msgRematch
{
	MsgLog(@"CTL: state=CBStateMatchOffered");
	state = CBStateMatchOffered;
	
	MsgLog(@"CTL: send msgRematch");
	[backEnd performSelector:@selector(msgRematch) 
					onThread:backEnd.backThread withObject:nil waitUntilDone:NO];
	return;
}

-(void)msgUnmatch
{
	MsgLog(@"CTL: state=CBStateReady");
	state = CBStateNotInGame;
	
	//MsgLog(@"CTL remove wait game dialog");
	//[scene waitGamePopupDismiss];
	MsgLog(@"CTL: send msgUnmatch");
	[backEnd performSelector:@selector(msgUnmatch) 
					onThread:backEnd.backThread withObject:nil waitUntilDone:NO];
	
	return;
}

/*
-(void)msgResign
{
	MsgLog(@"CTL: send msgResign");
	[backEnd performSelector:@selector(msgResign) 
					onThread:backEnd.backThread withObject:nil waitUntilDone:NO];
	return;
}

-(void)msgOfferDraw
{
	MsgLog(@"CTL: send msgOfferDraw");
	[backEnd performSelector:@selector(msgOfferDraw) 
					onThread:backEnd.backThread withObject:nil waitUntilDone:NO];
	return;
}

-(void)msgAbort
{
	MsgLog(@"CTL: send msgAbort");
	[backEnd performSelector:@selector(msgAbort) 
					onThread:backEnd.backThread withObject:nil waitUntilDone:NO];
	return;
}

-(void)msgAdjourn
{
	MsgLog(@"CTL: send msgAdjourn");
	[backEnd performSelector:@selector(msgAdjourn) 
					onThread:backEnd.backThread withObject:nil waitUntilDone:NO];
	return;
}
*/

-(void)msgCommand:(NSString*)cmd
{
	MsgLog(@"CTL: send msgCommand:%@",cmd);
	[cmd retain];
	[backEnd performSelector:@selector(msgCommand:) 
					onThread:backEnd.backThread withObject:cmd waitUntilDone:NO];
	return;
}


-(void)msgPlayerMove:(NSDictionary*)move
{
	MsgLog(@"CTL: send msgPlayerMove");
	[move retain];
	[backEnd performSelector:@selector(msgPlayerMove:) 
					onThread:backEnd.backThread withObject:move waitUntilDone:NO];
	return;
}

-(void)msgPieceMoved:(NSDictionary*)data
{
	MsgLog(@"CTL: send msgPieceMoved");
	[data retain];
	[backEnd performSelector:@selector(msgPieceMoved:) 
					onThread:backEnd.backThread withObject:data waitUntilDone:NO];
	return;
}

-(void)msgPromoPiece:(NSDictionary*)data
{
	MsgLog(@"CTL: send msgPromoPiece");
	[data retain];
	[backEnd performSelector:@selector(msgPromoPiece:) 
					onThread:backEnd.backThread withObject:data waitUntilDone:NO];
	return;
}


//******************************************************************************
// BackEndResponses Protocol
//******************************************************************************
-(void)rspError:(NSString*)errMsg
{
	MsgLog(@"CTL: received rspError:%@",errMsg);
	[scene errorPopupShow:errMsg];
	return;
}

-(void)rspConnected:(NSDictionary*)params
{
	MsgLog(@"CTL: received rspConnected:%@",params);
	isConnected = YES;
	if(state==CBStateConnecting)
	{
		MsgLog(@"CTL: state=CBStateNotInGame");
		state = CBStateNotInGame;
		[scene clearInfo];
		if([[params objectForKey:@"IsRegistered"] boolValue])
		{
			isRegistred = YES;
			[scene writeInfo:[NSString stringWithFormat:@"Logged in as '%@' (registred)",[params objectForKey:@"RealLogin"]]];
		}
		else
		{
			isRegistred = NO;
			[scene writeInfo:[NSString stringWithFormat:@"Logged in as '%@' (unregistred)",[params objectForKey:@"RealLogin"]]];
			//[scene writeInfo:[NSString stringWithFormat:@"Please register to play rated games"]];
		}
		[scene writeInfo:@"Press Seek or Match to start a game"];
		
		// remember real login
		[realLogin setString:[params objectForKey:@"RealLogin"]];
		
		// hide connect poput
		//[scene hideConnect];
		[scene connectPopupDismiss];
		[scene setBotName:realLogin];
	}
	return;
}

-(void)rspDisconnected:(NSDictionary*)params
{
	MsgLog(@"CTL: received rspDisconnected");

	// game is certainly ended, when disconnected
	[scene gameEnded:nil];

	BOOL wasConnected = isConnected;
	isConnected = NO;
	if([[params objectForKey:@"IsSolicited"] boolValue]==NO)
	{
		NSString *desc = [params objectForKey:@"Description"];
		NSString *err  = nil;
		if(desc)
			err = [NSString stringWithFormat:@"%@", desc];
		else
			err = [NSString stringWithFormat:@"Code %@", [params objectForKey:@"Code"]];

		NSString *txt = nil;
		if(wasConnected)
		{
			// Disconnected existed connection
			txt = [NSString stringWithFormat:@"Disconnected from server (%@), try reconnect?",err]; 
		}
		else
		{
			// Failed to establish connection
			txt = [NSString stringWithFormat:@"Failed to connect to server (%@), try again?",err]; 
		}
		[scene disconnectedPopupShow:txt];
		MsgLog(@"CTL: state=CBStateError");
		state = CBStateError;
	}
	[params release];
	
	return;
}

-(void)rspMatchIssued:(NSDictionary*)params
{
	MsgLog(@"CTL: received rspMatchIssued");
	[scene waitGamePopupShow:@"Match request issued, wait opponent's reply"];
	[params release];
	return;
}

-(void)rspMatchDeclined
{
	MsgLog(@"CTL: received rspMatchDeclined");
	[scene waitGamePopupDelete];
	
	[scene infoPopupShow:@"Your match offer declined"];
	[scene writeInfo:@"Your match offer declined"];
	return;
}

-(void)rspChallenge:(NSDictionary*)params
{
	MsgLog(@"CTL: received rspChallenge %@", params);
	
	NSString *wn = [params objectForKey:@"WhiteName"];
	NSString *bn = [params objectForKey:@"BlackName"];
	NSString *wr = [params objectForKey:@"WhiteRating"];
	NSString *br = [params objectForKey:@"BlackRating"];
	NSString *time = [params objectForKey:@"Time"];
	NSString *inc  = [params objectForKey:@"Increment"];
	NSString *rtyp = [params objectForKey:@"RateType"];
	NSString *rate = [params objectForKey:@"IsRated"];
	
	NSString *text = [NSString stringWithFormat:@"Challenge:\n%@(%@)\nvs\n%@(%@)\n%@min/%@sec, %@ %@",
					  wn,wr,bn,br,time,inc,rate,rtyp];
	
	[scene challengePopupShow:text];
	[params release];
	return;
}

-(void)rspGameStarted:(NSDictionary*)params
{
	MsgLog(@"CTL: received rspGameStarted:%@",params);
	
	// remove wait game popup, if any
	[scene waitGamePopupDismiss];
	
	// determine which side we play
	NSDictionary *startPars = [params objectForKey:@"StartingParams"];
	NSString *time = [startPars objectForKey:@"Time"];
	NSString *inc  = [startPars objectForKey:@"Increment"];

	NSString *whName   = [startPars objectForKey:@"WhiteName"];
	NSString *whRating = [startPars objectForKey:@"WhiteRating"]; 
	NSString *blName   = [startPars objectForKey:@"BlackName"];
	NSString *blRating = [startPars objectForKey:@"BlackRating"]; 
	
	NSString *rateType  = [startPars objectForKey:@"RateType"];
	NSString *isRated   = [startPars objectForKey:@"IsRated"];
	
	// notify scene on new game start
	[scene gameStarted:nil];
	
	// initial time
	[scene setTopTime:[NSString stringWithFormat:@"%02d:00", [time intValue]]];
	[scene setBotTime:[NSString stringWithFormat:@"%02d:00", [time intValue]]];
	
	if([realLogin isEqualToString:whName])
	{
		// We play white
		[scene setOrientation:WHITE_ON_BOTTOM];

		[scene setTopName:blName];
		[scene setTopRating:blRating];
		
		[scene setBotName:whName];
		[scene setBotRating:whRating];
	}
	else if(([realLogin isEqualToString:blName]))
	{
		// We play black
		[scene setOrientation:BLACK_ON_BOTTOM];
		
		[scene setTopName:whName];
		[scene setTopRating:whRating];
		
		[scene setBotName:blName];
		[scene setBotRating:blRating];
	}
	else
	{
		[NSException raise:@"CBL" format:@"realLogin does not match both white and black names"];
	}
	[scene clearInfo];
	[scene writeInfo:[NSString stringWithFormat:@"%@(%@) vs %@(%@)",whName,whRating,blName,blRating]];
	[scene writeInfo:[NSString stringWithFormat:@"%@ %@ game (%@min/%@sec inc)", 
					  rateType, isRated, time, inc]];
	
	return;
}

-(void)rspGameEnded:(NSDictionary*)params
{
	MsgLog(@"CTL: received rspGameEnded:%@",params);

	[scene gameEnded:params];
	[params release];
	
	return;
}

-(void)rspStatusInfo:(NSString*)info
{
	MsgLog(@"CTL: received rspStatusInfo:%@",info);
	//[scene changeConnectText:[NSString stringWithString:info]];
	[scene connectPopupSetText:[NSString stringWithString:info]];
	[info release];
	
	return;
}

-(void)rspPopupInfo:(NSString*)info
{
	MsgLog(@"CTL: received rspPopupInfo:%@",info);
	[scene infoPopupShow:[NSString stringWithString:info]];
	[info release];
	
	return;
}

-(void)rspUpdateTime:(NSDictionary*)time
{
	//MsgLog(@"CTL: received rspUpdateTime:%@",time);
	[scene updateTime:time];
	[time release];
	
	return;
}

-(void)rspSideToMove:(NSDictionary*)params
{
	MsgLog(@"CTL: received rspSideToMove:%@",params);
	[scene sideToMove:params];
	[params release];
	return;
}

-(void)rspClearBoard
{
	MsgLog(@"CTL: received rspClearBoard");
	return;
}

-(void)rspPutPiece:(NSDictionary*)data
{
	MsgLog(@"CTL: received rspPutPiece:%@",data);
	return;
}

-(void)rspDropPiece:(NSDictionary*)data
{
	MsgLog(@"CTL: received rspDropPiece:%@",data);
	return;
}

-(void)rspSyncPosition:(NSString*)posStyle12
{
	MsgLog(@"CTL: received rspSyncPosition:%@",posStyle12);
	[scene syncPosition:posStyle12 isAnimated:YES];
	return;
}

-(void)rspMovePiece:(NSDictionary*)data
{
	MsgLog(@"CTL: received rspMovePiece:%@",data);
	[scene movePiece:data];
	[data release];
	return;
}

-(void)rspGetMove:(NSArray*)validMoves
{
	MsgLog(@"CTL: received rspGetMove (%d legal moves)", [validMoves count]);
	
	// output moves list
	/*
	int cnt=0;
	for(NSDictionary *move in validMoves)
	{
		MsgLog(@"CTL: move %02d is %@-%@", ++cnt, 
			   [move objectForKey:@"From"], [move objectForKey:@"To"]);
	}
	*/
	if([validMoves count]>0)
	{
		[scene getMove:validMoves];
	}
	
	[validMoves release];
	return;
}

-(void)rspGetPromoPiece:(NSDictionary*)data
{
	NSString *color = [data objectForKey:@"PieceColor"];
	PieceColor col = [color isEqualToString:@"W"] ? kPieceWhite : kPieceBlack;
	[scene promoPopupShowPieceColor:col];
	[data release];
	return;
}

-(void)rspShowMove:(NSDictionary*)data
{
	MsgLog(@"CTL: received rspShowMove:%@",data);
	[scene showMove:data];
	[data release];
	return;
}

-(void)rspOffer:(NSDictionary*)data
{
	MsgLog(@"CTL: received rspOffer:%@",data);
	//[scene offer:data];
	[scene offerPopupShow:[data objectForKey:@"OfferName"] 
				   accept:[data objectForKey:@"AcceptCommand"] 
				  decline:[data objectForKey:@"DeclineCommand"]];
	[data release];
	return;
}

@end
