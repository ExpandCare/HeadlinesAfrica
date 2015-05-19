//
//  Post.h
//  Headlines
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * commentsCount;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * likesCount;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * postID;
@property (nonatomic, retain) NSNumber * sharesCount;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * titleImage;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * likedBy;

@end
