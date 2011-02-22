//
//  FICSProtocol.m
//  HandyChess
//
//  Created by Anton Zemyanov on 30.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FICSProtocol.h"
#import "FICSSequencer.h"
#import "FICSMatcher.h"
#import "TCPConnection.h"

#import "Logger.h"

@implementation FICSProtocol

@synthesize delegate;

// init object
- (id)init
{
    if (self = [super init] ) 
	{
		// Allocate conection and sequencer
		connection = [[TCPConnection alloc] init]; 
		sequencer = [[FICSSequencer alloc] init];
		// Make them know each other
		connection.delegate = sequencer;
		sequencer.connection = connection;
		sequencer.delegate = self;
		
		// create matcher
		matcher = [[FICSMatcher alloc] init];
		
		// dictionary
		chessData = [[NSMutableDictionary alloc] initWithCapacity:32];

		// Set initial states
		[self setState:kFICSStateDisconnected];
		stateLogin	= kFICSLoginStateIdle;
		//stateInitialize;
		//stateReady;
		//stateInGame;
		
		int status = regcomp(&mergedPrompt, "^(fics%) ([A-Za-z0-9].*)$", REG_EXTENDED);
		if(status)
			[NSException raise:@"Error" format:@"Cant compile merged prompt regex"];
    }
    return self;
}

// dealloc object
- (void)dealloc 
{
	regfree(&mergedPrompt);
	[sequencer release];
    [super dealloc];
}

-(void)setState:(FICSState)newState
{
	switch (newState) 
	{
		case kFICSStateDisconnected:
			MsgLog(@"FIC: new state = kFICSStateDisconnected");
			state = newState;
			break;
		case kFICSStateConnecting:
			MsgLog(@"FIC: new state = kFICSStateConnecting");
			state = newState;
			break;
		case kFICSStateConnected:
			MsgLog(@"FIC: new state = kFICSStateConnected");
			state = newState;
			break;
		case kFICSStateLoggingIn:
			MsgLog(@"FIC: new state = kFICSStateLoggingIn");
			state = newState;
			break;
		case kFICSStateLoggedIn:
			MsgLog(@"FIC: new state = kFICSStateLoggedIn");
			state = newState;
			break;
		case kFICSStateInitialize:
			MsgLog(@"FIC: new state = kFICSStateInitialize");
			state = newState;
			break;
		case kFICSStateReady:
			MsgLog(@"FIC: new state = kFICSStateReady");
			state = newState;
			break;
		case kFICSStateSeekingGame:
			MsgLog(@"FIC: new state = kFICSStateSeekingGame");
			state = newState;
			break;
		case kFICSStateMatchIssued:
			MsgLog(@"FIC: new state = kFICSStateMatchIssued");
			state = newState;
			break;
		case kFICSStateInGame:
			MsgLog(@"FIC: new state = kFICSStateInGame");
			state = newState;
			break;
		default:
			[NSException raise:@"FICSProtocol" format:@"cannot set invalid state"];
			break;
	}
}

