//
//  FICSSequncer.m
//  NetTest
//
//  Created by Anton Zemyanov on 28.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FICSSequencer.h"
#import "TCPConnection.h"
#import "Logger.h"

@implementation FICSSequencer

@synthesize delegate;
@synthesize connection;

// init object
- (id)init
{
    if (self = [super init] ) 
	{
		rxBuffer = [[FICSRingBuffer alloc] initWithSize:32768];
		txBuffer = [[FICSRingBuffer alloc] initWithSize:32768];
    }
    return self;
}

// dealloc object
- (void)dealloc 
{
	[txBuffer release];
	[rxBuffer release];
    [super dealloc];
}

// clear buffers
-(BOOL)clearBuffers
{
	[txBuffer clear];
	[rxBuffer clear];
	return YES;
}

//******************************************************************************
// TCPConnectionDelegate protocol
//******************************************************************************
-(void)TCPConnected:(NSDictionary*)data
{
	MsgLog(@"SEQ: TCPConnected");
	[self.delegate FICSSeqConnected:data];
}

-(void)TCPDisconnected:(NSDictionary*)data
{
	MsgLog(@"SEQ: TCPDisconnected");
	[self.delegate FICSSeqDisconnected:data];
}

// Tcp connection delegate
-(void)TCPHasBytesAvailable
{
	//NSLog(@"SEQ: TCPHasBytesAvailable");
	
	while(YES) 
	{
		NSMutableData *data = [NSMutableData dataWithCapacity:1024];
		if(![connection hasBytesAvailable])
			break;
		
		// Read data from TCP connection
		NSUInteger sz = [connection readData:data];
		
		// try to store rx data into buffer
		NSUInteger written = [rxBuffer writeBytesFrom:[data bytes] size:[data length]];
		if(written!=sz)
			[NSException raise:@"SEQError" format:@"Cannot write to RX buffer"];
		
	}
	
	// notify delegate, probably new line is available (if not, no problems)
	[[self delegate] FICSSeqNewDataAvailable];
	
	return;
}

-(void)TCPCanAcceptBytes
{
	UInt8 tmpBuff[512];
	
	//NSLog(@"SEQ: TCPCanAcceptBytes");
	
	while(YES)
	{
		if(![connection canAcceptBytes])
			break;
		
		// lock the TX queue
		[txBuffer lock];
		NSUInteger peekBytes = [txBuffer peekBytesTo:tmpBuff maxNumber:512];
		if(peekBytes==0)
		{
			[txBuffer unlock];
			break;
		}
		
		NSMutableData *data = [NSMutableData dataWithBytes:tmpBuff length:peekBytes];
		NSUInteger written=[connection writeData:data];
		if(written>0)
		{
			[txBuffer readBytesTo:tmpBuff maxNumber:written];
		}
		[txBuffer unlock];
	}
	
	return;
}

// Read line (completed lines are removed, while not completed - does not)
-(NSString*)readLine
{
	NSMutableString *str = [NSMutableString string];
	UInt8 tmpBuff[512];
	UInt8 tmpBuff2[512];

	[rxBuffer lock];
	memset(tmpBuff, 0, sizeof(tmpBuff));
	NSUInteger peekBytes = [rxBuffer peekBytesTo:tmpBuff maxNumber:512];
	if(peekBytes==0)
	{
		[rxBuffer unlock];
		return str;
	}
	// scan peeked data
	Boolean fullLineFound=NO;
	NSUInteger bytesRead = 0;
	for(int cnt=0; cnt<peekBytes; ++cnt)
	{
		if(tmpBuff[cnt]=='\r' || tmpBuff[cnt]=='\n')
		{
			fullLineFound = YES;
		}
		else
		{
			//non EOL char and fullLine found already YES
			if(fullLineFound)
			{
				// terminate string
				tmpBuff[cnt] = '\0';
				break;
			}
		}
		++bytesRead;
	}
	if(fullLineFound && bytesRead>0)
	{
		[rxBuffer readBytesTo:tmpBuff2 maxNumber:bytesRead];
	}
	[rxBuffer unlock];
	
	// return value appen
	[str appendFormat:@"%s", tmpBuff];
	
	// Test there are RX data pending, if yes, force reading next data
	if([connection hasBytesAvailable])
		[self TCPHasBytesAvailable];
	
	// Log the line just read
	NSString *tmpStr = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
	NSString *tmpStr2 = [tmpStr stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
	NetLog(@"<-%@",tmpStr2);
	
	return str;
}

-(BOOL)writeLine:(NSString*)line
{
	// Log the line that is about to be sent
	NSString *s1 = [line stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
	NSString *s2 = [s1 stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
	if([s2 length]>0)
		NetLog(@"->%@",s2);
	
	// Put to tx buffer
	NSUInteger written = [txBuffer writeBytesFrom:(UInt8*)[line UTF8String] size:[line length]];
	if(written != [line length])
	{
		[NSException raise:@"SEQError" format:@"Tx buffer full"];
	}
	
	if([connection canAcceptBytes])
		[self TCPCanAcceptBytes];
	
	return YES;
}

@end
