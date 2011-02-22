//
//  ChessBoardScene.m
//  HandyChess
//
//  Created by Anton Zemyanov on 18.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#define VERT_OFFSET	56

#import "GlobalConfig.h"
#import "Logger.h"

#import "ChessBoardScene.h"
#import "ChessBoardStaticLayer.h"

#import "SoundEngine.h"
//#import "MessageBoxActivity.h"
//#import "MessageBoxError.h"
#import "PopupActivity.h"
#import "PopupQuestion.h"
#import "PopupError.h"
#import "PopupPromo.h"
#import "PopupSeekOptions.h"
#import "PopupMatchOptions.h"

#import "ChessInitialMenu.h"
#import "ChessGameMenu.h"
#import "PopupGameResult.h"

#import "Transitions.h"
#import "MainMenuScene.h"


@implementation ChessBoardScene

#pragma mark ******************* init stuff *******************
-(id)init
{
	if(self=[super init])
	{
		ColorLayer *bg = [ColorLayer layerWithColor:0xFFFFFFFF width:320 height:480];
		[self addChild:bg];
		
		staticLayer = [ChessBoardStaticLayer node];
		[self addChild:staticLayer];
		chessBoardLayer = [ChessBoardLayer node];
		chessBoardLayer.isTouchEnabled = YES;
		chessBoardLayer.scene = self;
		[self addChild:chessBoardLayer];
		initialMenuLayer = [ChessInitialMenu node];
		[self addChild:initialMenuLayer];
		
		controller = [[ChessBoardController alloc] init];
		controller.scene = self;
		//controller.chessBoard = chessBoardLayer;
		
		info1 = [[NSString alloc] initWithString:@"Welcome to HandyChess"];
		info2 = [[NSString alloc] initWithString:@"Connecting to chess server..."];

		[staticLayer.topName setRGB:0 :0 :0];
		[staticLayer.botName setRGB:0 :0 :0];
	}
	return self;
}

-(void)dealloc
{
	[controller release];
	[super dealloc]; 
}

/*
 -(void)onEnter
 {
 [super onEnter];
 return;
 }
 
 -(void)OnExit
 {
 [super onExit];
 return;
 }
 */

-(void)didTransitIn:(id)obj
{
	[controller startBackend];
	[controller connect];
}

-(void)willTransitOut:(id)obj
{
	[controller disconnect];
	[controller stopBackend];
}

#pragma mark ******************* chess board manipulation *******************
-(void)setOrientation:(BOOL)isWhiteOnBottom
{
	[chessBoardLayer setOrientation:isWhiteOnBottom];
}

-(void)syncPosition:(NSString*)posStyle12 isAnimated:(BOOL)isAnimated
{
	[chessBoardLayer syncPosition:posStyle12 isAnimated:isAnimated];
	return;
}

-(void)movePiece:(NSDictionary*)data
{
	[chessBoardLayer movePiece:data];
	return;
}

-(void)getMove:(NSArray*)validMoves
{
	[chessBoardLayer getMove:validMoves];
	return;
}

-(void)clearAllMarks
{
	[chessBoardLayer clearAllMarks];
	return;
}

#pragma mark ******************* chessboard callbacks *******************
-(void)playerMove:(NSDictionary*)playerMove
{
	// retranslate to controller
	[controller msgPlayerMove:playerMove];
	return;
}

-(void)pieceMoved:(NSDictionary*)data
{
	// retranslate to controller
	[[SoundEngine sharedSoundEngine] playSound:@"piece_down.wav"];
	[controller msgPieceMoved:data];
	return;
}

#pragma mark ******************* initial menu *******************
-(void)seekPressed
{
	[self seekPopupShow];
	return;
}

-(void)matchPressed
{
	[self matchPopupShow];
	return;
}

-(void)rematchPressed
{
	[controller msgRematch];
	[self writeInfo:@"Rematch request sent to server"];
	
	[self waitGamePopupShow:@"Wait for oppenent to accept/decline offer"];
}

-(void)optionsPressed
{
	offGameActionSheet = [[UIActionSheet alloc] 
						 initWithTitle:nil delegate:self 
						 cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil 
						 otherButtonTitles:@"Adjudicate Adjourned",@"Exit to Main Menu",nil];
	
	[offGameActionSheet showInView:[Director sharedDirector].openGLView];
	[offGameActionSheet release];
	
	return;
}

#pragma mark ******************* game menu *******************
-(void)offerDrawPressed
{
	[self confirmPopupShow:@"Are you sure you want to offer draw?" command:@"draw\n"];
	return;
}

