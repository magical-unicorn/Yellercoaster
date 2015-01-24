//
//  BezierHelper.h
//  Yellercoaster
//
//  Created by Biou on 24/01/2015.
//  Copyright (c) 2015 magicalunicorns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BezierHelper : NSObject
+(NSMutableArray *) getPointsFromPath: (CGPathRef) p;
@end
