//
//  TrendsView.m
//  OmaTauko
//
//  Created by Vlad Tufis on 09/01/2014.
//  Copyright (c) 2014 Vlad Tufis. All rights reserved.
//

#import "TrendsView.h"
#import "Utils.h"
#import "strings.h"
#import "colors.h"

@interface TrendsView()
// the radius of the pie chart
@property (nonatomic) NSUInteger pieRadius;
// an array defining the colors of the slices of the pie chart; if the pie should display more colors, add more elements in this array
@property (strong, nonatomic) NSArray *sliceColors;
@end

@implementation TrendsView

// getter for the sliceColors property; lazy instantiation
- (NSArray *) sliceColors
{
    if(!_sliceColors) {
        UIColor *pieChart_Slice1 = PieChart_Slice1;
        UIColor *pieChart_Slice2 = PieChart_Slice2;
        UIColor *pieChart_Slice3 = PieChart_Slice3;
        UIColor *pieChart_Slice4 = PieChart_Slice4;
        _sliceColors = @[pieChart_Slice1,pieChart_Slice2,pieChart_Slice3,pieChart_Slice4];
    }
    return _sliceColors;
}

// setter for the distributionData property; makes a call to setNeedsDisplay which will call drawRect
- (void) setDistributionData:(NSArray *)distributionData
{
    _distributionData = [[NSArray alloc] initWithArray:distributionData];
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// sets up the view
- (void) setup
{
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    // default values for the pie radius
    
}

// called immediately after displaying the view; instead of constructor
- (void) awakeFromNib
{
    [self setup];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    float r = self.bounds.size.width < self.bounds.size.height ? self.bounds.size.width : self.bounds.size.height;
    self.pieRadius = r * 0.45;
    [self drawDistributionPie];
}

/**
 Draws the distribution pie chart according to the values in the distributionData property
 For each element in the distributionData property, a pie slice and an associated label are added in the view
 The angles of the pie slices and the colors are defined from the values of distributionData
 */

- (void) drawDistributionPie
{
    [self cleanView];
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    if (self.distributionData) {
        if(self.distributionData.count) {
            CGFloat offset = 3 * M_PI_2;
            //    CGFloat offset = 0;
            CGFloat startAngle = offset;
            NSMutableArray *copyDistributionData = [[NSMutableArray alloc] initWithArray:self.distributionData];
            for(NSDictionary *dataValue in self.distributionData) {
                float pctg = ([[dataValue objectForKey:@"amount"] floatValue] / [Utils arraySum:self.distributionData OnField:@"amount"]);
                CGFloat endAngle = startAngle + pctg * 2 * M_PI;
                int ipctg = (round(pctg * 100) * 1000) / 1000;
                [self drawPieSliceFrom:startAngle To:endAngle AtCenter:center WithColor:self.sliceColors[[copyDistributionData indexOfObject:dataValue]]];
                CGFloat midAngle = (startAngle + endAngle) * 0.5;
                CGFloat labelX = center.x + 2*self.pieRadius/3 * cos(midAngle);
                CGFloat labelY = center.y + self.pieRadius * sin(midAngle);
                [self drawLabelForPieSliceWithValue:[NSString stringWithFormat:@"%d%%",ipctg] AtPosition:CGPointMake(labelX,labelY) WithImage:[dataValue objectForKey:@"iconPath"] Angle:midAngle];
                [copyDistributionData setObject:[NSNumber numberWithInt:-1] atIndexedSubscript:[self.distributionData indexOfObject:dataValue]];
                startAngle = endAngle;
            }
        } else {
            [self showNoDataAtPosition:center];
        }
    }
}

- (void) showNoDataAtPosition:(CGPoint) center
{
    CGFloat width = 64;
    CGFloat height = 64;
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    imageView.tag = 125;
    imageView.image = [UIImage imageNamed:@"noworkoutyet"];
    imageView.frame = CGRectMake(center.x - width/2, center.y - height/2, width, height);
    [self addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.origin.y + height, 0, 50)];
    label.text = TrendsView_NO_TRAININGS_COMPLETED;
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setNumberOfLines:2];
    CGSize realSize;
    if([label.text respondsToSelector:@selector(sizeWithAttributes:)]) {
        realSize = [label.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    } else {
        realSize = [label.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:(CGSize){self.frame.size.width, CGFLOAT_MAX}];
    }
    
    CGRect frame = label.frame;
    frame.size.width = realSize.width;
    frame.origin.x = (self.bounds.size.width - realSize.width) * 0.5;
    label.frame = frame;
    label.tag = 125;
    // small hack, without this line, the label has a vertical line to the right that spans its full height
    [label setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.0]];
    [self addSubview:label];

}

