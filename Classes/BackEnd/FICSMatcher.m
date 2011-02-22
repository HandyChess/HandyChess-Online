//
//  FICSMatcher.m
//  HandyChess
//
//  Created by Anton Zemyanov on 30.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FICSMatcher.h"
#import "Logger.h"

//"AntonZ" is a registered name.  If it is yours, type the password.
//"AntonZZ" is not a registered name.  You may use this name to play unrated games.
//Logging you in as "GuestDKTF"; you may use this name to play unrated games.
//Challenge: GuestCJFW (----) AntonZ (----) unrated blitz 10 0
//<12> rnbqkbnr pppppppp -------- -------- -------- -------- PPPPPPPP RNBQKBNR W -
//1 1 1 1 1 0 76 TeleFuze GuestKKLB 1 10 0 39 39 600 600 1 none (0:00) none 0 0 0
//Challenge: GuestQBXJ (----) AntonZ (1316) unrated blitz 5 0

// neselov is playing a game.
// You can't match yourself.


//------------------------------------------------------------------------------
// Tokens
//------------------------------------------------------------------------------
// Common
#define T_NAME      "([A-Za-z]{3,17})"
#define T_QWNAME    "\"([A-Za-z]{3,17})\""
#define T_RATING    "\\(([ 0-9+\\-]{4})\\)"
#define T_ISRATED   "(rated|unrated)"
#define T_RTYPE     "(lightning|blitz|standard|suicide|atomic)"
#define T_TIME      "(0|[1-9][0-9]*)"
#define T_INC       "(0|[1-9][0-9]*)"
#define T_STRING    "(.*)"
#define T_RESULT    "(1-0|0-1|1/2-1/2|\\*)"
#define T_NUM       "(0|[1-9][0-9]*)"
#define T_ALPHA		"([A_Za-z])"
#define T_NL			"[\n\r]"

// Style 12
#define S_BRD       "([pnbrqkPNBRQK\\-]{8} [pnbrqkPNBRQK\\-]{8} [pnbrqkPNBRQK\\-]{8} "\
"[pnbrqkPNBRQK\\-]{8} [pnbrqkPNBRQK\\-]{8} [pnbrqkPNBRQK\\-]{8} "\
"[pnbrqkPNBRQK\\-]{8} [pnbrqkPNBRQK\\-]{8})"
#define S_CLR       "([BW])"
#define S_EPS       "(-1|[0-7])"
#define S_BOOL      "([01])"
#define S_NUM       "(0|[1-9][0-9]*)"
#define S_SNUM      "(0|-?[1-9][0-9]*)"
#define S_NAME      T_NAME
#define S_REL       "(-3|-2|-1|0|1|2)"
#define S_VNOT      "([^ ]+)"
#define S_TIME      "(\\([1-9]?[0-9]:[0-9]{2}\\))"
#define S_PNOT      "([^ ]+)"
#define S_NL		   T_NL

//------------------------------------------------------------------------------
// Regular expressions IDs
//------------------------------------------------------------------------------
#define RE_PROMPT_READY				0
#define RE_PROMPT_PAST				1
#define RE_LOG_LOGIN					2		
#define RE_LOG_REG_NAME				3
#define RE_LOG_UNREG_NAME			4
#define RE_LOG_GUEST_NAME			5
#define RE_LOG_PASSWORD				6
#define RE_LOG_ENTER_AS				7
#define RE_LOG_START_SESSION		8
#define RE_LOG_ALREADY_LOGGED		9
#define RE_SEEK_CREATING				10
#define RE_GAME_STYLE12				11
#define RE_GAME_START				12
#define RE_GAME_END					13
#define RE_CHALLENGE					14                               
#define RE_ISSUING					15
#define RE_MATCH_DECLINED			16
#define RE_OFFER_ABORT				17
#define RE_OFFER_ADJOURN				18
#define RE_OFFER_DRAW				19
#define RE_OFFER_PAUSE				20
#define RE_OFFER_SWITCH				21
#define RE_OFFER_TAKEBACK			22
#define RE_MATCH_NOT_LOGGED_IN		23
#define RE_MATCH_IS_PLAYING			24
#define RE_MATCH_AMBIGUOUS			25
#define RE_MATCH_CANT_MATCH_SELF	26
#define RE_MATCH_LAST_NOT_LOGGED	27
#define RE_MATCH_NOT_FIT_FORMULA	28