-(void)resignPressed
{
	[self confirmPopupShow:@"Are you sure you want to resign the game?" command:@"resign\n"];
	return;
}

-(void)adjournPressed
{
	[self confirmPopupShow:@"Are you sure you want to adjourn the game?" command:@"adjourn\n"];
	return;
}

-(void)gameOptionsPressed
{
	inGameActionSheet = [[UIActionSheet alloc] 
						 initWithTitle:nil delegate:self 
						 cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil 
						 otherButtonTitles:@"Abort",@"Adjourn",@"Exit to Main Menu",nil];
	
	[inGameActionSheet showInView:[Director sharedDirector].openGLView];
	[inGameActionSheet release];
	
	return;
}

#pragma mark ******************* game start/end notifications *******************
-(void)gameStarted:(NSDictionary*)params
{
	[chessBoardLayer setInGameState:YES];
	[self clearAllMarks];

	[staticLayer.topName setRGB:0 :0 :0];
	[staticLayer.botName setRGB:0 :0 :0];
	
	// delete seek/match popups if any
	[self seekPopupDelete];
	[self matchPopupDelete];
	
	// remove ChessInitialMenu
	if(initialMenuLayer)
	{
		[initialMenuLayer.parent removeChild:initialMenuLayer cleanup:YES];
		initialMenuLayer = nil;
	}
	
	// place ChessGameMenu
	if(gameMenuLayer==nil)
	{
		gameMenuLayer = [ChessGameMenu node];
		[self addChild:gameMenuLayer];
	}
	
	// remove last moves for both players
	[self setTopMove:@""];
	[self setBotMove:@""];
	
	return;
}

-(void)gameEnded:(NSDictionary*)params
{
	[chessBoardLayer setInGameState:NO];
	[staticLayer.topName setRGB:0 :0 :0];
	[staticLayer.botName setRGB:0 :0 :0];
	
	// delete confirm/offer popups
	[self confirmPopupDelete];
	
	// remove ChessInitialMenu
	if(gameMenuLayer)
	{
		[gameMenuLayer.parent removeChild:gameMenuLayer cleanup:YES];
		gameMenuLayer = nil;
	}
	
	// place ChessGameMenu
	if(initialMenuLayer==nil)
	{
		initialMenuLayer = [ChessInitialMenu node];
		[self addChild:initialMenuLayer];
	}
	
	if(params==nil)
	{
		// if no params, no game result (network error)
		return;
	}
	
	NSString *wh = [params objectForKey:@"WhiteName"];
	NSString *bl = [params objectForKey:@"BlackName"];
	NSString *players = [NSString stringWithFormat:@"%@ vs %@", wh, bl];
	
	NSString *res = [params objectForKey:@"Result"];
	NSString *resStr = [params objectForKey:@"ResultString"];
	NSString *result = [NSString stringWithFormat:@"%@ %@", res, resStr];
	ccColorF wColor = POPUP_WON_COLOR;
	ccColorF lColor = POPUP_LOST_COLOR;
	ccColorF dColor = POPUP_DRAW_COLOR;
	ccColorF oColor = POPUP_OTHER_COLOR;
	
	ccColorF color = oColor;
	if( [res isEqualToString:@"1/2-1/2"] )
		color = dColor;
	else if( ([res isEqualToString:@"1-0"] && chessBoardLayer.isWhiteOnBottom) || 
			([res isEqualToString:@"0-1"] && !chessBoardLayer.isWhiteOnBottom) )
		color = wColor;
	else if( ([res isEqualToString:@"0-1"] && chessBoardLayer.isWhiteOnBottom) || 
			([res isEqualToString:@"1-0"] && !chessBoardLayer.isWhiteOnBottom) )
		color = lColor;
	
	[self gameResultPopupShowColor:color players:players result:result];
	
	// duplicate to console
	[self writeInfo:result];
	
	return;
}


#pragma mark ******************* top/bottom/info *******************

// update time for both players
-(void)updateTime:(NSDictionary*)time
{
    if(chessBoardLayer.isWhiteOnBottom)
	{
		[staticLayer.topTime setString:[time objectForKey:@"BlackTime"]];
		[staticLayer.botTime setString:[time objectForKey:@"WhiteTime"]];
	}
	else
	{
		[staticLayer.topTime setString:[time objectForKey:@"WhiteTime"]];
		[staticLayer.botTime setString:[time objectForKey:@"BlackTime"]];
	}
	return;
}

