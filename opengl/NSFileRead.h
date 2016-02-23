//
//  NSFileRead.h
//  opengl
//
//  Created by marcin on 15/01/16.
//  Copyright © 2016 Marcin Karmelita. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileRead : NSObject


/// Reads previously prepared points of working space
///
/// @return Points of working space
- (NSArray*) readFile;
@end