//------------------------------------------------------------------------------
// Regular expressions static vars
//------------------------------------------------------------------------------
static regex_t      regexObjects[RE_MAX_EXPRESSIONS];
static regmatch_t   regexMatches[RE_MAX_MATCHES];
static char*        regexExpressions[RE_MAX_EXPRESSIONS] =
{
// General stuff
	"^fics% $", 
	"^fics% .*", 
	// Login related stuff
	"^login:.*$",
	"^"T_QWNAME" is a registered name.*$",
	"^"T_QWNAME" is not a registered name.*unrated.*$",
	"^Logging you in as "T_QWNAME";.*unrated.*$",
	"^password:.*$",
	"^Press return to enter the server as "T_QWNAME".*$",
    "^.* Starting FICS session as "T_NAME".*$",
	"^\\*{3} Sorry "T_NAME" is already logged in \\*{3}"T_NL,
	//"^.*Starting FICS session as "T_QWNAME".*$",
	// Seek-related stuff
	"^Creating: "T_NAME" "T_RATING" "T_NAME" "T_RATING" "
	T_ISRATED" "T_RTYPE" "T_TIME" "T_INC".*"T_NL,
    // Style 12
	"^<12> "
	S_BRD" "  // Board
	S_CLR" "  // Color to make move
	S_EPS" "  // Enpassant column or -1
	S_BOOL" " // White can castle short
	S_BOOL" " // White can castle long
	S_BOOL" " // Black can castle short
	S_BOOL" " // Black can castle short
	S_NUM" "  // Number since last irreversible
	S_NUM" "  // Game number
	S_NAME" " // White's name
	S_NAME" " // Black's name
	S_REL" "  // My relation to game
	S_NUM" "  // Initial time in minutes
	S_NUM" "  // Increment in seconds
	S_NUM" "  // White strength
	S_NUM" "  // Black strength
	S_SNUM" "  // White remaining time
	S_SNUM" "  // Black remaning time
	S_NUM" "  // Move number
	S_VNOT" " // Verbose notation
	S_TIME" " // Time for previous move
	S_PNOT" " // Pretty notation
	S_BOOL" " // Flip (0 - white on bottom, 1 black on bottom)
	"(.*)"
	S_NL,
	"^\\{Game "T_NUM" \\("T_NAME" vs. "T_NAME"\\) (Creating|Continuing) "T_ISRATED" "T_RTYPE" match.\\}.*"T_NL,
	"^\\{Game "T_NUM" \\("T_NAME" vs. "T_NAME"\\) "T_STRING"\\} "T_RESULT".*"T_NL,
	"^Challenge: "T_NAME" "T_RATING" "T_NAME" "T_RATING" "T_ISRATED" "T_RTYPE" "T_TIME" "T_INC".?"T_NL,
    "^Issuing: "T_NAME" "T_RATING" "T_NAME" "T_RATING" "T_ISRATED" "T_RTYPE" "T_TIME" "T_INC".?"T_NL,
	"^"T_NAME" declines the match offer."T_NL,
	"^"T_NAME" would like to abort the game. type .abort. to accept.?"T_NL,
	"^"T_NAME" would like to adjourn the game. type .adjourn. to accept.?"T_NL,
	"^"T_NAME" offers you a draw.?"T_NL,
	"^"T_NAME" requests to pause the game.?"T_NL,
	"^"T_NAME" would like to switch sides.?"T_NL,
	"^"T_NAME" would like to take back "T_NUM" half move(s).?"T_NL,
	// match reject reasons
	T_NAME" is not logged in.?"T_NL,
	T_NAME" is playing a game.?"T_NL,
	"Ambiguous name "T_NAME":"T_NL,
	"You can.t match yourself.?"T_NL,
	"Your last opponent, ."T_NAME"., is not logged in.?"T_NL,
	"Match request does not fit formula for "T_NAME"."T_NL,
	"EOF"
}; 

//AntonZM would like to adjourn the game; type "adjourn" to accept.\n\r
//{Game 350 (Detroitman vs. AntonZ) Game aborted on move 1} *

