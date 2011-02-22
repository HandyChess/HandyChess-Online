//
//  SettingScene.m
//  HandyChess
//
//  Created by Anton Zemyanov on 01.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SettingsScene.h"

#import "Transitions.h"
#import "MainMenuScene.h"
#import "SoundEngine.h"

#import "Logger.h"

#define SETTINGS_NUMBER_OF_SECTIONS	3
#define SETTINGS_SECTION_0_ROWS			2
#define SETTINGS_SECTION_1_ROWS			3
#define SETTINGS_SECTION_2_ROWS			2

@implementation SettingsScene

@synthesize tabView;
@synthesize navCtrl;


-(id)init
{
	if(self = [super init])
	{
		MsgLog(@"Create settings scene");

		// background
		//Sprite *img = [Sprite spriteWithFile:@"bg2_320x480.png"];
		//img.position = cpv(160,240);
		//[self addChild:img];
		
		AtlasSpriteManager *bgAtlasManager = [AtlasSpriteManager spriteManagerWithFile:@"bg2_320x480.pvr"];
		[self addChild:bgAtlasManager];
		
		AtlasSprite *bgImage = [AtlasSprite spriteWithRect:CGRectMake(5,5,320,480) spriteManager:bgAtlasManager];
		//bgImage.tag = BOARD_NODE_BGIMAGE;
		bgImage.position = cpv(160,240);
		[bgAtlasManager addChild:bgImage];		
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

-(void)showSettingsView:(id)obj
{
	MsgLog(@"showSettingsView");
	NSArray *arr = [[[NSBundle mainBundle] loadNibNamed:@"Settings" owner:self options:nil] retain];
	if([arr count]==0)
		[NSException raise:@"bad arr" format:@"bad arr"];
	
	[navCtrl.view setFrame:CGRectMake(0,0,320,480)];
	[navCtrl.view setOpaque:YES];
	[navCtrl.view setAlpha:1.0f];
	
	UIColor *backgroundColor = [UIColor clearColor];
	tabView.backgroundColor = backgroundColor;
	
	// separator
	//tabView.separatorColor = [UIColor colorWithRed:0.66f green:0.66f blue:0.66f alpha:1.0f];
	MsgLog(@"adding subview %@",navCtrl.view);
	[[Director sharedDirector].openGLView addSubview:navCtrl.view];
	
	return;
}

-(void)hideSettingsView:(id)obj
{
	MsgLog(@"hideSettingsView");
	[navCtrl.view removeFromSuperview];
}

-(IBAction)donePressed:(id)obj
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	[self hideSettingsView:nil];

	Scene *sc = [MainMenuScene node];
	TransitionScene *tr = [FadeTransition transitionWithDuration:0.3f scene:sc];
	[[Director sharedDirector] replaceScene:tr];
}

// ----- Settings table data source -----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return SETTINGS_NUMBER_OF_SECTIONS;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *header = nil;
	switch(section)
	{
		case 0:
			header = @"Chess Server";
			break;
		case 1:
			header = @"Account";
			break;
		case 2:
			header = @"Chess Settings";
			break;
		default:
			header = @"Invalid";
			break;
	}
	return header;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch(section)
	{
		case 0:
			return SETTINGS_SECTION_0_ROWS;
			break;
		case 1:
			return SETTINGS_SECTION_1_ROWS;
			break;
		case 2:
			return SETTINGS_SECTION_2_ROWS;
			break;
	}
	return 0;		
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MsgLog(@"sec=%d row=%d", indexPath.section, indexPath.row);
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
	if(cell==nil)
		cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 0, 0) reuseIdentifier:@"default"];
	
	switch(indexPath.section)
	{
		case 0:
			switch(indexPath.row)
			{
				case 0:
				{
					cell.text = @"Host:";
					host = [[UITextField alloc] initWithFrame:CGRectMake(70, 8, 230, 30)];
					host.delegate = self;
					host.borderStyle = UITextBorderStyleRoundedRect;
					host.text = [defs objectForKey:@"Host"];
					[cell addSubview:host];
					break;
				}
				case 1:
				{
					cell.text = @"Port:";
					port = [[UITextField alloc] initWithFrame:CGRectMake(70, 8, 80, 30)];
					port.delegate = self;
					port.borderStyle = UITextBorderStyleRoundedRect;
					port.text = [defs objectForKey:@"Port"];
					[cell addSubview:port];
					break;
				}
			}
			break;
			
		case 1:
			switch(indexPath.row)
			{
				case 0:
				{
					cell.text = @"Username:";
					login = [[UITextField alloc] initWithFrame:CGRectMake(120, 8, 180, 30)];
					login.delegate = self;
					login.borderStyle = UITextBorderStyleRoundedRect;
					login.text = [defs objectForKey:@"Login"];
					[cell addSubview:login];
					break;
				}
				case 1:
				{
					cell.text = @"Password:";
					password = [[UITextField alloc] initWithFrame:CGRectMake(120, 8, 180, 30)];
					password.delegate = self;
					password.borderStyle = UITextBorderStyleRoundedRect;
					password.text = [defs objectForKey:@"Password"];
					password.secureTextEntry = YES;
					[cell addSubview:password];
					break;
				}
				case 2:
				{
					/*
					cell.text = @"Login as guest ";
					*/
					registerButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
					registerButton.frame = CGRectMake(30, 0, 250, 40);
					[registerButton setTitle:@"Register on FICS" forState:UIControlStateNormal];
					[registerButton addTarget:self action:@selector(registerPressed:) forControlEvents:UIControlEventTouchUpInside];
					[cell addSubview:registerButton];
					
					break;
				}
			}
			break;
		
		case 2:
			switch(indexPath.row)
			{
				case 0:
				{
					cell.text = @"Show legal moves";
					showLegalMoves = [[UISwitch alloc] initWithFrame:CGRectMake(200, 8, 91, 31)];
					showLegalMoves.on = [defs boolForKey:@"ShowLegalMoves"];
					[showLegalMoves addTarget:self action:@selector(showLegalMovesChanged:) forControlEvents:UIControlEventValueChanged];
					[cell addSubview:showLegalMoves];
					break;
				}
				case 1:
				{
					cell.text = @"Autoflag status";
					autoFlag = [[UISwitch alloc] initWithFrame:CGRectMake(200, 8, 91, 31)];
					autoFlag.on = [defs boolForKey:@"AutoFlag"];
					[autoFlag addTarget:self action:@selector(autoFlagChanged:) forControlEvents:UIControlEventValueChanged];
					[cell addSubview:autoFlag];
					break;
				}
			}
			break;
			
		default:
			cell.text = @"Inv";
			break;
	}	
	return cell;
}

// ----- Settings table delegate -----
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	return;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	if(textField == host)
		[defs setObject:textField.text forKey:@"Host"];
	else if(textField == port)
		[defs setObject:textField.text forKey:@"Port"];
	else if(textField == login)
		[defs setObject:textField.text forKey:@"Login"];
	else if(textField == password)
		[defs setObject:textField.text forKey:@"Password"];
	
	return;
}

-(void)loginAsGuestChanged:(id)obj
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs setObject:(loginAsGuest.on ? @"1" : @"0") forKey:@"LoginAsGuest"];
	
	return;
}

-(void)autoFlagChanged:(id)obj
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs setObject:(autoFlag.on ? @"1" : @"0") forKey:@"AutoFlag"];
	
	return;
}

-(void)showLegalMovesChanged:(id)obj
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs setObject:(showLegalMoves.on ? @"1" : @"0") forKey:@"ShowLegalMoves"];
	
	return;
}

-(void)registerPressed:(id)theId
{
	[[SoundEngine sharedSoundEngine] playSound:@"tick.wav"];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.freechess.org/Register/index.html"]];
	return;
}

@end
