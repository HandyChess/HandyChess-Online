//
//  TCPConnection.m
//  NetTest
//
//  Created by Anton Zemyanov on 28.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Logger.h"
#import "TCPConnection.h"
#import <Foundation/Foundation.h>

static void CFReadStreamCallBack(CFReadStreamRef stream, CFStreamEventType type, void *info)
{
	//MsgLog(@"CFReadStreamCallBack type=%x",type);
	TCPConnection *conn = (TCPConnection*)info;
	switch (type) {
		case kCFStreamEventOpenCompleted:
			MsgLog(@"TCP Read kCFStreamEventOpenCompleted");
			conn.readOpen=YES;
			if(conn.readOpen && conn.writeOpen)
			{
				[conn.delegate TCPConnected:nil];
			}
			break;
		case kCFStreamEventHasBytesAvailable:
			//MsgLog(@"TCP Read kCFStreamEventHasBytesAvailable");
			[conn.delegate TCPHasBytesAvailable];
			break;
		case kCFStreamEventCanAcceptBytes:
			//MsgLog(@"TCP Read kCFStreamEventCanAcceptBytes");
			break;
		case kCFStreamEventErrorOccurred:
		{
			MsgLog(@"TCP Read kCFStreamEventErrorOccurred");
			conn.readOpen = NO;
			CFErrorRef err = CFReadStreamCopyError(stream);
			CFStringRef errDomain = CFErrorGetDomain(err);
			CFStringRef errDesc = CFErrorCopyDescription(err);
			CFIndex errCode = CFErrorGetCode(err);
			NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"RX",@"Channel",
								  errDesc, @"Description",
								  errDomain,@"Domain",
								  [NSString stringWithFormat:@"%d",errCode],@"Code", 
								  nil];
			CFRelease(err);
			CFRelease(errDesc);
			[conn.delegate TCPDisconnected:data];
			break;
		}
		case kCFStreamEventEndEncountered:
		{
			MsgLog(@"TCP Read kCFStreamEventEndEncountered");
			conn.readOpen = NO;
			NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"RX",@"Channel",
								  @"Remote server closed connection",@"Reason",
								  nil];
			[conn.delegate TCPDisconnected:data];
			break;
		}
		default:
			break;
	}
	return;
}

static void CFWriteStreamCallBack(CFWriteStreamRef stream, CFStreamEventType type, void *info)
{
	//MsgLog(@"CFWriteStreamCallBack type=%x",type);
	TCPConnection *conn = (TCPConnection*)info;
	switch (type) {
		case kCFStreamEventOpenCompleted:
			MsgLog(@"TCP Write kCFStreamEventOpenCompleted");
			conn.writeOpen = YES;
			if(conn.readOpen && conn.writeOpen)
			{
				[conn.delegate TCPConnected:nil];
			}
			break;
		case kCFStreamEventHasBytesAvailable:
			//MsgLog(@"TCP Write kCFStreamEventHasBytesAvailable");
			break;
		case kCFStreamEventCanAcceptBytes:
			//MsgLog(@"TCP Write kCFStreamEventCanAcceptBytes");
			[conn.delegate TCPCanAcceptBytes];
			break;
		case kCFStreamEventErrorOccurred:
		{
			MsgLog(@"TCP Write kCFStreamEventErrorOccurred");
			conn.writeOpen = NO;
			CFErrorRef err = CFWriteStreamCopyError(stream);
			CFStringRef errDomain = CFErrorGetDomain(err);
			CFStringRef errDesc = CFErrorCopyDescription(err);
			CFIndex errCode = CFErrorGetCode(err);
			NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"TX",@"Channel",
								  errDesc, @"Description",
								  errDomain,@"Domain",
								  [NSString stringWithFormat:@"%d",errCode],@"Code", 
								  nil];
			CFRelease(err);
			CFRelease(errDesc);
			[conn.delegate TCPDisconnected:data];
			break;
		}
		case kCFStreamEventEndEncountered:
		{
			MsgLog(@"TCP Write kCFStreamEventEndEncountered");
			conn.writeOpen = NO;
			NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"TX",@"Channel",
								  @"Application closed connection",@"Reason",
								  nil];
			[conn.delegate TCPDisconnected:data];
			break;
		}
		default:
			break;
	}
	return;
}

