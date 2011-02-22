//
//  FICSRingBuffer.h
//  NetTest
//
//  Created by Anton Zemyanov on 29.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface FICSRingBuffer : NSObject {
	// Buffer
	UInt8 	   *buffer;
	NSUInteger size;
	NSUInteger head;
	NSUInteger tail;
	NSUInteger usedBytes;
	NSUInteger freeBytes;
	NSRecursiveLock *lock;
}

@property (nonatomic, readonly) NSUInteger size;
@property (nonatomic, readonly) NSUInteger usedBytes;
@property (nonatomic, readonly) NSUInteger freeBytes;

-(id)initWithSize:(NSUInteger)sz;

// clear buffer
-(BOOL)clear;

// manual lock mode to ensure sequetial peek/read to work as a single operation
-(void)lock;
-(void)unlock;

// reading data
-(NSUInteger)peekBytesTo:(UInt8*)buff maxNumber:(NSUInteger)max;
-(NSUInteger)readBytesTo:(UInt8*)buff maxNumber:(NSUInteger)max;

// writing data
-(NSUInteger)writeBytesFrom:(const UInt8*)buff size:(NSUInteger)sz;

@end
