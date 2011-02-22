//
//  Polyglot.h
//  HandyChess
//
//  Created by Anton Zemyanov on 18.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Polyglot : NSObject {
	
}

-(NSArray*)legalMovesForPosition:(NSDictionary*)style12Data;
/*
-(BOOL)isCaptureMove:(NSString*)move;
-(BOOL)isPromoteMove:(NSString*)move;
-(BOOL)isEnPassantMove:(NSString*)move;
-(BOOL)isCastleMove:(NSString*)move;
*/
@end
