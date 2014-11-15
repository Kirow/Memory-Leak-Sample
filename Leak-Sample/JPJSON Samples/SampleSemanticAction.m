//
// Created by Kirow on 6/30/14.
//

#import "SampleSemanticAction.h"


@interface SampleSemanticAction ()

@end

@implementation SampleSemanticAction {
    NSInteger _insideLevel;
    NSInteger _colNum;
}

- (id)init {
    self = [super init];
    if (self) {
        _insideLevel = 0;
    }

    return self;
}

- (instancetype)initWithProgressDelegate:(id <SampleSemanticActionDelegate>)progressDelegate {
    self = [self init];
    if (self) {
        self.progressDelegate = progressDelegate;
    }

    return self;
}

+ (instancetype)actionWithProgressDelegate:(id <SampleSemanticActionDelegate>)progressDelegate {
    return [[self alloc] initWithProgressDelegate:progressDelegate];
}


- (void)parserFoundJsonBegin {
    NSLog(@"JSON BEGIN");
}


- (void)parserFoundArrayBegin {
    ++_insideLevel;
}

- (void)parserFoundArrayEnd {
    --_insideLevel;
}

- (void)parserFoundString:(const void *)bytes length:(size_t)length hasMore:(BOOL)hasMore encoding:(NSStringEncoding)encoding {
    NSString *str = [[NSString alloc] initWithBytes:bytes length:length encoding:encoding];
    ++_colNum;
}


- (void)parserFoundJsonEnd {
    NSLog(@"JSON END");
}

@end
