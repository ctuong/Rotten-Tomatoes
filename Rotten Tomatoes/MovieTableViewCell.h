//
//  MovieTableViewCell.h
//  Rotten Tomatoes
//
//  Created by Calvin Tuong on 2/3/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *mpaaAndLengthLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UIImageView *criticsStar1;
@property (weak, nonatomic) IBOutlet UIImageView *criticsStar2;
@property (weak, nonatomic) IBOutlet UIImageView *criticsStar3;
@property (weak, nonatomic) IBOutlet UIImageView *criticsStar4;
@property (weak, nonatomic) IBOutlet UIImageView *criticsStar5;
@property (weak, nonatomic) IBOutlet UIImageView *audienceStar1;
@property (weak, nonatomic) IBOutlet UIImageView *audienceStar2;
@property (weak, nonatomic) IBOutlet UIImageView *audienceStar3;
@property (weak, nonatomic) IBOutlet UIImageView *audienceStar4;
@property (weak, nonatomic) IBOutlet UIImageView *audienceStar5;

- (NSArray *)criticsStarArray;
- (NSArray *)audienceStarArray;

@end
