//
//  BezierHelper.m
//  Yellercoaster
//
//  Created by Biou on 24/01/2015.
//  Copyright (c) 2015 magicalunicorns. All rights reserved.
//

#import "BezierHelper.h"
#import "UIBezierPath+Rob_points.h"
#import <UIKit/UIKit.h>

@implementation BezierHelper

+(NSMutableArray *) getPointsFromPath: (CGPathRef) p {
	UIBezierPath *path = [UIBezierPath.class bezierPathWithCGPath:p];
	//    [path stroke];
	CGFloat interval = 8.0;
	NSMutableArray * result = [NSMutableArray array];
	[path Rob_forEachPointAtInterval:interval perform:^(CGPoint point, CGVector vector) {
		[result addObject:@[[NSNumber numberWithDouble:point.x],[NSNumber numberWithDouble:point.y]]];
	}];
	return result;
}

@end
