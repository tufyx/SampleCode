//
//  TrendsViewController.m
//  OmaTauko
//
//  Created by Vlad Tufis on 08/01/2014.
//  Copyright (c) 2014 Vlad Tufis. All rights reserved.
//

#import "TrendsViewController.h"
#import "TrendsView.h"
#import "OmaTaukoAppDelegate.h"
#import "APICaller.h"
#import "strings.h"

@interface TrendsViewController ()
#pragma mark - Outlets
// the view displaying the workout trends
@property (strong, nonatomic) IBOutlet TrendsView *trendsView;
// containers keeping the labels which display the tens digit and units digit of the break days in row number
@property (strong, nonatomic) IBOutlet UIView *daysTContainer;
@property (strong, nonatomic) IBOutlet UIView *daysUContainer;
// the labels displaying the tens digit and units digit of the break days in row number
@property (strong, nonatomic) IBOutlet UILabel *daysTLabel;
@property (strong, nonatomic) IBOutlet UILabel *daysULabel;
// the labels displaying the static text TrendsVC_BREAK_DAYS_ROW, TrendsVC_BREAK_DISTRIBUTION (strings.h)
@property (strong, nonatomic) IBOutlet UILabel *breakDaysInRowLabel;
@property (strong, nonatomic) IBOutlet UILabel *breakDistributionLabel;
// the view displaying the loading spinner and error label when loading break distribution data
@property (strong, nonatomic) IBOutlet UIView *activityView;
// the loading spinner displayed when loading break distribution data
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
// the label displaying the error message when the fetching of distribution data has failed
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;

#pragma mark - Private properties
// the number of break days in row
@property (nonatomic) NSUInteger breakDaysInRow;
// the object managing the API calls
@property (strong, nonatomic) APICaller *apiCaller;
@end

@implementation TrendsViewController

// setter for the breakDaysInRow property; when the number is set it also updates the corresponding labels
- (void) setBreakDaysInRow:(NSUInteger)breakDaysInRow
{
    _breakDaysInRow = breakDaysInRow;
    // uodate the corresponding labels
    [self updateBreakDaysInRow];
}

// reads the number of break days in row from the standard user defaults and sets the breakDaysInRow property of this class
- (void) readBreakDaysInRow
{
    NSInteger daysInRow = [[NSUserDefaults standardUserDefaults] integerForKey:@"OMATAUKO_DAYS_IN_ROW"];
    self.breakDaysInRow = daysInRow;
}

- (void) updateBreakDaysInRow
{
    self.daysTLabel.text = [NSString stringWithFormat:@"%u",(uint)self.breakDaysInRow / 10];
    self.daysULabel.text = [NSString stringWithFormat:@"%u",(uint)self.breakDaysInRow % 10];
    
    UIFont *daysLabelFont = [UIFont boldSystemFontOfSize:80];
    [self.daysTLabel setFont:daysLabelFont];
    [self.daysULabel setFont:daysLabelFont];
}

// getter for the apiCaller; lazy instantiation
- (APICaller *) apiCaller
{
    if(!_apiCaller) {
        _apiCaller = [[APICaller alloc] init];
    }
    return _apiCaller;
}

/**
 Refreshes the scene every time it is displayed
 Makes a request through the API to retrieve the newest distribution of exercises
 Reads the new number of break days in row
 */
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.activityView setHidden:NO];
    [self.errorLabel setHidden:YES];
    [self.activityIndicator startAnimating];
    [self.apiCaller retrieveExercisesOverallDistribution];
    [self readBreakDaysInRow];
    self.navigationController.navigationBar.hidden = YES;
}

// initializes the scene, shortly after it loaded
// configures the gestures
// configures the notifications
- (void) viewDidLoad
{
    [super viewDidLoad];
    [self configureUI];
    [self configureNotifications];
}

// configures the UI of the scene
// sets the static labels throughout the whole scene
- (void) configureUI
{
    self.view.autoresizesSubviews = YES;
    [self.daysTContainer.layer setCornerRadius:10];
    [self.daysUContainer.layer setCornerRadius:10];
    self.breakDaysInRowLabel.text = TrendsVC_BREAK_DAYS_ROW;
    self.breakDistributionLabel.text = TrendsVC_BREAK_DISTRIBUTION;
}

/**
 Registers listeners for the notifications to which the VC is responding
 DISTRIBUTION_RECEIVED - when the distribution of exercises has been retrieved and is ready to be displayed
 DISTRIBUTION_RECEIVED_ERROR - when an error occurred during the fetching of the data; possible reasons: corrupted JSON format, network error, etc.
 */
- (void) configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDistributionReceived:) name:@"DISTRIBUTION_RECEIVED" object:self.apiCaller];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDistributionReceivedError:) name:@"DISTRIBUTION_RECEIVED_ERROR" object:self.apiCaller];
}

/**
 Handles the successful fetching of the distribution data; the function performs UI operation, hence the instructions need to be executed on the main UI thread
 Sets the distributionData property of the trendsView which will display the pie chart
 */
- (void) handleDistributionReceived:(NSNotification *) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityView setHidden:YES];
        [self.activityIndicator stopAnimating];
        self.trendsView.distributionData = [notification.userInfo objectForKey:@"distributionData"];
    });
}

/**
 Handles the failed fetching of the current month; the function performs UI operation, hence the instructions need to be executed on the main UI thread
 Sets and displays the error messages; hides the activityIndicator
 */
- (void) handleDistributionReceivedError:(NSNotification *) notification
{
//    NSError *error = [notification.userInfo valueForKey:@"error"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.errorLabel setHidden:NO];
        [self.activityIndicator stopAnimating];
        self.errorLabel.text = NetworkErrorMessage;
    });
}
@end
