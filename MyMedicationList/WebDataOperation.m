//
//  WebDataOperation.m
//  MyMedicationList

// National Library of Medicine
// Code available in the public domain
//

#import "WebDataOperation.h"

@interface WebDataOperation (){
    
	BOOL _doesUseJSON;
	SEL _operationDataHandler;
    SEL _errorDataHandler;

}
@property (copy,nonatomic) NSString *urlString;
@property (retain,nonatomic) id context;

@end


@implementation WebDataOperation
@synthesize dataHandlerDelegate = _dataHandlerDelegate;
@synthesize urlString = _urlString;
@synthesize context = _context;

- (id)initWithURLString:(NSString *)urlString usesJSON:(BOOL)doesUseJSON withDataHandler:(SEL)dataHandler forError:(SEL) errorHandler
{
	NSLog(@"initWithURLString:usesJSONL:withDataHandler");
    return [self initWithURLString:urlString usesJSON:doesUseJSON withDataHandler:dataHandler withContext:nil forError:errorHandler];
}

- (id)initWithURLString:(NSString *)urlString usesJSON:(BOOL)doesUseJSON withDataHandler:(SEL)dataHandler withContext:(id)context forError:(SEL) errorHandler
{
	NSLog(@"initWithURLString:usesJSONL:withDataHandler:withContext:");
    self = [super init];
	if(self)
	{
		self.urlString = urlString;
		self.context = context;
        _doesUseJSON = doesUseJSON;
        _operationDataHandler = dataHandler;
        _errorDataHandler = errorHandler;
	}
	return self;
}

- (void)dealloc {
	self.urlString = nil;
    self.context = nil;
    self.dataHandlerDelegate = nil;
	[super dealloc];	
}

- (void)main{
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	
	NSURL *url = [NSURL URLWithString:_urlString];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url 
																cachePolicy:NSURLRequestReloadIgnoringCacheData 
															timeoutInterval:30.0];
	if(_doesUseJSON)
		[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	
	NSMutableData *receivedData = nil;
	receivedData = (NSMutableData *)[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	[request release];

    if(error != nil) {
        NSLog(@"%@",[error description]);
        if([_dataHandlerDelegate respondsToSelector:_errorDataHandler])
        {
           [_dataHandlerDelegate performSelector:_errorDataHandler withObject:[error localizedDescription]];
        }
        else
			[NSException raise:@"Missing Implementation" format:@"The handler for the selector '%@' was not found...",NSStringFromSelector(_errorDataHandler)];
    }
	if(error == nil && ![self isCancelled])
	{
		if([_dataHandlerDelegate respondsToSelector:_operationDataHandler])
        {
            if(_context == nil)
                [_dataHandlerDelegate performSelector:_operationDataHandler withObject:receivedData];
            else
                [_dataHandlerDelegate performSelector:_operationDataHandler withObject:receivedData withObject:_context];
        }
		else
			[NSException raise:@"Missing Implementation" format:@"The handler for the selector '%@' was not found...",NSStringFromSelector(_operationDataHandler)];
	}
	
	[pool release];
	
}

@end
