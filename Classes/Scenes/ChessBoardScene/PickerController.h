//
//  PickerController.h
//  HandyChess
//
//  Created by Anton on 5/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PickerController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
	IBOutlet UIPickerView *pickerView;
	
	id		target;
	SEL		valuePickedAction;
	
	NSArray *pickerData;
	NSUInteger pickerIndex;
}

@property (nonatomic,retain) IBOutlet UIPickerView *pickerView;

@property (nonatomic,assign) id		target;
@property (nonatomic,assign) SEL		valuePickedAction; 


-(id)initWithNibName:(NSString*)nib bundle:(NSBundle*)bun 
						 data:(NSArray*)data selectedIndex:(NSUInteger)selIndex;

-(IBAction)closePressed;
-(IBAction)selectPressed;

@end
