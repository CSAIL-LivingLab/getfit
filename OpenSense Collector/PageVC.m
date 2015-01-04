//
//  PageVC.m
//  GetFit
//
//  Created by Albert Carter on 12/28/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "PageVC.h"
#import "GraphVC.h"
#import "AboutVC.h"
#import "ExerciseVC.h"

@interface PageVC ()

@property ExerciseVC *exerciseVC;
@property GraphVC *graphVC;
@property AboutVC *aboutVC;
@property NSArray *viewControllerArray;

@end

@implementation PageVC
@synthesize exerciseVC, graphVC, aboutVC, viewControllerArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    graphVC = [[GraphVC alloc]init];
    aboutVC = [[AboutVC alloc] init];
    exerciseVC = [[ExerciseVC alloc] init];
    
    viewControllerArray = [[NSArray alloc] initWithObjects:exerciseVC, graphVC, aboutVC, nil];
    
    if (graphVC != nil) {
        self.dataSource = self;
        
        [self setViewControllers:@[graphVC]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:NULL];
        
        
    }
}


#pragma mark - UIPageViewControllerDelegate
- (UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {

    NSUInteger index = [viewControllerArray indexOfObject:viewController];
    if (index >= [viewControllerArray count]-1) {
        return nil;
    } else {
        return [viewControllerArray objectAtIndex:index+1];
    }
}

- (UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    NSUInteger index = [viewControllerArray indexOfObject:viewController];
    if (index <= 0) {
        return nil;
    } else {
        return [viewControllerArray objectAtIndex:index-1];
    }
}

- (void) pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    NSLog(@"PageViewController didFinishAnimating");
}


#pragma mark - UIPageViewController Page Count

- (NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [viewControllerArray count];
}

- (NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // start at page 1
    return 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
