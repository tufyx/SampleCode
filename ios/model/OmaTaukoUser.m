//
//  OmaTaukoUser.m
//  OmaTauko
//
//  Created by Vlad Tufis on 20/01/2014.
//  Copyright (c) 2014 Vlad Tufis. All rights reserved.
//

#import "OmaTaukoUser.h"
#import "APICaller.h"
#import "Utils.h"
#import "strings.h"

@interface OmaTaukoUser()
// the object managing the API calls
@property (strong, nonatomic) APICaller* apiCaller;
@end

@implementation OmaTaukoUser

/**
 Constructor of the class
 initializes the apiCaller object and configures the notifications to which this object responds
 */
- (instancetype) init
{
    self = [super init];
    if(self) {
        self.apiCaller = [[APICaller alloc] init];
        [self configureNotifications];
    }
    return self;
}

/**
 Configures the notifications to which this object responds
 USERDETAILS_RETRIEVED - the user details have been succesfully retrieved
 USERDETAILS_RETRIEVED_ERROR - the user details could not be retrieved due to an error: no internet connection, corrupted JSON format, etc.
 */
- (void) configureNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserDetailsRetreived:) name:@"USERDETAILS_RETRIEVED" object:self.apiCaller];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserDetailsRetreivedError:) name:@"USERDETAILS_RETRIEVED_ERROR" object:self.apiCaller];
}

/**
 Handles the succesful completion of retrieving the user details
 Sets the fullName, userID, email and date of birth properties of this object
 */
- (void) handleUserDetailsRetreived:(NSNotification *) notification
{
    NSDictionary *userDetails = [notification.userInfo objectForKey:@"userDetails"];
    if(userDetails) {
        for (NSString *item in userDetails) {
            self.fullName = (NSString *)[userDetails objectForKey:@"username"];
            self.userID = [(NSNumber *)[userDetails objectForKey:@"id"] integerValue];
            self.email = (NSString *)[userDetails objectForKey:@"email"];
            if([item isEqualToString:@"dateOfBirth"]) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [formatter setDateFormat:@"yyyy-MM-dd 00:00:00"];
                
                NSObject *obj = [userDetails objectForKey:@"dateOfBirth"];
                if(obj != [NSNull null]) {
                    self.dateOfBirth = [formatter dateFromString:[[(NSString *)[userDetails objectForKey:@"dateOfBirth"] substringToIndex:10] stringByAppendingString:@" 00:00:00"]];
                } else {
                    self.dateOfBirth = [NSDate date];
                }
            }
        }
        [self initializeOmaTaukoPreferences];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"USERDETAILS_RETRIEVED" object:self userInfo:notification.userInfo];
    }
}

- (void) handleUserDetailsRetreivedError:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"USERDETAILS_RETRIEVED_ERROR" object:self userInfo:notification.userInfo];
}

// defines the OmaTaukoPreferences upon the first accessing of the application
- (void) initializeOmaTaukoPreferences
{
    // if the preferences have not been set yet
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"OMATAUKO_LAST_BREAK_DATE"]) {
        NSDate *now = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"OMATAUKO_DAYS_IN_ROW"];
        [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"OMATAUKO_LAST_COMPLETED_DAY"];
        [[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"OMATAUKO_USER_GENDER"]; // default is female
        [[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"OMATAUKO_USING_SOUND"]; // default is on
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"OMATAUKO_DAILY_WORKOUT"];
        [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"OMATAUKO_LAST_BREAK_DATE"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self defineDefaultReminders];
    }
}

// deletes the OmaTaukoPreferences from the standardUserDefaults
- (void) deleteOmaTaukoPreferences
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *d = [defaults dictionaryRepresentation];
    NSString *prefix = @"OMATAUKO";
    for (NSString* key in d) {
        if([[key substringToIndex:prefix.length] isEqualToString:prefix]) {
            [defaults removeObjectForKey:key];
        }
    }
}

/**
 Defines default reminders for the current user, if none are defined (upon the first accessing of the app)
 Two default reminders are defined, 30 minutes after 10:00 AM and around 14:00 PM
 The reminders are scheduled to repeat from monday to friday
 */
- (void) defineDefaultReminders
{
    int countReminders = 2;
    int currentCount = 0;
    // the reference hours since when the two default reminders will be scheduled; the first one will be scheduled approximately 30 minutes after this reference start hour, while the second one approximately 4 hours after the reference start hour
    int startingHour = 10;
    
    NSUInteger dateComponentsFlags = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    NSCalendar *c = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *dateComponents = [c components:dateComponentsFlags fromDate:[NSDate date]];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yyyy 00:00:00"];

    NSMutableArray *repeats = [[NSMutableArray alloc] init];
    while(currentCount < 7) {
        BOOL value = currentCount < 5 ? YES : NO;
        [repeats addObject:[NSNumber numberWithBool:value]];
        currentCount++;
    }
    currentCount = 0;
    
    NSMutableArray *reminders = [[NSMutableArray alloc] init];
    while(currentCount < countReminders) {
        NSTimeInterval interval = (startingHour + (currentCount) * 4) * 3600 + (arc4random() % 30 ) * 60;
        NSString *message = ReminderMessageVC_DEFAULT_REMINDER_MESSAGE;
        NSDate *d = [df dateFromString:[NSString stringWithFormat:@"%ld/%ld/%ld 00:00:00",(long)dateComponents.day,(long)dateComponents.month,(long)dateComponents.year]];
        
        Reminder *reminder = [[Reminder alloc] initWith:[d dateByAddingTimeInterval:interval] Repeats:repeats Message:message];
        [reminders addObject:reminder];
        currentCount++;
    }
    [Utils saveReminders:reminders];
}

// sends a call throught the apiCaller to retrieve the user information
- (void) retrieveUserInformation
{
    [self.apiCaller retrieveUserInfo];
}
@end