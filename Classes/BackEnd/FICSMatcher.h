//
//  FICSMatcher.h
//  HandyChess
//
//  Created by Anton Zemyanov on 30.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "regex.h"
#import <UIKit/UIKit.h>

#define RE_MAX_EXPRESSIONS			32
#define RE_MAX_MATCHES				32

@interface FICSMatcher : NSObject {

}

// General stuff
-(BOOL) matchPrompt:(NSString*)str;

// Login related regex'es
-(BOOL)matchLogin:(NSString*)str;
-(BOOL)matchRegName:(NSString*)str;
-(BOOL)matchUnregName:(NSString*)str;
-(BOOL)matchGuestName:(NSString*)str;
-(BOOL)matchPassword:(NSString*)str;
-(BOOL)matchEnterAs:(NSString*)str;
-(BOOL)matchStartSession:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
-(BOOL)matchAlreadyLogged:(NSString*)str matchedData:(NSMutableDictionary*)outDict;

// Game seek/match/challenge related stuff
-(BOOL)matchStarting:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
-(BOOL)matchChallenge:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
-(BOOL)matchIssuing:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
-(BOOL)matchMatchDeclined:(NSString*)str matchedData:(NSMutableDictionary*)outDict;

// match decline reasons
-(BOOL)matchNotLoggedIn:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
-(BOOL)matchAlreadyPlaying:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
-(BOOL)matchAmbiguousName:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
-(BOOL)matchCantMatchYourself:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
-(BOOL)matchLastNotLogged:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
-(BOOL)matchNotFitFormula:(NSString*)str matchedData:(NSMutableDictionary*)outDict;

// Game related stuff
-(BOOL)matchGameStart:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
-(BOOL)matchGameEnd:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
-(BOOL)matchStyle12:(NSString*)str matchedData:(NSMutableDictionary*)outDict;

// Offers
-(BOOL)matchAbortOffer:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
-(BOOL)matchAdjournOffer:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
-(BOOL)matchDrawOffer:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
-(BOOL)matchSwitchOffer:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
-(BOOL)matchTakebackOffer:(NSString*)str matchedData:(NSMutableDictionary*)outDict;



@end
