/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2009 On-Core
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "TiledGridAction.h"
#import "Director.h"
#import "ccMacros.h"

typedef struct
{
	cpVect	position;
	cpVect	startPosition;
	ccGridSize	delta;
} Tile;


@implementation ShakyTiles3D

+(id)actionWithRange:(int)range shakeZ:(BOOL)shakeZ grid:(ccGridSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithRange:range shakeZ:shakeZ grid:gridSize duration:d] autorelease];
}

-(id)initWithRange:(int)range shakeZ:(BOOL)sz grid:(ccGridSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		randrange = range;
		shakeZ = sz;
	}
	
	return self;
}

-(void)update:(ccTime)time
{
	int i, j;
	
	for( i = 0; i < gridSize.x; i++ )
	{
		for( j = 0; j < gridSize.y; j++ )
		{
			ccQuad3 coords = [self originalTile:ccg(i,j)];

			// X
			coords.bl_x += ( rand() % (randrange*2) ) - randrange;
			coords.br_x += ( rand() % (randrange*2) ) - randrange;
			coords.tl_x += ( rand() % (randrange*2) ) - randrange;
			coords.tr_x += ( rand() % (randrange*2) ) - randrange;

			// Y
			coords.bl_y += ( rand() % (randrange*2) ) - randrange;
			coords.br_y += ( rand() % (randrange*2) ) - randrange;
			coords.tl_y += ( rand() % (randrange*2) ) - randrange;
			coords.tr_y += ( rand() % (randrange*2) ) - randrange;

			if( shakeZ ) {
				coords.bl_z += ( rand() % (randrange*2) ) - randrange;
				coords.br_z += ( rand() % (randrange*2) ) - randrange;
				coords.tl_z += ( rand() % (randrange*2) ) - randrange;
				coords.tr_z += ( rand() % (randrange*2) ) - randrange;
			}
						
			[self setTile:ccg(i,j) coords:coords];
		}
	}
}

@end

////////////////////////////////////////////////////////////

@implementation ShatteredTiles3D

+(id)actionWithRange:(int)range shatterZ:(BOOL)sz grid:(ccGridSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithRange:range shatterZ:sz grid:gridSize duration:d] autorelease];
}

-(id)initWithRange:(int)range shatterZ:(BOOL)sz grid:(ccGridSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		once = NO;
		randrange = range;
		shatterZ = sz;
	}
	
	return self;
}

-(void)update:(ccTime)time
{
	int i, j;
	
	if ( once == NO )
	{
		for( i = 0; i < gridSize.x; i++ )
		{
			for( j = 0; j < gridSize.y; j++ )
			{
				ccQuad3 coords = [self originalTile:ccg(i,j)];
				
				// X
				coords.bl_x += ( rand() % (randrange*2) ) - randrange;
				coords.br_x += ( rand() % (randrange*2) ) - randrange;
				coords.tl_x += ( rand() % (randrange*2) ) - randrange;
				coords.tr_x += ( rand() % (randrange*2) ) - randrange;
				
				// Y
				coords.bl_y += ( rand() % (randrange*2) ) - randrange;
				coords.br_y += ( rand() % (randrange*2) ) - randrange;
				coords.tl_y += ( rand() % (randrange*2) ) - randrange;
				coords.tr_y += ( rand() % (randrange*2) ) - randrange;

				if( shatterZ ) {
					coords.bl_z += ( rand() % (randrange*2) ) - randrange;
					coords.br_z += ( rand() % (randrange*2) ) - randrange;				
					coords.tl_z += ( rand() % (randrange*2) ) - randrange;
					coords.tr_z += ( rand() % (randrange*2) ) - randrange;
				}
				
				[self setTile:ccg(i,j) coords:coords];
			}
		}
		
		once = YES;
	}
}

@end

////////////////////////////////////////////////////////////

@implementation ShuffleTiles

+(id)actionWithSeed:(int)s grid:(ccGridSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithSeed:s grid:gridSize duration:d] autorelease];
}

-(id)initWithSeed:(int)s grid:(ccGridSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		seed = s;
		tilesOrder = nil;
		tiles = nil;
	}
	
	return self;
}

-(void)dealloc
{
	if ( tilesOrder ) free(tilesOrder);
	if ( tiles ) free(tiles);
	[super dealloc];
}

