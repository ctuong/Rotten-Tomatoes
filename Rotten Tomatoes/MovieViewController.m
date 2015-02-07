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

@end

@implementation MovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = self.movie[@"title"];
    
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"synopsis"];
    
    // set the image
    NSString *thumbnailURLString = [self.movie valueForKeyPath:@"posters.thumbnail"];
    NSString *originalImageURLString = [thumbnailURLString stringByReplacingOccurrencesOfString:@"_tmb" withString:@"_ori"];
    NSURL *imageURL = [NSURL URLWithString:originalImageURLString];
    [self.posterImageView setImageWithURL:imageURL];
    self.posterImageView.alpha = 0.3;
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
