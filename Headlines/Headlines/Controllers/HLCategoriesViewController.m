//
//  HLCategoriesViewController.m
//  Headlines
//
//

#import "HLCategoriesViewController.h"
#import "CategoryCell.h"
#import "HLNewsViewController.h"
#import "HLNavigationController.h"
#import "Post+Additions.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIFont+Consended.h"
#import <UIImage-Categories/UIImage+Resize.h>
#import "NSString+URLEncoding.h"
#import <SDWebImage/SDWebImageManager.h>
#import "HLCountryCell.h"
#import "HLSearchViewController.h"

#define CELL_ID @"CELL_ID"
#define CELL_ID_COUNTRY @"countryCell"
#define CELL_LINE_PADDING 1.5
#define CATEGORIES_COUNT 10
#define COUNTRY_CELL_HEIGHT 30
#define COUNTRY_CELL_HEIGHT_WITH_PADDING 45
#define CELL_LEFT_RIGHT_INSETS 8 //Check in storyboard
#define BIG_CELL_WIDTH (CGRectGetWidth(self.view.frame) / 1.6f) // ¯\_(ツ)_/¯
#define IS_BIG_CELL (indexPath.row == 0 || !(indexPath.row % 3))

typedef NS_ENUM(NSUInteger, CollectionViewTag) {
    CollectionViewTagCategories,
    CollectionViewTagCountries
};

typedef NS_ENUM(NSUInteger, CellIndex) {
    CellIndexAllNews,
    CellIndexBlogs,
    CellIndexBusiness,
    CellIndexPolitics,
    CellIndexSports,
    CellIndexTechnology,
    CellIndexHealthcare
};

@interface HLCategoriesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isDownloading;
@property (strong, nonatomic) NSMutableDictionary *usedURLs;
@property (weak, nonatomic) IBOutlet UIButton *topicsButton;
@property (weak, nonatomic) IBOutlet UIButton *countriesButton;
@property (weak, nonatomic) IBOutlet UICollectionView *countriesCollectionView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIImageView *countryBackground;
@property (weak, nonatomic) IBOutlet UIImageView *searchIconView;

@end

@implementation HLCategoriesViewController
{
    NSMutableArray *images;
    NSArray *categories;
    NSArray *countries;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.usedURLs = [NSMutableDictionary new];
    
    self.collectionView.tag = CollectionViewTagCategories;
    self.countriesCollectionView.tag = CollectionViewTagCountries;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self
                            action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    [self topicsButtonPressed:self.topicsButton];
    
    [self prepareImagesArray];
    
    categories = @[@"Blogs",
                   @"Business",
                   @"Politics",
                   @"Sports",
                   @"Technology",
                   @"Healthcare"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CategoryCell class])
                                                    bundle:[NSBundle mainBundle]]
          forCellWithReuseIdentifier:CELL_ID];
    
    [self.collectionView reloadData];
    
    countries = @[@"Eastern Africa",
                  @"Ethiopia",
                  @"Kenya",
                  @"Middle Africa",
                  @"Angola",
                  @"Cameroon",
                  @"Nothern Africa",
                  @"Algeria",
                  @"Egypt",
                  @"Southern Africa",
                  @"Ghana",
                  @"Nigeria",
                  @"Western Africa"];
    
    self.countriesCollectionView.allowsMultipleSelection = YES;
    self.countriesCollectionView.backgroundColor = [UIColor clearColor];
    [self.countriesCollectionView reloadData];
}

- (void)refresh:(UIRefreshControl *)control
{
    [control beginRefreshing];
    
    [self fetchAndLoadNewsForCategory:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self reloadImages];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadImages)
                                                 name:kNotificationDownloadedPosts
                                               object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationDownloadedPosts
                                                  object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - News

- (void)fetchAndLoadNewsForCategory:(NSString *)category
{
    if (self.isDownloading)
    {
        [self.refreshControl endRefreshing];
        
        return;
    }
    
    self.isDownloading = YES;
    
    PFQuery *query = [PFQuery queryWithClassName:NSStringFromClass([Post class])];
    
    if (category.length)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", category];
        
        query = [PFQuery queryWithClassName:NSStringFromClass([Post class]) predicate:predicate];
    }
    
    query.limit = 100;
    [query orderByDescending:@"createdAt"];
    
    __weak typeof(self) controller = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [Post createOrUpdatePostsInBackground:objects completion:^(BOOL success, NSError *error) {
            
            [controller.refreshControl endRefreshing];
            
            controller.isDownloading = NO;
            
            if (error)
            {
                NSLog(@"Error: %@", error);
            }
            
            [controller reloadImages];
        }];
    }];
}