@implementation FICSMatcher

// init object
- (id)init
{
    if (self = [super init] ) 
	{
		int Status;
		for(int Cnt=0; Cnt<RE_MAX_EXPRESSIONS; ++Cnt)
		{
			if(regexExpressions[Cnt]==NULL)
			{
				MsgLog(@"MAT: Compiled %d RegExs\n", Cnt);
				break;
			}
			Status = regcomp(&regexObjects[Cnt], regexExpressions[Cnt], REG_EXTENDED);
			//MsgLog(@"MAT: #%02d '%s'", Cnt, regexExpressions[Cnt]);
			if(Status)
			{
				MsgLog(@"MAT: Failed to compile '%s' status=%x\n", regexExpressions[Cnt], Status);
				[NSException raise:@"Matcher" format:@"Cannot compile regex"];
			}
		}		
    }
    return self;
}

// dealloc object
- (void)dealloc 
{
    [super dealloc];
}

//------------------------------------------------------------------------------
// Match 'fics%' prompt
//------------------------------------------------------------------------------
-(BOOL) matchPrompt:(NSString*)str
{
    int Status;
	
    memset(regexMatches, 0, sizeof(regexMatches));
    Status = regexec(&regexObjects[RE_PROMPT_READY], [str UTF8String],
									RE_MAX_MATCHES,regexMatches,0);
    if(Status==0)
    {
        MsgLog(@"MAT: Prompt matched");
    }
	
    return Status==0 ? TRUE : FALSE;
}

//------------------------------------------------------------------------------
// Match login
//------------------------------------------------------------------------------
-(BOOL)matchLogin:(NSString*)str
{
    int Status;
	
	memset(regexMatches, 0, sizeof(regexMatches));
    Status = regexec(&regexObjects[RE_LOG_LOGIN], [str UTF8String],
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status==0)
    {
        MsgLog(@"MAT: Login is matched");
    }
	
    return Status==0 ? TRUE : FALSE;
}

//------------------------------------------------------------------------------
// Match 'XXXXX is a registred name'
//------------------------------------------------------------------------------
-(BOOL)matchRegName:(NSString*)str
{
    int Status;
	
	memset(regexMatches, 0, sizeof(regexMatches));
    Status = regexec(&regexObjects[RE_LOG_REG_NAME], [str UTF8String],
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status==0)
    {
        MsgLog(@"MAT: RegName matched");
    }
	
    return Status==0 ? TRUE : FALSE;
}

//------------------------------------------------------------------------------
// Match 'XXXXX is not a registred name'
//------------------------------------------------------------------------------
-(BOOL)matchUnregName:(NSString*)str
{
    int Status;
	
	memset(regexMatches, 0, sizeof(regexMatches));
    Status = regexec(&regexObjects[RE_LOG_UNREG_NAME], [str UTF8String],
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status==0)
    {
        MsgLog(@"MAT: UnRegName matched");
    }
	
    return Status==0 ? TRUE : FALSE;
}


//------------------------------------------------------------------------------
// Match 'Logging you as ...'
//------------------------------------------------------------------------------
-(BOOL)matchGuestName:(NSString*)str
{
    int Status;
	
	memset(regexMatches, 0, sizeof(regexMatches));
    Status = regexec(&regexObjects[RE_LOG_GUEST_NAME], [str UTF8String],
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status==0)
    {
        MsgLog(@"MAT: GuestName matched");
    }
	
    return Status==0 ? TRUE : FALSE;
}


//------------------------------------------------------------------------------
// Match Password
//------------------------------------------------------------------------------
-(BOOL)matchPassword:(NSString*)str
{
    int Status;
	
	memset(regexMatches, 0, sizeof(regexMatches));
    Status = regexec(&regexObjects[RE_LOG_PASSWORD], [str UTF8String],
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status==0)
    {
        MsgLog(@"MAT: Password matched");
    }
	
    return Status==0 ? TRUE : FALSE;
}

