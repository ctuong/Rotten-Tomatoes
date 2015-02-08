//
//  MoviesViewController.m
//  Rotten Tomatoes
//
//  Created by Calvin Tuong on 2/3/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieTableViewCell.h"
#import "MovieViewController.h"
#import "UIImageView+AFNetworking.h"
#import "SVProgressHUD.h"
#import "MovieCollectionViewCell.h"

#define kRottenTomatoesAPIKey @"kdfte37hampxct6f7xr8mzxb"
#define kMovieTableViewCellHeight 100
#define kNumColumnsInCollectionView 2
#define kListViewIndex 0

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSArray *searchResults;
@property (atomic) BOOL useSearchResults;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIView *networkErrorView;
@property (nonatomic, strong) UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UISegmentedControl *viewStyleControl;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.useSearchResults = false;
    
    // set up the table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = kMovieTableViewCellHeight;
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieTableViewCell" bundle:nil] forCellReuseIdentifier:@"MovieTableViewCell"];
    
    // set up the collection view
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"MovieCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"MovieCollectionViewCell"];
    
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD show];
    [self fetchMovieData];
    
    // set up the search controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    // set up the table header
//    self.tableHeaderView = [[UIView alloc] init];
//    [self.tableHeaderView addSubview:self.searchController.searchBar];
//    [self.tableHeaderView addSubview:self.networkErrorView];
//    self.tableView.tableHeaderView = self.tableHeaderView;
    
    // set up the refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovieData) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
    
    // set up the segmented control
    self.viewStyleControl = (UISegmentedControl *)self.navigationController.navigationBar.topItem.titleView;
    [self.viewStyleControl addTarget:self action:@selector(viewStyleChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"memory warning");
}

- (void)fetchMovieData {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=%@&limit=50", kRottenTomatoesAPIKey]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"%@", connectionError);
            [self.networkErrorView setHidden:NO];
        } else {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.movies = result[@"movies"];
            [self.tableView reloadData];
            [self.collectionView reloadData];
            [self.networkErrorView setHidden:YES];
        }
        [self.refreshControl endRefreshing];
        [SVProgressHUD dismiss];
    }];
}

- (NSArray *)getCurrentMovies {
    if (self.useSearchResults) return self.searchResults;
    return self.movies;
}

- (NSString *)getMovieLengthStringForTime:(NSInteger)time {
    NSInteger numHours = time / 60;
    NSInteger numMinutes = time - (60 * numHours);
    
    return [NSString stringWithFormat:@"%ld hr %ld min", numHours, numMinutes];
}

- (NSInteger)getNumFullStarsForScore:(NSInteger)score {
    return score / 20;
}

- (NSInteger)getNumHalfStarsForScore:(NSInteger)score {
    return (score % 20) / 10;
}

- (void)fillStarsArray:(NSArray *)array withStarsForScore:(NSInteger)score {
    NSInteger fullStars = [self getNumFullStarsForScore:score];
    NSInteger halfStars = [self getNumHalfStarsForScore:score];
    
    for (UIImageView *starImage in array) {
        if (fullStars > 0) {
            [starImage setImage:[UIImage imageNamed:@"full-star"]];
            fullStars--;
        } else if (halfStars > 0) {
            [starImage setImage:[UIImage imageNamed:@"half-star"]];
            halfStars--;
        } else {
            [starImage setImage:[UIImage imageNamed:@"empty-star"]];
        }
    }
}

// display the MovieViewController
- (void)pushMovieViewControllerWithPlaceholderImage:(UIImage *)image ForMovieAtIndex:(NSInteger) index {
    NSArray *currentMovies = [self getCurrentMovies];
    
    NSDictionary *movie = currentMovies[index];
    MovieViewController *mvc = [[MovieViewController alloc] init];
    mvc.movie = movie;
    mvc.placeholderImage = image;
    
    [self.navigationController pushViewController:mvc animated:YES];
}

#pragma mark - SegmentedControl methods

