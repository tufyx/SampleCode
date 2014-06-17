//
//  APICaller.m
//  SampleLogin
//
//  Created by Vlad Tufis on 17/01/2014.
//  Copyright (c) 2014 Vlad Tufis. All rights reserved.
//

#import "APICaller.h"
#import "Utils.h"
#import "OverallStatsItem.h"
#import "Task.h"

@interface APICaller()
@property (strong, nonatomic) NSMutableURLRequest *urlRequest;
@end
@implementation APICaller

+ (NSString *)retrieveAPIURL
{
    if(LIVE) {
        return API_URL_LIVE_BASE;
    }
    return API_URL_BETA_BASE;
}

- (instancetype) init
{
    self = [super init];
    if(self) {
        if(LIVE) {
            self.APIURL = API_URL_LIVE_DEFAULT;
        } else {
            self.APIURL = API_URL_BETA_DEFAULT;
            self.ChallengesAPIURL = @"http://dev.tufyx.com/OmaTaukoGoals/test_goals.php";
        }

    }
    return self;
}

- (instancetype) initBase
{
    NSString *baseURL = API_URL_BETA_BASE;
    if(LIVE) {
        baseURL = API_URL_LIVE_BASE;
    }
    return [self initWithURL:baseURL];
}

- (instancetype) initWithURL:(NSString *)url
{
    self = [super init];
    if (self) {
        self.APIURL = url;
    }
    return self;
}

/**
 Configures a url request with the following parameters:
 @param path - the path where the request should go
 @param method - the method of the request: GET,POST,PUT,DELETE
 @param data - the data sent along with the request
 
 Sets the header-type as JSON
 */
- (void) configureURLRequestForURL:(NSString *) path WithMethod:(NSString *)method AndData:(NSData *)data
{
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@",self.APIURL,path]];
    self.urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [self.urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.urlRequest setHTTPMethod:method];
    if(data) {
        [self.urlRequest setHTTPBody:data];
    }
}

/**
 Sends a request with the specified completion handler block
 The request is sent asynchronously
 */
- (void) sendRequestWithCompletionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completionHandler
{
    [NSURLConnection sendAsynchronousRequest:self.urlRequest
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:completionHandler];
}

- (void) retrieveDailyStatistics
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd-MM-yyyy"];
    NSString *today = [df stringFromDate:[NSDate date]];
    NSString *queryString = [NSString stringWithFormat:@"/userstatistics?startdate=%@&enddate=%@",today,today];
    
    [self configureURLRequestForURL:queryString WithMethod:@"GET" AndData:nil];
    [self sendRequestWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] >0 && error == nil) {
            NSError *jsonDecodeError;
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonDecodeError];
            NSInteger target = [[d objectForKey:@"target"] integerValue];
            NSInteger duration = 0;
            for (NSDictionary *item in [d objectForKey:@"entries"]) {
                duration = [[item objectForKey:@"duration"] integerValue];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DAILY_STATS_RETRIEVED" object:self userInfo:@{@"dailyStats":[NSNumber numberWithFloat:duration/60.0],@"target":[NSNumber numberWithFloat:target/60.0]}];
        }
        else if ([data length] == 0 && error == nil) {
            // nothing was downloaded
        }
        else if (error != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DAILY_STATS_RETRIEVED_ERROR" object:self userInfo:@{@"error":error}];
        }
    }];
}

- (void) retrieveWeeklyStatistics
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd-MM-yyyy"];
    NSDate *now = [NSDate date];
    
    NSUInteger dateComponentsFlags = (NSWeekCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekdayCalendarUnit);
    NSCalendar *c = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *dateComponents = [c components:dateComponentsFlags fromDate:now];
    NSInteger weekday = dateComponents.weekday;
    weekday -= 1;
    if(weekday == 0) {
        weekday = 7;
    }
    
    now = [now dateByAddingTimeInterval:(-1) * (weekday - 1) * 24 * 3600];
    NSString *startDate = [df stringFromDate:now];
    NSString *endDate = [df stringFromDate:[now dateByAddingTimeInterval:4 * 24 * 3600]];
    
    NSString *queryString = [NSString stringWithFormat:@"/userstatistics?startdate=%@&enddate=%@",startDate,endDate];
    
    [self configureURLRequestForURL:queryString WithMethod:@"GET" AndData:nil];
    [self sendRequestWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] >0 && error == nil) {
            NSError *jsonDecodeError;
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonDecodeError];
            NSMutableArray *weekdaysStatus = [[NSMutableArray alloc] initWithCapacity:5];
            int target = [[d objectForKey:@"target"] intValue];
            for (NSDictionary *item in [d objectForKey:@"entries"]) {
                int duration = [[item objectForKey:@"duration"] intValue];
                [weekdaysStatus addObject:[NSNumber numberWithBool: duration >= target ? 1 : 0]];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WEEKLY_STATS_RETRIEVED" object:self userInfo:@{@"weeklyStats":weekdaysStatus}];
        }
        else if ([data length] == 0 && error == nil) {
            // nothing was downloaded
        }
        else if (error != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WEEKLY_STATS_RETRIEVED_ERROR" object:self userInfo:@{@"error":error}];
        }
    }];
}

