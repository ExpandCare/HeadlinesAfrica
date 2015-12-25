//
//  Post.h
//  Headlines


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Post : NSManagedObject

@property (nullable, nonatomic, retain) NSString *author;
@property (nullable, nonatomic, retain) NSString *category;
@property (nullable, nonatomic, retain) NSNumber *commentsCount;
@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSString *country;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *imageURL;
@property (nullable, nonatomic, retain) NSString *likedBy;
@property (nullable, nonatomic, retain) NSNumber *likesCount;
@property (nullable, nonatomic, retain) NSString *link;
@property (nullable, nonatomic, retain) NSString *postID;
@property (nullable, nonatomic, retain) NSNumber *sharesCount;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSData *titleImage;
@property (nullable, nonatomic, retain) NSDate *updatedAt;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSString *thumb;

@end