// Analyze seekData and prepare set formula string
-(NSString*)prepareFormula
{
	NSMutableString *formula = [NSMutableString stringWithString:@"set formula "];
	
	// game time
	[formula appendFormat:@"(time>=%@ & time<=%@) & ", 
		[seekData objectForKey:@"SeekTimeMin"], 
		[seekData objectForKey:@"SeekTimeMax"]];

	// game increment
	[formula appendFormat:@"(inc>=%@ & inc<=%@) & ", 
		[seekData objectForKey:@"SeekIncMin"], 
		[seekData objectForKey:@"SeekIncMax"]];

	// piece color
	switch([[seekData objectForKey:@"SeekPieceColor"] intValue])
	{
		case 0: // Any
			[formula appendString:@"nocolor & "]; 
			break;
		case 1: // White
			[formula appendString:@"black & "];
			break;
		case 2: // Black
			[formula appendString:@"white & "];
			break;
	}

	// game rate type
	switch([[seekData objectForKey:@"SeekRatingType"] intValue])
	{
		case 0: // Any
			break;
		case 1: // Rated
			[formula appendString:@"rated & "];
			break;
		case 2: // Black
			[formula appendString:@"unrated & "];
			break;
	}
	
	// rating filter
	if([[seekData objectForKey:@"SeekAllowUnregistred"] intValue]==0)
	{
		[formula appendFormat:@"(rating>=%@ & rating<=%@) & ", 
			[seekData objectForKey:@"SeekRatingMin"], 
			[seekData objectForKey:@"SeekRatingMax"]];
	}
	
	// allow unregistred?
	if([[seekData objectForKey:@"SeekAllowUnregistred"] intValue]==0)
	{
		[formula appendString:@"registered & "];
	}
	
	// add game types and no abuser
	[formula appendString:@" !abuser & (lightning|blitz|standard)\n"];
	
	// log formula
	MsgLog(@"formula = '%@'", formula);
	
	return formula;
}

//******************************************************************************
// FICSSequencerDelegate protocol
//******************************************************************************
-(void)FICSSeqConnected:(NSDictionary*)data
{
	MsgLog(@"FIC connected %@",data);
	[self setState:kFICSStateConnected];
	[delegate FicsRspConnected:data];
	return;
}

-(void)FICSSeqDisconnected:(NSDictionary*)data
{
	MsgLog(@"FIC disconnected %@",data);
	[self setState:kFICSStateDisconnected];
	[delegate FicsRspDisconnected:data];
	return;
}

-(void)FICSSeqError:(NSString*)str
{
	MsgLog(@"FICSSeqError called");
	[delegate FicsRspError:@"Sequencer error"];
	return;
}

-(void)FICSSeqNewDataAvailable
{
	//MsgLog(@"FIC New data from sequencer");
	
	while (YES)	
	{
		NSString *str = [sequencer readLine];
		if([str length]==0)
			break;
		
		[self processLine:str];
		
		// if EOL not present, break the cycle 
		unichar ch = [str characterAtIndex:[str length]-1];
		if(ch!='\n' && ch!='\r')
			break;
		
	}
	return;
}