-(void)showMove:(NSDictionary*)data
{
	if([[data objectForKey:@"MoveNumber"] intValue]==0)
		return;
	
	NSString *color = [data objectForKey:@"PieceColor"];
	NSString *move = [NSString stringWithFormat:@"%@.%@",
					  [data objectForKey:@"MoveNumber"],
					  [data objectForKey:@"PrettyMove"]];
	PieceColor col = [color isEqualToString:@"W"] ? kPieceWhite : kPieceBlack;
    if(chessBoardLayer.isWhiteOnBottom)
	{
		if(col==kPieceWhite)
			[self setBotMove:move];
		else
			[self setTopMove:move];
	}
	else
	{
		if(col==kPieceWhite)
			[self setTopMove:move];
		else
			[self setBotMove:move];
	}
	return;
}

// side to move
-(void)sideToMove:(NSDictionary*)data
{
	NSString *color = [data objectForKey:@"Color"];
	PieceColor col = [color isEqualToString:@"W"] ? kPieceWhite : kPieceBlack;

	[staticLayer.topName setRGB:0 :0 :0];
	[staticLayer.botName setRGB:0 :0 :0];
    
	if(chessBoardLayer.isWhiteOnBottom)
	{
		if(col==kPieceWhite)
			[staticLayer.botName setRGB:0 :0 :128];
		else
			[staticLayer.topName setRGB:0 :0 :128];
	}
	else
	{
		if(col==kPieceWhite)
			[staticLayer.topName setRGB:0 :0 :128];
		else
			[staticLayer.botName setRGB:0 :0 :128];
	}
	return;
}

// top player info
-(void)setTopTime:(NSString*)time
{
	[staticLayer.topTime setString:time];
	return;
}

-(void)setTopName:(NSString*)name
{
	[staticLayer.topName setString:name];
	return;
}

-(void)setTopMove:(NSString*)name
{
	[staticLayer.topMove setString:name];
	return;
}


-(void)setTopRating:(NSString*)rt
{
	[staticLayer.topRating setString:rt];
	return;
}

// bottom player info
-(void)setBotTime:(NSString*)time
{
	[staticLayer.botTime setString:time];
	return;
}

-(void)setBotName:(NSString*)name
{
	[staticLayer.botName setString:name];
	return;
}

-(void)setBotMove:(NSString*)name
{
	[staticLayer.botMove setString:name];
	return;
}

-(void)setBotRating:(NSString*)rt
{
	[staticLayer.botRating setString:rt];
	return;
}

-(void)clearInfo
{
	[info1 release];
	[info2 release];

	info1 = @"";
	info2 = @"";
	
	[staticLayer.info1 setString:info1];
	[staticLayer.info2 setString:info2];
}

-(void)writeInfo:(NSString*)info
{
	if([info1 isEqualToString:@""])
	{
		[info1 release];
		info1 = [info retain];
		[staticLayer.info1 setString:info1];
	}
	else if([info2 isEqualToString:@""])
	{
		// two tines 
		[info2 release];
		info2 = [info retain];
		[staticLayer.info2 setString:info2];
	}
	else
	{
		// two tines 
		[info1 release];
		info1 = info2;
		info2 = [info retain];
		
		// update labels
		[staticLayer.info1 setString:info1];
		[staticLayer.info2 setString:info2];
	}
	return;
}

#pragma mark  ******************* connect popup *******************
-(void)connectPopupShow
{
	[self connectPopupDelete];
	ccColorF col = {1.0f, 1.0f, 1.0f, 1.0f};
	connPopup = [PopupActivity popupWithTitle:@"Conecting" titleSize:CGSizeMake(200,48) color:col];
	connPopup.onCancel = [CallFuncN actionWithTarget:self selector:@selector(connectPopupCancelled:)];
	connPopup.scale = 0.0f;
	connPopup.position = cpv(0, VERT_OFFSET);
	connPopup.isTouchEnabled = YES;
	[self addChild:connPopup];
	[connPopup runAction:[ScaleTo actionWithDuration:0.3f scale:1.0f]];
	return;
}

-(void)connectPopupSetText:(NSString*)txt
{
	[connPopup.message setString:txt];
}

