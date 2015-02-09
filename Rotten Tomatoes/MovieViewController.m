//
//  MovieViewController.m
//  Rotten Tomatoes
//
//  Created by Calvin Tuong on 2/3/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "MovieViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *criticsSayLabel;
@property (weak, nonatomic) IBOutlet UILabel *audienceSaysLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIView *contentContainerView;

@end

@implementation MovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // set the image
    NSString *thumbnailURLString = [self.movie valueForKeyPath:@"posters.thumbnail"];
    NSString *originalImageURLString = [thumbnailURLString stringByReplacingOccurrencesOfString:@"_tmb" withString:@"_ori"];
    NSURL *imageURL = [NSURL URLWithString:originalImageURLString];
    [self.posterImageView setImageWithURL:imageURL placeholderImage:self.placeholderImage];
    
    self.navigationController.navigationBar.alpha = 0.95;
    
    self.title = self.movie[@"title"];
    
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = [self formatTitleText];
    [self.titleLabel sizeToFit];

    self.synopsisLabel.numberOfLines = 0;
    self.synopsisLabel.text = self.movie[@"synopsis"];
    [self.synopsisLabel sizeToFit];
    
    NSDictionary *ratings = self.movie[@"ratings"];
    
    self.criticsSayLabel.numberOfLines = 0;
    self.criticsSayLabel.text = [NSString stringWithFormat:@"Critics Say: %@%% %@", ratings[@"critics_score"], ratings[@"critics_rating"]];
    [self.criticsSayLabel sizeToFit];
    
    self.audienceSaysLabel.numberOfLines = 0;
    self.audienceSaysLabel.text = [NSString stringWithFormat:@"Audience Says: %@%% %@", ratings[@"audience_score"], ratings[@"audience_rating"]];
    
    // the total height of the scroll content is container's offset from the top + the size of the content in the container
    CGFloat contentHeight = [self getContentHeight];
    CGFloat totalContentHeight = self.contentContainerView.frame.origin.y + contentHeight;
    CGRect contentContainerViewFrame = self.contentContainerView.frame;
    // set the size of the view to match the size of its content
    self.contentContainerView.frame = CGRectMake(contentContainerViewFrame.origin.x, contentContainerViewFrame.origin.y, contentContainerViewFrame.size.width, totalContentHeight);
    // set the scroll view's content size
    CGSize contentSize = CGSizeMake(self.contentContainerView.frame.size.width, totalContentHeight);
    self.contentScrollView.contentSize = contentSize;
    
    self.contentScrollView.showsVerticalScrollIndicator = NO;
}

- (CGFloat)getContentHeight {
    // size of the content in the container is the size of the last label + its y origin
    return self.synopsisLabel.frame.size.height + self.synopsisLabel.frame.origin.y;
}

- (NSString *)formatTitleText {
    return [NSString stringWithFormat:@"%@ (%@)", self.movie[@"title"], self.movie[@"year"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
