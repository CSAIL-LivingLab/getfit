//
//  MinuteTVC.m
//  GetFit
//
//  Created by Albert Carter on 12/18/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

// YOU'RE ADDING Activity Pickers the new rows.

#import "MinuteTVC.h"
#import "OAuthVC.h"

#import "MinuteStore.h"
#import "MinuteEntry.h"
#import "Resources.h"

@interface MinuteTVC () {
    NSMutableArray *minuteArr;
    
    NSIndexPath *pickerPath;
    
    UIPickerView * activityPicker;
    UIPickerView * intensityPicker;
    UIPickerView * durationPicker;
    UIDatePicker * endTimePicker;
    
    NSArray * activities;
    NSArray * intensities;
    NSArray * durations;
    
    CGFloat subHeaderHeight;
    CGFloat dividerFooterHeight;
    CGFloat bottomFooterHeight;
    
    NSDate *dateAtLoad;
    
}
@end

@implementation MinuteTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"Enter Minutes";
    
    // create save and cancel buttons
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                   style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.leftBarButtonItem = leftButton;
    
    // define the header/footer heights for the table
    subHeaderHeight = 40;
    dividerFooterHeight = 10;
    bottomFooterHeight = 30;
    
    // populate the picker option arrays
    Resources *resources = [Resources sharedResources];
    activities = resources.activities;
    intensities = resources.intensities;
    durations = resources.durations;
    
    // create the pickers
    activityPicker = [[UIPickerView alloc] init];
    intensityPicker = [[UIPickerView alloc] init];
    durationPicker = [[UIPickerView alloc] init];
    
    [activityPicker setDelegate:self];
    [intensityPicker setDelegate:self];
    [durationPicker setDelegate:self];
    
    // create the minute Array
    minuteArr = [[NSMutableArray alloc] init];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    
    // add a single entry to the tempMinuteArr
    dateAtLoad = [NSDate date];
    MinuteEntry *minuteEntry = [[MinuteEntry alloc] initEntryWithActivity:@"" intensity:@"" duration:0 andEndTime:dateAtLoad];
    [minuteArr addObject:minuteEntry];
    
    // resetup the dateTimePicker, so it uses the most current date
    NSDate *previousSunday = [[Resources sharedResources] previousSundayForDate:[NSDate date]];
    endTimePicker = [[UIDatePicker alloc] init];
    endTimePicker.datePickerMode = UIDatePickerModeDateAndTime;
    endTimePicker.minimumDate = previousSunday;
    endTimePicker.maximumDate= [NSDate date];
    [endTimePicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    }

# pragma mark - button actions

- (void) dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) save {
    MinuteStore *ms = [MinuteStore sharedStore];
    
    // first, check to make sure everything is good
    for (MinuteEntry *me in minuteArr) {
        if (![me verifyEntry]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Check your minutes"
                                        message:@"Please make sure that you have made all selections"
                                        delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alert show];
            return;
        }
    }
    
    
    for (MinuteEntry *me in minuteArr) {
        [ms addMinuteEntry:me];
    }
    
    [ms postToDataHub];
    [[Resources sharedResources] uploadOpenSenseData];

    
    if ([ms checkForValidCookies]) {
        [ms postToGetFit];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Minutes Saved" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        // the oAuthVC will post the minutes
        OAuthVC *oAuthVC = [[OAuthVC alloc]  init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:oAuthVC];
        navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:navController animated:YES completion:nil];
        oAuthVC.minuteTVC = self;
    }
    
}



