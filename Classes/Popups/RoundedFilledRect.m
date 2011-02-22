//
//  RoundedFilledRect.m
//  HandyChess
//
//  Created by Anton Zemlyanov on 1/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RoundedFilledRect.h"

#define RECT_LINE_WIDTH	2

// Private category
@interface RoundedFilledRect (Private)
-(UIImage*)makeRoundedRect;
-(void)makePathContext:(CGContextRef)ctx leftBottom:(CGPoint)p1 rightTop:(CGPoint)p2 raduis:(CGFloat)rad;
@end


@implementation RoundedFilledRect

+(id)rectWithSize:(CGSize)sz radius:(CGFloat)rad strokeColor:(ccColorF)stroke fillColor:(ccColorF)fill
{
	return [[[self alloc] initWithSize:sz radius:rad strokeColor:stroke fillColor:fill] autorelease];
}

-(id)initWithSize:(CGSize)sz radius:(CGFloat)rad strokeColor:(ccColorF)str fillColor:(ccColorF)fill
{
	if(self = [super init])
	{
		// cache data
		rectSize = sz;
		roundRadius = rad;
		strokeColor = str;
		fillColor = fill;
		
		// make the image
		UIImage *img = [self makeRoundedRect];
		self.texture = [[Texture2D alloc] initWithImage:img];
		
		self.transformAnchor = cpv(sz.width/2.0f, sz.height/2.0f);
	}
	return self;
}

-(void)dealloc
{
	[self.texture release];
	[super dealloc];
}

// rounded filled rectangle image
-(UIImage*)makeRoundedRect
{
	// Create color space and context
	float width  = rectSize.width;
	float height = rectSize.height;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	//CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
	CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8/*bpp*/, width*4, colorSpace, kCGImageAlphaPremultipliedLast);
	if(ctx==NULL)
		[NSException raise:@"RRT" format:@"Cant create image context"];

	CGGradientRef myGradient;
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8] = { fillColor.r, fillColor.g, fillColor.b, fillColor.a,  // Start color
							  fillColor.r*0.5, fillColor.g*0.5, fillColor.b*0.5, fillColor.a}; // End color
	myGradient = CGGradientCreateWithColorComponents (colorSpace, components,
													  locations, num_locations);		
	
	// Context setup
	CGContextSetRGBStrokeColor(ctx, strokeColor.r, strokeColor.g, strokeColor.b, strokeColor.a);
	CGContextSetRGBFillColor(ctx, fillColor.r, fillColor.g, fillColor.b, fillColor.a);
	CGContextSetLineWidth(ctx, RECT_LINE_WIDTH);
	
	// Create and fill path
	CGFloat radius = roundRadius;
	CGFloat off = RECT_LINE_WIDTH+1;

	// rect shadow
	//CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 0.1);
	//CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 0.1);
	//[self makePathContext:ctx leftBottom:CGPointMake(off+2,off-2) rightTop:CGPointMake(width-off+2, height-off-2) raduis:radius];
	//CGContextDrawPath(ctx, kCGPathFillStroke);
	
	// rect gradient
	[self makePathContext:ctx leftBottom:CGPointMake(off,off) rightTop:CGPointMake(width-off, height-off) raduis:radius];
	CGContextSaveGState(ctx);
	CGContextClip(ctx);
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = 0.0;
	myStartPoint.y = height;
	myEndPoint.x = 0.0;
	myEndPoint.y = 0.0;
	CGContextDrawLinearGradient (ctx, myGradient, myStartPoint, myEndPoint, 0);	
	CGContextRestoreGState(ctx);
	
	// rect rounded box
	CGContextSetRGBStrokeColor(ctx, strokeColor.r, strokeColor.g, strokeColor.b, strokeColor.a);
	CGContextSetRGBFillColor(ctx, fillColor.r, fillColor.g, fillColor.b, fillColor.a);
	[self makePathContext:ctx leftBottom:CGPointMake(off,off) rightTop:CGPointMake(width-off, height-off) raduis:radius];
	CGContextDrawPath(ctx, kCGPathStroke);
	
	// create an image from context
	CGImageRef imgRef = CGBitmapContextCreateImage(ctx);
	UIImage *img = [UIImage imageWithCGImage:imgRef];
	CGImageRelease(imgRef);
	
	// release context
	CGColorSpaceRelease(colorSpace);
	CGContextRelease(ctx);
	
	return img;
}

-(void)makePathContext:(CGContextRef)ctx leftBottom:(CGPoint)p1 rightTop:(CGPoint)p2 raduis:(CGFloat)radius;
{
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddArc(path, NULL, p1.x+radius, p1.y+radius, radius, 3*M_PI/2, M_PI, 1);
	CGPathAddLineToPoint(path, NULL, p1.x, p2.y-radius);
	CGPathAddArc(path, NULL, p1.x+radius, p2.y-radius, radius, M_PI, M_PI/2, 1);
	CGPathAddLineToPoint(path, NULL, p2.x-radius, p2.y);
	CGPathAddArc(path, NULL, p2.x-radius, p2.y-radius, radius, M_PI/2, 0, 1);
	CGPathAddLineToPoint(path, NULL, p2.x, p1.y+radius);
	CGPathAddArc(path, NULL, p2.x-radius, p1.y+radius, radius,0, 3*M_PI/2, 1);
	CGPathCloseSubpath(path);
	CGContextAddPath(ctx, path);
	CGPathRelease(path);
}

@end