-(void)shuffle:(int*)array count:(int)len
{
	int i;
	for( i = len - 1; i >= 0; i-- )
	{
		int j = rand() % (i+1);
		int v = array[i];
		array[i] = array[j];
		array[j] = v;
	}
}

-(ccGridSize)getDelta:(ccGridSize)pos
{
	cpVect	pos2;
	
	int idx = pos.x * gridSize.y + pos.y;
	
	pos2.x = tilesOrder[idx] / (int)gridSize.y;
	pos2.y = tilesOrder[idx] % (int)gridSize.y;
	
	return ccg(pos2.x - pos.x, pos2.y - pos.y);
}

-(void)placeTile:(ccGridSize)pos tile:(Tile)t
{
	ccQuad3	coords = [self originalTile:pos];
	
	coords.bl_x += (int)(t.position.x * target.grid.step.x);
	coords.bl_y += (int)(t.position.y * target.grid.step.y);

	coords.br_x += (int)(t.position.x * target.grid.step.x);
	coords.br_y += (int)(t.position.y * target.grid.step.y);

	coords.tl_x += (int)(t.position.x * target.grid.step.x);
	coords.tl_y += (int)(t.position.y * target.grid.step.y);

	coords.tr_x += (int)(t.position.x * target.grid.step.x);
	coords.tr_y += (int)(t.position.y * target.grid.step.y);

	[self setTile:pos coords:coords];
}

-(void)start
{
	[super start];
	
	if ( seed != -1 )
		srand(seed);
	
	tilesCount = gridSize.x * gridSize.y;
	tilesOrder = (int*)malloc(tilesCount*sizeof(int));
	int i, j;
	
	for( i = 0; i < tilesCount; i++ )
		tilesOrder[i] = i;
	
	[self shuffle:tilesOrder count:tilesCount];
	
	tiles = malloc(tilesCount*sizeof(Tile));
	Tile *tileArray = (Tile*)tiles;
	
	for( i = 0; i < gridSize.x; i++ )
	{
		for( j = 0; j < gridSize.y; j++ )
		{
			tileArray->position = cpv(i,j);
			tileArray->startPosition = cpv(i,j);
			tileArray->delta = [self getDelta:ccg(i,j)];
			tileArray++;
		}
	}
}

-(void)update:(ccTime)time
{
	int i, j;
	
	Tile *tileArray = (Tile*)tiles;
	
	for( i = 0; i < gridSize.x; i++ )
	{
		for( j = 0; j < gridSize.y; j++ )
		{
			tileArray->position = cpvmult( cpv(tileArray->delta.x, tileArray->delta.y), time);
			[self placeTile:ccg(i,j) tile:*tileArray];
			tileArray++;
		}
	}
}

@end

////////////////////////////////////////////////////////////

@implementation FadeOutTRTiles

-(float)testFunc:(ccGridSize)pos time:(ccTime)time
{
	cpVect	n = cpvmult( cpv(gridSize.x,gridSize.y), time);
	if ( (n.x+n.y) == 0.0f )
		return 1.0f;
	return powf( (pos.x+pos.y) / (n.x+n.y), 6 );
}

-(void)turnOnTile:(ccGridSize)pos
{
	[self setTile:pos coords:[self originalTile:pos]];
}

-(void)turnOffTile:(ccGridSize)pos
{
	ccQuad3	coords;	
	bzero(&coords, sizeof(ccQuad3));
	[self setTile:pos coords:coords];
}

-(void)transformTile:(ccGridSize)pos distance:(float)distance
{
	ccQuad3	coords = [self originalTile:pos];
	
	coords.bl_x += (target.grid.step.x / 2) * (1.0f - distance);
	coords.bl_y += (target.grid.step.y / 2) * (1.0f - distance);

	coords.br_x -= (target.grid.step.x / 2) * (1.0f - distance);
	coords.br_y += (target.grid.step.y / 2) * (1.0f - distance);

	coords.tl_x += (target.grid.step.x / 2) * (1.0f - distance);
	coords.tl_y -= (target.grid.step.y / 2) * (1.0f - distance);

	coords.tr_x -= (target.grid.step.x / 2) * (1.0f - distance);
	coords.tr_y -= (target.grid.step.y / 2) * (1.0f - distance);

	[self setTile:pos coords:coords];
}