// Process a new incoming line
-(void)processLine:(NSString*)line
{
	BOOL isMatched = NO;
	
	NSArray *arr = [line componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	NSMutableString *str = [arr objectAtIndex:0];
	if([str length]==0)
		return;
	
	// Cut possible fics% prompt
	regmatch_t regexMatches[16];
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [line UTF8String];

	int matched = regexec(&mergedPrompt, [line UTF8String], 16, regexMatches, 0);
	if(matched==0)
	{
		int Length = 0;
		int Offset = 0;
		char tmpBuff[256];
		
		MsgLog(@"FIC: Merged prompt detected");
		Offset = regexMatches[1].rm_so;  
        Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
        if(Offset>=0)
        {
            strncpy(tmpBuff, &pStr[Offset], Length);
            tmpBuff[Length] = '\0';
			MsgLog(@"FIC: first:%s",tmpBuff);
			[self processLine:[NSString stringWithUTF8String:tmpBuff]];
        }
		
        Offset = regexMatches[2].rm_so;  
        Length = regexMatches[2].rm_eo -regexMatches[2].rm_so;
        if(Offset>=0)
        {
            strncpy(tmpBuff, &pStr[Offset], Length);
            tmpBuff[Length] = '\0';
			MsgLog(@"FIC: second:%s",tmpBuff);
			[self processLine:[NSString stringWithUTF8String:tmpBuff]];
        }
		return;
	}
	
	// Log the line to be processed
	//MsgLog(@"<-%@",str);
	
	// parsed parameters
	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity:32];
	
	switch(state)
	{
		case kFICSStateConnected:
			isMatched = [matcher matchLogin:line];
			if(isMatched)
			{
				[self setState:kFICSStateLoggingIn];
				stateLogin = kFICSLoginStateGotLogin;
				NSString *log = [chessData objectForKey:@"login"];
				if([log length]==0)
					log = @"guest";

				stateLogin = kFICSLoginStateWaitMessage;
				NSString *txt = nil;
				if([log isEqual:@"guest"])
				{
					// send status info
					txt = [NSString stringWithString:@"Logging in using default guest account..."]; 
				}
				else
				{
					// send status info
					txt = [NSString stringWithFormat:@"Logging in as '%@'", 
								 [chessData objectForKey:@"login"]];
				}
				[self.delegate FicsRspInfo:txt];
				// login length is non-zero, send it to FICS
				NSString *str = [NSString stringWithFormat:@"%@\n", [chessData objectForKey:@"login"]];
				[sequencer writeLine:str];
			}
			break;
			
		case kFICSStateLoggingIn:
			switch(stateLogin)
			{
				case kFICSLoginStateWaitMessage:	// wait message indicating reg/unreg user
					if([matcher matchRegName:line])
					{
						// Matched registered user
						stateLogin = kFICSLoginStateWaitPassword;
						isRegistred = YES;
					}
					else if([matcher matchUnregName:line])
					{
						// Matched unregistred user
						stateLogin = kFICSLoginStateWaitEnterAs;
						isRegistred = NO;
					}
					else if([matcher matchGuestName:line])
					{
						// Matched unregistred user
						stateLogin = kFICSLoginStateWaitEnterAs;
						isRegistred = NO;
					}
					break;
					
				case kFICSLoginStateWaitPassword:	// wait password prompt, if reg user
					if([matcher matchPassword:line])
					{
						stateLogin = kFICSLoginStateWaitStartSession;
						
						NSString *str = [NSString stringWithFormat:@"%@\n", [chessData objectForKey:@"password"]];
						[sequencer writeLine:str];
					}
					break;
					
				case kFICSLoginStateWaitEnterAs:	    // wait propmt, if unreg
					if([matcher matchEnterAs:line])
					{
						stateLogin = kFICSLoginStateWaitStartSession;
						
						NSString *str = [NSString stringWithString:@"\n"];
						[sequencer writeLine:str];
					}
					break;

				case kFICSLoginStateWaitStartSession:	// wait 'Starting FICS session as...
					if([matcher matchStartSession:line matchedData:tmpDict])
					{
						[self setState:kFICSStateLoggedIn];
						stateLogin = kFICSLoginStateIdle;
						
						// report logging in
						[delegate FicsRspLoggedIn:[tmpDict objectForKey:@"RealLogin"] isRegistred:isRegistred];
						
						// report status
						//NSString *str = [NSString stringWithFormat:@"Logged in as '%@'", 
						//				 [tmpDict objectForKey:@"RealLogin"]];
						NSString *str = [NSString stringWithFormat:@"Applying default settings"]; 
						[delegate FicsRspInfo:str];
						
					}
					else if([matcher matchLogin:line])
					{
						// got login once again, send error - invalid password
						[delegate FicsRspError:@"Invalid password (please change password in account settings)"];
					}
					else if([matcher matchAlreadyLogged:line matchedData:tmpDict])
					{
						// got login once again, send error - invalid password
						NSString *errText = [NSString 
										 stringWithFormat:@"Unregistred user with '%@' name is already logged in",
										 [tmpDict objectForKey:@"Name"]];
						[delegate FicsRspError:errText];
					}
					break;

				default:
					[NSException raise:@"FICS" format:@"Invalid substate stateLogin"];
			}
			break;
			
		case kFICSStateLoggedIn:
			break;
			
		case kFICSStateInitialize:
			switch(stateInitialize)
			{
				case kFICSInitStateWaitFirstPrompt: // wait prompt to start initialization
					if([matcher matchPrompt:line])
					{
						stateInitialize = kFICSInitStateWaitConfStyle12;
						stateInitialize = kFICSInitStateWaitConfShouts;
						[sequencer writeLine:@"set style 12\n"];
						[sequencer writeLine:@"set seek off\n"];
						[sequencer writeLine:@"set shout off\n"];
						[sequencer writeLine:@"set formula\n"];
						
						NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
						if([defs boolForKey:@"AutoFlag"])
							[sequencer writeLine:@"set autoflag 1\n"];
						else
							[sequencer writeLine:@"set autoflag 0\n"];
					}
					break;
				case kFICSInitStateWaitConfStyle12: // wait confirmation style set
					if([matcher matchPrompt:line])
					{
						stateInitialize = kFICSInitStateWaitConfSeeks;
						[sequencer writeLine:@"set seek off\n"];
					}
					break;
				case kFICSInitStateWaitConfSeeks: // wait confirmation style set
					if([matcher matchPrompt:line])
					{
						stateInitialize = kFICSInitStateWaitConfShouts;
						[sequencer writeLine:@"set shout off\n"];
					}
					break;
				case kFICSInitStateWaitConfShouts:  // wait confirmation style set
					if([matcher matchPrompt:line])
					{
						[self setState:kFICSStateReady];
						stateInitialize = kFICSInitStateIdle;
						// send initialized to FICS delegate
						[delegate FicsRspInitialized];
						[delegate FicsRspReady];
					}
					break;
				default:
					[NSException raise:@"FICS" format:@"Invalid initialization state"];
					break;
			}
			break;
		
		case kFICSStateReady:
			if([matcher matchChallenge:line matchedData:tmpDict])
			{
				MsgLog(@"FIC: Got Challenge");
				[delegate FicsRspChallenge:tmpDict];
			}
			else if([matcher matchStarting:line matchedData:tmpDict])
			{
				[self setState:kFICSStateInGame];
				stateInGame = kFICSGameStateWaitStart;
				[delegate FicsRspStartingGame:tmpDict];
			}
			break;
			
		case kFICSStateSeekingGame:
			switch(stateSeek)
			{
				case kFICSSeekStateWaitPrompt:  		// wait '%fics'
					if([matcher matchPrompt:line])
					{
						stateSeek = kFICSSeekStateWaitConfTime;
						NSString *ln = [NSString stringWithFormat:@"set time %@\n", 
										[seekData objectForKey:@"SeekTimeMin"]];
						[sequencer writeLine:ln];
					}
					break;
				case kFICSSeekStateWaitConfTime:		// wait '%fics'
					if([matcher matchPrompt:line])
					{
						stateSeek = kFICSSeekStateWaitConfInc;
						NSString *ln = [NSString stringWithFormat:@"set inc %@\n", 
										[seekData objectForKey:@"SeekIncMin"]];
						[sequencer writeLine:ln];
					}
					break;
				case kFICSSeekStateWaitConfInc:			// wait '%fics'
					if([matcher matchPrompt:line])
					{
						stateSeek = kFICSSeekStateWaitConfFormula;
						NSString *ln = [self prepareFormula];
						[sequencer writeLine:ln];
					}
					break;
				case kFICSSeekStateWaitConfFormula:  	// wait '%fics'
					if([matcher matchPrompt:line])
					{
						stateSeek = kFICSSeekStateWaitGameStart;
						[sequencer writeLine:@"resume\n"];
						[sequencer writeLine:@"getgame f\n"];
					}
					break;
				case kFICSSeekStateWaitGameStart:		// wait game start
					if([matcher matchStarting:line matchedData:tmpDict])
					{
						[self setState:kFICSStateInGame];
						stateSeek = kFICSSeekStateWaitPrompt;
						stateInGame = kFICSGameStateWaitStart;
						[delegate FicsRspStartingGame:tmpDict];
					}
					break;
				default:
					[NSException raise:@"FICS" format:@"Invalid seek state"];
					break;
			}
			break;
			
		case kFICSStateMatchIssued:
			switch(stateMatch)
			{
				case kFICSMatchStateWaitPrompt:  		// wait '%fics'
					if([matcher matchPrompt:line])
					{
						stateMatch = kFICSMatchStateWaitIssuing;
						if(matchData)
						{
							// match 
							NSMutableString *match = [NSMutableString 
													  stringWithFormat:@"match %@", 
													  [matchData objectForKey:@"MatchName"]];
							
							// rating type
							switch([[matchData objectForKey:@"MatchRatingType"] intValue])
							{
								case 0: // rated
									[match appendString:@" rated"];
									break;
								case 1: // unrated
									[match appendString:@" unrated"];
									break;
							}
							
							// time & inc
							[match appendFormat:@" %@ %@", [matchData objectForKey:@"MatchTime"],
														   [matchData objectForKey:@"MatchInc"]];
							
							// color
							switch([[matchData objectForKey:@"MatchPieceColor"] intValue])
							{
								case 0: // fair
									break;
								case 1: // white
									[match appendString:@" White"];
									break;
								case 2: // black
									[match appendString:@" Black"];
									break;
							}
							[match appendString:@"\n"];
							[sequencer writeLine:match];
						}
						else
						{
							// rematch
							[sequencer writeLine:@"rematch\n"];
						}
					}
					break;
				case kFICSMatchStateWaitIssuing:		
					if([matcher matchIssuing:line matchedData:tmpDict])
					{
						// match issued
						stateMatch = kFICSMatchStateWaitGameStart;
						[delegate FicsRspMatchIssued:tmpDict];
					}
					else if([matcher matchNotLoggedIn:line matchedData:tmpDict])
					{
						// possible reasons why match was not issued
						// not logged in
						NSString *str = [NSString stringWithFormat:@"%@ is not logged in", 
										 [tmpDict objectForKey:@"Name"]];
						[delegate FicsRspPopupInfo:str];
						[self setState:kFICSStateReady];
					}
					else if([matcher matchAlreadyPlaying:line matchedData:tmpDict])
					{
						// possible reasons why match was not issued
						// already playing a game
						NSString *str = [NSString stringWithFormat:@"%@ already plays a game", 
										 [tmpDict objectForKey:@"Name"]];
						[delegate FicsRspPopupInfo:str];
						[self setState:kFICSStateReady];
					}
					else if([matcher matchAmbiguousName:line matchedData:tmpDict])
					{
						// possible reasons why match was not issued
						// name is ambiguous
						NSString *str = [NSString stringWithFormat:@"%@ is invalid/ambiguous name", 
										 [tmpDict objectForKey:@"Name"]];
						[delegate FicsRspPopupInfo:str];
					}
					else if([matcher matchCantMatchYourself:line matchedData:tmpDict])
					{
						// possible reasons why match was not issued
						// try to match himself
						NSString *str = [NSString stringWithFormat:@"You cannot match yourself"];
						[delegate FicsRspPopupInfo:str];
						[self setState:kFICSStateReady];
					}
					else if([matcher matchLastNotLogged:line matchedData:tmpDict])
					{
						// possible reasons why match was not issued
						// try to match himself
						NSString *str = [NSString stringWithFormat:@"last opponent %@ is not logged in", 
										 [tmpDict objectForKey:@"Name"]];
						[delegate FicsRspPopupInfo:str];
						[self setState:kFICSStateReady];
					}
					else if([matcher matchNotFitFormula:line matchedData:tmpDict])
					{
						// possible reasons why match was not issued
						// try to match himself
						NSString *str = [NSString stringWithFormat:@"Match offer does not fit formula for %@", 
										 [tmpDict objectForKey:@"Name"]];
						[delegate FicsRspPopupInfo:str];
						[self setState:kFICSStateReady];
					}
					break;
				case kFICSMatchStateWaitGameStart:		
					if([matcher matchStarting:line matchedData:tmpDict])
					{
						// match started
						[self setState:kFICSStateInGame];
						stateSeek = kFICSSeekStateWaitPrompt;
						stateInGame = kFICSGameStateWaitStart;
						[delegate FicsRspStartingGame:tmpDict];
					}
					else if([matcher matchMatchDeclined:line matchedData:tmpDict])
					{
						// match request declined
						[self setState:kFICSStateReady];
						[delegate FicsRspMatchDeclined:tmpDict];
					}
					break;
				default:
					[NSException raise:@"FICS" format:@"Invalid match state"];
					break;
			}
			break;
			
		case kFICSStateInGame:
			switch(stateInGame)
			{
				case kFICSGameStateWaitStart:
					if( [matcher matchGameStart:line matchedData:tmpDict] )
					{
						stateInGame = kFICSGameStateInGame;
						// send above
						[delegate FicsRspGameStarted:tmpDict];
					}
					break;
				case kFICSGameStateInGame:
					if( [matcher matchStyle12:line matchedData:tmpDict] )
					{
						[delegate FicsRspGameStyle12:tmpDict];
					}
					else if([matcher matchGameEnd:line matchedData:tmpDict])
					{
						[self setState:kFICSStateReady];
						stateReady = kFICSReadyStateStateIdle;
						[delegate FicsRspGameEnded:tmpDict];
					}
					else if([matcher matchAbortOffer:line matchedData:tmpDict])
					{
						NSMutableDictionary *data = [NSMutableDictionary dictionary];
						NSString *name = [tmpDict objectForKey:@"Name"];
						[data setObject:[NSString stringWithFormat:@"%@ would like to abort the game",name] forKey:@"OfferName"];
						[data setObject:@"accept t abort\n" forKey:@"AcceptCommand"];
						[data setObject:@"decline t abort\n" forKey:@"DeclineCommand"];
						[delegate FicsRspOffer:data];
					}
					else if([matcher matchAdjournOffer:line matchedData:tmpDict])
					{
						NSMutableDictionary *data = [NSMutableDictionary dictionary];
						NSString *name = [tmpDict objectForKey:@"Name"];
						[data setObject:[NSString stringWithFormat:@"%@ would like to adjourn the game",name] forKey:@"OfferName"];
						[data setObject:@"accept t adjourn\n" forKey:@"AcceptCommand"];
						[data setObject:@"decline t adjourn\n" forKey:@"DeclineCommand"];
						[delegate FicsRspOffer:data];
					}
					else if([matcher matchDrawOffer:line matchedData:tmpDict])
					{
						NSMutableDictionary *data = [NSMutableDictionary dictionary];
						NSString *name = [tmpDict objectForKey:@"Name"];
						[data setObject:[NSString stringWithFormat:@"%@ offers you a draw",name] forKey:@"OfferName"];
						[data setObject:@"accept t draw\n" forKey:@"AcceptCommand"];
						[data setObject:@"decline t draw\n" forKey:@"DeclineCommand"];
						[delegate FicsRspOffer:data];
					}
					else if([matcher matchSwitchOffer:line matchedData:tmpDict])
					{
						NSMutableDictionary *data = [NSMutableDictionary dictionary];
						NSString *name = [tmpDict objectForKey:@"Name"];
						[data setObject:[NSString stringWithFormat:@"%@ would like to switch sides",name] forKey:@"OfferName"];
						[data setObject:@"accept t switch\n" forKey:@"AcceptCommand"];
						[data setObject:@"decline t switch\n" forKey:@"DeclineCommand"];
						[delegate FicsRspOffer:data];
					}
					else if([matcher matchTakebackOffer:line matchedData:tmpDict])
					{
						NSMutableDictionary *data = [NSMutableDictionary dictionary];
						NSString *name  = [tmpDict objectForKey:@"Name"];
						NSString *moves = [tmpDict objectForKey:@"NumberOfHalfMoves"];
						[data setObject:[NSString stringWithFormat:@"%@ would like to take back %@ half move(s)",name, moves] forKey:@"OfferName"];
						[data setObject:@"accept t takeback\n" forKey:@"AcceptCommand"];
						[data setObject:@"decline t takeback\n" forKey:@"DeclineCommand"];
						[delegate FicsRspOffer:data];
					}
					break;
			}
			break;
		default:
			[NSException raise:@"FICSProtocol" format:@"got data in invalid state"];
			break;
	}
	
	return;
}