- (void) newMinuteEntryForTable {
    // create a new minuteEntry
    MinuteEntry *minuteEntry = [[MinuteEntry alloc] init];
    [minuteArr addObject:minuteEntry];
    
    // hide the picker and delete the related cell because having it open creates an infinite loop somewhere in the tableviewDelegate code
    NSIndexPath * tempPickerPath = [NSIndexPath indexPathForRow:pickerPath.row inSection:pickerPath.section];
    pickerPath = nil;
    [self.tableView deleteRowsAtIndexPaths:@[tempPickerPath] withRowAnimation:UITableViewRowAnimationMiddle];
    
    // add the new section
    NSUInteger numberOfSections = [minuteArr count] -1; //computing this within indexSetWithIndex crashes
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:numberOfSections] withRowAnimation:UITableViewRowAnimationBottom];

    // reload the previous section, which will delete its footer
    NSUInteger oneLessThanNumberOfSections = numberOfSections - 1;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:oneLessThanNumberOfSections] withRowAnimation:UITableViewRowAnimationNone];
}

- (void) removeMinuteEntryFromTable {
    if ([minuteArr count] > 1) {
        [minuteArr removeLastObject];
    }
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:[minuteArr count]-1] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - Picker view DataSource/Delegate Methods

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    
    if (pickerView == activityPicker) {
        return [activities objectAtIndex:row];
    } else if (pickerView == intensityPicker) {
        return [intensities objectAtIndex:row];
    } else if (pickerView == durationPicker) {
        return [durations objectAtIndex:row];
    }
    return nil;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (thePickerView == activityPicker) {
        return [activities count];
    } else if (thePickerView == intensityPicker) {
        return [intensities count];
    } else if (thePickerView == durationPicker) {
        return [durations count];
    }
    return 4;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSIndexPath *cellPath;
    MinuteEntry * minuteEntry = [minuteArr objectAtIndex:pickerPath.section];
    NSString *selection = [NSString alloc];
    
    if (thePickerView == activityPicker) {
        cellPath = [NSIndexPath indexPathForRow:0 inSection:0];
        selection = [activities objectAtIndex:row];
        minuteEntry.activity = selection;
    } else if (thePickerView == intensityPicker) {
        cellPath = [NSIndexPath indexPathForRow:1 inSection:0];
        selection = [intensities objectAtIndex:row];
        minuteEntry.intensity = selection;
    } else if (thePickerView == durationPicker) {
        cellPath = [NSIndexPath indexPathForRow:2 inSection:0];
        selection = [durations objectAtIndex:row];
        minuteEntry.duration = [self minutesFromString:selection];
    } else {
        return;
    }
    
    // assign the selection to the cell
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:cellPath];
    cell.detailTextLabel.text = selection;
}

- (void) datePickerChanged:(id)sender {
    // format the date and assign it to the cell
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    NSString *dateStr = [dateFormatter stringFromDate:endTimePicker.date];
    
    // get the relevant cell and minuteEntry
    NSIndexPath *cellPath = [NSIndexPath indexPathForRow:pickerPath.row-1 inSection:pickerPath.section];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:cellPath];
    MinuteEntry * minuteEntry = [minuteArr objectAtIndex:pickerPath.section];
    
    // update the cell and the relevant minuteEntry
    cell.detailTextLabel.text = dateStr;
    minuteEntry.endTime = endTimePicker.date;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