-(void)connectPopupCancelled:(id)obj
{
	[connPopup runAction:
	 [Sequence actions:[ScaleTo actionWithDuration:0.2f scale:0.0f],
	  [CallFuncN actionWithTarget:self selector:@selector(connectPopupDelete)],nil]];
	
	//send disconnect
	[controller disconnect];
	
	//return to main menu
	[self willTransitOut:nil];
	MainMenuScene *mainMenu = [MainMenuScene node];
	[[Director sharedDirector] replaceScene:[FadeTransition transitionWithDuration:FADE_TRANSITION_TIME scene:mainMenu]];

	return;
}

-(void)connectPopupDismiss
{
	if(connPopup==nil)
		return;
	
	[connPopup runAction:
	 [Sequence actions:[ScaleTo actionWithDuration:0.2f scale:0.0f],
	  [CallFuncN actionWithTarget:self selector:@selector(connectPopupDelete)],nil]];
	return;
}


-(void)connectPopupDelete
{
	connPopup.isTouchEnabled = NO;
	[self removeChild:connPopup cleanup:YES];
	connPopup = nil;
}

#pragma mark ******************* disconnected popup *******************
-(void)disconnectedPopupShow:(NSString*)title
{
	[self disconnectedPopupDelete];
	[self connectPopupDismiss];
	
	ccColorF col = {0.99f, 0.9f, 0.9f, 1.0f};
	discPopup = [PopupQuestion popupWithTitle:title buttons:kQuestionButtonsYesNo color:col];
	discPopup.onFirst  = [CallFuncN actionWithTarget:self selector:@selector(disconnectedPopupReconnect:)];
	discPopup.onSecond = [CallFuncN actionWithTarget:self selector:@selector(disconnectedPopupCancel:)];
	discPopup.scale = 0.0f;
	discPopup.position = cpv(0, VERT_OFFSET);
	discPopup.isTouchEnabled = YES;
	[self addChild:discPopup];
	[discPopup runAction:[ScaleTo actionWithDuration:0.3f scale:1.0f]];

	return;	
}

-(void)disconnectedPopupReconnect:(id)obj
{
	MsgLog(@"SBC: reconnect requested");
	[discPopup runAction:
	 [Sequence actions:[ScaleTo actionWithDuration:0.2f scale:0.0f],
	  [CallFuncN actionWithTarget:self selector:@selector(disconnectedPopupDelete)],nil]];
	
	[controller connect];
}

-(void)disconnectedPopupCancel:(id)obj
{
	MsgLog(@"SBC: cancel");
	
	[self willTransitOut:nil];
	MainMenuScene *mainMenu = [MainMenuScene node];
	[[Director sharedDirector] replaceScene:[FadeTransition transitionWithDuration:FADE_TRANSITION_TIME scene:mainMenu]];
}

-(void)disconnectedPopupDelete
{
	if(discPopup==nil)
		return;

	discPopup.isTouchEnabled = NO;
	[self removeChild:discPopup cleanup:YES];
	discPopup = nil;
	return;
}

#pragma mark ******************* challenge popup *******************
-(void)challengePopupShow:(NSString*)title
{
	[self gameResultPopupDelete];
	[self challengePopupDelete];
	
	ccColorF col = {0.99f, 0.99f, 0.99f, 1.0f};
	challengePopup = [PopupQuestion popupWithTitle:title buttons:kQuestionButtonsYesNo color:col];
	challengePopup.onFirst  = [CallFuncN actionWithTarget:self selector:@selector(challengePopupAccept:)];
	challengePopup.onSecond = [CallFuncN actionWithTarget:self selector:@selector(challengePopupDecline:)];
	challengePopup.scale = 0.0f;
	challengePopup.position = cpv(0, VERT_OFFSET);
	challengePopup.isTouchEnabled = YES;
	[self addChild:challengePopup];
	[challengePopup runAction:[ScaleTo actionWithDuration:0.3f scale:1.0f]];

	return;
}

-(void)challengePopupAccept:(id)obj
{
	MsgLog(@"SBC: accept match requested");
	[challengePopup runAction:
	 [Sequence actions:[ScaleTo actionWithDuration:0.2f scale:0.0f],
	  [CallFuncN actionWithTarget:self selector:@selector(challengePopupDelete)],nil]];
	
	[controller msgCommand:@"accept t match\n"];
	return;
}

-(void)challengePopupDecline:(id)obj
{
	MsgLog(@"SBC: decline match requested");
	[challengePopup runAction:
	 [Sequence actions:[ScaleTo actionWithDuration:0.2f scale:0.0f],
	  [CallFuncN actionWithTarget:self selector:@selector(challengePopupDelete)],nil]];
	
	[controller msgCommand:@"decline t match\n"];
	return;
}