- (void)prepareImagesArray
{
    images = [NSMutableArray new];
    
    for (NSInteger i = 0; i < 6; i++)
    {
        [images addObject:[UIImage imageNamed:@"category_default"]];
    }
}

- (void)reloadImages
{
    for (NSInteger i = 0; i < CellIndexHealthcare; i++)
    {
        NSString *categoryName = categories[i];
        Post *featuredPost = [Post MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"category == %@ && imageURL.length > 0", categoryName]
                                                    sortedBy:@"createdAt"
                                                   ascending:NO];
        
        NSString *key = [NSString stringWithFormat:@"%li", (long)i];
        
        if (!featuredPost && ![self.usedURLs[key] length])
        {
            self.usedURLs[key] = @"";
            [self showImageAtIndex:i animated:YES];
            
            [self fetchAndLoadNewsForCategory:categories[i]];
            continue;
        }
        
        BOOL animate = YES;
        
        if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:featuredPost.imageURL]])
        {
            animate = NO;
        }
        
        if ([self.usedURLs[key] length] > 0 && [self.usedURLs[key] isEqualToString:featuredPost.imageURL])
        {
            continue;
        }
        
        __weak typeof(self) controller = self;
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:featuredPost.imageURL.URLWithoutQueryParameters]
                                                              options:(SDWebImageDownloaderContinueInBackground|SDWebImageDownloaderUseNSURLCache)
                                                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                                 
                                                             }
                                                            completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                
                                                                if (image && finished)
                                                                {
                                                                    NSLog(@"Downloaded** %li %@", (long)i, featuredPost.imageURL);
                                                                    
                                                                    self.usedURLs[key] = featuredPost.imageURL;
                                                                    
                                                                    images[i] = image;
                                                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                        
                                                                        [controller showImageAtIndex:i animated:YES];
                                                                    });
                                                                }
                                                                else
                                                                {
                                                                    NSLog(@"Failed** %li %@", (long)i, featuredPost.imageURL);
                                                                    
                                                                    controller.usedURLs[key] = @"";
                                                                    
                                                                    if (images[i])
                                                                    {
                                                                        //[controller showImageAtIndex:i animated:YES];
                                                                    }
                                                                    
                                                                    NSLog(@"%@", error);
                                                                }
                                                            }];


    }
}

- (void)showImageAtIndex:(NSInteger)index animated:(BOOL)animated
{
    CategoryCell *theCell = (CategoryCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    CGSize cellSize = theCell.frame.size;
    
    UIImage *prevImage = nil;
    if (theCell.theImageView.frontView && ((UIImageView *)theCell.theImageView.frontView).image)
    {
        prevImage = ((UIImageView *)theCell.theImageView.frontView).image;
    }
    
    CGFloat scaleFactor = [UIScreen mainScreen].scale;
    
    UIImage *frontImage = prevImage ? prevImage : [self imageWithImage:[UIImage imageNamed:@"navbarIMG"] scaledToSize:CGSizeMake(cellSize.width * scaleFactor, cellSize.height * scaleFactor)];
    UIImage *backImage = [self imageWithImage:images[index] scaledToSize:CGSizeMake(cellSize.width * scaleFactor, cellSize.height * scaleFactor)];
    
    UIImageView *frontView = [[UIImageView alloc] initWithImage:frontImage];
    UIImageView *backView = [[UIImageView alloc] initWithImage:backImage];
    frontView.contentMode = backView.contentMode = UIViewContentModeScaleAspectFill;
    frontView.clipsToBounds = backView.clipsToBounds = YES;
    
    theCell.theImageView.contentMode = UIViewContentModeScaleAspectFill;
    theCell.theImageView.frontView = frontView;
    theCell.theImageView.backView = backView;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [theCell.theImageView tick:SBTickerViewTickDirectionDown animated:animated completion:^{
            
            
        }];
    });
}

- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    CGFloat w = 0, h = 0;
    CGRect bounds;
    
    if (image.size.width <= image.size.height)
    {
        w = h = image.size.width;
        bounds = CGRectMake(0, (image.size.height - h) / 2, w, h);
    }
    else
    {
        w = h = image.size.height;
        bounds = CGRectMake((image.size.width - w) / 2, 0, w, h);
    }
    
    image = [image croppedImage:bounds];
    
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (CGRect)imageBoundsForCellSize:(CGSize)cellSize imageSize:(CGSize)imageSize
{
    CGFloat x = 0, y = 0, width = 0, height = 0;
    
    if (imageSize.width >= imageSize.height)
    {
        height = imageSize.height;
        width = height * cellSize.width / cellSize.height;
        
        x = (imageSize.width - width) / 2;
    }
    else
    {
        width = imageSize.width;
        height = width * cellSize.height / cellSize.width;
        
        y = (imageSize.height - height) / 2;
    }
    
    CGRect bounds = CGRectMake(x, y, cellSize.width, cellSize.height);
    
    return bounds;
}

