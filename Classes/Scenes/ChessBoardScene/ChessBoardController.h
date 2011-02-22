//
//  ChessBoardController.h
//  HandyChess
//
//  Created by Anton Zemyanov on 27.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ChessBackEnd.h";

@class ChessBoardScene;
@class ChessBoardLayer;

typedef enum tagCBEnum {
	CBStateUninitialized	= 0x00,
	CBStateConnecting		= 0x01,
	CBStateNotInGame		= 0x02,
	CBStateSeeking  		= 0x03,
	CBStateMatchOffered		= 0x04,
	CBStateDisconnecting	= 0x05,
	CBStateDisconnected		= 0x06,
	CBStateError			= 0xFF
} 
CBState;

@interface ChessBoardController : NSObject <BackEndMessages,BackEndResponses>
{
	BOOL			isConnected;
	BOOL			isRegistred;
	CBState			state;
	ChessBoardScene	*scene;
	//ChessBoardLayer	*chessBoard;
	
	NSMutableString	*realLogin;
	
	ChessBackEnd	*backEnd;
}

@property (readonly) BOOL	    isConnected;
@property (readonly) BOOL	    isRegistred;
@property (readonly) CBState	state;
@property (nonatomic, assign)  ChessBoardScene	*scene;

-(BOOL)startBackend;
-(BOOL)stopBackend;

-(BOOL)connect;
-(BOOL)disconnect;

@end
