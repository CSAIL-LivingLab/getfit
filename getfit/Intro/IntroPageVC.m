//
//  IntroPageVC.m
//  GetFit
//
//  Created by Albert Carter on 1/6/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "IntroPageVC.h"
#import "IntroAboutVC.h"
#import "IntroDetailVC.h"

@interface IntroPageVC ()

@property IntroAboutVC*introAboutVC;
@property IntroDetailVC *introDetailVC;
@property NSArray *viewControllerArray;

@end

@implementation IntroPageVC
@synthesize introAboutVC, introDetailVC, viewControllerArray;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    introAboutVC = [[IntroAboutVC alloc] initWithParentPageVC:self];
    introDetailVC = [[IntroDetailVC alloc] init];
    
    viewControllerArray = [[NSArray alloc] initWithObjects:introAboutVC, nil];
    [self setTitle:@"Welcome!"];
    if (introAboutVC !=nil ) {
        self.dataSource = self;
        [self setViewControllers:@[introAboutVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    }
    
}

- (void) addIntroDetailVCToArr {
    if ([viewControllerArray count] < 2) {
        introDetailVC = [[IntroDetailVC alloc] init];
        viewControllerArray = [[NSArray alloc] initWithObjects:introAboutVC, introDetailVC, nil];
        [self setViewControllers:@[introAboutVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    }
}

- (void) pushDetailVC {
    [self setViewControllers:@[introDetailVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
}

- (void) removeIntroDetailVCFromArr {
    if ([viewControllerArray count] > 1) {
        viewControllerArray = [[NSArray alloc] initWithObjects:introAboutVC, nil];
    }
}

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



#pragma mark - UIPageViewController Page Count

- (NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [viewControllerArray count];
}

- (NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