#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self performSegueWithIdentifier:@"toSearchScreen" sender:self];
    
    return YES;
}

#pragma mark - CollectionView

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellSize;
   
    // Countries
    if (collectionView.tag == CollectionViewTagCountries)
    {
        cellSize.height = IS_BIG_CELL ? COUNTRY_CELL_HEIGHT : COUNTRY_CELL_HEIGHT_WITH_PADDING;
        cellSize.width = IS_BIG_CELL ? BIG_CELL_WIDTH : (CGRectGetWidth(self.view.frame) - CELL_LEFT_RIGHT_INSETS * 3) / 2;
        
        return cellSize;
    }
    
    cellSize.width = CGRectGetWidth(self.view.bounds) / 2 - CELL_LINE_PADDING;
    cellSize.height = cellSize.width;
    
    return cellSize;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // Countries
    if (collectionView.tag == CollectionViewTagCountries)
    {
        return countries.count + 1;
    }
    
    return images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Countries
    if (collectionView.tag == CollectionViewTagCountries)
    {
        HLCountryCell *theCell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID_COUNTRY
                                                                           forIndexPath:indexPath];
        
        if (indexPath.row == countries.count)
        {
            theCell.hidden = YES;
            
            return theCell;
        }
        else
        {
            theCell.hidden = NO;
        }
        
        [theCell setSelected:NO];
        theCell.theLabel.text = countries[indexPath.row];

        return theCell;
    }
    
    
    // Categories
    CategoryCell *theCell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    theCell.layer.masksToBounds = NO;
    theCell.clipsToBounds = NO;
    //theCell.theImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    //Post *featuredPost = [Post MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"category == %@ && imageURL.length > 0", categoryName]
    //                                            sortedBy:@"createdAt"
    //                                           ascending:NO];
    
    theCell.theImageView.alpha = 1;
    
    if (theCell.theImageView.frontView)
    {
        CGFloat scaleFactor = [UIScreen mainScreen].scale;
        CGSize cellSize = CGSizeMake(CGRectGetWidth(self.view.bounds) / 2 - CELL_LINE_PADDING, CGRectGetWidth(self.view.bounds) / 2 - CELL_LINE_PADDING);
        UIImage *backImage = [self imageWithImage:images[indexPath.row] scaledToSize:CGSizeMake(cellSize.width * scaleFactor, cellSize.height * scaleFactor)];
        
        UIImageView *frontView = [[UIImageView alloc] initWithImage:backImage];
        UIImageView *backView = [[UIImageView alloc] initWithImage:backImage];
        frontView.contentMode = backView.contentMode = UIViewContentModeScaleAspectFill;
        frontView.clipsToBounds = backView.clipsToBounds = YES;
        
        theCell.theImageView.contentMode = UIViewContentModeScaleAspectFill;
        theCell.theImageView.frontView = frontView;
        theCell.theImageView.backView = backView;
    }
    
    theCell.theTitleLabel.font = [UIFont mediumConsendedWithSize:16];
    theCell.theTitleLabel.text = categories[indexPath.row];
    
    return theCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Countries
    if (collectionView.tag == CollectionViewTagCountries)
    {
        [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        
        return;
    }
    
    [self.view endEditing:YES];
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    HLNewsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardIDNewsController];
    
    controller.category = categories[indexPath.row];
    
    HLNavigationController *navController = [[HLNavigationController alloc] initWithRootViewController:controller];
    
    [self presentViewController:navController animated:NO completion:nil];
    //[self.navigationController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)topicsButtonPressed:(id)sender
{
    [self.view endEditing:YES];
    
    [self.topicsButton setSelected:YES];
    [self.countriesButton setSelected:NO];
    
    self.collectionView.hidden = self.searchField.hidden = self.searchIconView.hidden = NO;
    self.countriesCollectionView.hidden = self.countryBackground.hidden = YES;
}

- (IBAction)countriesButtonPressed:(id)sender
{
    [self.view endEditing:YES];
    
    [self.countriesButton setSelected:YES];
    [self.topicsButton setSelected:NO];
    
    self.collectionView.hidden = self.searchField.hidden = self.searchIconView.hidden = YES;
    self.countriesCollectionView.hidden = self.countryBackground.hidden = NO;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"toSearchScreen"])
    {
        ((HLSearchViewController *)(((UINavigationController *)segue.destinationViewController)).viewControllers[0]).searchString = self.searchField.text;
    }
}

@end