//-(void)challengePopupDismiss;
-(void)challengePopupDelete
{
	if(challengePopup==nil)
		return;

	challengePopup.isTouchEnabled = NO;
	[self removeChild:challengePopup cleanup:YES];
	challengePopup = nil;
	return;
}

// confirm popup
#pragma mark ******************* confirm popup *******************
-(void)confirmPopupShow:(NSString*)title command:(NSString*)cmd
{
	[self confirmPopupDelete];
	
	[confCmd release];
	confCmd = [[NSString alloc] initWithString:cmd];
	
	ccColorF col = {0.99f, 0.99f, 0.99f, 1.0f};
	confirmPopup = [PopupQuestion popupWithTitle:title buttons:kQuestionButtonsYesNo color:col];
	confirmPopup.onFirst  = [CallFuncN actionWithTarget:self selector:@selector(confirmPopupConfirm:)];
	confirmPopup.onSecond = [CallFuncN actionWithTarget:self selector:@selector(confirmPopupDecline:)];
	confirmPopup.scale = 0.0f;
	confirmPopup.position = cpv(0, VERT_OFFSET);
	confirmPopup.isTouchEnabled = YES;
	[self addChild:confirmPopup];
	[confirmPopup runAction:[ScaleTo actionWithDuration:0.3f scale:1.0f]];
	
	return;
}

-(void)confirmPopupConfirm:(id)obj
{
	MsgLog(@"SBC: confirm accepted");
	[confirmPopup runAction:
	 [Sequence actions:[ScaleTo actionWithDuration:0.2f scale:0.0f],
	  [CallFuncN actionWithTarget:self selector:@selector(confirmPopupDelete)],nil]];
	
	[controller msgCommand:confCmd];
	return;
}

-(void)confirmPopupDecline:(id)obj
{
	MsgLog(@"SBC: confirm rejected");
	[confirmPopup runAction:
	 [Sequence actions:[ScaleTo actionWithDuration:0.2f scale:0.0f],
	  [CallFuncN actionWithTarget:self selector:@selector(confirmPopupDelete)],nil]];
	
	return;
}

//-(void)confirmPopupDismiss;
-(void)confirmPopupDelete
{
	if(confirmPopup==nil)
		return;
	
	confirmPopup.isTouchEnabled = NO;
	[self removeChild:confirmPopup cleanup:YES];
	confirmPopup = nil;

	return;
}

#pragma mark ******************* wait game popup *******************
// waitGame popup
-(void)waitGamePopupShow:(NSString*)title
{
	[self waitGamePopupDelete];
	
	ccColorF col = {1.0f, 1.0f, 1.0f, 1.0f};
	waitGamePopup = [PopupActivity popupWithTitle:title titleSize:CGSizeMake(200,48) color:col];
	waitGamePopup.onCancel = [CallFuncN actionWithTarget:self selector:@selector(waitGamePopupCancel:)];
	waitGamePopup.scale = 0.0f;
	waitGamePopup.position = cpv(0, VERT_OFFSET);
	waitGamePopup.isTouchEnabled = YES;
	[self addChild:waitGamePopup];
	[waitGamePopup runAction:[ScaleTo actionWithDuration:0.3f scale:1.0f]];
	
	return;
}

-(void)waitGamePopupCancel:(id)obj
{
	// send cancel command
	switch(controller.state)
	{
		case CBStateSeeking:
			[controller msgUnseekGame];
			break;
		case CBStateMatchOffered:
			[controller msgUnmatch];
			break;
	}
	
	// remove window
	[waitGamePopup runAction:
	 [Sequence actions:[ScaleTo actionWithDuration:0.2f scale:0.0f],
	  [CallFuncN actionWithTarget:self selector:@selector(waitGamePopupDelete)],nil]];
}

-(void)waitGamePopupDismiss
{
	if(waitGamePopup)
	{
		// remove window
		[waitGamePopup runAction:
		 [Sequence actions:[ScaleTo actionWithDuration:0.2f scale:0.0f],
		  [CallFuncN actionWithTarget:self selector:@selector(waitGamePopupDelete)],nil]];
	}
	return;
}

