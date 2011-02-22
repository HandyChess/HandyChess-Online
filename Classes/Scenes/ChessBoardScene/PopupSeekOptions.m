//
//  PopupSeekOptions.m
//  HandyChess
//
//  Created by Anton on 4/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PopupSeekOptions.h"
#import "Logger.h"
#import "SoundEngine.h"
#import "RoundedFilledRect.h"

#import "PickerController.h"

#define POPUP_COLOR_FRAME			{0.1, 0.1, 0.1, 1.0};
#define POPUP_COLOR_BACKGROUND		{0.94, 0.95, 0.9, 0.99};
#define FRAME_ROUNDING_RADIUS	20

@interface PopupSeekOptions (Private)
-(void)initGameTime;
-(void)initGameInc;
-(void)initPieceColor;
-(void)initRateType;
-(void)initRateValue;
-(void)initUnregState;
-(void)cancelPressed:(id)obj;
-(void)seekPressed:(id)obj;
-(void)pieceColorPressed:(id)obj;
-(void)rateTypePressed:(id)obj;
-(void)checkboxPressed:(id)obj;
@end

@implementation PopupSeekOptions

@synthesize picker;
@synthesize onSeek;
@synthesize onCancel;

+(id)popupWithRegisteredStatus:(BOOL)isReg
{
	return [[[self alloc] initWithRegisteredStatus:isReg] autorelease];
}

-(id)initWithRegisteredStatus:(BOOL)isReg
{
	if( self = [super init] )
	{
		opacity = 255;
		//self.isTouchEnabled = YES;
		
		// Registred player status
		isRegistred = isReg;
		
		// Seek params
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		seekParams = [[NSMutableDictionary alloc] initWithDictionary:[defs objectForKey:@"SeekParams"]];
		times   = [[NSArray alloc] initWithArray:[defs objectForKey:@"Times"]];
		incs    = [[NSArray alloc] initWithArray:[defs objectForKey:@"Increments"]];
		ratings = [[NSArray alloc] initWithArray:[defs objectForKey:@"Ratings"]];
		
		// Title 
		CGSize sz = CGSizeMake(300,26);
		title = [Label labelWithString:@"Seek for an Opponent" dimensions:sz alignment:UITextAlignmentCenter
							  fontName:@"Arial-BoldMT" fontSize:24];
		[title setRGB:0 :0 :0];
		title.position = cpv(0,216);
		[self addChild:title];
		
		[self initGameTime];
		[self initGameInc];
		[self initPieceColor];
		[self initRateType];
		[self initRateValue];
		[self initUnregState];
		
		// menu buttons
		MenuItemImage *cancel = [MenuItemImage itemFromNormalImage:@"button_cancel_100px_normal.png" 
													 selectedImage:@"button_cancel_100px_pressed.png"
															target:self
														  selector:@selector(cancelPressed:)];
		MenuItemImage *seek =[MenuItemImage itemFromNormalImage:@"button_seek_100px_normal.png" 
												  selectedImage:@"button_seek_100px_pressed.png"
														 target:self
													   selector:@selector(seekPressed:)];
		cancel.position = cpv(56,-205);
		seek.position = cpv(-56,-205);
		menu = [Menu menuWithItems:gameTimeMinButton,gameTimeMaxButton,
				gameIncMinButton,gameIncMaxButton, pieceColorAny,pieceColorWhite,pieceColorBlack,
				rateTypeAny, rateTypeRated, rateTypeUnrated, rateValMinButton,rateValMaxButton,
				checkBox, cancel,seek,nil];
		menu.position = cpv(0,0);
		[self addChild:menu];
		
		// message box frame and aligner
		ccColorF frCol = POPUP_COLOR_FRAME;
		ccColorF bgCol = POPUP_COLOR_BACKGROUND;
		roundedRect = [RoundedFilledRect rectWithSize:CGSizeMake(310,470) radius:FRAME_ROUNDING_RADIUS 
										  strokeColor:frCol fillColor:bgCol];
		//roundedRect.position = cpv(160,240);
		[self addChild:roundedRect z:-1];
		
		// if unregistred player, some special settings are forced
		[self enableRateType:YES];
		[self enableRateValue:YES];
		[self enableAllowUnregistred:YES];
		
		if([[seekParams objectForKey:@"SeekAllowUnregistred"] intValue])
		{
			[seekParams setObject:@"2" forKey:@"SeekRatingType"];
			[self enableRateType:NO];
			[self enableRateValue:NO];
			[defs setObject:seekParams forKey:@"SeekParams"];
		}
		
		if(!isRegistred)
		{
			[seekParams setObject:@"2" forKey:@"SeekRatingType"];
			[seekParams setObject:@"1" forKey:@"SeekAllowUnregistred"];
			[self enableRateType:NO];
			[self enableRateValue:NO];
			[self enableAllowUnregistred:NO];
			[defs setObject:seekParams forKey:@"SeekParams"];
		}
		
		// set default values
		[self setTimeMin:		[seekParams objectForKey:@"SeekTimeMin"]];
		[self setTimeMax:		[seekParams objectForKey:@"SeekTimeMax"]];
		[self setIncMin:		[seekParams objectForKey:@"SeekIncMin"]];
		[self setIncMax:		[seekParams objectForKey:@"SeekIncMax"]];
		[self setPieceColor:	[seekParams objectForKey:@"SeekPieceColor"]];
		[self setRatingType:	[seekParams objectForKey:@"SeekRatingType"]];
		[self setRatingMin:		[seekParams objectForKey:@"SeekRatingMin"]];
		[self setRatingMax:		[seekParams objectForKey:@"SeekRatingMax"]];
		[self setAllowUnregistred:[seekParams objectForKey:@"SeekAllowUnregistred"]];
		
	}
	return self;
}