- (void) retrieveMonthlyStatisticsForMonth:(NSInteger)month Year:(NSInteger)year
{
    NSInteger endDay = [Utils daysInMonthForMonth:month Year:year];
    NSString *monthString = [NSString stringWithFormat:@"%ld",(long)month];
    if(month < 10) {
        monthString = [@"0" stringByAppendingString:monthString];
    }
    NSString *startDate = [NSString stringWithFormat:@"01-%@-%ld",monthString,(long)year];
    NSString *endDate = [NSString stringWithFormat:@"%ld-%@-%ld",(long)endDay,monthString,(long)year];
    
    NSString *queryString = [NSString stringWithFormat:@"/userstatistics?startdate=%@&enddate=%@",startDate,endDate];
    [self configureURLRequestForURL:queryString WithMethod:@"GET" AndData:nil];
    [self sendRequestWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if ([data length] >0 && error == nil) {
            NSError *jsonDecodeError;
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonDecodeError];
            int target = [[d objectForKey:@"target"] intValue];
            NSMutableArray *monthStats = [[NSMutableArray alloc] init];
            for (NSDictionary *item in [d objectForKey:@"entries"]) {
                int duration = [[item objectForKey:@"duration"] intValue];
                NSString *s = [item objectForKey:@"date"];
                NSString  *workout_date = [[s substringToIndex:[s rangeOfString:@"T"].location] stringByAppendingString:
                                           [NSString stringWithFormat:@" %@",[s substringFromIndex:[s rangeOfString:@"T"].location + 1]]];
                OverallStatsItem *item = [[OverallStatsItem alloc] initWithDate:workout_date Duration:duration Target:target];
                [monthStats addObject:item];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MONTHLY_STATS_RECEIVED" object:self userInfo:@{@"monthlyStats":monthStats,@"target":[NSNumber numberWithInt:target]}];
        }
        else if ([data length] == 0 && error == nil) {
            // nothing was downloaded
        }
        else if (error != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MONTHLY_STATS_RECEIVED_ERROR" object:self userInfo:@{@"error":error}];
        }
    }];
}

- (void) retrieveExercisesOverallDistribution
{
    [self configureURLRequestForURL:@"/distribution?sort=amount" WithMethod:@"GET" AndData:nil];
    [self sendRequestWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] >0 && error == nil) {
            NSArray *result = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil] objectForKey:@"entries"];
            NSMutableArray *distributionData = [[NSMutableArray alloc] init];
            for (NSMutableDictionary *item in result) {
                NSMutableDictionary *mutableItem = [[NSMutableDictionary alloc] initWithDictionary:item];
                NSString *imPath = [@"b_" stringByAppendingString:[item objectForKey:@"iconPath"]]; // append a "b_" to the front of the string to obtain the path of the black icon
                NSString *imageURL = [self.APIURL
                                      stringByAppendingString:
                                      [NSString stringWithFormat:@"/images/%@",imPath]];
                [mutableItem setObject:imageURL forKey:@"iconPath"];
                [distributionData addObject:mutableItem];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DISTRIBUTION_RECEIVED" object:self userInfo:@{@"distributionData":distributionData}];
        }
        else if ([data length] == 0 && error == nil) {
            // nothing was downloaded
        }
        else if (error != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DISTRIBUTION_RECEIVED_ERROR" object:self userInfo:@{@"error":error}];
        }
    }];
}

- (NSString *) buildQueryStringDevices
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *devices = [userDefaults objectForKey:@"OMATAUKO_DEVICES"];
    NSString *queryString = @"";
    for (NSDictionary *d in devices) {
        if([(NSNumber *)[d objectForKey:@"selected"] boolValue]) {
            
            queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@"%d,",[(NSNumber *)[d objectForKey:@"deviceID"] intValue]]];
        }
    }
    if(queryString.length > 0) {
        queryString = [NSString stringWithFormat:@"devices=%@",[queryString substringToIndex:queryString.length - 1]] ;
    }
    return queryString;
}

