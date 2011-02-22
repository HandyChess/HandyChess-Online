//
//  SettingScene.h
//  HandyChess
//
//  Created by Anton Zemyanov on 01.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface SettingsScene : Scene <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
	GLuint opacity;
	IBOutlet UITableView			*tabView;
	IBOutlet UINavigationController *navCtrl;
	
	UITextField *host;
	UITextField *port;
	UITextField *login;
	UITextField *password;
	UISwitch	*loginAsGuest;
	UISwitch	*showLegalMoves;
	UISwitch	*autoFlag;
	UIButton	*registerButton;
}

@property (nonatomic, retain) IBOutlet UITableView	*tabView;
@property (nonatomic, retain) IBOutlet UINavigationController *navCtrl;

-(void)showSettingsView:(id)obj;
-(void)hideSettingsView:(id)obj;

-(IBAction)donePressed:(id)obj;

@end
