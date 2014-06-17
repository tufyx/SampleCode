//
//  TrendsView.h
//  OmaTauko
//
//  Created by Vlad Tufis on 09/01/2014.
//  Copyright (c) 2014 Vlad Tufis. All rights reserved.
//
//  The view displaying the exercise distribution pie chart
//  Public API for this class

#import <UIKit/UIKit.h>

@interface TrendsView : UIView
// an array containing the distribution of exercises
@property (nonatomic, strong) NSArray *distributionData;
@end