-(void)update:(ccTime)time
{
	int i, j;
	
	for( i = 0; i < gridSize.x; i++ )
	{
		for( j = 0; j < gridSize.y; j++ )
		{
			float distance = [self testFunc:ccg(i,j) time:time];
			if ( distance == 0 )
				[self turnOffTile:ccg(i,j)];
			else if ( distance < 1 )
				[self transformTile:ccg(i,j) distance:distance];
			else
				[self turnOnTile:ccg(i,j)];
		}
	}
}

@end

////////////////////////////////////////////////////////////

@implementation FadeOutBLTiles

-(float)testFunc:(ccGridSize)pos time:(ccTime)time
{
	cpVect	n = cpvmult(cpv(gridSize.x, gridSize.y), (1.0f-time));
	
	if ( (pos.x+pos.y) == 0 )
		return 1.0f;
	return powf( (n.x+n.y) / (pos.x+pos.y), 6 );
}

@end

////////////////////////////////////////////////////////////

@implementation FadeOutUpTiles

-(float)testFunc:(ccGridSize)pos time:(ccTime)time
{
	cpVect	n = cpvmult(cpv(gridSize.x, gridSize.y), time);
	if ( n.y == 0 )
		return 1.0f;
	return powf( pos.y / n.y, 6 );
}

-(void)transformTile:(ccGridSize)pos distance:(float)distance
{
	ccQuad3	coords = [self originalTile:pos];
	
	coords.bl_y += (target.grid.step.y / 2) * (1.0f - distance);
	coords.br_y += (target.grid.step.y / 2) * (1.0f - distance);
	coords.tl_y -= (target.grid.step.y / 2) * (1.0f - distance);
	coords.tr_y -= (target.grid.step.y / 2) * (1.0f - distance);
	
	[self setTile:pos coords:coords];
}

@end

////////////////////////////////////////////////////////////

@implementation FadeOutDownTiles

-(float)testFunc:(ccGridSize)pos time:(ccTime)time
{
	cpVect	n = cpvmult(cpv(gridSize.x,gridSize.y), (1.0f - time));
	if ( pos.y == 0 )
		return 1.0f;
	return powf( n.y / pos.y, 6 );
}

@end

////////////////////////////////////////////////////////////

@implementation TurnOffTiles

+(id)actionWithSeed:(int)s grid:(ccGridSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithSeed:s grid:gridSize duration:d] autorelease];
}

-(id)initWithSeed:(int)s grid:(ccGridSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		seed = s;
		tilesOrder = nil;
	}
	
	return self;
}

-(void)dealloc
{
	if ( tilesOrder ) free(tilesOrder);
	[super dealloc];
}

-(void)shuffle:(int*)array count:(int)len
{
	int i;
	for( i = len - 1; i >= 0; i-- )
	{
		int j = rand() % (i+1);
		int v = array[i];
		array[i] = array[j];
		array[j] = v;
	}
}

-(void)turnOnTile:(ccGridSize)pos
{
	[self setTile:pos coords:[self originalTile:pos]];
}

-(void)turnOffTile:(ccGridSize)pos
{
	ccQuad3	coords;
	
	bzero(&coords, sizeof(ccQuad3));
	[self setTile:pos coords:coords];
}

-(void)start
{
	int i;
	
	[super start];
	
	if ( seed != -1 )
		srand(seed);
	
	tilesCount = gridSize.x * gridSize.y;
	tilesOrder = (int*)malloc(tilesCount*sizeof(int));

	for( i = 0; i < tilesCount; i++ )
		tilesOrder[i] = i;
	
	[self shuffle:tilesOrder count:tilesCount];
}

-(void)update:(ccTime)time
{
	int i, l, t;
	
	l = (int)(time * (float)tilesCount);
	
	for( i = 0; i < tilesCount; i++ )
	{
		t = tilesOrder[i];
		ccGridSize tilePos = ccg( t / gridSize.y, t % gridSize.y );
		
		if ( i < l )
			[self turnOffTile:tilePos];
		else
			[self turnOnTile:tilePos];
	}
}

@end

////////////////////////////////////////////////////////////

@implementation WavesTiles3D

@synthesize amplitude;
@synthesize amplitudeRate;

+(id)actionWithWaves:(int)wav amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithWaves:wav amplitude:amp grid:gridSize duration:d] autorelease];
}

-(id)initWithWaves:(int)wav amplitude:(float)amp grid:(ccGridSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		waves = wav;
		amplitude = amp;
		amplitudeRate = 1.0f;
	}
	
	return self;
}

