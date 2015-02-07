//
//  MovieTableViewCell.m
//  Rotten Tomatoes
//
//  Created by Calvin Tuong on 2/3/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "MovieTableViewCell.h"

@implementation MovieTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSArray *)criticsStarArray {
    return [NSArray arrayWithObjects:self.criticsStar1, self.criticsStar2, self.criticsStar3, self.criticsStar4, self.criticsStar5, nil];
}

- (NSArray *)audienceStarArray {
    return [NSArray arrayWithObjects:self.audienceStar1, self.audienceStar2, self.audienceStar3, self.audienceStar4, self.audienceStar5, nil];
}

@end