//******************************************************************************
// FICSProtocolMessages protocol
//******************************************************************************
-(void)FicsMsgConnect:(NSString*)host port:(UInt16)port
{
	[chessData setObject:host forKey:@"host"];
	[chessData setObject:[NSNumber numberWithInt:port] forKey:@"port"];
	
	[self setState:kFICSStateConnecting];
	[connection connectToHost:host andPort:port];
	
	return;
}

-(void)FicsMsgDisconnect
{
	//[self setState:kFICSStateDisconnected];
	[connection disconnect];
	
	return;
}

-(void)FicsMsgLogin:(NSString*)login password:(NSString*)password
{
	// remember login/password
	[chessData setObject:login forKey:@"login"];
	[chessData setObject:password forKey:@"password"];	
	
	if(state != kFICSStateLoggingIn)
		return;
	
	// send login, if prompt already matched
	if(stateLogin==kFICSLoginStateGotLogin)
	{
		// send status info
		NSString *txt = [NSString stringWithFormat:@"Logging in as '%@'", login];
		[self.delegate FicsRspInfo:txt];
		// send login
		NSString *str = [NSString stringWithFormat:@"%@\n", login];
		[sequencer writeLine:str];
	}
	
	return;
}

// global things, shouts off, set style 12
-(void)FicsMsgInitialize
{
	// global init, right after login usually
	[self setState:kFICSStateInitialize];
	stateInitialize = kFICSInitStateWaitFirstPrompt;
	// prompt is already there waiting us?
	[self processLine:[sequencer readLine]];
	return;
}

