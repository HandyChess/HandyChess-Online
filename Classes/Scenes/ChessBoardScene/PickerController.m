//
//  PickerController.m
//  HandyChess
//
//  Created by Anton on 5/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PickerController.h"

@implementation PickerController

@synthesize target;
@synthesize valuePickedAction;
@synthesize pickerView;

-(id)initWithNibName:(NSString*)nib bundle:(NSBundle*)bun 
{
	[NSException raise:@"Error" format:@"Use full designated constructor"];
	return nil;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
-(id)initWithNibName:(NSString*)nib bundle:(NSBundle*)bun 
				data:(NSArray*)data selectedIndex:(NSUInteger)selIndex
{
    if (self = [super initWithNibName:nib bundle:bun]) 
	{
        // Custom initialization
		pickerData = [data retain];
		pickerIndex = selIndex;
    }
    return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
/*
- (void)loadView 
{
}
*/ 

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[pickerView selectRow:pickerIndex inComponent:0 animated:NO];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[pickerData release];
    [super dealloc];
}

#pragma mark ***** picker datasource *****
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [pickerData count];
}

#pragma mark ***** picker delegate *****
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [pickerData objectAtIndex:row];
}

#pragma mark ***** key handlers *****
-(IBAction)closePressed
{
	[self.view removeFromSuperview];
}

-(IBAction)selectPressed
{
	[self.view removeFromSuperview];
	if(target && valuePickedAction)
	{
		[target performSelector:valuePickedAction withObject:
				[NSNumber numberWithInt:[pickerView selectedRowInComponent:0]]];
	}
	return;
}

#pragma mark ***** touches *****
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