-(void)waitGamePopupDelete
{
	if(waitGamePopup==nil)
		return;
	
	waitGamePopup.isTouchEnabled = NO;
	[self removeChild:waitGamePopup cleanup:YES];
	waitGamePopup = nil;

	return;
}
#pragma mark ******************* error popup *******************
-(void)errorPopupShow:(NSString*)msg
{
	//if(connPopup)
	//	[connPopup dismiss];
	ccColorF col = {1.0f, 0.8f, 0.8f, 1.0f};
	errPopup = [PopupError popupWithTitle:msg color:col];
	errPopup.onCancel = [CallFuncN actionWithTarget:self selector:@selector(errorPopupButtonPressed:)];
	errPopup.scale = 0.0f;
	errPopup.position = cpv(0, VERT_OFFSET);
	errPopup.isTouchEnabled = YES;
	[self addChild:errPopup];
	[errPopup runAction:[ScaleTo actionWithDuration:0.3f scale:1.0f]];
	
}

-(void)errorPopupButtonPressed:(id)obj
{
	// go to main menu scene
	[self willTransitOut:nil];
	MainMenuScene *mainMenu = [MainMenuScene node];
	[[Director sharedDirector] replaceScene:[FadeTransition transitionWithDuration:FADE_TRANSITION_TIME scene:mainMenu]];
	return;
}

-(void)errorPopupDelete
{
	if(errPopup==nil)
		return;
	
	errPopup.isTouchEnabled = NO;
	[self removeChild:errPopup cleanup:YES];
	errPopup = nil;
	
	return;
}

#pragma mark ******************* offer popup *******************
-(void)offerPopupShow:(NSString*)msg accept:(NSString*)acc decline:(NSString*)decl
{
	[self confirmPopupDelete];
	
	[offerAcceptCmd release];
	[offerDeclineCmd release];
	offerAcceptCmd = [[NSString alloc] initWithString:acc];
	offerDeclineCmd = [[NSString alloc] initWithString:decl];
	
	ccColorF col = {0.99f, 0.99f, 0.99f, 1.0f};
	offerPopup = [PopupQuestion popupWithTitle:msg buttons:kQuestionButtonsYesNo color:col];
	offerPopup.onFirst  = [CallFuncN actionWithTarget:self selector:@selector(offerPopupAccept:)];
	offerPopup.onSecond = [CallFuncN actionWithTarget:self selector:@selector(offerPopupDecline:)];
	offerPopup.scale = 0.0f;
	offerPopup.position = cpv(0, VERT_OFFSET);
	offerPopup.isTouchEnabled = YES;
	[self addChild:offerPopup];
	[offerPopup runAction:[ScaleTo actionWithDuration:0.3f scale:1.0f]];
	
	return;
}

-(void)offerPopupAccept:(id)obj
{
	MsgLog(@"SBC: offerPopup accepted");
	[offerPopup runAction:
	 [Sequence actions:[ScaleTo actionWithDuration:0.2f scale:0.0f],
	  [CallFuncN actionWithTarget:self selector:@selector(offerPopupDelete)],nil]];
	
	[controller msgCommand:offerAcceptCmd];
	return;
}

-(void)offerPopupDecline:(id)obj
{
	MsgLog(@"SBC: offerPopup declined");
	[offerPopup runAction:
	 [Sequence actions:[ScaleTo actionWithDuration:0.2f scale:0.0f],
	  [CallFuncN actionWithTarget:self selector:@selector(offerPopupDelete)],nil]];
	
	[controller msgCommand:offerDeclineCmd];
	return;
}

-(void)offerPopupDelete
{
	if(offerPopup==nil)
		return;
	
	offerPopup.isTouchEnabled = NO;
	[self removeChild:offerPopup cleanup:YES];
	offerPopup = nil;
	
	return;
}

// info popup
-(void)infoPopupShow:(NSString*)msg
{
	[self infoPopupDelete];

	ccColorF col = {0.95f, 0.99f, 0.95f, 1.0f};
	infoPopup = [PopupError popupWithTitle:msg color:col];
	infoPopup.onCancel  = [CallFuncN actionWithTarget:self selector:@selector(infoPopupDismiss:)];
	infoPopup.scale = 0.0f;
	infoPopup.position = cpv(0, VERT_OFFSET);
	infoPopup.isTouchEnabled = YES;
	[self addChild:infoPopup];
	[infoPopup runAction:[ScaleTo actionWithDuration:0.3f scale:1.0f]];
	
	return;
}

-(void)infoPopupDismiss:(id)obj
{
	[infoPopup runAction:
	 [Sequence actions:[ScaleTo actionWithDuration:0.2f scale:0.0f],
	  [CallFuncN actionWithTarget:self selector:@selector(infoPopupDelete)],nil]];
	
	return;
}