-(void)dealloc
{
	[ratings release];
	[incs release];
	[times release];
	[seekParams release];
	[super dealloc];
}

-(void)initGameTime
{
	CGFloat firstY = 182;
	CGFloat secondY = 152;
	
	// Game time
	CGSize sz = CGSizeMake(300,26);
	gameTime = [Label labelWithString:@"Game Time (time for all moves):" dimensions:sz alignment:UITextAlignmentCenter
							 fontName:@"ArialMT" fontSize:18];
	[gameTime setRGB:0 :0 :0];
	gameTime.position = cpv(0,firstY);
	[self addChild:gameTime];
	
	sz = CGSizeMake(54,26);
	gameTimeFrom = [Label labelWithString:@"From:" dimensions:sz alignment:UITextAlignmentRight
								 fontName:@"ArialMT" fontSize:18];
	[gameTimeFrom setRGB:0 :0 :0];
	gameTimeFrom.position = cpv(-112,secondY);
	[self addChild:gameTimeFrom];
	
	sz = CGSizeMake(50,26);
	gameTimeTo = [Label labelWithString:@"To:" dimensions:sz alignment:UITextAlignmentRight
							   fontName:@"ArialMT" fontSize:18];
	[gameTimeTo setRGB:0 :0 :0];
	gameTimeTo.position = cpv(20,secondY);
	[self addChild:gameTimeTo];
	
	//NSString *timeMin = [NSString stringWithFormat:@"%@ min", [seekParams objectForKey:@"SeekTimeMin"]];
	sz = CGSizeMake(70,26);
	gameTimeMin = [Label labelWithString:@"*" dimensions:sz alignment:UITextAlignmentCenter
								fontName:@"Arial-BoldMT" fontSize:20];
	[gameTimeMin setRGB:0 :0 :0];
	gameTimeMin.position = cpv(-40-5,secondY);
	[self addChild:gameTimeMin z:1];
	
	//NSString *timeMax = [NSString stringWithFormat:@"%@ min", [seekParams objectForKey:@"SeekTimeMax"]];
	sz = CGSizeMake(70,26);
	gameTimeMax = [Label labelWithString:@"*" dimensions:sz alignment:UITextAlignmentCenter
								fontName:@"Arial-BoldMT" fontSize:20];
	[gameTimeMax setRGB:0 :0 :0];
	gameTimeMax.position = cpv(90-5,secondY);
	[self addChild:gameTimeMax z:1];		
	
	gameTimeMinButton = [MenuItemImage itemFromNormalImage:@"combo_90x44.png" 
											 selectedImage:@"combo_90x44.png"
													target:self
												  selector:@selector(timeMinPressed:)];
	gameTimeMinButton.position = cpv(-40,secondY);
	
	gameTimeMaxButton = [MenuItemImage itemFromNormalImage:@"combo_90x44.png" 
											 selectedImage:@"combo_90x44.png"
													target:self
												  selector:@selector(timeMaxPressed:)];
	gameTimeMaxButton.position = cpv(90,secondY);
	
	return;
	
}

