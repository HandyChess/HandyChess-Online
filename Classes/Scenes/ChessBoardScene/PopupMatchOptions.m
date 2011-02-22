//
//  PopupSeekOptions.m
//  HandyChess
//
//  Created by Anton on 4/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PopupMatchOptions.h"
#import "Logger.h"
#import "SoundEngine.h"
#import "RoundedFilledRect.h"

#import "PickerController.h"

#define POPUP_COLOR_FRAME			{0.1, 0.1, 0.1, 1.0};
#define POPUP_COLOR_BACKGROUND		{0.94, 0.95, 0.9, 0.99};
#define FRAME_ROUNDING_RADIUS		20

@interface PopupMatchOptions (Private)
-(void)initName;
-(void)initGameTime;
-(void)initGameInc;
-(void)initPieceColor;
-(void)initRateType;

-(void)cancelPressed:(id)obj;
-(void)matchPressed:(id)obj;
@end

@implementation PopupMatchOptions

@synthesize picker;
@synthesize onMatch;
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
		
		// Match params
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		matchParams = [[NSMutableDictionary alloc] initWithDictionary:[defs objectForKey:@"MatchParams"]];
		times   = [[NSArray alloc] initWithArray:[defs objectForKey:@"Times"]];
		incs    = [[NSArray alloc] initWithArray:[defs objectForKey:@"Increments"]];
		
		// Title 
		CGSize sz = CGSizeMake(300,26);
		title = [Label labelWithString:@"Match the Opponent" dimensions:sz alignment:UITextAlignmentCenter
							  fontName:@"Arial-BoldMT" fontSize:24];
		[title setRGB:0 :0 :0];
		title.position = cpv(0,170);
		[self addChild:title];
		
		[self initName];
		[self initGameTime];
		[self initGameInc];
		[self initPieceColor];
		[self initRateType];
		
		// menu buttons
		MenuItemImage *cancel = [MenuItemImage itemFromNormalImage:@"button_cancel_100px_normal.png" 
													 selectedImage:@"button_cancel_100px_pressed.png"
															target:self
														  selector:@selector(cancelPressed:)];
		MenuItemImage *match =[MenuItemImage itemFromNormalImage:@"button_match_100px_normal.png" 
												  selectedImage:@"button_match_100px_pressed.png"
														 target:self
													   selector:@selector(matchPressed:)];
		cancel.position = cpv(56,-160);
		match.position = cpv(-56,-160);
		menu = [Menu menuWithItems:
				gameTimeButton, gameIncButton,
				pieceColorFair, pieceColorWhite, pieceColorBlack,
				rateTypeRated, rateTypeUnrated,
				cancel,match,nil];
		menu.position = cpv(0,0);
		[self addChild:menu];
		
		// message box frame and aligner
		ccColorF frCol = POPUP_COLOR_FRAME;
		ccColorF bgCol = POPUP_COLOR_BACKGROUND;
		roundedRect = [RoundedFilledRect rectWithSize:CGSizeMake(310,380) radius:FRAME_ROUNDING_RADIUS 
										  strokeColor:frCol fillColor:bgCol];
		//roundedRect.position = cpv(160,240);
		[self addChild:roundedRect z:-1];
		
		// if unregistred player, some special settings are forced
		[self enableRateType:YES];
		
		
		if(!isRegistred)
		{
			[matchParams setObject:@"1" forKey:@"MatchRatingType"];
			[defs setObject:matchParams forKey:@"MatchParams"];
			[self enableRateType:NO];
		}
		
		// set default values
		[self setName:		[matchParams objectForKey:@"MatchName"]];
		[self setTime:		[matchParams objectForKey:@"MatchTime"]];
		[self setInc:		[matchParams objectForKey:@"MatchInc"]];
		[self setPieceColor:[matchParams objectForKey:@"MatchPieceColor"]];
		[self setRatingType:[matchParams objectForKey:@"MatchRatingType"]];
		
	}
	return self;
}

-(void)dealloc
{
	[nameField release];
	[incs release];
	[times release];
	[matchParams release];
	[super dealloc];
}


