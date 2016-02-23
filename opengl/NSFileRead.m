//
//  NSFileRead.m
//  opengl
//
//  Created by marcin on 15/01/16.
//  Copyright © 2016 Marcin Karmelita. All rights reserved.
//

#import "NSFileRead.h"

@implementation NSFileRead

-(NSArray*) readFile{

    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"przestrzen_robocza_xyz" ofType:@"txt"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    if (error)
        NSLog(@"Error reading file: %@", error.localizedDescription);
    

    NSArray *listArray = [fileContents componentsSeparatedByString:@"\n"];
    
    NSLog(@"items = %lu", (unsigned long)[listArray count]);
    
  

    return listArray;
}



@end
