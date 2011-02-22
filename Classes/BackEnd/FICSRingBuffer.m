//
//  FICSRingBuffer.m
//  NetTest
//
//  Created by Anton Zemyanov on 29.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FICSRingBuffer.h"


@implementation FICSRingBuffer

@synthesize size;
@synthesize usedBytes;
@synthesize freeBytes;

- (id)initWithSize:(NSUInteger)sz
{
    if (self = [super init] ) 
	{
		buffer = malloc(sz);
		if(buffer==NULL)
		{
			[super release];
			return nil;
		}
		size = sz;
		freeBytes = sz;
		usedBytes = 0;
		head = 0;
		tail = 0;
		lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

- (void)dealloc 
{
	if(buffer)
		free(buffer);
    [super dealloc];
}

// clear buffer
-(BOOL)clear
{
	[lock lock];
	freeBytes = size;
	usedBytes = 0;
	head = 0;
	tail = 0;
	[lock unlock];
	return YES;
}

// manual lock mode to ensure sequetial peek/read to work as a single operation
-(void)lock
{
	[lock lock];
}

-(void)unlock
{
	[lock unlock];
}

// reading data
-(NSUInteger)peekBytesTo:(UInt8*)buff maxNumber:(NSUInteger)max
{
	NSUInteger tmpHead = head;

	NSUInteger bytesPeeked = max;
	[lock lock];
	if(usedBytes==0)
	{
		[lock unlock];
		return 0;
	}
	
	if( bytesPeeked > usedBytes )
		bytesPeeked = usedBytes;
	
	UInt8 *dataPtr = buff;
	for(int cnt=0; cnt<bytesPeeked; ++cnt)
	{
		*dataPtr++ = buffer[tmpHead];
		++tmpHead;
		if(tmpHead>=size)
			tmpHead=0;
	}
	[lock unlock];
	return bytesPeeked;
}

-(NSUInteger)readBytesTo:(UInt8*)buff maxNumber:(NSUInteger)max
{
	NSUInteger bytesRead = max;
	[lock lock];
	if(usedBytes==0)
	{
		[lock unlock];
		return 0;
	}
	
	if( bytesRead > usedBytes )
		bytesRead = usedBytes;
	
	UInt8 *dataPtr = buff;
	for(int cnt=0; cnt<bytesRead; ++cnt)
	{
		*dataPtr++ = buffer[head];
		++head;
		if(head>=size)
			head=0;
		--usedBytes;
		++freeBytes;
	}
	[lock unlock];
	return bytesRead;
}

// writing data
-(NSUInteger)writeBytesFrom:(const UInt8*)buff size:(NSUInteger)sz
{
	NSUInteger bytesWritten = sz;

	[lock lock];
	if( sz == 0 )
	{
		//[NSException raise:@"RingBufferError" format:@"Invalid Size"];
		[lock unlock];
		return 0;
	}
	
	if( bytesWritten > freeBytes )
		bytesWritten = freeBytes;

	const UInt8 *dataPtr = buff;
	for(int cnt=0; cnt<bytesWritten; ++cnt)
	{
		buffer[tail] = *dataPtr++;
		++tail;
		if( tail >= size )
			tail = 0;
		++usedBytes;
		--freeBytes;
	}	
	[lock unlock];
	
	return bytesWritten;
}


@end