-(void)initName
{
	CGFloat firstY = 128;
	
	// Game time
	CGSize sz = CGSizeMake(138,26);
	name = [Label labelWithString:@"Opponent Name:" dimensions:sz alignment:UITextAlignmentLeft
							 fontName:@"ArialMT" fontSize:18];
	[name setRGB:0 :0 :0];
	name.position = cpv(-75,firstY);
	[self addChild:name];
	
	// edit field
	nameField = [[UITextField alloc] initWithFrame:CGRectMake(155, 94, 150, 31)];
	nameField.delegate = self;
	nameField.borderStyle = UITextBorderStyleRoundedRect;
	[[Director sharedDirector].openGLView addSubview:nameField];
		
	return;
}

-(void)initGameTime
{
	CGFloat firstY = 86;
	
	// Game time
	CGSize sz = CGSizeMake(136,26);
	gameTime = [Label labelWithString:@"Game Time:" dimensions:sz alignment:UITextAlignmentRight
							 fontName:@"ArialMT" fontSize:18];
	[gameTime setRGB:0 :0 :0];
	gameTime.position = cpv(-75,firstY);
	[self addChild:gameTime];
	
	sz = CGSizeMake(70,26);
	gameTimeVal = [Label labelWithString:@"*" dimensions:sz alignment:UITextAlignmentCenter
								fontName:@"Arial-BoldMT" fontSize:20];
	[gameTimeVal setRGB:0 :0 :0];
	gameTimeVal.position = cpv(40-5,firstY);
	[self addChild:gameTimeVal z:1];
	
	gameTimeButton = [MenuItemImage itemFromNormalImage:@"combo_90x44.png" 
											 selectedImage:@"combo_90x44.png"
													target:self
												  selector:@selector(timeValPressed:)];
	gameTimeButton.position = cpv(40,firstY);
	
	return;
	
}

-(void)initGameInc
{
	CGFloat firstY = 36;
	
	// Game time
	CGSize sz = CGSizeMake(136,26);
	gameInc = [Label labelWithString:@"Increment:" dimensions:sz alignment:UITextAlignmentRight
							 fontName:@"ArialMT" fontSize:18];
	[gameInc setRGB:0 :0 :0];
	gameInc.position = cpv(-75,firstY);
	[self addChild:gameInc];
	
	sz = CGSizeMake(70,26);
	gameIncVal = [Label labelWithString:@"*" dimensions:sz alignment:UITextAlignmentCenter
								fontName:@"Arial-BoldMT" fontSize:20];
	[gameIncVal setRGB:0 :0 :0];
	gameIncVal.position = cpv(40-5,firstY);
	[self addChild:gameIncVal z:1];
	
	gameIncButton = [MenuItemImage itemFromNormalImage:@"combo_90x44.png" 
										  selectedImage:@"combo_90x44.png"
												 target:self
											   selector:@selector(incValPressed:)];
	gameIncButton.position = cpv(40,firstY);
	
	return;
	
}

