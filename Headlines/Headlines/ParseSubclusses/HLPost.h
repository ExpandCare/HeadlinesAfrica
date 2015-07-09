//
//  HLPost.h
//  Headlines
//
//

#import <Parse/Parse.h>
#import <Parse/PFSubclassing.h>
#import <Parse/PFObject+Subclass.h>

@interface HLPost : PFObject <PFSubclassing>

@property (nonatomic) NSString * author;
@property (nonatomic) NSString * category;
@property (nonatomic) NSString * country;
@property (nonatomic) NSString * content;
@property (nonatomic) NSDate * createdAt;
@property (nonatomic) NSArray * imageURL;
@property (nonatomic) NSString * link;
@property (nonatomic) NSString * postID;
@property (nonatomic) NSString * title;
@property (nonatomic) NSData * titleImage;
@property (nonatomic) NSDate * updatedAt;
@property (nonatomic) NSString * url;
@property (nonatomic) NSString * source;
@property (nonatomic) NSNumber * sharesCount;
@property (nonatomic) NSNumber * likesCount;
@property (nonatomic) NSNumber * commentsCount;

+ (NSString *)parseClassName;

@end
