//
// Created by Kirow on 6/30/14.
//

#import <Foundation/Foundation.h>
#import "JPStreamSemanticActions.h"

@protocol SampleSemanticActionDelegate <NSObject>

@end

@interface SampleSemanticAction : JPStreamSemanticActions

@property(weak, nonatomic) id <SampleSemanticActionDelegate> progressDelegate;

- (instancetype)initWithProgressDelegate:(id <SampleSemanticActionDelegate>)progressDelegate;

+ (instancetype)actionWithProgressDelegate:(id <SampleSemanticActionDelegate>)progressDelegate;

@end