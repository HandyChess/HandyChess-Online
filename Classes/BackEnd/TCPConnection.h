//
//  TCPConnection.h
//  NetTest
//
//  Created by Anton Zemyanov on 28.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol TCPConnectionDelegate
-(void)TCPConnected:(NSDictionary*)data;
-(void)TCPDisconnected:(NSDictionary*)data;
-(void)TCPHasBytesAvailable;
-(void)TCPCanAcceptBytes;
@end


@interface TCPConnection : NSObject 
{
	// TCP connection client (delegate)
	id<TCPConnectionDelegate>	delegate;
	
	CFReadStreamRef		readStream;
	CFWriteStreamRef	writeStream;
	
	BOOL readOpen;
	BOOL writeOpen;
}

@property(nonatomic, assign) id<TCPConnectionDelegate> delegate;
@property(assign)			 BOOL readOpen;
@property(assign)			 BOOL writeOpen;


-(BOOL)connectToHost:(NSString*)host andPort:(NSUInteger)port;
-(BOOL)disconnect;

-(BOOL)canAcceptBytes;
-(NSUInteger)writeData:(NSMutableData*)data;

-(BOOL)hasBytesAvailable;
-(NSUInteger)readData:(NSMutableData*)data;

@end
