/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "TextureAtlas.h"
#import "CocosNode.h"

/** AtlasNode is a subclass of CocosNode that implements CocosNodeOpacity, CocosNodeRGB and
 CocosNodeSize protocols.
 
 It knows how to render a TextureAtlas object.
 
 All features from CocosNode are valid, plus the following features:
 - opacity
 - color (setRGB:::)
 - contentSize
 */
@interface AtlasNode : CocosNode <CocosNodeOpacity, CocosNodeRGB, CocosNodeSize> {
	
	/// texture atlas
	TextureAtlas	*textureAtlas;
	/// chars per row
	int				itemsPerRow;
	/// chars per column
	int				itemsPerColumn;
	
	/// texture coordinate x increment
	float			texStepX;
	/// texture coordinate y increment
	float			texStepY;
	
	/// width of each char
	int				itemWidth;
	/// height of each char
	int				itemHeight;
	
	/// texture opacity
	GLubyte opacity;
	
	/// texture color
	GLubyte	r,g,b;
	
}

/// Conforms to CocosNodeOpacity and CocosNodeRGB protocol
@property (readwrite,assign) GLubyte opacity, r, g, b;


/** creates an AtlasNode  with an Atlas file the width and height of each item and the quantity of items to render*/
+(id) atlasWithTileFile:(NSString*)tile tileWidth:(int)w tileHeight:(int)h itemsToRender: (int) c;

/** initializes an AtlasNode  with an Atlas file the width and height of each item and the quantity of items to render*/
-(id) initWithTileFile:(NSString*)tile tileWidth:(int)w tileHeight:(int)h itemsToRender: (int) c;

/** updates the Atlas (indexed vertex array).
 * Shall be overriden in subclasses
 */
-(void) updateAtlasValues;
@end