-(void)initPieceColor
{
	CGFloat firstY = -8;
	CGFloat secondY = -36;
	
	// Piece color
	CGSize sz = CGSizeMake(300,26);
	pieceColor = [Label labelWithString:@"Piece Color to Play:" dimensions:sz alignment:UITextAlignmentCenter
							   fontName:@"ArialMT" fontSize:18];
	[pieceColor setRGB:0 :0 :0];
	pieceColor.position = cpv(0,firstY);
	[self addChild:pieceColor];
	
	// piece color labels
	sz = CGSizeMake(80,24);
	pieceColorLabelFair = [Label labelWithString:@"Fair" dimensions:sz alignment:UITextAlignmentCenter
									   fontName:@"Arial-BoldMT" fontSize:20];
	[pieceColorLabelFair setRGB:0 :0 :0];
	pieceColorLabelFair.position = cpv(-89,secondY);
	[self addChild:pieceColorLabelFair z:1];
	
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
	pieceColorFair = [MenuItemImage itemFromNormalImage:@"segmented_3p_p1_norm.png" 
										 selectedImage:@"segmented_3p_p1_norm.png" 
										 disabledImage:@"segmented_3p_p1_sel.png"
												target:self selector:@selector(pieceColorPressed:)];
	pieceColorFair.position = cpv(-89,secondY);
	
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
	CGFloat firstY = -76;
	CGFloat secondY = -104;
	
	// rating types
	CGSize sz = CGSizeMake(300,26);
	rateType = [Label labelWithString:@"Rated/Unrated Game:" dimensions:sz alignment:UITextAlignmentCenter
							 fontName:@"ArialMT" fontSize:18];
	[rateType setRGB:0 :0 :0];
	rateType.position = cpv(0,firstY);
	[self addChild:rateType];
	
	// rate type labels
	
	sz = CGSizeMake(80,24);
	rateTypeLabelRated = [Label labelWithString:@"Rated" dimensions:sz alignment:UITextAlignmentCenter
									   fontName:@"Arial-BoldMT" fontSize:20];
	[rateTypeLabelRated setRGB:0 :0 :0];
	rateTypeLabelRated.position = cpv(-45,secondY);
	[self addChild:rateTypeLabelRated z:1];
	
	sz = CGSizeMake(80,24);
	rateTypeLabelUnrated = [Label labelWithString:@"Unrated" dimensions:sz alignment:UITextAlignmentCenter
										 fontName:@"Arial-BoldMT" fontSize:20];
	[rateTypeLabelUnrated setRGB:0 :0 :0];
	rateTypeLabelUnrated.position = cpv(44,secondY);
	[self addChild:rateTypeLabelUnrated z:1];
	
	// rate type buttons
	rateTypeRated = [MenuItemImage itemFromNormalImage:@"segmented_3p_p1_norm.png" 
										 selectedImage:@"segmented_3p_p1_norm.png" 
										 disabledImage:@"segmented_3p_p1_sel.png"
												target:self selector:@selector(rateTypePressed:)];
	rateTypeRated.position = cpv(-45,secondY);
	
	rateTypeUnrated = [MenuItemImage itemFromNormalImage:@"segmented_3p_p3_norm.png" 
										   selectedImage:@"segmented_3p_p3_norm.png" 
										   disabledImage:@"segmented_3p_p3_sel.png"
												  target:self selector:@selector(rateTypePressed:)];
	rateTypeUnrated.position = cpv(44,secondY);
	
	return;
}

#pragma mark ********** appear/disappear callback **********
-(void)nodeDidAppeared
{
	if(!isRegistred)
	{
		[matchParams setObject:@"1" forKey:@"MatchRatingType"];
		//[defs setObject:matchParams forKey:@"MatchParams"];
		[self enableRateType:NO];
	}
	return;
}

-(void)nodeWillDisappear
{
	[nameField removeFromSuperview];
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
	
	nameField.opaque = NO;
	nameField.alpha = opac/255.0f;
	return;
}

#pragma mark ********** key presses **********
-(void)matchPressed:(id)obj
{
	DbgLog(@"POP: seek popup seek pressed");
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	// call client callback
	if(onMatch)
		[self runAction:onMatch];
	
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

-(void)timeValPressed:(id)obj
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	NSUInteger index = 0;
	NSUInteger cnt = 0;
	NSMutableArray *tmp = [NSMutableArray array];
	for(NSString *item in times)
	{
		[tmp addObject:[NSString stringWithFormat:@" %@ minutes",item]];
		if([item intValue]==[[matchParams objectForKey:@"MatchTime"] intValue])
			index = cnt;
		++cnt;
	}
	
	self.picker = [[PickerController alloc] initWithNibName:@"Picker" bundle:nil 
												data:tmp selectedIndex:index];
	
	picker.target = self;
	picker.valuePickedAction = @selector(timeChanged:);
	
	[[Director sharedDirector].openGLView addSubview:picker.view];
	return;
}

-(void)incValPressed:(id)obj
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	
	NSUInteger index = 0;
	NSUInteger cnt = 0;
	NSMutableArray *tmp = [NSMutableArray array];
	for(NSString *item in incs)
	{
		[tmp addObject:[NSString stringWithFormat:@" %@ second(s)",item]];
		if([item intValue]==[[matchParams objectForKey:@"MatchInc"] intValue])
			index = cnt;
		++cnt;
	}
	
	self.picker = [[PickerController alloc] initWithNibName:@"Picker" bundle:nil 
													   data:tmp selectedIndex:index];
	
	picker.target = self;
	picker.valuePickedAction = @selector(incChanged:);
	
	[[Director sharedDirector].openGLView addSubview:picker.view];
	return;
}