-(void)initGameInc
{
	CGFloat firstY = 112;
	CGFloat secondY = 82;
	
	// Game Inc
	CGSize sz = CGSizeMake(300,26);
	gameInc = [Label labelWithString:@"Increment after Each Move:" dimensions:sz alignment:UITextAlignmentCenter
							fontName:@"ArialMT" fontSize:18];
	[gameInc setRGB:0 :0 :0];
	gameInc.position = cpv(0,firstY);
	[self addChild:gameInc];
	
	sz = CGSizeMake(54,26);
	gameIncFrom = [Label labelWithString:@"From:" dimensions:sz alignment:UITextAlignmentRight
								fontName:@"ArialMT" fontSize:18];
	[gameIncFrom setRGB:0 :0 :0];
	gameIncFrom.position = cpv(-112,secondY);
	[self addChild:gameIncFrom];
	
	sz = CGSizeMake(50,26);
	gameIncTo = [Label labelWithString:@"To:" dimensions:sz alignment:UITextAlignmentRight
							  fontName:@"ArialMT" fontSize:18];
	[gameIncTo setRGB:0 :0 :0];
	gameIncTo.position = cpv(20,secondY);
	[self addChild:gameIncTo];
	
	//NSString *incMin = [NSString stringWithFormat:@"%@ sec", [seekParams objectForKey:@"SeekIncMin"]];
	sz = CGSizeMake(70,26);
	gameIncMin = [Label labelWithString:@"*" dimensions:sz alignment:UITextAlignmentCenter
							   fontName:@"Arial-BoldMT" fontSize:20];
	[gameIncMin setRGB:0 :0 :0];
	gameIncMin.position = cpv(-40-5,secondY);
	[self addChild:gameIncMin z:1];
	
	//NSString *incMax = [NSString stringWithFormat:@"%@ sec", [seekParams objectForKey:@"SeekIncMax"]];
	sz = CGSizeMake(70,26);
	gameIncMax = [Label labelWithString:@"*" dimensions:sz alignment:UITextAlignmentCenter
							   fontName:@"Arial-BoldMT" fontSize:20];
	[gameIncMax setRGB:0 :0 :0];
	gameIncMax.position = cpv(90-5,secondY);
	[self addChild:gameIncMax z:1];		
	
	gameIncMinButton = [MenuItemImage itemFromNormalImage:@"combo_90x44.png" 
											selectedImage:@"combo_90x44.png"
												   target:self
												 selector:@selector(incMinPressed:)];
	gameIncMinButton.position = cpv(-40,secondY);
	
	gameIncMaxButton = [MenuItemImage itemFromNormalImage:@"combo_90x44.png" 
											selectedImage:@"combo_90x44.png"
												   target:self
												 selector:@selector(incMaxPressed:)];
	gameIncMaxButton.position = cpv(90,secondY);
	
	return;
	
}

-(void)initPieceColor
{
	CGFloat firstY = 42;
	CGFloat secondY = 14;
	
	// Piece color
	CGSize sz = CGSizeMake(300,26);
	pieceColor = [Label labelWithString:@"Piece Color to Play:" dimensions:sz alignment:UITextAlignmentCenter
							   fontName:@"ArialMT" fontSize:18];
	[pieceColor setRGB:0 :0 :0];
	pieceColor.position = cpv(0,firstY);
	[self addChild:pieceColor];
	
	// piece color labels
	sz = CGSizeMake(80,24);
	pieceColorLabelAny = [Label labelWithString:@"Any" dimensions:sz alignment:UITextAlignmentCenter
									   fontName:@"Arial-BoldMT" fontSize:20];
	[pieceColorLabelAny setRGB:0 :0 :0];
	pieceColorLabelAny.position = cpv(-89,secondY);
	[self addChild:pieceColorLabelAny z:1];
	
	sz = CGSizeMake(80,24);
	pieceColorLabelWhite = [Label labelWithString:@"White" dimensions:sz alignment:UITextAlignmentCenter
										 fontName:@"Arial-BoldMT" fontSize:20];
	[pieceColorLabelWhite setRGB:0 :0 :0];
	pieceColorLabelWhite.position = cpv(0,secondY);
	[self addChild:pieceColorLabelWhite z:1];
	
	sz = CGSizeMake(80,24);
	pieceColorLabelBlack = [Label labelWithString:@"Black" dimensions:sz alignment:UITextAlignmentCenter
										 fontName:@"Arial-BoldMT" fontSize:20];
	[pieceColorLabelBlack setRGB:0 :0 :0];
	pieceColorLabelBlack.position = cpv(89,secondY);
	[self addChild:pieceColorLabelBlack z:1];
	
	// piece color buttons
	pieceColorAny = [MenuItemImage itemFromNormalImage:@"segmented_3p_p1_norm.png" 
										 selectedImage:@"segmented_3p_p1_norm.png" 
										 disabledImage:@"segmented_3p_p1_sel.png"
												target:self selector:@selector(pieceColorPressed:)];
	pieceColorAny.position = cpv(-89,secondY);
	
	pieceColorWhite = [MenuItemImage itemFromNormalImage:@"segmented_3p_p2_norm.png" 
										   selectedImage:@"segmented_3p_p2_norm.png" 
										   disabledImage:@"segmented_3p_p2_sel.png"
												  target:self selector:@selector(pieceColorPressed:)];
	pieceColorWhite.position = cpv(0,secondY);
	
	pieceColorBlack = [MenuItemImage itemFromNormalImage:@"segmented_3p_p3_norm.png" 
										   selectedImage:@"segmented_3p_p3_norm.png" 
										   disabledImage:@"segmented_3p_p3_sel.png"
												  target:self selector:@selector(pieceColorPressed:)];
	pieceColorBlack.position = cpv(89,secondY);
	
	return;
}

