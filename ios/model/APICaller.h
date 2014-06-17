//
//  APICaller.h
//  SampleLogin
//
//  Created by Vlad Tufis on 17/01/2014.
//  Copyright (c) 2014 Vlad Tufis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "configuration.h"

@interface APICaller : NSObject
@property NSString *APIURL;
@property NSString *ChallengesAPIURL;

#pragma mark - initializers
- (instancetype) initWithURL:(NSString *)url;
- (instancetype) initBase;

#pragma mark - Statistics retrieval

// retrieves the daily statistics
- (void) retrieveDailyStatistics;
// retrieves the weekly statistics, according to the current date
- (void) retrieveWeeklyStatistics;
// retrieves the monthly statistics, according to the month and year passed in as input parameters
- (void) retrieveMonthlyStatisticsForMonth:(NSInteger)month Year:(NSInteger)year;
// retrieves the overall distribution of exercises with respect to duration and number of exercises
- (void) retrieveExercisesOverallDistribution;

#pragma mark - Break operations
// retrieves a new list of tasks that sum to the duration specified by the user and are performed with the preferred devices
- (void) retrieveNewBreakWithDuration:(int)duration;
// saves a completed/skipped break into the database
- (void) saveBreak:(NSDictionary *) breakInfo;


#pragma mark - User Profile operations
// retrieves the user details
- (void) retrieveUserInfo;
// performs the login operation for the current user
- (void) loginUser:(NSDictionary *)userDetails;
// performs the logout operation for the current user
- (void) logoutUser;
// recovers the password for the current user
- (void) recoverPassword:(NSDictionary *)userDetails;
// updates the user`s date of birth
- (void) updateUserDOB:(NSDictionary *)userDetails;
// updates the user`s username
- (void) updateUsername:(NSDictionary *)userDetails;


#pragma mark - Feedback operations
// saves feedback in the database
- (void) saveFeedback:(NSString *)feedback;

#pragma mark - Devices operations
// retrieves avaialable list of devices
- (void) retrieveDevices;

#pragma mark - Challenge operations
// retrieves the current active challenge
- (void) retrieveChallenge;

#pragma mark - Misc
+ (NSString *)retrieveAPIURL;
@end
