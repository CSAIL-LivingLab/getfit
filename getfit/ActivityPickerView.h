//
//  ActivityPickerView.h
//  GetFit
//
//  Created by Albert Carter on 12/27/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityPickerView : NSObject <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) NSMutableArray *dataArray;

@end