-(void)update:(ccTime)time
{
	int i, j;
	
	for( i = 0; i < gridSize.x; i++ )
	{
		for( j = 0; j < gridSize.y; j++ )
		{
			ccQuad3 coords = [self originalTile:ccg(i,j)];
			
			coords.bl_z = (sinf(time*(cpFloat)M_PI*waves*2 + (coords.bl_y+coords.bl_x) * .01f) * amplitude * amplitudeRate );
			coords.br_z	= coords.bl_z;
			coords.tl_z = coords.bl_z;
			coords.tr_z = coords.bl_z;
			
			[self setTile:ccg(i,j) coords:coords];
		}
	}
}
@end

////////////////////////////////////////////////////////////

@implementation JumpTiles3D

@synthesize amplitude;
@synthesize amplitudeRate;

+(id)actionWithJumps:(int)j amplitude:(float)amp grid:(ccGridSize)gridSize duration:(ccTime)d
{
	return [[[self alloc] initWithJumps:j amplitude:amp grid:gridSize duration:d] autorelease];
}

-(id)initWithJumps:(int)j amplitude:(float)amp grid:(ccGridSize)gSize duration:(ccTime)d
{
	if ( (self = [super initWithSize:gSize duration:d]) )
	{
		jumps = j;
		amplitude = amp;
		amplitudeRate = 1.0f;
	}
	
	return self;
}

-(void)update:(ccTime)time
{
	int i, j;
	
	float sinz =  (sinf((cpFloat)M_PI*time*jumps*2) * amplitude * amplitudeRate );
	float sinz2 = (sinf((cpFloat)M_PI*(time*jumps*2 + 1)) * amplitude * amplitudeRate );
	
	for( i = 0; i < gridSize.x; i++ )
	{
		for( j = 0; j < gridSize.y; j++ )
		{
			ccQuad3 coords = [self originalTile:ccg(i,j)];
			
			if ( ((i+j) % 2) == 0 )
			{
				coords.bl_z += sinz;
				coords.br_z += sinz;
				coords.tl_z += sinz;
				coords.tr_z += sinz;
			}
			else
			{
				coords.bl_z += sinz2;
				coords.br_z += sinz2;
				coords.tl_z += sinz2;
				coords.tr_z += sinz2;
			}
			
			[self setTile:ccg(i,j) coords:coords];
		}
	}
}
@end

////////////////////////////////////////////////////////////

@implementation SplitRows

+(id)actionWithRows:(int)r duration:(ccTime)d
{
	return [[[self alloc] initWithRows:r duration:d] autorelease];
}

-(id)initWithRows:(int)r duration:(ccTime)d
{
	return [super initWithSize:ccg(1,r) duration:d];
}

-(void)start
{
	[super start];
	winSize = [[Director sharedDirector] winSize];
}

-(void)update:(ccTime)time
{
	int j;
	
	for( j = 0; j < gridSize.y; j++ )
	{
		ccQuad3 coords = [self originalTile:ccg(0,j)];
		float	direction = 1;
		
		if ( (j % 2 ) == 0 )
			direction = -1;
		
		coords.bl_x += direction * winSize.width * time;
		coords.br_x += direction * winSize.width * time;
		coords.tl_x += direction * winSize.width * time;
		coords.tr_x += direction * winSize.width * time;
		
		[self setTile:ccg(0,j) coords:coords];
	}
}

@end

////////////////////////////////////////////////////////////

@implementation SplitCols

+(id)actionWithCols:(int)c duration:(ccTime)d
{
	return [[[self alloc] initWithCols:c duration:d] autorelease];
}

-(id)initWithCols:(int)c duration:(ccTime)d
{
	return [super initWithSize:ccg(c,1) duration:d];
}

-(void)start
{
	[super start];
	winSize = [[Director sharedDirector] winSize];
}

-(void)update:(ccTime)time
{
	int i;
	
	for( i = 0; i < gridSize.x; i++ )
	{
		ccQuad3 coords = [self originalTile:ccg(i,0)];
		float	direction = 1;
		
		if ( (i % 2 ) == 0 )
			direction = -1;
		
		coords.bl_y += direction * winSize.height * time;
		coords.br_y += direction * winSize.height * time;
		coords.tl_y += direction * winSize.height * time;
		coords.tr_y += direction * winSize.height * time;
		
		[self setTile:ccg(i,0) coords:coords];
	}
}

@end