@implementation TCPConnection

@synthesize delegate;
@synthesize readOpen;
@synthesize writeOpen;

- (id)init
{
    if (self = [super init] ) 
	{
        // Custom initialization
		readOpen = NO;
		writeOpen = NO;
    }
    return self;
}

- (void)dealloc 
{
    [super dealloc];
}

-(BOOL)connectToHost:(NSString*)host andPort:(NSUInteger)port
{
	MsgLog(@"TCP enter connect");

	// Create streams
	CFStringRef str = CFStringCreateWithCString(NULL, [host UTF8String], kCFStringEncodingUTF8);
	CFStreamCreatePairWithSocketToHost(NULL, str, port, &readStream, &writeStream);
	if(readStream==NULL || writeStream==NULL)
		return NO;

	// connect streams
	Boolean readStatus  = CFReadStreamOpen(readStream);
	Boolean writeStatus = CFWriteStreamOpen(writeStream);
	if(readStatus==NO || writeStatus==NO)
		return NO;
	
	// Read callback
	Boolean res;
	CFStreamClientContext readCtx = {0, self, NULL, NULL, NULL};
	res = CFReadStreamSetClient(readStream, 
						  kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable | kCFStreamEventCanAcceptBytes |
						  kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered, 
						  CFReadStreamCallBack, &readCtx);
	if(!res)
		return NO;

	// Write callback
	CFStreamClientContext writeCtx = {0, self, NULL, NULL, NULL};
	res = CFWriteStreamSetClient(writeStream, 
								kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable | kCFStreamEventCanAcceptBytes |
								kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered, 
								CFWriteStreamCallBack, &writeCtx);
	if(!res)
		return NO;
	
	// schesule read
	CFReadStreamScheduleWithRunLoop(readStream, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopCommonModes);

	// schesule write
	CFWriteStreamScheduleWithRunLoop(writeStream, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopCommonModes);
	
	MsgLog(@"TCP quit connect");
	
	return YES;
}

-(BOOL)disconnect
{
	CFReadStreamClose(readStream);
	CFWriteStreamClose(writeStream);
	return YES;
}

-(BOOL)canAcceptBytes
{
	if(CFWriteStreamCanAcceptBytes(writeStream))
		return YES;
	return NO;
}

-(NSUInteger)writeData:(NSMutableData*)data
{
	if(!CFWriteStreamCanAcceptBytes(writeStream))
	{
		//[NSException raise:@"TCP" format:@"writeData when stream cannot accept data"];
		return 0;
	}
	CFIndex bytesWritten = CFWriteStreamWrite(writeStream, [data bytes], [data length]);
	if(bytesWritten==-1)
		[NSException raise:@"TCP" format:@"error writing to stream"];
	
	//MsgLog(@"TCP: written %d bytes", bytesWritten);
	return bytesWritten;
}

-(BOOL)hasBytesAvailable
{
	if(CFReadStreamHasBytesAvailable(readStream))
		return YES;
	return NO;
}

-(NSUInteger)readData:(NSMutableData*)data
{
	UInt8 buff[512];
	
	if(!CFReadStreamHasBytesAvailable(readStream))
	{
		//[NSException raise:@"TCP" format:@"readData when no data available"];
		return 0;
	}
	CFIndex bytesRead = CFReadStreamRead(readStream, buff, 512);
	if(bytesRead==-1)
		[NSException raise:@"TCP" format:@"error reading stream"];
		
	if(bytesRead>0)
		[data appendBytes:buff length:bytesRead];
	
	//MsgLog(@"TCP: read %d bytes", bytesRead);
	return bytesRead;
}


@end