-(void)initRateType
{
	CGFloat firstY = -26;
	CGFloat secondY = -54;
	
	// rating types
	CGSize sz = CGSizeMake(300,26);
	rateType = [Label labelWithString:@"Rated/Unrated Filter:" dimensions:sz alignment:UITextAlignmentCenter
							 fontName:@"ArialMT" fontSize:18];
	[rateType setRGB:0 :0 :0];
	rateType.position = cpv(0,firstY);
	[self addChild:rateType];
	
	// rate type labels
	sz = CGSizeMake(80,24);
	rateTypeLabelAny = [Label labelWithString:@"Any" dimensions:sz alignment:UITextAlignmentCenter
									 fontName:@"Arial-BoldMT" fontSize:20];
	[rateTypeLabelAny setRGB:0 :0 :0];
	rateTypeLabelAny.position = cpv(-89,secondY);
	[self addChild:rateTypeLabelAny z:1];
	
	sz = CGSizeMake(80,24);
	rateTypeLabelRated = [Label labelWithString:@"Rated" dimensions:sz alignment:UITextAlignmentCenter
									   fontName:@"Arial-BoldMT" fontSize:20];
	[rateTypeLabelRated setRGB:0 :0 :0];
	rateTypeLabelRated.position = cpv(0,secondY);
	[self addChild:rateTypeLabelRated z:1];
	
	sz = CGSizeMake(80,24);
	rateTypeLabelUnrated = [Label labelWithString:@"Unrated" dimensions:sz alignment:UITextAlignmentCenter
										 fontName:@"Arial-BoldMT" fontSize:20];
	[rateTypeLabelUnrated setRGB:0 :0 :0];
	rateTypeLabelUnrated.position = cpv(89,secondY);
	[self addChild:rateTypeLabelUnrated z:1];
	
	// rate type buttons
	rateTypeAny = [MenuItemImage itemFromNormalImage:@"segmented_3p_p1_norm.png" 
									   selectedImage:@"segmented_3p_p1_norm.png" 
									   disabledImage:@"segmented_3p_p1_sel.png"
											  target:self selector:@selector(rateTypePressed:)];
	rateTypeAny.position = cpv(-89,secondY);
	
	
	rateTypeRated = [MenuItemImage itemFromNormalImage:@"segmented_3p_p2_norm.png" 
										 selectedImage:@"segmented_3p_p2_norm.png" 
										 disabledImage:@"segmented_3p_p2_sel.png"
												target:self selector:@selector(rateTypePressed:)];
	rateTypeRated.position = cpv(0,secondY);
	
	rateTypeUnrated = [MenuItemImage itemFromNormalImage:@"segmented_3p_p3_norm.png" 
										   selectedImage:@"segmented_3p_p3_norm.png" 
										   disabledImage:@"segmented_3p_p3_sel.png"
												  target:self selector:@selector(rateTypePressed:)];
	rateTypeUnrated.position = cpv(89,secondY);
	
	return;
}

-(void)initRateValue
{
	CGFloat firstY = -94;
	CGFloat secondY = -122;
	
	// Game Inc
	CGSize sz = CGSizeMake(300,26);
	rateVal = [Label labelWithString:@"Opponent's Rating Range:" dimensions:sz alignment:UITextAlignmentCenter
							fontName:@"ArialMT" fontSize:18];
	[rateVal setRGB:0 :0 :0];
	rateVal.position = cpv(0,firstY);
	[self addChild:rateVal];
	
	sz = CGSizeMake(54,26);
	rateValFrom = [Label labelWithString:@"From:" dimensions:sz alignment:UITextAlignmentRight
								fontName:@"ArialMT" fontSize:18];
	[rateValFrom setRGB:0 :0 :0];
	rateValFrom.position = cpv(-112,secondY);
	[self addChild:rateValFrom];
	
	sz = CGSizeMake(50,26);
	rateValTo = [Label labelWithString:@"To:" dimensions:sz alignment:UITextAlignmentRight
							  fontName:@"ArialMT" fontSize:18];
	[rateValTo setRGB:0 :0 :0];
	rateValTo.position = cpv(20,secondY);
	[self addChild:rateValTo];
	
	sz = CGSizeMake(70,26);
	rateValMin = [Label labelWithString:@"100" dimensions:sz alignment:UITextAlignmentCenter
							   fontName:@"Arial-BoldMT" fontSize:20];
	[rateValMin setRGB:0 :0 :0];
	rateValMin.position = cpv(-40-5,secondY);
	[self addChild:rateValMin z:1];
	
	sz = CGSizeMake(70,26);
	rateValMax = [Label labelWithString:@"3000" dimensions:sz alignment:UITextAlignmentCenter
							   fontName:@"Arial-BoldMT" fontSize:20];
	[rateValMax setRGB:0 :0 :0];
	rateValMax.position = cpv(90-5,secondY);
	[self addChild:rateValMax z:1];		
	
	rateValMinButton = [MenuItemImage itemFromNormalImage:@"combo_90x44.png" 
											selectedImage:@"combo_90x44.png"
												   target:self
												 selector:@selector(rateValMinPressed:)];
	rateValMinButton.position = cpv(-40,secondY);
	
	rateValMaxButton = [MenuItemImage itemFromNormalImage:@"combo_90x44.png" 
											selectedImage:@"combo_90x44.png"
												   target:self
												 selector:@selector(rateValMaxPressed:)];
	rateValMaxButton.position = cpv(90,secondY);
	
	return;
}

