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

#define kRottenTomatoesAPIKey @"kdfte37hampxct6f7xr8mzxb"
#define kMovieTableViewCellHeight 100

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSArray *searchResults;
@property (atomic) BOOL useSearchResults;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self) {
        self.title = @"Movies";
    }
    
    self.useSearchResults = false;
    
    // set up the table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = kMovieTableViewCellHeight;
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieTableViewCell" bundle:nil] forCellReuseIdentifier:@"MovieTableViewCell"];
    
    [self fetchMovieData];
    
    // set up the search controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // set up the refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovieData) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchMovieData {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=%@&limit=30", kRottenTomatoesAPIKey]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        self.movies = result[@"movies"];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (NSArray *)getCurrentMovies {
    if (self.useSearchResults) return self.searchResults;
    return self.movies;
}

#pragma mark - TableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getCurrentMovies].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *currentMovies = [self getCurrentMovies];
    
    MovieTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MovieTableViewCell"];
    
    NSDictionary *movie = currentMovies[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"synopsis"];
    
    NSURL *imageURL = [NSURL URLWithString:[movie valueForKeyPath:@"posters.thumbnail"]];
    [cell.posterImageView setImageWithURL:imageURL];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *currentMovies = [self getCurrentMovies];
    
    NSDictionary *movie = currentMovies[indexPath.row];
    MovieViewController *mvc = [[MovieViewController alloc] init];
    mvc.movie = movie;
    
    [self.navigationController pushViewController:mvc animated:YES];
}

#pragma mark - SearchController methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    if ([searchText length] == 0) {
        // if no search text, default to all movies
        self.searchResults = self.movies;
    } else {
        self.searchResults = [self moviesForSearchText:searchController.searchBar.text];
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
    self.useSearchResults = false;
    [self.tableView reloadData];
}

// when the search bar is selected, set the searchResults to all movies
- (void)didPresentSearchController:(UISearchController *)searchController {
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
