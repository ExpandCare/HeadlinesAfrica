//
//  HLNewsViewController.m
//  Headlines
//
//

#import "HLNewsViewController.h"
#import "TopPostCell.h"
#import "SimplePostCell.h"
#import "HLPostDetailViewController.h"
#import "HLNavigationController.h"
#import <Parse/Parse.h>
#import "Post+Additions.h"
#import <SDWebImageDownloader.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSDate+Extentions.h"
#import "NSString+URLEncoding.h"
#import "HLHeaderViewCell.h"
#import <SAMHUDView/SAMHUDView.h>
#import "NSCache+Fix.h"
#import "NSUserDefaults+Countries.h"

#define CELL_ID_TOP @"CELL_ID_TOP"
#define CELL_ID_REGULAR @"CELL_ID_REGULAR"
#define CELL_ID_REGULAR_SMALL @"CELL_ID_REGULAR_AD_SMALL"
#define CELL_ID_REGULAR_BIG @"CELL_ID_REGULAR_AD_BIG"
#define CELL_ID_HEADER @"CELL_ID_HEADER"

#define CELL_HEIGHT_TOP CGRectGetWidth(self.view.bounds)
#define CELL_HEIGHT_REGULAR 100

#define LOAD_NEWS_COUNT 100

@interface HLNewsViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *navbarBackgroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBackgroundBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBackgroundHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;

@property (strong, nonatomic) NSFetchedResultsController *resultController;
@property (strong, nonatomic) NSString *selectedPostID;
@property (strong, nonatomic) SAMHUDView *hud;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic) BOOL downloadedAllNews;
@property (nonatomic) BOOL downloading;

@end

@implementation HLNewsViewController

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"Memory warning");
    
    [[SDWebImageManager sharedManager] cancelAll];
    
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
    
    [PFQuery clearAllCachedResults];
    
    [SDWebImageManager.sharedManager.imageCache clearMemory];
}

#pragma mark - ViewController Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SDWebImageManager.sharedManager.imageCache setValue:nil forKey:@"memCache"];
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    [SDWebImageDownloader sharedDownloader].shouldDecompressImages = NO;

    self.refreshControl = [UIRefreshControl new];
    
    [self.tableView addSubview:self.refreshControl];
    
    [self.refreshControl beginRefreshing];
    [self.refreshControl endRefreshing];
    
    [self.refreshControl addTarget:self
                            action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.tableView.bounces = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TopPostCell class])
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:CELL_ID_TOP];
//    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SimplePostCell class])
//                                               bundle:[NSBundle mainBundle]]
//         forCellReuseIdentifier:CELL_ID_REGULAR];
    
    if (!SMALL_BANNER || !BIG_BANNER)
    {
        [((AppDelegate *)[UIApplication sharedApplication].delegate) loadBanners];
    }

    if (self.category)
    {
        self.title = self.category;
        self.tableViewBottomConstraint.constant = 0;
        //[((HLNavigationController *)self.navigationController) makebarCompletelyTranparent];
        [((HLNavigationController *)self.navigationController) makeBarTransparent];
        
        [super configureBackButtonWhite:NO];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPostNotification:) name:kNotificationOpenPost object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    [self.view layoutIfNeeded];
    
    [self fetchAndLoadNewsWithSkipping:NO];
    [self.tableView reloadData];
    
    [self checkArticleIdToPushTo];
}

- (void)didBecomeActive:(NSNotification*)note
{
    [self checkArticleIdToPushTo];
}

- (void)checkArticleIdToPushTo
{
    NSString *articleIdToOpen = [(AppDelegate*)[[UIApplication sharedApplication] delegate] articleIdToOpen];
    
    if (articleIdToOpen)
    {
        self.hud = [[SAMHUDView alloc] initWithTitle:@"Opening an article.." loading:YES];
        PFQuery *query = [PFQuery queryWithClassName:@"Post"];
        __weak typeof(self) weakSelf = self;
        [self.hud show];
        [query getObjectInBackgroundWithId:articleIdToOpen block:^(PFObject *post, NSError *error)
         {
             if (!error)
             {
                 [Post createOrUpdatePostsInBackground:@[post] completion:^(BOOL success, NSError *error)
                 {
                      [weakSelf openPost:[Post MR_findFirstByAttribute:@"postID" withValue:articleIdToOpen]];
                 }];
             }
             [weakSelf.hud completeAndDismissWithTitle:nil];
         }];
    }
}