//------------------------------------------------------------------------------
// Match 'Enter as ...'
//------------------------------------------------------------------------------
-(BOOL)matchEnterAs:(NSString*)str
{
    int Status;
    //int Length = 0;
    //int Offset = 0;
	//char tmpBuff[256];
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_LOG_ENTER_AS], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status==0)
    {
        MsgLog(@"MAT: EnterAs matched");
		
		/*
        Offset = regexMatches[1].rm_so;  
        Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
        if(Offset>=0)
        {
            strncpy(tmpBuff, &pStr[Offset], Length);
            tmpBuff[Length] = '\0';
			[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Name"];
        }
		*/
		
        return TRUE;
    }
	
    return FALSE;
}

//------------------------------------------------------------------------------
// Match 'Starting FICS Session as...'
//------------------------------------------------------------------------------
-(BOOL)matchStartSession:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_LOG_START_SESSION], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status==0)
    {
        MsgLog(@"MAT: StartSession matched");
		
        Offset = regexMatches[1].rm_so;  
        Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
        if(Offset>=0)
        {
            strncpy(tmpBuff, &pStr[Offset], Length);
            tmpBuff[Length] = '\0';
			[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"RealLogin"];
        }

        Offset = regexMatches[2].rm_so;  
        Length = regexMatches[2].rm_eo -regexMatches[2].rm_so;
        if(Offset>=0)
        {
            strncpy(tmpBuff, &pStr[Offset], Length);
            tmpBuff[Length] = '\0';
			[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"RegMark"];
        }
		
        return TRUE;
    }
	
    return FALSE;
}

//------------------------------------------------------------------------------
// Match 'already logged'
//------------------------------------------------------------------------------
-(BOOL)matchAlreadyLogged:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];
	
	//MsgLog(@"matching 'already logged in'");
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_LOG_ALREADY_LOGGED], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }    
    MsgLog(@"MAT: AlreadLogged matched");
	
    // White name
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Name"];
	}

	return YES;
}


//------------------------------------------------------------------------------
// Match Challenge: GuestQBXJ (----) AntonZ (1316) unrated blitz 5 0
//------------------------------------------------------------------------------
-(BOOL)matchChallenge:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];

	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_CHALLENGE], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }    
    MsgLog(@"MAT: Challenge matched");
	
    // White name
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"WhiteName"];
	}
    // White rating
    Offset = regexMatches[2].rm_so;  
    Length = regexMatches[2].rm_eo -regexMatches[2].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"WhiteRating"];
	}
    // Black name
    Offset = regexMatches[3].rm_so;  
    Length = regexMatches[3].rm_eo -regexMatches[3].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"BlackName"];
	}
    // Black rating
    Offset = regexMatches[4].rm_so;  
    Length = regexMatches[4].rm_eo -regexMatches[4].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"BlackRating"];
	}
    // Is Rated
    Offset = regexMatches[5].rm_so;  
    Length = regexMatches[5].rm_eo -regexMatches[5].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"IsRated"];
	}
    // Lightning/Blitz/Standard
    Offset = regexMatches[6].rm_so;  
    Length = regexMatches[6].rm_eo -regexMatches[6].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"RateType"];
	}
    // Time
    Offset = regexMatches[7].rm_so;  
    Length = regexMatches[7].rm_eo -regexMatches[7].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Time"];
	}
    // Increment
    Offset = regexMatches[8].rm_so;  
    Length = regexMatches[8].rm_eo -regexMatches[8].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Increment"];
	}
	
	return YES;
}

//------------------------------------------------------------------------------
// Match Issuing: GuestQBXJ (----) AntonZ (1316) unrated blitz 5 0
//------------------------------------------------------------------------------
-(BOOL)matchIssuing:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_ISSUING], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }    
    MsgLog(@"MAT: Issuing matched");
	
    // White name
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"WhiteName"];
	}
    // White rating
    Offset = regexMatches[2].rm_so;  
    Length = regexMatches[2].rm_eo -regexMatches[2].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"WhiteRating"];
	}
    // Black name
    Offset = regexMatches[3].rm_so;  
    Length = regexMatches[3].rm_eo -regexMatches[3].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"BlackName"];
	}
    // Black rating
    Offset = regexMatches[4].rm_so;  
    Length = regexMatches[4].rm_eo -regexMatches[4].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"BlackRating"];
	}
    // Is Rated
    Offset = regexMatches[5].rm_so;  
    Length = regexMatches[5].rm_eo -regexMatches[5].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"IsRated"];
	}
    // Lightning/Blitz/Standard
    Offset = regexMatches[6].rm_so;  
    Length = regexMatches[6].rm_eo -regexMatches[6].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"RateType"];
	}
    // Time
    Offset = regexMatches[7].rm_so;  
    Length = regexMatches[7].rm_eo -regexMatches[7].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Time"];
	}
    // Increment
    Offset = regexMatches[8].rm_so;  
    Length = regexMatches[8].rm_eo -regexMatches[8].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Increment"];
	}
	
	return YES;
}

