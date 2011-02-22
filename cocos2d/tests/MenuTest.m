//
// Menu Demo
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//


#import "MenuTest.h"

enum {
	kTagMenu = 1,
};

@implementation Layer1
-(id) init
{
	[super init];
	
	[MenuItemFont setFontSize:30];
	[MenuItemFont setFontName: @"Courier New"];
	
	
	MenuItem *item1 = [MenuItemFont itemFromString: @"Start" target:self selector:@selector(menuCallback:)];
	MenuItem *item2 = [MenuItemImage itemFromNormalImage:@"SendScoreButton.png" selectedImage:@"SendScoreButtonPressed.png" target:self selector:@selector(menuCallback2:)];
	MenuItem *item3 = [MenuItemFont itemFromString: @"Disabled Item" target: self selector:@selector(menuCallbackDisabled:)];
	MenuItem *item4 = [MenuItemFont itemFromString: @"I toggle enable items" target: self selector:@selector(menuCallbackEnable:)];
	MenuItem *item5 = [MenuItemFont itemFromString: @"Configuration" target: self selector:@selector(menuCallbackConfig:)];
	
	MenuItemFont *item6 = [MenuItemFont itemFromString: @"Quit" target:self selector:@selector(onQuit:)];
	
	[[item6 label] setRGB:255:0:32];

	Menu *menu = [Menu menuWithItems: item1, item2, item3, item4, item5, item6, nil];
	[menu alignItemsVertically];

	disabledItem = [item3 retain];
	disabledItem.isEnabled = NO;

	[self addChild: menu];

	return self;
}

-(void) dealloc
{
	[disabledItem release];
	[super dealloc];
}

-(void) menuCallback: (id) sender
{
	[(MultiplexLayer*)parent switchTo:1];
}

-(void) menuCallbackConfig:(id) sender
{
	[(MultiplexLayer*)parent switchTo:3];
}

-(void) menuCallbackDisabled:(id) sender {
}

-(void) menuCallbackEnable:(id) sender {
	disabledItem.isEnabled = ~disabledItem.isEnabled;
}

-(void) menuCallback2: (id) sender
{
	[(MultiplexLayer*)parent switchTo:2];
}

-(void) onQuit: (id) sender
{
	[[Director sharedDirector] end];
	if( [[UIApplication sharedApplication] respondsToSelector:@selector(terminate)] )
		[[UIApplication sharedApplication] performSelector:@selector(terminate)];
}
@end

@implementation Layer2
-(id) init
{
	[super init];
	
	isTouchEnabled = YES;
	
	MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"btn-play-normal.png" selectedImage:@"btn-play-selected.png" target:self selector:@selector(menuCallbackBack:)];
	MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"btn-highscores-normal.png" selectedImage:@"btn-highscores-selected.png" target:self selector:@selector(menuCallbackH:)];
	MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"btn-about-normal.png" selectedImage:@"btn-about-selected.png" target:self selector:@selector(menuCallbackV:)];
	
	Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
	
	menu.tag = kTagMenu;
	[menu alignItemsHorizontally];

	menu.opacity = 128;

	[self addChild: menu];

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) menuCallbackBack: (id) sender
{
// One way to obtain the menu is:
//	[self  getChildByTag:xxx]
	id menu = [self getChildByTag:kTagMenu];
	[menu setOpacity: 128];

	[(MultiplexLayer*)parent switchTo:0];
}

-(void) menuCallbackH: (id) sender
{
	// Another way to obtain the menu
	// in this particular case is:
	// self.parent

	id menu = [sender parent];
	[menu setOpacity: 255];
	[menu alignItemsHorizontally];
}
-(void) menuCallbackV: (id) sender
{
	id menu = [self getChildByTag:kTagMenu];
	[menu alignItemsVertically];
}

-(BOOL) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// you will only receive this message if Menu doesn't handle the touchesBegan event
	// new in v0.6
	NSLog(@"touches received");
	return kEventHandled;
}

@end