/**
 Draws a pie slice with the following parameters:
 @param startAngle - the starting angle of the arc
 @param endAngle - the ending angle of the arc
 @param center - the center of the circle which contains the drawn arc
 @param color - the color of the pie slice
 A pie slice consists of an arc and the triangle with the tip in the center and the angle at the tip equal to endAngle-startAngle >>> GEOMETRY IN ACTION!!! Just draw the problem on a piece of paper and you will understand the calculations
 */
- (void) drawPieSliceFrom:(CGFloat) startAngle To:(CGFloat) endAngle AtCenter:(CGPoint)center WithColor:(UIColor *)color
{

    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:self.pieRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    UIBezierPath *triangle = [[UIBezierPath alloc] init];
    [triangle moveToPoint:center];
    [triangle addLineToPoint:CGPointMake(center.x + self.pieRadius * cos(startAngle), center.y + self.pieRadius * sin(startAngle))];
    [triangle addLineToPoint:CGPointMake(center.x + self.pieRadius * cos(endAngle), center.y + self.pieRadius * sin(endAngle))];
    [triangle closePath];
    [color set];
    [path appendPath:triangle];
    [path fill];
}

/**
 Draws a label for the associated pie slice, with the following parameters:
 @param value - the string displayed on the label
 @param point - the point where the label will be displayed
 @param angle - the angle at which the label is displayed
 */
- (void) drawLabelForPieSliceWithValue:(NSString *)value AtPosition:(CGPoint)point WithImage:(NSString *)imageName Angle:(CGFloat)angle
{
    CGFloat midAngleDeg = abs(360 - (angle * 180 / M_PI));
    UIImageView *im = [[UIImageView alloc] initWithFrame:CGRectMake(point.x, point.y, 25, 25)];
    if(midAngleDeg > 90) {
        im.frame = CGRectMake(point.x - 50, point.y - 25, 25, 25);
    }
    [im setTag:125];
    [im setBackgroundColor:[UIColor whiteColor]];
    [im setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageName]]]];
    [im setContentMode:UIViewContentModeScaleAspectFit];
    
    [self addSubview:im];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(point.x + 25, point.y, 50, 25)];
    if(midAngleDeg > 90) {
        CGPoint original = label.frame.origin;
        CGSize dimension = label.frame.size;
        label.frame = CGRectMake(original.x - dimension.width,original.y - dimension.height,dimension.width,dimension.height);
    }

    label.tag = 125;
    label.text = value;
    label.textAlignment = NSTextAlignmentCenter;
    [label setBackgroundColor:[UIColor whiteColor]];
    label.textColor = [UIColor colorWithRed:28/255 green:162/255 blue:156/255 alpha:1];
    
    [self addSubview:label];
}

// cleans the view before drawing a new pie chart
- (void) cleanView
{
    // remove the labels with the percentages
    for(UILabel *label in [self subviews]) {
        if ([label isKindOfClass:[UILabel class]]) {
            if(label.tag == 125) {
                [label removeFromSuperview];
            }
        }
    }
    
    // remove the images
    for(UIImageView *img in [self subviews]) {
        if ([img isKindOfClass:[UIImageView class]]) {
            if(img.tag == 125) {
                [img removeFromSuperview];
            }
        }
    }
}

@end