- (void) retrieveNewBreakWithDuration:(int)duration
{
    NSString *queryString = [self buildQueryStringDevices];
    NSString *languageCode = [[Utils preferredLanguage] uppercaseString];
    
    [self configureURLRequestForURL:[NSString stringWithFormat:@"/newbreak/%ld?language=%@&%@",(long)duration,languageCode,queryString] WithMethod:@"GET" AndData:nil];
    [self sendRequestWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if ([data length] >0 && error == nil) {
            NSError *jsonDecodeError;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonDecodeError];
            NSMutableArray *taskList = [[NSMutableArray alloc] init];
            int categoryID = 0;
            NSDictionary *challenge;
            for (NSString *item in result) {
                if([item isEqualToString:@"tasklist"]) {
                    NSArray *list = [result objectForKey:item];
                    for (NSDictionary *taskItem in list) {
                        Task *task = [[Task alloc] init];
                        task.duration = [(NSNumber *)[taskItem objectForKey:@"duration"] intValue];
                        task.taskID = [(NSNumber *)[taskItem objectForKey:@"id"] intValue];
                        NSString *mediaPath = [taskItem objectForKey:@"mediaPath"];
                        long dotLocation = [mediaPath rangeOfString:@"."].location;
                        task.mediaPath = [mediaPath substringToIndex:dotLocation];
                        task.title = (NSString *)[taskItem objectForKey:@"name"];
                        task.directions = (NSString *)[taskItem objectForKey:@"description"];
                        task.status = NO;
                        [taskList addObject:task];
                    }
                }

                if([item isEqualToString:@"kategoryId"]) {
                    categoryID = [(NSNumber *)[result objectForKey:item] intValue];
                }
                
                if ([item isEqualToString:@"goal"]) {
                    challenge = [result objectForKey:item];
                }
            }
            if (![[challenge description] isEqualToString:@"<null>"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"BREAK_RETRIEVED" object:self userInfo:@{@"taskList":taskList,@"categoryID":[NSNumber numberWithInt:categoryID],@"challenge":challenge}];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"BREAK_RETRIEVED" object:self userInfo:@{@"taskList":taskList,@"categoryID":[NSNumber numberWithInt:categoryID]}];
            }
            
        }
        else if ([data length] == 0 && error == nil)
        {
            // nothing was downloaded
        }
        else if (error != nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BREAK_RETRIEVED_ERROR" object:self];
        }
    }];
}

- (void) saveBreak:(NSDictionary *) breakInfo
{
    NSError *jsonEncodeError;
    NSData *data = [NSJSONSerialization dataWithJSONObject:breakInfo options:0 error:&jsonEncodeError];
    
    [self configureURLRequestForURL:@"/breaks" WithMethod:@"POST" AndData:data];
    [self sendRequestWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        // handle response
    }];

}

- (void) saveFeedback:(NSString *)feedback
{
    NSDictionary *object = @{@"feedback":feedback};
    NSError *jsonDecodeError;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&jsonDecodeError];
    
    [self configureURLRequestForURL:@"/feedback" WithMethod:@"POST" AndData:data];
    [self sendRequestWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if ([data length] >0 && error == nil) {
            NSError *jsonDecodeError;
            [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonDecodeError];
            NSLog(@"json decode error = %@",[jsonDecodeError description]);
            if (jsonDecodeError) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FEEDBACK_SAVE_ERROR" object:self userInfo:@{@"error":jsonDecodeError}];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FEEDBACK_SAVE_SUCCESS" object:self];
            }
        }
        else if ([data length] == 0 && error == nil)
        {
            // nothing was downloaded
        }
        else if (error != nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FEEDBACK_SAVE_ERROR" object:self userInfo:@{@"error":error}];
        }
    }];
}

- (void) retrieveUserInfo
{
    [self configureURLRequestForURL:@"/auth/load" WithMethod:@"GET" AndData:nil];
    [self sendRequestWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if ([data length] > 0 && error == nil) {
            NSError *jsonDecodeError;
            NSDictionary *userDetails = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonDecodeError];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"USERDETAILS_RETRIEVED" object:self userInfo:@{@"userDetails":userDetails}];
        } else if ([data length] == 0 && error == nil) {
            // nothing was downloaded
        }
        else if (error != nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"USERDETAILS_RETRIEVED_ERROR" object:self userInfo:@{@"error":error}];
        }
    }];
}

