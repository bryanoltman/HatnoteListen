//
//  HATWikipediaLanguage.h
//  HatnoteListen
//
//  Created by Bryan Oltman on 3/16/14.
//  Copyright (c) 2014 Bryan Oltman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HATWikipediaLanguage : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSURL *websocketURL;

@end
