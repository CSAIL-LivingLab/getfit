//
//  ActivityPickerView.m
//  GetFit
//
//  Created by Albert Carter on 12/27/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "ActivityPickerView.h"

@implementation ActivityPickerView

- (instancetype) init {
    self = [super init];
    
    if (self) {
        // Init the data array.
        self.dataArray = [[NSMutableArray alloc] init];
        
        // Add some data for demo purposes.
        [self.dataArray addObject:@"Running"];
        [self.dataArray addObject:@"Jogging"];
        [self.dataArray addObject:@"Three"];
        [self.dataArray addObject:@"Four"];
        [self.dataArray addObject:@"Five"];
        
        float screenWidth = [UIScreen mainScreen].bounds.size.width;
        self.pickerView = [[UIPickerView alloc] init];
        
        // Calculate the starting x coordinate.
        float xPoint = screenWidth / 2 - screenWidth / 2;
        
        
        // Set the delegate and datasource. Don't expect picker view to work
        // correctly if you don't set it.
        [self.pickerView setDataSource: self];
        [self.pickerView setDelegate: self];
        
        // Set the picker's frame. We set the y coordinate to 50px.
        [self.pickerView setFrame: CGRectMake(xPoint, 50.0f, screenWidth, 200.0f)];
        
        // Before we add the picker view to our view, let's do a couple more
        // things. First, let the selection indicator (that line inside the
        // picker view that highlights your selection) to be shown.
        self.pickerView.showsSelectionIndicator = YES;
        
        // Allow us to pre-select the third option in the pickerView.
        [self.pickerView selectRow:2 inComponent:0 animated:YES];
        
        // OK, we are ready. Add the picker in our view.
//        [self addSubview: self.pickerView];
    }
    
    return self;
}

// Number of components.
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.dataArray count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.dataArray objectAtIndex: row];
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"You selected this: %@", [self.dataArray objectAtIndex: row]);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
