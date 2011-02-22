//
//  FICSSequncer.h
//  NetTest
//
//  Created by Anton Zemyanov on 28.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPConnection.h"
#import "FICSRingBuffer.h"

#define FICS_SEQ_TX_SIZE	32768
#define FICS_SEQ_RX_SIZE	32768

@protocol FICSSequencerDelegate
-(void)FICSSeqConnected:(NSDictionary*)data;
-(void)FICSSeqDisconnected:(NSDictionary*)data;
-(void)FICSSeqNewDataAvailable;
-(void)FICSSeqError:(NSString*)error;
@end

@interface FICSSequencer : NSObject <TCPConnectionDelegate>
{
	id<FICSSequencerDelegate> delegate;
	TCPConnection *connection;
	
	// Ring buffers
	FICSRingBuffer  *rxBuffer;
	FICSRingBuffer  *txBuffer;
}

@property (nonatomic, assign) id<FICSSequencerDelegate> delegate;
@property (nonatomic, retain) TCPConnection *connection;

// clear buffers
-(BOOL)clearBuffers;

// Read line (completed lines are removed, while not completed - does not)
-(NSString*)readLine;
-(BOOL)writeLine:(NSString*)line;

@end