@implementation Layer3
-(id) init
{
	[super init];
	[MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:28];

	MenuItemFont *item1 = [MenuItemFont itemFromString: @"Another option" target:self selector:@selector(menuCallback2:)];
	MenuItemFont *item2 = [MenuItemFont itemFromString: @"--- Go Back ---" target:self selector:@selector(menuCallback:)];
	
	Menu *menu = [Menu menuWithItems: item1, item2, nil];	
	menu.position = cpv(0,0);
	
	item1.position = cpv(100,100);
	item2.position = cpv(100,200);
	
	id jump = [JumpBy actionWithDuration:3 position:cpv(400,0) height:50 jumps:4];
	[item2 runAction: [RepeatForever actionWithAction:
				 [Sequence actions: jump, [jump reverse], nil]
								   ]
	 ];
	id spin1 = [RotateBy actionWithDuration:3 angle:360];
	id spin2 = [[spin1 copy] autorelease];
	
	[item1 runAction: [RepeatForever actionWithAction:spin1]];
	[item2 runAction: [RepeatForever actionWithAction:spin2]];
	
	[self addChild: menu];
	
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) menuCallback: (id) sender
{
	[(MultiplexLayer*)parent switchTo:0];
}

-(void) menuCallback2: (id) sender
{
}

@end


@implementation Layer4
-(id) init
{
	[super init];

	[MenuItemFont setFontName: @"American Typewriter"];
	[MenuItemFont setFontSize:18];
	MenuItemFont *title1 = [MenuItemFont itemFromString: @"Sound"];
    [title1 setIsEnabled:NO];
	[MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:34];
    MenuItemToggle *item1 = [MenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
                             [MenuItemFont itemFromString: @"On"],
                             [MenuItemFont itemFromString: @"Off"],
                             nil];
    
	[MenuItemFont setFontName: @"American Typewriter"];
	[MenuItemFont setFontSize:18];
	MenuItemFont *title2 = [MenuItemFont itemFromString: @"Music"];
    [title2 setIsEnabled:NO];
	[MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:34];
    MenuItemToggle *item2 = [MenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
                             [MenuItemFont itemFromString: @"On"],
                             [MenuItemFont itemFromString: @"Off"],
                             nil];
    
	[MenuItemFont setFontName: @"American Typewriter"];
	[MenuItemFont setFontSize:18];
	MenuItemFont *title3 = [MenuItemFont itemFromString: @"Quality"];
    [title3 setIsEnabled:NO];
	[MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:34];
    MenuItemToggle *item3 = [MenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
                             [MenuItemFont itemFromString: @"High"],
                             [MenuItemFont itemFromString: @"Low"],
                             nil];
    
	[MenuItemFont setFontName: @"American Typewriter"];
	[MenuItemFont setFontSize:18];
	MenuItemFont *title4 = [MenuItemFont itemFromString: @"Volume"];
    [title4 setIsEnabled:NO];
	[MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:34];
    MenuItemToggle *item4 = [MenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
                             [MenuItemFont itemFromString: @"Off"],
                             [MenuItemFont itemFromString: @"33%"],
                             [MenuItemFont itemFromString: @"66%"],
                             [MenuItemFont itemFromString: @"100%"],
                             nil];
    // you can change the one of the items by doing this
    item4.selectedIndex = 2;
    
    [MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:34];
	MenuItemFont *back = [MenuItemFont itemFromString: @"Go Back" target:self selector:@selector(backCallback:)];

    
	Menu *menu = [Menu menuWithItems:
                  title1, title2,
                  item1, item2,
                  title3, title4,
                  item3, item4,
                  back, nil]; // 9 items.
    [menu alignItemsInColumns:
     [NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:1],
     nil
    ]; // 2 + 2 + 2 + 2 + 1 = total count of 9.
    
	[self addChild: menu];
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) menuCallback: (id) sender
{
	NSLog(@"selected item: %@ index:%d", [sender selectedItem], [sender selectedIndex] );
}

-(void) backCallback: (id) sender
{
	[(MultiplexLayer*)parent switchTo:0];
}

@end



// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// must be called before any othe call to the director
//	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setLandscape: YES];

	// show FPS
	[[Director sharedDirector] setDisplayFPS:YES];

	// multiple touches or not ?
//	[[Director sharedDirector] setMultipleTouchEnabled:YES];
	
	// frames per second
	[[Director sharedDirector] setAnimationInterval:1.0/60];	

	// attach cocos2d to a window
	[[Director sharedDirector] attachInView:window];

	Scene *scene = [Scene node];

	MultiplexLayer *layer = [MultiplexLayer layerWithLayers: [Layer1 node], [Layer2 node], [Layer3 node], [Layer4 node], nil];
	[scene addChild: layer z:0];

	[window makeKeyAndVisible];
	[[Director sharedDirector] runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window dealloc];
	[super dealloc];
}

@end
