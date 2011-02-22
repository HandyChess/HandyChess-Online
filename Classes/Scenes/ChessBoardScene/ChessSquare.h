//
//  ChessSquare.h
//  HandyChess
//
//  Created by Anton Zemyanov on 17.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CB_COL_NUMBER	8
#define CB_ROW_NUMBER	8

#define CB_COL_INV	(-1)
#define CB_COL_A	0
#define CB_COL_B	1
#define CB_COL_C	2
#define CB_COL_D	3
#define CB_COL_E	4
#define CB_COL_F	5
#define CB_COL_G	6
#define CB_COL_H	7

#define CB_ROW_INV	(-1)
#define CB_ROW_1	0
#define CB_ROW_2	1
#define CB_ROW_3	2
#define CB_ROW_4	3
#define CB_ROW_5	4
#define CB_ROW_6	5
#define CB_ROW_7	6
#define CB_ROW_8	7

@interface ChessSquare : NSObject <NSCopying>
{
	SInt8 col;
	SInt8 row;
}

@property (readonly) SInt8 col;
@property (readonly) SInt8 row;

+(id)squareWithCol:(SInt8)col row:(SInt8)row;
+(id)squareWithTextNotation:(NSString*)txt;

-(id)initWithCol:(SInt8)col row:(SInt8)row;
-(id)initWithTextNotation:(NSString*)txt;

-(BOOL)isOnBoard;

-(NSString*)description;
@end