//------------------------------------------------------------------------------
// Match Creating...
//------------------------------------------------------------------------------
-(BOOL)matchStarting:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];
	
    //printf("MATCH: Starting, input='%s'\n", pStr);
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_SEEK_CREATING], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }    
    MsgLog(@"MAT: Starting matched");
	
    // White name
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"WhiteName"];
	}
    // White rating
    Offset = regexMatches[2].rm_so;  
    Length = regexMatches[2].rm_eo -regexMatches[2].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"WhiteRating"];
	}
    // Black name
    Offset = regexMatches[3].rm_so;  
    Length = regexMatches[3].rm_eo -regexMatches[3].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"BlackName"];
	}
    // Black rating
    Offset = regexMatches[4].rm_so;  
    Length = regexMatches[4].rm_eo -regexMatches[4].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"BlackRating"];
	}
    // Is Rated
    Offset = regexMatches[5].rm_so;  
    Length = regexMatches[5].rm_eo -regexMatches[5].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"IsRated"];
	}
    // Lightning/Blitz/Standard
    Offset = regexMatches[6].rm_so;  
    Length = regexMatches[6].rm_eo -regexMatches[6].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"RateType"];
	}
    // Time
    Offset = regexMatches[7].rm_so;  
    Length = regexMatches[7].rm_eo -regexMatches[7].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Time"];
	}
    // Increment
    Offset = regexMatches[8].rm_so;  
    Length = regexMatches[8].rm_eo -regexMatches[8].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Increment"];
	}
	
    return TRUE;
}

//------------------------------------------------------------------------------
// Match 'Game XXX { ... }' 
//------------------------------------------------------------------------------
-(BOOL)matchMatchDeclined:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];
	
    //printf("MATCH: Starting, input='%s'\n", pStr);
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_MATCH_DECLINED], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }    
    MsgLog(@"MAT: MatchDeclined matched");
	
    // White name
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Name"];
	}
	
	return YES;
}

// match decline reasons
-(BOOL)matchNotLoggedIn:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];

	//MsgLog(@"MAT: try matchNotLoggedIn");
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_MATCH_NOT_LOGGED_IN], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }    
    MsgLog(@"MAT: matchNotLoggedIn matched");
	
    // White name
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Name"];
	}
	
	return YES;
}

-(BOOL)matchAlreadyPlaying:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_MATCH_IS_PLAYING], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }    
    MsgLog(@"MAT: matchAlreadyPlaying matched");
	
    // White name
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Name"];
	}
	
	return YES;
}

-(BOOL)matchAmbiguousName:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_MATCH_AMBIGUOUS], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }    
    MsgLog(@"MAT: matchAmbiguousName matched");
	
    // White name
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Name"];
	}
	
	return YES;
}

-(BOOL)matchCantMatchYourself:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    //int Length = 0;
    //int Offset = 0;
	//char tmpBuff[256];
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_MATCH_CANT_MATCH_SELF], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }    
    MsgLog(@"MAT: matchCantMatchYourself matched");
	
	return YES;
}

-(BOOL)matchLastNotLogged:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_MATCH_LAST_NOT_LOGGED], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }    
    MsgLog(@"MAT: matchLastNotLogged matched");
	
    // name
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Name"];
	}
	
	return YES;
}

-(BOOL)matchNotFitFormula:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_MATCH_NOT_FIT_FORMULA], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }    
    MsgLog(@"MAT: matchNotFitFormula matched");
	
    // name
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Name"];
	}
	
	return YES;
}