- (void) loginUser:(NSDictionary *)userDetails
{
    NSError *jsonEncodeError;
    NSData *data = [NSJSONSerialization dataWithJSONObject:userDetails options:0 error:&jsonEncodeError];

    [self configureURLRequestForURL:@"/login" WithMethod:@"POST" AndData:data];
    [self sendRequestWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] >0 && error == nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"USER_LOGGED_IN" object:self userInfo:@{@"response":response,@"data":data}];
        }
        else if ([data length] == 0 && error == nil) {
            // nothing was downloaded
        } else if (error != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"USER_LOGGED_IN_ERROR" object:self userInfo:@{@"error":error}];
        }
    }];
}

- (void) logoutUser
{
    [self configureURLRequestForURL:@"/logout" WithMethod:@"GET" AndData:nil];
    [self sendRequestWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if ([data length] > 0 && error == nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"USER_LOGGED_OUT" object:self];
        }
        else if ([data length] == 0 && error == nil) {
            // nothing was downloaded
        }
        else if (error != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"USER_LOGGED_OUT_ERROR" object:self userInfo:@{@"error":error}];
        }
    }];
}

- (void) recoverPassword:(NSDictionary *)userDetails
{
    NSError *jsonEncodeError;
    NSData *data = [NSJSONSerialization dataWithJSONObject:userDetails options:0 error:&jsonEncodeError];
    [self configureURLRequestForURL:@"/reset" WithMethod:@"POST" AndData:data];
    [self sendRequestWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            NSError *jsonDecodeError;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonDecodeError];
            NSDictionary *jsonResponse = [result objectForKey:@"response"];
            if([jsonResponse objectForKey:@"user"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PASSWORD_RETRIEVED" object:self];
            } else if ([jsonResponse objectForKey:@"errors"]) {
                NSDictionary *errors = [jsonResponse objectForKey:@"errors"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PASSWORD_RETRIEVED_USER_ERROR" object:self userInfo:@{@"errors":errors}];
            }
        } else if ([data length] == 0 && error == nil) {
            // nothing was downloaded
        } else if(error != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PASSWORD_RETRIEVED_ERROR" object:self userInfo:@{@"error":error}];
        }
    }];
}

- (void) updateUserDOB:(NSDictionary *)userDetails
{
    NSError *jsonEncodeError;
    NSData *data = [NSJSONSerialization dataWithJSONObject:userDetails options:0 error:&jsonEncodeError];
    [self configureURLRequestForURL:@"/user" WithMethod:@"POST" AndData:data];
    [self sendRequestWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DOB_UPDATED" object:self];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DOB_UPDATED_ERROR" object:self userInfo:@{@"errors":error}];
        }
    }];
}

- (void) updateUsername:(NSDictionary *)userDetails
{
    NSError *jsonEncodeError;
    NSData *data = [NSJSONSerialization dataWithJSONObject:userDetails options:0 error:&jsonEncodeError];
    
    [self configureURLRequestForURL:@"/user" WithMethod:@"POST" AndData:data];
    [self sendRequestWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if(!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"USERNAME_UPDATED" object:self];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"USERNAME_UPDATED_ERROR" object:self userInfo:@{@"errors":error}];
        }
    }];
}

- (void) retrieveDevices
{
    NSString *languageCode = [[Utils preferredLanguage] uppercaseString];
    [self configureURLRequestForURL:[NSString stringWithFormat:@"/devices?language=%@",languageCode] WithMethod:@"GET" AndData:nil];
    [self sendRequestWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            NSDictionary *devices = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] objectForKey:@"devices"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DEVICES_RETRIEVED" object:self userInfo:@{@"devices":devices}];
        } else if ([data length] == 0 && error == nil) {
            // nothing was downloaded
        }
        else if (error != nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DEVICES_RETRIEVED_ERROR" object:self userInfo:@{@"errors":error}];
        }
    }];
}

- (void) retrieveChallenge
{
    [self configureURLRequestForURL:@"/currentgoal" WithMethod:@"GET" AndData:nil];
    [self sendRequestWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            NSError *jsonDecodeError;
            NSObject *challenge = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonDecodeError];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CHALLENGE_RETRIEVED" object:self userInfo:@{@"result":challenge}];
        } else if ([data length] == 0 && error == nil) {
            // nothing was downloaded
        }
        else if (error != nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CHALLENGE_RETRIEVED_ERROR" object:self userInfo:@{@"error":error}];
        }
    }];
}
@end