-(void)initUnregState
{
	CGFloat firstY = -160;
	
	// Checkbox
	checkBoxUnchecked = [MenuItemImage itemFromNormalImage:@"cb_44x44_unchecked.png" 
											 selectedImage:@"cb_44x44_unchecked.png"
													target:self selector:@selector(checkboxPressed:)];
	//checkBoxUnchecked.position = cpv(-120,-200);
	
	checkBoxChecked = [MenuItemImage itemFromNormalImage:@"cb_44x44_checked.png" 
										   selectedImage:@"cb_44x44_checked.png"
												  target:self selector:@selector(checkboxPressed:)];
	//checkBoxChecked.position = cpv(-120,-200);
	
	checkBox = [MenuItemToggle itemWithTarget:self 
									 selector:@selector(checkboxPressed:) 
										items:checkBoxUnchecked, checkBoxChecked, nil];
	checkBox.position = cpv(-115,firstY);
	
	CGSize sz = CGSizeMake(240,26);
	checkBoxPrompt = [Label labelWithString:@"Allow Unregistred Opponents" dimensions:sz alignment:UITextAlignmentLeft
								   fontName:@"ArialMT" fontSize:18];
	[checkBoxPrompt setRGB:0 :0 :0];
	checkBoxPrompt.position = cpv(32,firstY);
	[self addChild:checkBoxPrompt];
	
	return;
}

#pragma mark ********** appear/disappear  **********
-(void)nodeDidAppeared
{
	if([[seekParams objectForKey:@"SeekAllowUnregistred"] intValue])
	{
		[seekParams setObject:@"2" forKey:@"SeekRatingType"];
		[self enableRateType:NO];
		[self enableRateValue:NO];
	}
	
	if(!isRegistred)
	{
		[seekParams setObject:@"2" forKey:@"SeekRatingType"];
		[seekParams setObject:@"1" forKey:@"SeekAllowUnregistred"];
		[self enableRateType:NO];
		[self enableRateValue:NO];
		[self enableAllowUnregistred:NO];
	}
	return;
}

-(void)nodeWillDisappear
{
	return;
}

#pragma mark ********** opacity **********
-(GLubyte) opacity
{
	return opacity;
}

/// sets the opacity
-(void) setOpacity: (GLubyte) opac
{
	opacity = opac;
	
	for(CocosNode *node in children)
	{
		if( [[node class] conformsToProtocol:@protocol(CocosNodeOpacity)] )
		{
			id<CocosNodeOpacity> obj = (id<CocosNodeOpacity>)node;
			[obj setOpacity:opac];
		}
	}
	
	return;
}

#pragma mark ********** key presses **********
-(void)seekPressed:(id)obj
{
	DbgLog(@"POP: seek popup seek pressed");
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	// call client callback
	if(onSeek)
		[self runAction:onSeek];
	
	return;
}

-(void)cancelPressed:(id)obj
{
	DbgLog(@"POP: seek popup cancel pressed");
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	// call client callback
	if(onCancel)
		[self runAction:onCancel];
	
	return;
}

-(void)timeMinPressed:(id)obj
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	NSUInteger index = 0;
	NSUInteger cnt = 0;
	NSMutableArray *tmp = [NSMutableArray array];
	for(NSString *item in times)
	{
		[tmp addObject:[NSString stringWithFormat:@" %@ minutes",item]];
		if([item intValue]==[[seekParams objectForKey:@"SeekTimeMin"] intValue])
			index = cnt;
		++cnt;
	}
	
	self.picker = [[PickerController alloc] initWithNibName:@"Picker" bundle:nil 
												data:tmp selectedIndex:index];
	
	picker.target = self;
	picker.valuePickedAction = @selector(timeMinChanged:);
	
	[[Director sharedDirector].openGLView addSubview:picker.view];
	return;
}

-(void)timeMaxPressed:(id)obj
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	NSUInteger index = 0;
	NSUInteger cnt = 0;
	NSMutableArray *tmp = [NSMutableArray array];
	for(NSString *item in times)
	{
		[tmp addObject:[NSString stringWithFormat:@" %@ minutes",item]];
		if([item intValue]==[[seekParams objectForKey:@"SeekTimeMax"] intValue])
			index = cnt;
		++cnt;
	}
	
	self.picker = [[PickerController alloc] initWithNibName:@"Picker" bundle:nil 
													   data:tmp selectedIndex:index];
	
	picker.target = self;
	picker.valuePickedAction = @selector(timeMaxChanged:);
	
	[[Director sharedDirector].openGLView addSubview:picker.view];
	return;
}