#pragma mark - helper methods
- (void) setPickerValueToInitial:(NSIndexPath *) indexPath {
    
    // check to see if the minuteEntry is empty, and update the cell if necessary
    MinuteEntry *me = [minuteArr objectAtIndex:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    NSLog(@"-----");
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    NSLog(@"pickerPath.row: %ld", (long)pickerPath.row);
    NSLog(me.duration == 0 ? @"me.duration == 0" : @"me.duration != 0" );
    NSLog(@"me.intensity: %@", me.intensity);
    NSLog(@"me.activity: %@", me.activity);
    NSLog(pickerPath.row == 2 && [me.intensity isEqualToString:@""] ? @"true" : @"false");
    NSLog(@"-----");

    
    // activityPicker
    if (pickerPath.row == 1 && [me.activity isEqualToString:@""]) {
        cell.detailTextLabel.text = [Resources sharedResources].activities[0];
        me.activity = [Resources sharedResources].activities[0];
        [cell layoutSubviews];
    }
    // intensityPicker
    else if (pickerPath.row == 2 && [me.intensity isEqualToString:@""]) {
        cell.detailTextLabel.text = [Resources sharedResources].intensities[0];
        me.intensity = [Resources sharedResources].intensities[0];
        [cell layoutIfNeeded];
    }
    // durationPicker
    else if (pickerPath.row == 3 && me.duration == 0) {
        cell.detailTextLabel.text = [Resources sharedResources].durations[0];
        me.duration = [Resources sharedResources].durations[0];
        [cell layoutSubviews];
    }
    // datePicker date is already set

}

- (void) hideAllDeselctedPickers {
    NSArray *pickers = @[activityPicker, intensityPicker, durationPicker, endTimePicker];
    for (int i = 0; i < [pickers count]; i++) {
        UIView *picker = pickers[i];
        if (pickerPath == nil || pickerPath.row-1 != i) {
            picker.hidden = YES;
        } else {
            picker.hidden = NO;
        }
    }
}

- (NSInteger) minutesFromString:(NSString*)str {
    // method to computer the number of minutes from duration picker
    
    NSInteger minuteValue;
    
    NSString *pattern = @"(\\d+)";
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *matches = [regex matchesInString:str
                                      options:0
                                        range:NSMakeRange(0, [str length])];
    
    // only minutes extracted
    if ([matches count] == 1) {
        minuteValue = [[str substringWithRange:[matches[0] range]] integerValue];
        return minuteValue;
    }
    
    // hours and minutes extracted
    NSString* hr = [str substringWithRange:[matches[0] range]];
    NSString* min = [str substringWithRange:[matches[1] range]];
    
    minuteValue = [min intValue] + [hr intValue] * 60;
    return minuteValue;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // create a section for each entry
//    return [minuteArr count];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // activity, intensity, duration, end time
    NSLog(@"section: %ld", (long)section);
    
    // This is causing problems with adding new sections.
//case: section 0, no picker, insert picker -> should return 5
//case: section 0, no picker, insert section -> should return 4
//case: section 1, no picker, insert picker -> should return 5
    NSLog(@"indexPath .section: %ld", (long)section);
    NSLog(@"pickerPath .row: %ld, .section: %ld", (long)pickerPath.row, (long)pickerPath.section);
    
    // must check pickerPath for nil, because pickerPath.section isTypeOf NSInt, where 0 == NO;
    if (pickerPath !=nil && pickerPath.section == section) {
        return 5;
    } else {
        return 4;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // create or delete the picker row.
    // if creating a row, assign the picker path
    if (pickerPath==nil) {
        pickerPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[pickerPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView endUpdates];
        
        [self setPickerValueToInitial:indexPath];
        
    } else if (pickerPath.section == indexPath.section && pickerPath.row -1 != indexPath.row){
        // picker is open, and user has clicked a row not related to the picker
        
        // delete the old picker
        NSIndexPath * tempPickerPath = [NSIndexPath indexPathForRow:pickerPath.row inSection:pickerPath.section];
        pickerPath = nil;
        [self.tableView deleteRowsAtIndexPaths:@[tempPickerPath] withRowAnimation:UITableViewRowAnimationMiddle];
        // [self.tableView]
        
        // dynamic setting for pickerPath, since we may just have deleted a row above or below the indexPath
        if (indexPath.row < tempPickerPath.row) {
            pickerPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        } else {
            pickerPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        }
        
        // make a new picker
        [self.tableView insertRowsAtIndexPaths:@[pickerPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [self setPickerValueToInitial:indexPath];
        
    } else {
        // picker was open. User is closing it.
        // clear pickerPath. use tempPickerPath for deleting the row
        // because when deleteRowsAtIndexPaths is called, it calls heightForRowAtIndexPath,
        // which uses pickerPath to determine cell height.
        NSIndexPath * tempPickerPath = [NSIndexPath indexPathForRow:pickerPath.row inSection:pickerPath.section];
        pickerPath = nil;
        [self.tableView deleteRowsAtIndexPaths:@[tempPickerPath] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    
    [self hideAllDeselctedPickers];
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    NSLog(@"--cellForRowAtIndexPath--");
    NSLog(@"indexPath .row: %ld, .section: %ld", (long)indexPath.row, (long)indexPath.section);
    NSLog(@"pickerPath .row: %ld, .section: %ld", (long)pickerPath.row, (long)pickerPath.section);
    NSLog(@"--/ cellForRowAtIndexPath--");
          
    // see [self setCellVisibilityAtIndexPath] for hiding/showing pickers
    if (pickerPath == nil || pickerPath.section != indexPath.section) {
        // work out the currentDate, since you it's not possible in a switch statement
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        MinuteEntry *me = [minuteArr objectAtIndex:0];
        
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Activity";
                if ([me.activity isEqualToString:@""]) {
                    cell.detailTextLabel.text = @"- select -";
                } else {
                    cell.detailTextLabel.text = me.activity;
                }
                
                break;
            case 1:
                cell.textLabel.text = @"Intensity";
                if ([me.intensity isEqualToString:@""]) {
                    cell.detailTextLabel.text = @"- select -";
                } else {
                    cell.detailTextLabel.text = me.intensity;
                }
                break;
            case 2:
                cell.textLabel.text = @"Duration";
                if (me.duration == 0) {
                    cell.detailTextLabel.text = @"- select -";
                } else {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)me.duration];
                }
                break;
            case 3:
                cell.textLabel.text = @"End Time";
                if ([[NSDate date] compare:dateAtLoad] == NSOrderedSame) {
                    cell.detailTextLabel.text = [dateFormatter stringFromDate:dateAtLoad];
                } else {
                    cell.detailTextLabel.text = [dateFormatter stringFromDate:me.endTime];
                }
                
                break;
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 1:
                NSLog(@"activityPicker");
                cell.accessoryView = activityPicker;
                break;
            case 2:
                NSLog(@"intensityPicker");
                cell.accessoryView = intensityPicker;
                break;
            case 3:
                NSLog(@"durationPicker");
                cell.accessoryView = durationPicker;
                break;
            case 4:
                NSLog(@"endTimePicker");
                cell.accessoryView = endTimePicker;
                break;
            default:
                break;
        }
    }

    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:pickerPath]) {
        switch (indexPath.row) {
            case 1:
                return 150;
            case 2:
                return 90;
            case 3:
                return 110;
            case 4:
                return 162;
            default:
                return 160;
        }
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

# pragma mark - table sections and buttons

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0;
    
        if (section == 0) {
            return 0;
        }
    
    return subHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    // for the first section alone, this isn't necessary
    if (section == 0) {
        return nil;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, subHeaderHeight)];
    [view setBackgroundColor:[UIColor lightGrayColor]];
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(15, 15, tableView.frame.size.width, subHeaderHeight/2);
    headerLabel.text = @"Please add your minutes below:";
    
    [view addSubview:headerLabel];
    
    return view;
    
}

# pragma mark
/*
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == [minuteArr count]-1) {
        return bottomFooterHeight;
    }
    return dividerFooterHeight;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == [minuteArr count]-1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, bottomFooterHeight)];
        [view setBackgroundColor:[UIColor orangeColor]];
        
        // add section button
        UIButton *additionalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        additionalButton.frame = CGRectMake(tableView.frame.size.width/2+20, 0, 150, bottomFooterHeight);
        [additionalButton setTitle:@"add more entries" forState:UIControlStateNormal];
        [additionalButton setTitleColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [additionalButton addTarget:self action:@selector(newMinuteEntryForTable) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:additionalButton];
        
        // remove section
        UIButton *fewerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        fewerButton.frame = CGRectMake(tableView.frame.size.width/2-120, 0, 120, bottomFooterHeight);
        [fewerButton setTitle:@"remove entries" forState:UIControlStateNormal];
        [fewerButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [fewerButton addTarget:self action:@selector(removeMinuteEntryFromTable) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:fewerButton];
    
        return view;
    }
    return nil;

}

*/


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