-(void)FicsMsgSeekGame:(NSDictionary*)params
{
	// State and substate
	[self setState:kFICSStateSeekingGame];
	stateSeek = kFICSSeekStateWaitPrompt;
	
	// cache seek data
	[seekData release];
	seekData = [[NSDictionary alloc] initWithDictionary:params];
	
	// Test is there prompt waiting there?
	[self processLine:[sequencer readLine]];
	
	return;
}

-(void)FicsMsgUnseekGame
{
	[self setState:kFICSStateReady];
	[sequencer writeLine:@"unseek\n"];
	[sequencer writeLine:@"set formula\n"];
	return;
}

-(void)FicsMsgMatch:(NSDictionary*)params
{
	// State and substate
	[self setState:kFICSStateMatchIssued];
	stateMatch = kFICSMatchStateWaitPrompt;
	
	// cache match data
	[matchData release];
	matchData = [[NSDictionary alloc] initWithDictionary:params];
	
	// Test is there prompt waiting there?
	[self processLine:[sequencer readLine]];
	
	return;
}

-(void)FicsMsgRematch
{
	// State and substate
	[self setState:kFICSStateMatchIssued];
	stateMatch = kFICSMatchStateWaitPrompt;
	
	// cache seek data
	[matchData release];
	matchData = nil;
	
	// Test is there prompt waiting there?
	[self processLine:[sequencer readLine]];
	
	return;
}

-(void)FicsMsgUnmatch
{
	[self setState:kFICSStateReady];
	[sequencer writeLine:@"withdraw t match\n"];
	return;
}

-(void)FicsMsgCommand:(NSString*)cmd
{
	MsgLog(@"FIC: send '%@'",cmd);
	[sequencer writeLine:cmd];
}

-(void)FicsMsgSendMove:(NSString*)move
{
	MsgLog(@"FIC: send move %@", move);
	[sequencer writeLine:[NSString stringWithFormat:@"%@\n",move]];
}

@end