-(void)incMinPressed:(id)obj
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	NSUInteger index = 0;
	NSUInteger cnt = 0;
	NSMutableArray *tmp = [NSMutableArray array];
	for(NSString *item in incs)
	{
		[tmp addObject:[NSString stringWithFormat:@" %@ seconds",item]];
		if([item intValue]==[[seekParams objectForKey:@"SeekIncMin"] intValue])
			index = cnt;
		++cnt;
	}
	
	self.picker = [[PickerController alloc] initWithNibName:@"Picker" bundle:nil 
													   data:tmp selectedIndex:index];
	
	picker.target = self;
	picker.valuePickedAction = @selector(incMinChanged:);
	
	[[Director sharedDirector].openGLView addSubview:picker.view];
	return;
}

-(void)incMaxPressed:(id)obj
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	NSUInteger index = 0;
	NSUInteger cnt = 0;
	NSMutableArray *tmp = [NSMutableArray array];
	for(NSString *item in incs)
	{
		[tmp addObject:[NSString stringWithFormat:@" %@ seconds",item]];
		if([item intValue]==[[seekParams objectForKey:@"SeekIncMax"] intValue])
			index = cnt;
		++cnt;
	}
	
	self.picker = [[PickerController alloc] initWithNibName:@"Picker" bundle:nil 
													   data:tmp selectedIndex:index];
	
	picker.target = self;
	picker.valuePickedAction = @selector(incMaxChanged:);
	
	[[Director sharedDirector].openGLView addSubview:picker.view];
	return;
}

-(void)rateValMinPressed:(id)obj
{
	if(!isRateValEnabled)
		return;
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	NSUInteger index = 0;
	NSUInteger cnt = 0;
	NSMutableArray *tmp = [NSMutableArray array];
	for(NSString *item in ratings)
	{
		[tmp addObject:[NSString stringWithFormat:@" %04@ points",item]];
		if([item intValue]==[[seekParams objectForKey:@"SeekRatingMin"] intValue])
			index = cnt;
		++cnt;
	}
	
	self.picker = [[PickerController alloc] initWithNibName:@"Picker" bundle:nil 
													   data:tmp selectedIndex:index];
	
	picker.target = self;
	picker.valuePickedAction = @selector(rateValMinChanged:);
	
	[[Director sharedDirector].openGLView addSubview:picker.view];
	return;
}

-(void)rateValMaxPressed:(id)obj
{
	if(!isRateValEnabled)
		return;
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	NSUInteger index = 0;
	NSUInteger cnt = 0;
	NSMutableArray *tmp = [NSMutableArray array];
	for(NSString *item in ratings)
	{
		[tmp addObject:[NSString stringWithFormat:@" %04@ points",item]];
		if([item intValue]==[[seekParams objectForKey:@"SeekRatingMax"] intValue])
			index = cnt;
		++cnt;
	}
	
	self.picker = [[PickerController alloc] initWithNibName:@"Picker" bundle:nil 
													   data:tmp selectedIndex:index];
	
	picker.target = self;
	picker.valuePickedAction = @selector(rateValMaxChanged:);
	
	[[Director sharedDirector].openGLView addSubview:picker.view];
	return;
}


-(void)pieceColorPressed:(id)obj
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];

	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	pieceColorAny.isEnabled   = YES;
	pieceColorWhite.isEnabled = YES;
	pieceColorBlack.isEnabled = YES;
	if( obj==pieceColorAny )
	{
		[seekParams setObject:@"0" forKey:@"SeekPieceColor"];
		pieceColorAny.isEnabled   = NO;
	}
	else if(obj==pieceColorWhite)
	{
		[seekParams setObject:@"1" forKey:@"SeekPieceColor"];
		pieceColorWhite.isEnabled = NO;
	}
	else if(obj==pieceColorBlack)
	{
		[seekParams setObject:@"2" forKey:@"SeekPieceColor"];
		pieceColorBlack.isEnabled = NO;
	}

	// update defaults
	[defs setObject:seekParams forKey:@"SeekParams"];
	
	return;
}

-(void)rateTypePressed:(id)obj
{
	if(!isRateTypeEnabled)
		return;
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
 
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	rateTypeAny.isEnabled		= YES;
	rateTypeRated.isEnabled		= YES;
	rateTypeUnrated.isEnabled	= YES;
	if( obj==rateTypeAny )
	{
		[seekParams setObject:@"0" forKey:@"SeekRatingType"];
		rateTypeAny.isEnabled   = NO;
	}
	else if(obj==rateTypeRated)
	{
		[seekParams setObject:@"1" forKey:@"SeekRatingType"];
		rateTypeRated.isEnabled = NO;
	}
	else if(obj==rateTypeUnrated)
	{
		[seekParams setObject:@"2" forKey:@"SeekRatingType"];
		rateTypeUnrated.isEnabled = NO;
	}
	// update defaults
	[defs setObject:seekParams forKey:@"SeekParams"];
	
	return;	
}

