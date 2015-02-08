//
//  MovieCollectionViewCell.h
//  Rotten Tomatoes
//
//  Created by Calvin Tuong on 2/7/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *mpaaAndLengthLabel;

@end