//------------------------------------------------------------------------------
// Match 'Game XXX { ... }' 
//------------------------------------------------------------------------------
-(BOOL)matchGameStart:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_GAME_START], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }

    MsgLog(@"MAT: GameStart matched");
    
	// Game number
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"GameNumber"];
	}
    // White name
    Offset = regexMatches[2].rm_so;  
    Length = regexMatches[2].rm_eo -regexMatches[2].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"WhiteName"];
	}
    // Black name
    Offset = regexMatches[3].rm_so;  
    Length = regexMatches[3].rm_eo -regexMatches[3].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"BlackName"];
	}
    // IsRated
    Offset = regexMatches[4].rm_so;  
    Length = regexMatches[4].rm_eo -regexMatches[4].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"IsRated"];
	}
    // RateType
    Offset = regexMatches[5].rm_so;  
    Length = regexMatches[5].rm_eo -regexMatches[5].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"RateType"];
	}
	
    return TRUE;
}

//------------------------------------------------------------------------------
// Match 'Game XXX { ... } [Result]' 
//------------------------------------------------------------------------------
-(BOOL)matchGameEnd:(NSString*)str matchedData:(NSMutableDictionary*)outDict;
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_GAME_END], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }

    MsgLog(@"MAT: GameEnd matched");
    
	// Game number
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"GameNumber"];
	}
    // White name
    Offset = regexMatches[2].rm_so;  
    Length = regexMatches[2].rm_eo -regexMatches[2].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"WhiteName"];
	}
    // Black name
    Offset = regexMatches[3].rm_so;  
    Length = regexMatches[3].rm_eo -regexMatches[3].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"BlackName"];
	}
    // Result String
    Offset = regexMatches[4].rm_so;  
    Length = regexMatches[4].rm_eo -regexMatches[4].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"ResultString"];
	}
    // Result
    Offset = regexMatches[5].rm_so;  
    Length = regexMatches[5].rm_eo -regexMatches[5].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Result"];
	}
	
    return TRUE;
}

//------------------------------------------------------------------------------
// Match '<12> ...' (style 12 board)
//------------------------------------------------------------------------------
 -(BOOL)matchStyle12:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];

    //MsgLog(@"MAT: try to match style12");
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_GAME_STYLE12], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }
	
    MsgLog(@"MAT: Style12 record matched");
    
	// Board name
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Board"];
	}
    // Color
    Offset = regexMatches[2].rm_so;  
    Length = regexMatches[2].rm_eo -regexMatches[2].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"IsWhiteMove"];
	}
    // En-passant column
    Offset = regexMatches[3].rm_so;  
    Length = regexMatches[3].rm_eo -regexMatches[3].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"EnPassantCol"];
	}
    // White short castle
    Offset = regexMatches[4].rm_so;  
    Length = regexMatches[4].rm_eo -regexMatches[4].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"CanWhiteCastleShort"];
	}
    // White long castle
    Offset = regexMatches[5].rm_so;  
    Length = regexMatches[5].rm_eo -regexMatches[5].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"CanWhiteCastleLong"];
	}
    // Black short castle
    Offset = regexMatches[6].rm_so;  
    Length = regexMatches[6].rm_eo -regexMatches[6].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"CanBlackCastleShort"];
	}
    // Black long castle
    Offset = regexMatches[7].rm_so;  
    Length = regexMatches[7].rm_eo -regexMatches[7].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"CanBlackCastleLong"];
	}
    // Number of moves since last irreversible
    Offset = regexMatches[8].rm_so;  
    Length = regexMatches[8].rm_eo -regexMatches[8].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"MovesSinceIrreversible"];
	}
    // Game Number
    Offset = regexMatches[9].rm_so;  
    Length = regexMatches[9].rm_eo -regexMatches[9].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"GameNumber"];
	}
    // White's name
    Offset = regexMatches[10].rm_so;  
    Length = regexMatches[10].rm_eo -regexMatches[10].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"WhiteName"];
	}
    // Black's name
    Offset = regexMatches[11].rm_so;  
    Length = regexMatches[11].rm_eo -regexMatches[11].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"BlackName"];
	}
    // My relation
    Offset = regexMatches[12].rm_so;  
    Length = regexMatches[12].rm_eo -regexMatches[12].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Relation"];
	}
    // Initial time
    Offset = regexMatches[13].rm_so;  
    Length = regexMatches[13].rm_eo -regexMatches[13].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"InitialTime"];
	}
    // Time increment
    Offset = regexMatches[14].rm_so;  
    Length = regexMatches[14].rm_eo -regexMatches[14].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Increment"];
	}
    // White's strength
    Offset = regexMatches[15].rm_so;  
    Length = regexMatches[15].rm_eo -regexMatches[15].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"WhiteStrength"];
	}
    // Black's strength
    Offset = regexMatches[16].rm_so;  
    Length = regexMatches[16].rm_eo -regexMatches[16].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"BlackStrength"];
	}
    // White's time
    Offset = regexMatches[17].rm_so;  
    Length = regexMatches[17].rm_eo -regexMatches[17].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"WhiteTime"];
	}
    // Black's time
    Offset = regexMatches[18].rm_so;  
    Length = regexMatches[18].rm_eo -regexMatches[18].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"BlackTime"];
	}
    // Move number
    Offset = regexMatches[19].rm_so;  
    Length = regexMatches[19].rm_eo -regexMatches[19].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"MoveNumber"];
	}
    // Verbose move notation
    Offset = regexMatches[20].rm_so;  
    Length = regexMatches[20].rm_eo -regexMatches[20].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"VerboseMove"];
	}
    // Time taken for last move
    Offset = regexMatches[21].rm_so;  
    Length = regexMatches[21].rm_eo -regexMatches[21].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"TimePrevMove"];
	}
    // Pretty move notation
    Offset = regexMatches[22].rm_so;  
    Length = regexMatches[22].rm_eo -regexMatches[22].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"PrettyMove"];
	}
    // Flip
    Offset = regexMatches[23].rm_so;  
    Length = regexMatches[23].rm_eo -regexMatches[23].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Flip"];
	}
	
    return TRUE;
}

