//
//  Comment.h
//  Headlines
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Comment : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * postID;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * commentID;

@end
