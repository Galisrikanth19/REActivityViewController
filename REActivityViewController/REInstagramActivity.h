//
//  REInstagramActivity.h
//  Pods
//
//  Created by Admin on 1/3/14.
//
//

#import "REActivity.h"

@interface REInstagramActivity : REActivity

@property (copy, nonatomic) NSString *consumerKey;
@property (copy, nonatomic) NSString *consumerSecret;

- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret;


@end