- (void)refresh:(UIRefreshControl *)control
{
    [self fetchAndLoadNewsWithSkipping:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setInsets];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doubleTap)
                                                 name:kNotificationDoubleTap
                                               object:nil];
    
    self.navBackgroundBottomConstraint.constant = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.navigationController.navigationBar.frame);
    
    self.navBackgroundHeightConstraint.constant = 0;
    self.navbarBackgroundView.backgroundColor = [UIColor whiteColor];

    [self.view layoutIfNeeded];
    
    [self setInsets];
    
    self.resultController.delegate = self;

    [self.tableView reloadData];
    
//    __weak typeof(self) controller = self;
//    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        
//        [controller.tableView reloadData];
//    });
    
    if ([NSUserDefaults countryPostsUpdateNeeded])
    {
        self.resultController.fetchRequest.predicate = [self thePredicate];
        [self.resultController performFetch:nil];
        [self.tableView reloadData];
        
        [self fetchAndLoadNewsWithSkipping:NO];
        
        [NSUserDefaults countryPostsUpdated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.resultController.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationDoubleTap
                                                  object:nil];
}

- (void)dealloc
{
    [[SDWebImageManager sharedManager] cancelAll];
    
    self.resultController.delegate = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setInsets
{
    if (self.category)
    {
        self.tableViewTopConstraint.constant = CGRectGetHeight(self.navigationController.navigationBar.frame) + [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    else
    {
        CGFloat topInset = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
        
        self.tableView.contentInset = self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(topInset, 0, CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
        if (CGPointEqualToPoint(self.tableView.contentOffset, CGPointZero))
        {
            self.tableView.contentOffset = CGPointMake(0, - self.tableView.contentInset.top);
        }
    }
}

- (void)doubleTap
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                              inSection:(self.category ? 1 : 0)]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

#pragma mark - News

- (void)fetchAndLoadNewsWithSkipping:(BOOL)skip
{
    if (self.downloading)
    {
        [self.refreshControl endRefreshing];
        
        return;
    }
    
    self.downloading = YES;
    
    NSError *error;
    if ([self.resultController performFetch:&error])
    {
        if (error)
        {
            NSLog(@"%@", error);
        }
        else
        {
            [self.tableView reloadData];
        }
    }
    
    PFQuery *query = [PFQuery queryWithClassName:NSStringFromClass([Post class])];
    
    if (self.category)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", self.category];
        
        query = [PFQuery queryWithClassName:NSStringFromClass([Post class]) predicate:predicate];
    }

    [query orderByDescending:@"createdAt"];
    query.limit = LOAD_NEWS_COUNT;
    
    if ([NSUserDefaults enabledCountries])
    {
        [query whereKey:@"country" containedIn:[NSUserDefaults enabledCountries]];
    }
    
    if (skip)
    {
        query.skip = self.resultController.fetchedObjects.count;
    }
    
    __weak HLNewsViewController *controller = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects.count < LOAD_NEWS_COUNT)
        {
            controller.downloadedAllNews = YES;
        }
        
        [controller.refreshControl endRefreshing];
        
        [Post createOrUpdatePostsInBackground:objects completion:^(BOOL success, NSError *error) {
            
            [query clearCachedResult];
            
            controller.downloading = NO;
            
            if (error)
            {
                NSLog(@"Error: %@", error);
            }
            
            //[controller.resultController performFetch:nil];
            //[controller.tableView reloadData];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDownloadedPosts
                                                                object:nil];
        }];
    }];
}