-(void)infoPopupDelete
{
	if(infoPopup==nil)
		return;
	
	infoPopup.isTouchEnabled = NO;
	[self removeChild:infoPopup cleanup:YES];
	infoPopup = nil;
	
	return;	
}

#pragma mark ******************* game result popup *******************
-(void)gameResultPopupShowColor:(ccColorF)clr players:(NSString*)players result:(NSString*)res
{
	[self confirmPopupDelete];
	[self promoPopupDelete];
	if(gameResultPopup)
		[gameResultPopup dismiss];
	
	gameResultPopup = [PopupGameResult popupWithColor:clr result:res];
	gameResultPopup.onOk = [CallFuncN actionWithTarget:self selector:@selector(gameResultPopupOkPressed:)];
	gameResultPopup.onRematch = [CallFuncN actionWithTarget:self selector:@selector(gameResultPopupRematchPressed:)];
	gameResultPopup.scale = 0.0f;
	[self addChild:gameResultPopup z:100];
	[gameResultPopup runAction:[ScaleTo actionWithDuration:0.3f scale:1.0f]];
	
	return;
}

-(void)gameResultPopupOkPressed:(id)obj
{
	[gameResultPopup runAction:
	 [Sequence actions:[FadeTo actionWithDuration:0.2f opacity:0],
	  [CallFunc actionWithTarget:self selector:@selector(gameResultPopupDelete)],nil]];
	
}

-(void)gameResultPopupRematchPressed:(id)obj
{
	[gameResultPopup runAction:
	 [Sequence actions:[FadeTo actionWithDuration:0.2f opacity:0],
	  [CallFunc actionWithTarget:self selector:@selector(gameResultPopupDelete)],nil]];
	
	[controller msgRematch];
	return;
}

-(void)gameResultPopupDelete
{
	if(gameResultPopup==nil)
		return;

	gameResultPopup.isTouchEnabled = NO;
	[self removeChild:gameResultPopup cleanup:YES];
	gameResultPopup = nil;
	
	return;
}

#pragma mark ******************* promo popup *******************
-(void)promoPopupShowPieceColor:(PieceColor)color
{
	if(promoPopup)
		[promoPopup dismiss];
	
	promoPopup = [PopupPromo popupWithPieceColor:color];
	promoPopup.onButton = [CallFuncN actionWithTarget:self selector:@selector(promoPopupButtonPressed:)];
	promoPopup.scale = 0.0f;
	[self addChild:promoPopup z:100];
	[promoPopup runAction:[ScaleTo actionWithDuration:0.3f scale:1.0f]];
	
	return;
}

-(void)promoPopupButtonPressed:(id)obj
{
	MsgLog(@"POP: piece pressed: %@", promoPopup.pieceSelected);
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:promoPopup.pieceSelected,@"PromoteTo",nil];
	[controller msgPromoPiece:dict];
	
	[promoPopup dismiss];	
}

-(void)promoPopupDelete
{
	if(promoPopup==nil)
		return;
	
	[promoPopup dismiss];
	promoPopup = nil;
	
	return;
}

#pragma mark ******************* seek Popup *******************
-(void)seekPopupShow
{
	seekOptionsPopup = [PopupSeekOptions popupWithRegisteredStatus:controller.isRegistred];
	seekOptionsPopup.onSeek   = [CallFuncN actionWithTarget:self selector:@selector(seekPopupSeekPressed:)];
	seekOptionsPopup.onCancel = [CallFuncN actionWithTarget:self selector:@selector(seekPopupCancelPressed:)];
	seekOptionsPopup.opacity = 0;
	seekOptionsPopup.position = cpv(160, 240);
	seekOptionsPopup.transformAnchor = cpv(0, 0);
	seekOptionsPopup.isTouchEnabled = YES;
	[self addChild:seekOptionsPopup];
	[seekOptionsPopup runAction:[Sequence actions:
								 [FadeTo actionWithDuration:0.3f opacity:255],
								 [CallFuncN actionWithTarget:seekOptionsPopup selector:@selector(nodeDidAppeared)],
								 nil]];
	return;
}

-(void)seekPopupCancelPressed:(id)obj
{
	[seekOptionsPopup runAction:
	 [Sequence actions:[FadeTo actionWithDuration:0.3f opacity:0],
	  [CallFuncN actionWithTarget:self selector:@selector(seekPopupDelete)],nil]];
	
	return;
}