-(void)checkboxPressed:(id)obj
{
	if(!isCheckBoxEnabled)
		return;
	
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	MenuItemToggle *cb = (MenuItemToggle*)obj;
	MsgLog(@"CheckBox:%@",cb.selectedIndex ? @"checked" : @"unchecked");
	if(cb.selectedIndex==0)
	{
		// unchecked
		[seekParams setObject:@"0" forKey:@"SeekAllowUnregistred"];
		[self enableRateType:YES];
		[self enableRateValue:YES];
	}
	else
	{
		// checked
		[seekParams setObject:@"1" forKey:@"SeekAllowUnregistred"];
		[self enableRateType:NO];
		[self enableRateValue:NO];
	}

	// update defaults
	[defs setObject:seekParams forKey:@"SeekParams"];
	return;
}

#pragma mark ***** picker callbacks *****
-(void)timeMinChanged:(NSNumber*)ord
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSString *newVal = [NSString stringWithFormat:@"%@",[times objectAtIndex:[ord intValue]]];
	// change TimeMin value
	[seekParams setObject:newVal forKey:@"SeekTimeMin"];
	[self setTimeMin:newVal];
	// if min>max, update max value also
	if([newVal intValue] > [[seekParams objectForKey:@"SeekTimeMax"] intValue])
	{
		[seekParams setObject:newVal forKey:@"SeekTimeMax"];
		[self setTimeMax:newVal];
	}
	// update defaults
	[defs setObject:seekParams forKey:@"SeekParams"];
	return;
}

-(void)timeMaxChanged:(NSNumber*)ord
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSString *newVal = [NSString stringWithFormat:@"%@",[times objectAtIndex:[ord intValue]]];
	// change TimeMin value
	[seekParams setObject:newVal forKey:@"SeekTimeMax"];
	[self setTimeMax:newVal];
	// if min>max, update max value also
	if([newVal intValue] < [[seekParams objectForKey:@"SeekTimeMin"] intValue])
	{
		[seekParams setObject:newVal forKey:@"SeekTimeMin"];
		[self setTimeMin:newVal];
	}
	// update defaults
	[defs setObject:seekParams forKey:@"SeekParams"];
	return;
}

-(void)incMinChanged:(NSNumber*)ord
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSString *newVal = [NSString stringWithFormat:@"%@",[incs objectAtIndex:[ord intValue]]];
	// change TimeMin value
	[seekParams setObject:newVal forKey:@"SeekIncMin"];
	[self setIncMin:newVal];
	// if min>max, update max value also
	if([newVal intValue] > [[seekParams objectForKey:@"SeekIncMax"] intValue])
	{
		[seekParams setObject:newVal forKey:@"SeekIncMax"];
		[self setIncMax:newVal];
	}
	// update defaults
	[defs setObject:seekParams forKey:@"SeekParams"];
	return;
}

-(void)incMaxChanged:(NSNumber*)ord
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSString *newVal = [NSString stringWithFormat:@"%@",[incs objectAtIndex:[ord intValue]]];
	// change TimeMin value
	[seekParams setObject:newVal forKey:@"SeekIncMax"];
	[self setIncMax:newVal];
	// if min>max, update max value also
	if([newVal intValue] < [[seekParams objectForKey:@"SeekIncMin"] intValue])
	{
		[seekParams setObject:newVal forKey:@"SeekIncMin"];
		[self setIncMin:newVal];
	}
	// update defaults
	[defs setObject:seekParams forKey:@"SeekParams"];
	return;
}

-(void)rateValMinChanged:(NSNumber*)ord
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSString *newVal = [NSString stringWithFormat:@"%@",[ratings objectAtIndex:[ord intValue]]];
	// change TimeMin value
	[seekParams setObject:newVal forKey:@"SeekRatingMin"];
	[self setRatingMin:newVal];
	// if min>max, update max value also
	if([newVal intValue] > [[seekParams objectForKey:@"SeekRatingMax"] intValue])
	{
		[seekParams setObject:newVal forKey:@"SeekRatingMax"];
		[self setRatingMax:newVal];
	}
	// update defaults
	[defs setObject:seekParams forKey:@"SeekParams"];
	return;
}

-(void)rateValMaxChanged:(NSNumber*)ord
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSString *newVal = [NSString stringWithFormat:@"%@",[ratings objectAtIndex:[ord intValue]]];
	// change TimeMin value
	[seekParams setObject:newVal forKey:@"SeekRatingMax"];
	[self setRatingMax:newVal];
	// if min>max, update max value also
	if([newVal intValue] < [[seekParams objectForKey:@"SeekRatingMin"] intValue])
	{
		[seekParams setObject:newVal forKey:@"SeekRatingMin"];
		[self setRatingMin:newVal];
	}
	// update defaults
	[defs setObject:seekParams forKey:@"SeekParams"];
	return;
}