#pragma mark - FetchedResultController

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    NSIndexPath *nIP = [NSIndexPath indexPathForRow:newIndexPath.row inSection:1];
    NSIndexPath *oIP = [NSIndexPath indexPathForRow:indexPath.row inSection:1];
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:nIP]
                             withRowAnimation:UITableViewRowAnimationFade];
            
            if (newIndexPath.row == 0 && self.tableView.contentOffset.y < CGRectGetHeight(self.view.bounds))
            {
                [self.tableView reloadData];
            }
            
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:oIP]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:oIP]
                    atIndexPath:oIP];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:oIP]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:nIP]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (NSFetchedResultsController *)resultController
{
    if (_resultController != nil)
    {
        return _resultController;
    }
    
    NSFetchRequest *fetchRequest = [self fetchRequest];
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                  managedObjectContext:[NSManagedObjectContext MR_defaultContext]
                                                                                                    sectionNameKeyPath:nil
                                                                                                             cacheName:nil];
    
    _resultController = theFetchedResultsController;
    self.resultController.delegate = self;
    
    return theFetchedResultsController;
}

- (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Post class])
                                              inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSPredicate *completePredicate = [self thePredicate];
    
    if (completePredicate)
    {
        [fetchRequest setPredicate:completePredicate];
    }

    return fetchRequest;
}