-(void)seekPopupSeekPressed:(id)obj
{
	[seekOptionsPopup runAction:
	 [Sequence actions:[FadeTo actionWithDuration:0.3f opacity:0],
	  [CallFuncN actionWithTarget:self selector:@selector(seekPopupDelete)],nil]];
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *seekParams = [NSMutableDictionary dictionaryWithDictionary:[defs objectForKey:@"SeekParams"]];
	[controller msgSeekGame:seekParams];
	
	return;
}

-(void)seekPopupDelete
{
	if(seekOptionsPopup==nil)
		return;

	seekOptionsPopup.isTouchEnabled = NO;
	[seekOptionsPopup.parent removeChild:seekOptionsPopup cleanup:YES];
	seekOptionsPopup = nil;

	return;
}

#pragma mark ******************* match Popup *******************
-(void)matchPopupShow
{
	matchOptionsPopup = [PopupMatchOptions popupWithRegisteredStatus:controller.isRegistred];
	matchOptionsPopup.onMatch   = [CallFuncN actionWithTarget:self selector:@selector(matchPopupMatchPressed:)];
	matchOptionsPopup.onCancel = [CallFuncN actionWithTarget:self selector:@selector(matchPopupCancelPressed:)];
	matchOptionsPopup.opacity = 0;
	matchOptionsPopup.position = cpv(160, 240);
	matchOptionsPopup.transformAnchor = cpv(0, 0);
	matchOptionsPopup.isTouchEnabled = YES;
	[self addChild:matchOptionsPopup];
	[matchOptionsPopup runAction:[Sequence actions:
								 [FadeTo actionWithDuration:0.3f opacity:255],
								 [CallFuncN actionWithTarget:matchOptionsPopup selector:@selector(nodeDidAppeared)],
								 nil]];
	return;
}

-(void)matchPopupCancelPressed:(id)obj
{
	[matchOptionsPopup nodeWillDisappear];
	[matchOptionsPopup runAction:
	 [Sequence actions:[FadeTo actionWithDuration:0.3f opacity:0],
	  [CallFuncN actionWithTarget:self selector:@selector(matchPopupDelete)],nil]];
	
	return;
}

-(void)matchPopupMatchPressed:(id)obj
{
	[self writeInfo:@"Match request sent to server"];
	[matchOptionsPopup nodeWillDisappear];
	[matchOptionsPopup runAction:
	 [Sequence actions:[FadeTo actionWithDuration:0.3f opacity:0],
	  [CallFuncN actionWithTarget:self selector:@selector(matchPopupDelete)],nil]];
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *matchParams = [NSMutableDictionary dictionaryWithDictionary:[defs objectForKey:@"MatchParams"]];
	[controller msgMatch:matchParams];
	
	return;
}

-(void)matchPopupDelete
{
	if(matchOptionsPopup==nil)
		return;
	
	matchOptionsPopup.isTouchEnabled = YES;
	[matchOptionsPopup.parent removeChild:matchOptionsPopup cleanup:YES];
	matchOptionsPopup = nil;

	return;
}


#pragma mark ******************* action sheet delegate *******************
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(actionSheet==inGameActionSheet)
	{
		// in game action sheet pressed
		switch(buttonIndex)
		{
			case 0:
			{
				// abort
				[self confirmPopupShow:@"Are you sure you want to abort the game?" command:@"abort\n"];
				break;
			}
			case 1:
			{
				// abort
				[self confirmPopupShow:@"Are you sure you want to adjourn the game?" command:@"adjourn\n"];
				break;
			}
			case 2:
			{
				// return to main menu
				[self willTransitOut:nil];
				MainMenuScene *mainMenu = [MainMenuScene node];
				[[Director sharedDirector] replaceScene:
				 [FadeTransition transitionWithDuration:FADE_TRANSITION_TIME scene:mainMenu]];
				break;
			}
		}
	} 
	else
	{
		// out game action sheet
		switch(buttonIndex)
		{
			case 0:
			{
				// adjudicate adjourned
				NSURL *url = [NSURL URLWithString:@"http://www.freechess.org/Adjudicate/index.html"];
				[[UIApplication sharedApplication] openURL:url];
				break;
			}
			case 1:
			{
				// return to main menu
				[self willTransitOut:nil];
				MainMenuScene *mainMenu = [MainMenuScene node];
				[[Director sharedDirector] replaceScene:
				 [FadeTransition transitionWithDuration:FADE_TRANSITION_TIME scene:mainMenu]];
				break;
			}
		}
	}
	return;
}

@end
