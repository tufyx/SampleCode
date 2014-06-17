//
//  OmaTaukoUser.h
//  OmaTauko
//
//  Created by Vlad Tufis on 20/01/2014.
//  Copyright (c) 2014 Vlad Tufis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OmaTaukoUser : NSObject
#pragma mark - User properties
// full name of the user
@property (strong, nonatomic) NSString *fullName;
// email of the user
@property (strong, nonatomic) NSString *email;
// id of the user
@property (nonatomic) NSInteger userID;
// birthdate of the user
@property (strong, nonatomic) NSDate *dateOfBirth;

#pragma mark - User methods
// initializes the OmaTaukoPreferences properties in the standardUserDefaults
- (void) initializeOmaTaukoPreferences;
// deletes all existing OmaTaukoPreferences properties in the standardUserDefaults
- (void) deleteOmaTaukoPreferences;
// retrieves user`s info from the database
- (void) retrieveUserInformation;
@end