- (NSPredicate *)thePredicate
{
    NSPredicate *predicate = nil;
    
    if (self.category)
    {
        if ([self.category isEqualToString:@"all"])
        {
            self.title = @"All News";
        }
        else
        {
            predicate = [NSPredicate predicateWithFormat:@"category == %@", self.category];
        }
    }
    
    NSPredicate *countryPredicate;
    
    NSMutableArray *predicates = [NSMutableArray new];
    for (NSString *country in [NSUserDefaults enabledCountries])
    {
        [predicates addObject:[NSPredicate predicateWithFormat:@"country == %@", country]];
    }
    
    if (predicates.count > 0)
    {
        countryPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
        
        if (predicate)
        {
            return [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, countryPredicate]];
        }
        else
        {
            return countryPredicate;
        }
    }
    else
    {
        return predicate;
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!section)
    {
        if (self.category)
        {
            return 0;
        }
        else
        {
            return 1;
        }
    }
    
    return self.resultController.fetchedObjects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return CGRectGetHeight(self.view.bounds) - CELL_HEIGHT_TOP - CGRectGetHeight(self.tabBarController.tabBar.frame) - CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    }
    
    if (!indexPath.row)
    {
        return CELL_HEIGHT_TOP;
        //return (self.category ? (CGRectGetHeight(self.view.bounds) - CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame])) : CELL_HEIGHT_TOP);
    }
    else
    {
        if (IS_SMALL_BANNER_INDEX(indexPath.row))
        {
            return CELL_HEIGHT_REGULAR + BANNER_HEIGHT;
        }
        else if (IS_BIG_BANNER_INDEX(indexPath.row))
        {
            return CELL_HEIGHT_REGULAR + BIG_BANNER_HEIGHT;
        }
        
        return CELL_HEIGHT_REGULAR;
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Post *post = [self.resultController fetchedObjects][indexPath.row];
    
    if (!indexPath.row)
    {
        ((TopPostCell *)cell).backgroundImage.backgroundColor = [UIColor colorWithRed:0.72 green:0.8 blue:0.89 alpha:1];
        
        if (post.imageURL.length)
        {
            [((TopPostCell *)cell).backgroundImage sd_setImageWithURL:[NSURL URLWithString:post.imageURL.URLWithoutQueryParameters]];
        }
        else
        {
            ((TopPostCell *)cell).backgroundImage.image = nil;
        }
        
        ((TopPostCell *)cell).titleLabel.text = post.title;
        ((TopPostCell *)cell).authorLabel.text = post.source;
        ((TopPostCell *)cell).dateLabel.text = [post.createdAt formattedString];
        
        [((TopPostCell *)cell).scrollDownButton addTarget:self
                                     action:@selector(scrollDownPressed:)
                           forControlEvents:UIControlEventTouchUpInside];
        
        [((TopPostCell *)cell) configureForCategoryScreen:NO];
        
        ((TopPostCell *)cell).scrollDownButton.hidden = YES;
        
        ((TopPostCell *)cell).tag = indexPath.row;
    }
    else
    {
        static UIImage *logoImage;
        
        if (!logoImage)
        {
            logoImage = [UIImage imageNamed:@"NewLogo"];
        }
        
        [((SimplePostCell *)cell) .postImageView sd_setImageWithURL:[NSURL URLWithString:post.imageURL.URLWithoutQueryParameters] placeholderImage:logoImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             //NSLog(@"%@\n%@", indexPath, post);
         }];
        
        ((SimplePostCell *)cell) .titleLabel.text = post.title;
        ((SimplePostCell *)cell) .authorLabel.text = post.source;
        ((SimplePostCell *)cell) .dateLabel.text = [post.createdAt formattedString];
        
        ((SimplePostCell *)cell) .tag = indexPath.row;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        HLHeaderViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_HEADER forIndexPath:indexPath];
        
        return headerCell;
    }
    
    if (indexPath.row == self.resultController.fetchedObjects.count - 1 && !self.downloading && !self.downloadedAllNews)
    {
        [self fetchAndLoadNewsWithSkipping:YES];
    }
    
    //Post *post = [self.resultController fetchedObjects][indexPath.row];
    
    if (!indexPath.row)
    {
        TopPostCell *topCell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_TOP forIndexPath:indexPath];
        
        [self configureCell:topCell atIndexPath:indexPath];
        
        return topCell;
    }
    else
    {
        SimplePostCell *theCell;
        
        if (!IS_SMALL_BANNER_INDEX(indexPath.row) && !IS_BIG_BANNER_INDEX(indexPath.row))
        {
            theCell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_REGULAR forIndexPath:indexPath];
            
            [theCell removeBanner];
        }
        else
        {
            if (IS_SMALL_BANNER_INDEX(indexPath.row))
            {
                theCell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_REGULAR_SMALL
                                                          forIndexPath:indexPath];
            }
            else
            {
                theCell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_REGULAR_BIG
                                                          forIndexPath:indexPath];
            }
        }
        
        [self configureCell:theCell atIndexPath:indexPath];
        
        return theCell;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.section)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Post *post = [self.resultController fetchedObjects][indexPath.row];

    self.selectedPostID = post.postID;
    
    if (post)
    {
        [self performSegueWithIdentifier:@"toPostDetailController"
                                  sender:self];
    }
}

#pragma mark - Actions

- (void)scrollDownPressed:(UIButton *)sender
{
    CGFloat topCellHeight = CGRectGetHeight(self.view.bounds) - CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) - CGRectGetHeight(self.navigationController.navigationBar.frame) - self.tableView.contentInset.top;
    
    [self.tableView scrollRectToVisible:CGRectMake(0, topCellHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)) animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toPostDetailController"])
    {
        UINavigationController *navController = segue.destinationViewController;
        HLPostDetailViewController *postController = [navController.viewControllers firstObject];
        
        postController.postID = self.selectedPostID;
    }
}

- (void)openPostNotification:(NSNotification*)note
{
    [self openPost:note.object];
}

- (void)openPost:(Post*)post
{
    [self.tabBarController setSelectedIndex:0];
    if ([self presentedViewController])
    {
        [self dismissViewControllerAnimated:YES completion:^()
        {
            self.selectedPostID = [post postID];
            [self performSegueWithIdentifier:@"toPostDetailController" sender:nil];
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] clearArticleIdToOpen];
        }];
    }
    else
    {
        self.selectedPostID = [post postID];
        [self performSegueWithIdentifier:@"toPostDetailController" sender:nil];
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] clearArticleIdToOpen];
    }
}

@end