- (void)viewStyleChanged {
    NSInteger index = self.viewStyleControl.selectedSegmentIndex;
    if (index == kListViewIndex) {
        [self.tableView setHidden:NO];
        [self.collectionView setHidden:YES];
    } else {
        [self.tableView setHidden:YES];
        [self.collectionView setHidden:NO];
    }
}

#pragma mark - TableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getCurrentMovies].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *currentMovies = [self getCurrentMovies];
    
    MovieTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MovieTableViewCell" forIndexPath:indexPath];
    cell.posterImageView.image = nil;
    
    NSDictionary *movie = currentMovies[indexPath.row];
    NSInteger runtime = [movie[@"runtime"] integerValue];
    NSInteger criticsScore = [[movie valueForKeyPath:@"ratings.critics_score"] integerValue];
    NSInteger audienceScore = [[movie valueForKeyPath:@"ratings.audience_score"] integerValue];
    
    [self fillStarsArray:[cell criticsStarArray] withStarsForScore:criticsScore];
    [self fillStarsArray:[cell audienceStarArray] withStarsForScore:audienceScore];
    
    cell.titleLabel.text = movie[@"title"];
    cell.mpaaAndLengthLabel.text = [NSString stringWithFormat:@"%@, %@", movie[@"mpaa_rating"], [self getMovieLengthStringForTime:runtime]];
    
    NSURL *imageURL = [NSURL URLWithString:[movie valueForKeyPath:@"posters.thumbnail"]];
    [cell.posterImageView setImageWithURL:imageURL];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MovieTableViewCell *cell = (MovieTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    [self pushMovieViewControllerWithPlaceholderImage:cell.posterImageView.image ForMovieAtIndex:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // one section with the search bar as the header
    return self.searchController.searchBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // height of the search bar
    return [self.searchController.searchBar frame].size.height;
}

#pragma mark - CollectionView methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kNumColumnsInCollectionView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self getCurrentMovies].count / kNumColumnsInCollectionView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *currentMovies = [self getCurrentMovies];
    
    MovieCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionViewCell" forIndexPath:indexPath];
    cell.posterImageView.image = nil;

    NSDictionary *movie = currentMovies[(kNumColumnsInCollectionView * indexPath.section) + indexPath.row];
    NSInteger runtime = [movie[@"runtime"] integerValue];
    
    cell.titleLabel.text = movie[@"title"];
    cell.mpaaAndLengthLabel.text = [NSString stringWithFormat:@"%@, %@", movie[@"mpaa_rating"], [self getMovieLengthStringForTime:runtime]];
    [cell.posterImageView setImageWithURL:[NSURL URLWithString:[movie valueForKeyPath:@"posters.thumbnail"]]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    MovieCollectionViewCell *cell = (MovieCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [self pushMovieViewControllerWithPlaceholderImage:cell.posterImageView.image ForMovieAtIndex:(kNumColumnsInCollectionView * indexPath.section) + indexPath.row];
}

#pragma mark - SearchController methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"updating search %@", searchController.searchBar.text);
    
    NSString *searchText = searchController.searchBar.text;
    if ([searchText length] == 0) {
        // if no search text, default to all movies
        self.searchResults = self.movies;
    } else {
        self.searchResults = [self moviesForSearchText:searchText];
    }
    [self.tableView reloadData];
}

// filter the list of movies to only those whose title contains the search text
- (NSArray *)moviesForSearchText:(NSString *)text {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[c] %@", text];
    NSArray *results = [self.movies filteredArrayUsingPredicate:predicate];
    return results;
}

// when the search bar goes away, reset the table to all movies
- (void)didDismissSearchController:(UISearchController *)searchController {
    NSLog(@"dismissed search");
    
    self.useSearchResults = false;
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

// when the search bar is selected, set the searchResults to all movies
- (void)didPresentSearchController:(UISearchController *)searchController {
    NSLog(@"presented search");
    
    self.useSearchResults = true;
    self.searchResults = [NSArray arrayWithArray:self.movies];
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
