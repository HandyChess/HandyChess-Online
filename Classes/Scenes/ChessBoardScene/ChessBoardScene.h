//
//  ChessBoardScene.h
//  HandyChess
//
//  Created by Anton Zemyanov on 18.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "ChessBoardStaticLayer.h"
#import "ChessBoardLayer.h"

#import "ChessBoardController.h"
#import "ChessPiece.h"

@class MessageBoxActivity;
@class MessageBoxError;
@class ChessInitialMenu;
@class ChessGameMenu;
@class PopupActivity;
@class PopupQuestion;
@class PopupError;
@class PopupGameResult;
@class PopupPromo;
@class PopupSeekOptions;
@class PopupMatchOptions;

@interface ChessBoardScene : Scene <UIActionSheetDelegate>
{
	ChessBoardController	*controller;

	ChessBoardStaticLayer	*staticLayer;
	ChessBoardLayer			*chessBoardLayer;
	// popups
	MessageBoxActivity		*connect;
	MessageBoxError			*error;
	PopupActivity			*connPopup;
	PopupQuestion			*discPopup;
	PopupQuestion			*challengePopup;
	PopupQuestion			*confirmPopup;
	PopupActivity			*waitGamePopup;
	PopupError				*errPopup;
	PopupQuestion			*offerPopup;
	PopupError				*infoPopup;
	PopupGameResult			*gameResultPopup;
	PopupPromo				*promoPopup;
	PopupSeekOptions		*seekOptionsPopup;
	PopupMatchOptions		*matchOptionsPopup;
	
	NSString				*waitGameCancelCmd;
	NSString				*confCmd;
	NSString				*offerAcceptCmd;
	NSString				*offerDeclineCmd;
	
	NSString				*info1;
	NSString				*info2;
	//NSString				*info3;
	
	// menus (only one of them is displayed)
	ChessInitialMenu		*initialMenuLayer;
	ChessGameMenu			*gameMenuLayer;
	
	// action sheets
	UIActionSheet			*offGameActionSheet;
	UIActionSheet			*inGameActionSheet;
}

// transitIn/transitOut
-(void)didTransitIn:(id)obj;
-(void)willTransitOut:(id)obj;

// initial menu presses handles
-(void)seekPressed;
-(void)matchPressed;
-(void)rematchPressed;
-(void)optionsPressed;

// game menu presses handles
-(void)offerDrawPressed;
-(void)resignPressed;
-(void)adjournPressed;
-(void)gameOptionsPressed;

// game start/end notifications
-(void)gameStarted:(NSDictionary*)params;
-(void)gameEnded:(NSDictionary*)params;

// chessboard manipulation
-(void)setOrientation:(BOOL)isWhiteOnBottom;
-(void)syncPosition:(NSString*)posStyle12 isAnimated:(BOOL)isAnimated;
-(void)movePiece:(NSDictionary*)data;
-(void)getMove:(NSArray*)validMoves;
-(void)clearAllMarks;
//-(void)rspPutPiece:(NSDictionary*)data;
//-(void)rspDropPiece:(NSDictionary*)data;
//-(void)rspShowMove:(NSDictionary*)data;

// chessboard callbacks
-(void)playerMove:(NSDictionary*)playerMove;
-(void)pieceMoved:(NSDictionary*)data;

// update time
-(void)updateTime:(NSDictionary*)time;

// update last move
-(void)showMove:(NSDictionary*)data;

// side to move
-(void)sideToMove:(NSDictionary*)data;

// top player info
-(void)setTopTime:(NSString*)time;
-(void)setTopName:(NSString*)name;
-(void)setTopMove:(NSString*)name;
-(void)setTopRating:(NSString*)rt;

// bottom player info
-(void)setBotTime:(NSString*)time;
-(void)setBotName:(NSString*)name;
-(void)setBotMove:(NSString*)name;
-(void)setBotRating:(NSString*)rt;

// info
-(void)clearInfo;
-(void)writeInfo:(NSString*)info;

// connect popup
-(void)connectPopupShow;
-(void)connectPopupSetText:(NSString*)txt;
-(void)connectPopupCancelled:(id)obj;
-(void)connectPopupDismiss;
-(void)connectPopupDelete;

// disconnected popup
-(void)disconnectedPopupShow:(NSString*)title;
-(void)disconnectedPopupCancel:(id)obj;
//-(void)disconnectedPopupDismiss;
-(void)disconnectedPopupDelete;

// challenge popup
-(void)challengePopupShow:(NSString*)title;
-(void)challengePopupAccept:(id)obj;
-(void)challengePopupDecline:(id)obj;
//-(void)challengePopupDismiss;
-(void)challengePopupDelete;

// confirm popup
-(void)confirmPopupShow:(NSString*)title command:(NSString*)cmd;
-(void)confirmPopupConfirm:(id)obj;
-(void)confirmPopupDecline:(id)obj;
//-(void)confirmPopupDismiss;
-(void)confirmPopupDelete;

// waitGame popup
-(void)waitGamePopupShow:(NSString*)title;
-(void)waitGamePopupCancel:(id)obj;
-(void)waitGamePopupDismiss;
-(void)waitGamePopupDelete;

// error popup
-(void)errorPopupShow:(NSString*)msg;
-(void)errorPopupButtonPressed:(id)obj;
-(void)errorPopupDelete;

// offer popup
-(void)offerPopupShow:(NSString*)msg accept:(NSString*)acc decline:(NSString*)decline;
-(void)offerPopupAccept:(id)obj;
-(void)offerPopupDecline:(id)obj;
-(void)offerPopupDelete;

// info popup
-(void)infoPopupShow:(NSString*)msg;
-(void)infoPopupDismiss:(id)obj;
-(void)infoPopupDelete;

// game result popup
-(void)gameResultPopupShowColor:(ccColorF)clr players:(NSString*)players result:(NSString*)res;
-(void)gameResultPopupOkPressed:(id)obj;
-(void)gameResultPopupRematchPressed:(id)obj;
//-(void)gameResultPopupDismiss;
-(void)gameResultPopupDelete;

// promotion popup
-(void)promoPopupShowPieceColor:(PieceColor)color;
-(void)promoPopupButtonPressed:(id)obj;
//-(void)promoPopupDismiss;
-(void)promoPopupDelete;

// seek popup
-(void)seekPopupShow;
-(void)seekPopupCancelPressed:(id)obj;
-(void)seekPopupSeekPressed:(id)obj;
-(void)seekPopupDelete;

// match popup
-(void)matchPopupShow;
-(void)matchPopupCancelPressed:(id)obj;
-(void)matchPopupMatchPressed:(id)obj;
-(void)matchPopupDelete;


@end