-(BOOL)matchAbortOffer:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];
	
    //printf("MATCH: Starting, input='%s'\n", pStr);
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_OFFER_ABORT], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }    
    MsgLog(@"MAT: matchAbortOffer matched");
	
    // name
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Name"];
	}
	
	return YES;
}

-(BOOL)matchAdjournOffer:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];
	
    //printf("MATCH: Starting, input='%s'\n", pStr);
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_OFFER_ADJOURN], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }    
    MsgLog(@"MAT: matchAdjournOffer matched");
	
    // name
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Name"];
	}
	
	return YES;
}

-(BOOL)matchDrawOffer:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];
	
    //printf("MATCH: Starting, input='%s'\n", pStr);
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_OFFER_DRAW], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }    
    MsgLog(@"MAT: matchDrawOffer matched");
	
    // name
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Name"];
	}
	
	return YES;
}

-(BOOL)matchSwitchOffer:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];
	
    //printf("MATCH: Starting, input='%s'\n", pStr);
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_OFFER_SWITCH], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }    
    MsgLog(@"MAT: matchSwitchOffer matched");
	
    // name
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Name"];
	}
	
	return YES;
}

-(BOOL)matchTakebackOffer:(NSString*)str matchedData:(NSMutableDictionary*)outDict
{
    int Status;
    int Length = 0;
    int Offset = 0;
	char tmpBuff[256];
	
    //printf("MATCH: Starting, input='%s'\n", pStr);
	
	memset(regexMatches, 0, sizeof(regexMatches));
	const char *pStr = [str UTF8String];
    Status = regexec(&regexObjects[RE_OFFER_TAKEBACK], pStr,
					 RE_MAX_MATCHES,regexMatches,0);
    if(Status!=0)
    {
        return FALSE;
    }    
    MsgLog(@"MAT: matchSwitchOffer matched");
	
    // name
    Offset = regexMatches[1].rm_so;  
    Length = regexMatches[1].rm_eo -regexMatches[1].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"Name"];
	}
	
    // Move number
    Offset = regexMatches[2].rm_so;  
    Length = regexMatches[2].rm_eo -regexMatches[2].rm_so;
    if(Offset>=0)
	{
		strncpy(tmpBuff, &pStr[Offset], Length);
		tmpBuff[Length] = '\0';
		[outDict setObject:[NSString stringWithCString:tmpBuff] forKey:@"NumberOfHalfMoves"];
	}
	
	return YES;
}

@end