#pragma mark ***** enable/disable controls *****
-(void)enableRateType:(BOOL)isEnabled
{
	isRateTypeEnabled = isEnabled;
	CGFloat opac = isEnabled ? 255 : 128;
	
	rateTypeLabelAny    .opacity = opac;
	rateTypeLabelRated  .opacity = opac;
	rateTypeLabelUnrated.opacity = opac;
	rateTypeAny			.opacity = opac;
	rateTypeRated		.opacity = opac;
	rateTypeUnrated		.opacity = opac;
	
	return;
}

-(void)enableRateValue:(BOOL)isEnabled
{
	isRateValEnabled = isEnabled;
	CGFloat opac = isEnabled ? 255 : 128;
	
	rateValMin		.opacity = opac;
	rateValMax		.opacity = opac;
	rateValMinButton.opacity = opac;
	rateValMaxButton.opacity = opac;
	
	return;
}

-(void)enableAllowUnregistred:(BOOL)isEnabled
{
	isCheckBoxEnabled = isEnabled;
	CGFloat opac = isEnabled ? 255 : 128;
	checkBox.isEnabled = isEnabled;
	checkBoxChecked.isEnabled = isEnabled;
	checkBoxUnchecked.isEnabled = isEnabled;
	checkBoxUnchecked.opacity = opac;
	checkBoxChecked  .opacity = opac;
	checkBox		 .opacity = opac;
	
	return;
}

#pragma mark ***** set Controls values *****
-(void)setTimeMin:(NSString*)val
{
	[gameTimeMin setString:[NSString stringWithFormat:@"%@ min",val]];
	return;
}

-(void)setTimeMax:(NSString*)val
{
	[gameTimeMax setString:[NSString stringWithFormat:@"%@ min",val]];
	return;
}

-(void)setIncMin:(NSString*)val
{
	[gameIncMin setString:[NSString stringWithFormat:@"%@ sec",val]];
	return;
}

-(void)setIncMax:(NSString*)val
{
	[gameIncMax setString:[NSString stringWithFormat:@"%@ sec",val]];
	return;
}

-(void)setPieceColor:(NSString*)val
{
	pieceColorAny.isEnabled   = YES;
	pieceColorWhite.isEnabled = YES;
	pieceColorBlack.isEnabled = YES;
	[pieceColorLabelAny   setRGB:0 :0 :0]; 
	[pieceColorLabelWhite setRGB:0 :0 :0]; 
	[pieceColorLabelBlack setRGB:0 :0 :0]; 
	switch([val intValue])
	{
		case 0:
			pieceColorAny.isEnabled = NO;
			//[pieceColorLabelAny setRGB:255:255:255]; 
			break;
		case 1:
			pieceColorWhite.isEnabled = NO;
			[pieceColorLabelWhite setRGB:255:255:255]; 
			break;
		case 2:
			pieceColorBlack.isEnabled = NO;
			//[pieceColorLabelBlack setRGB:255:255:255]; 
			break;
	}
	return;
}

-(void)setRatingType:(NSString*)val
{
	rateTypeAny.isEnabled   = YES;
	rateTypeRated.isEnabled = YES;
	rateTypeUnrated.isEnabled = YES;
	switch([val intValue])
	{
		case 0:
			rateTypeAny.isEnabled = NO;
			break;
		case 1:
			rateTypeRated.isEnabled = NO;
			break;
		case 2:
			rateTypeUnrated.isEnabled = NO;
			break;
	}
	return;
}

-(void)setRatingMin:(NSString*)val
{
	[rateValMin setString:[NSString stringWithFormat:@"%@",val]];
	return;
}

-(void)setRatingMax:(NSString*)val
{
	[rateValMax setString:[NSString stringWithFormat:@"%@",val]];
	return;
}

-(void)setAllowUnregistred:(NSString*)val
{
	if([val boolValue])
		checkBox.selectedIndex = 1;
	else
		checkBox.selectedIndex = 0;
	return;
}

#pragma mark ***** touches handling *****
- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//DbgLog(@"MSB: ccTouchesBegan");
	if(isTouchEnabled)
		return kEventHandled;
	return kEventIgnored;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//DbgLog(@"MSB: ccTouchesMoved");
	if(isTouchEnabled)
		return kEventHandled;
	return kEventIgnored;
}

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//DbgLog(@"MSB: ccTouchesEnded");
	if(isTouchEnabled)
		return kEventHandled;
	return kEventIgnored;
}

- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	//DbgLog(@"MSB: ccTouchesCancelled");
	if(isTouchEnabled)
		return kEventHandled;
	return kEventIgnored;
}


@end