-(void)pieceColorPressed:(id)obj
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];

	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	pieceColorFair.isEnabled   = YES;
	pieceColorWhite.isEnabled = YES;
	pieceColorBlack.isEnabled = YES;
	if( obj==pieceColorFair )
	{
		[matchParams setObject:@"0" forKey:@"MatchPieceColor"];
		pieceColorFair.isEnabled   = NO;
	}
	else if(obj==pieceColorWhite)
	{
		[matchParams setObject:@"1" forKey:@"MatchPieceColor"];
		pieceColorWhite.isEnabled = NO;
	}
	else if(obj==pieceColorBlack)
	{
		[matchParams setObject:@"2" forKey:@"MatchPieceColor"];
		pieceColorBlack.isEnabled = NO;
	}

	// update defaults
	[defs setObject:matchParams forKey:@"MatchParams"];
	
	return;
}

-(void)rateTypePressed:(id)obj
{
	if(!isRateTypeEnabled)
		return;
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
 
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	rateTypeRated.isEnabled		= YES;
	rateTypeUnrated.isEnabled	= YES;
	if(obj==rateTypeRated)
	{
		[matchParams setObject:@"0" forKey:@"MatchRatingType"];
		rateTypeRated.isEnabled = NO;
	}
	else if(obj==rateTypeUnrated)
	{
		[matchParams setObject:@"1" forKey:@"MatchRatingType"];
		rateTypeUnrated.isEnabled = NO;
	}
	// update defaults
	[defs setObject:matchParams forKey:@"MatchParams"];
	
	return;	
}

#pragma mark ***** picker callbacks *****
-(void)timeChanged:(NSNumber*)ord
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSString *newVal = [NSString stringWithFormat:@"%@",[times objectAtIndex:[ord intValue]]];
	// change TimeMin value
	[matchParams setObject:newVal forKey:@"MatchTime"];
	[self setTime:newVal];
	// update defaults
	[defs setObject:matchParams forKey:@"MatchParams"];
	return;
}

-(void)incChanged:(NSNumber*)ord
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSString *newVal = [NSString stringWithFormat:@"%@",[incs objectAtIndex:[ord intValue]]];
	// change TimeMin value
	[matchParams setObject:newVal forKey:@"MatchInc"];
	[self setInc:newVal];
	// update defaults
	[defs setObject:matchParams forKey:@"MatchParams"];
	return;
}

#pragma mark ***** text field delegate *****
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[matchParams setObject:textField.text forKey:@"MatchName"];
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs setObject:matchParams forKey:@"MatchParams"];
	return YES;
}

-(void)enableRateType:(BOOL)isEnabled
{
	isRateTypeEnabled = isEnabled;
	CGFloat opac = isEnabled ? 255 : 128;
	
	rateTypeLabelRated  .opacity = opac;
	rateTypeLabelUnrated.opacity = opac;
	rateTypeRated		.opacity = opac;
	rateTypeUnrated		.opacity = opac;
	
	return;
}

#pragma mark ***** set Controls values *****
-(void)setName:(NSString*)val
{
	nameField.text = val;
	return;
}

-(void)setTime:(NSString*)val
{
	[gameTimeVal setString:[NSString stringWithFormat:@"%@ min",val]];
	return;
}

-(void)setInc:(NSString*)val
{
	[gameIncVal setString:[NSString stringWithFormat:@"%@ sec",val]];
	return;
}

-(void)setPieceColor:(NSString*)val
{
	pieceColorFair.isEnabled   = YES;
	pieceColorWhite.isEnabled = YES;
	pieceColorBlack.isEnabled = YES;
	switch([val intValue])
	{
		case 0:
			pieceColorFair.isEnabled = NO;
			break;
		case 1:
			pieceColorWhite.isEnabled = NO;
			break;
		case 2:
			pieceColorBlack.isEnabled = NO;
			break;
	}
	return;
}

-(void)setRatingType:(NSString*)val
{
	rateTypeRated.isEnabled = YES;
	rateTypeUnrated.isEnabled = YES;
	switch([val intValue])
	{
		case 0:
			rateTypeRated.isEnabled = NO;
			break;
		case 1:
			rateTypeUnrated.isEnabled = NO;
			break;
	}
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
