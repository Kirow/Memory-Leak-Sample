//
//  ViewControllerJSON.m
//  MORLMPrototype
//
//  Created by Feather4 on 11/6/14.
//  Copyright (c) 2014 Appus. All rights reserved.
//


#import "ViewControllerJSON.h"
#import "JPAsyncJsonParser.h"
#import "JPRepresentationGenerator.h"
#import "SampleSemanticAction.h"

@interface ViewControllerJSON () <NSURLSessionDataDelegate, SampleSemanticActionDelegate>
@property(strong, nonatomic) NSURLSession *session;
@property(strong, nonatomic) JPAsyncJsonParser *parser;

@property(nonatomic, weak) IBOutlet UIProgressView *progressView;
@property(nonatomic, weak) IBOutlet UILabel *iterationLabel;
@property(nonatomic, weak) IBOutlet UILabel *sizeLabel;
@property(nonatomic, weak) IBOutlet UILabel *progressLabel;

@property(nonatomic) long long int totalSizeLoaded;
@property(readonly) long long int loadSize;
@property(nonatomic) int iteration;

@end

@implementation ViewControllerJSON

- (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible {
    static NSInteger NumberOfCallsToSetVisible = 0;
    if (setVisible)
        NumberOfCallsToSetVisible++;
    else
        NumberOfCallsToSetVisible--;

    // The assertion helps to find programmer errors in activity indicator management.
    // Since a negative NumberOfCallsToSetVisible is not a fatal error,
    // it should probably be removed from production code.
    NSAssert(NumberOfCallsToSetVisible >= 0, @"Network Activity Indicator was asked to hide more often than shown");

    // Display the indicator as long as our static counter is > 0.
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(NumberOfCallsToSetVisible > 0)];
}

- (long long int)loadSize {
    return 189778220;
}

- (void)setIteration:(int)iteration {
    _iteration = iteration;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.iterationLabel.text = [NSString stringWithFormat:@"Iteration: %i", _iteration];
    });
}


- (void)setTotalSizeLoaded:(long long int)totalSizeLoaded {
    _totalSizeLoaded = totalSizeLoaded;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.sizeLabel.text = [NSString stringWithFormat:@"Total Size: %qi", _totalSizeLoaded];
    });
}


- (JPAsyncJsonParser *)parser {
    if (!_parser) {
        SampleSemanticAction *actions = [[SampleSemanticAction alloc] initWithProgressDelegate:self];
        actions.errorHandlerBlock = ^(NSError *error) {
            NSLog(@"JPJson Error Catch - %@", error);
        };
        _parser = [[JPAsyncJsonParser alloc] initWithSemanticActions:actions workerDispatchQueue:NULL];

    }
    return _parser;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.progressView.progress = 0;
    self.iteration = 0;
    self.totalSizeLoaded = 0;

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setAllowsCellularAccess:YES];
    [config setHTTPAdditionalHeaders:@{
            @"Accept" : @"application/json, text/plain",
            @"Accept-Encoding" : @"gzip, deflate"
    }];

    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];

}

- (IBAction)sendRequest:(id)sender {
    self.progressView.progress = 0;
    NSURL *URL = [NSURL URLWithString:@"https://github.com/zemirco/sf-city-lots-json/raw/master/citylots.json"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 30;

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    [task resume];
    [self setNetworkActivityIndicatorVisible:YES];
    ++self.iteration;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler {

}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSLog(@"didReceiveResponse");
    NSDictionary *dictionary = [(NSHTTPURLResponse *) response allHeaderFields];
//    _loadSize = [dictionary[@"Content-Length"] longLongValue];
//    _itemsToParse = [dictionary[@"Archive-Rows"] integerValue];
    self.parser = nil;
    [self.parser start]; //restart parser
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    NSLog(@"didBecomeDownloadTask");
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.parser parseBuffer:data];
    self.totalSizeLoaded += data.length;

    dispatch_async(dispatch_get_main_queue(), ^{
        float percent = (float) dataTask.countOfBytesReceived / self.loadSize;
        self.progressView.progress = percent;
        self.progressLabel.text = [NSString stringWithFormat:@"Progress - %.02f%%", percent * 100];
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error");
    [self setNetworkActivityIndicatorVisible:NO];
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"URLSessionDidFinishEventsForBackgroundURLSession");
}


@end