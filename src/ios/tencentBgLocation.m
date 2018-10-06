/********* tencentBgLocation.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <TencentLBS/TencentLBS.h>
#import <AFNetworking/AFNetworking.h>

@interface tencentBgLocation : CDVPlugin<TencentLBSLocationManagerDelegate> {
  // Member variables go here.
}
@property (nonatomic, strong) TencentLBSLocationManager* locationManager;
@property (nonatomic, strong) CDVInvokedUrlCommand* command;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* carplate;
@property (nonatomic, strong) NSString* handoverno;

- (void)coolMethod:(CDVInvokedUrlCommand*)command;
- (void)start:(CDVInvokedUrlCommand*)command;
- (void)stop:(CDVInvokedUrlCommand*)command;
@end

@implementation tencentBgLocation
-(void)pluginInitialize{
     [self configLocationManager];
}
- (void)start:(CDVInvokedUrlCommand*)command{
    if (command.arguments.count == 0) {
        return;
    }
    NSDictionary* args = [command.arguments objectAtIndex:0];
    if (!args) {
        return;
    }
    self.url = [args objectForKey:@"url"];
    if (self.handoverno) {
        self.handoverno = [NSString stringWithFormat:@"%@,%@",[args objectForKey:@"handoverno"], self.handoverno];
    }else {
        self.handoverno = [args objectForKey:@"handoverno"];
    }
    self.carplate = [args objectForKey:@"carplate"];
    [self startSerialLocation];
}

- (void)stop:(CDVInvokedUrlCommand*)command{
    [self stopSerialLocation];
}

- (void)coolMethod:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = [command.arguments objectAtIndex:0];

    if (echo != nil && [echo length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)configLocationManager
{
    self.locationManager = [[TencentLBSLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setApiKey:[self.commandDelegate.settings objectForKey:@"api_key"]];
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    // 需要后台定位的话，可以设置此属性为YES。
    // [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    // 如果需要POI信息的话，根据所需要的级别来设定，定位结果将会根据设定的POI级别来返回，如：
    [self.locationManager setRequestLevel:TencentLBSRequestLevelName];
    // 申请的定位权限，得和在info.list申请的权限对应才有效
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

// 单次定位
- (void)startSingleLocation {
    [self.locationManager requestLocationWithCompletionBlock:
     ^(TencentLBSLocation *location, NSError *error) {
         NSDictionary* result = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithDouble:location.location.coordinate.latitude], @"latitude",
                                 [NSNumber numberWithDouble:location.location.coordinate.longitude], @"longitude",
                                 nil];
         CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
         [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
     }];
}

// 连续定位
- (void)startSerialLocation {
    //开始定位
    [self.locationManager startUpdatingLocation];
}

- (void)stopSerialLocation {
    //停止定位
    [self.locationManager stopUpdatingLocation];
}

- (void)tencentLBSLocationManager:(TencentLBSLocationManager *)manager
                 didFailWithError:(NSError *)error {
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusDenied ||
        authorizationStatus == kCLAuthorizationStatusRestricted) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"定位权限未开启，是否开启？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"是"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    if( [[UIApplication sharedApplication]canOpenURL:
                                                         [NSURL URLWithString:UIApplicationOpenSettingsURLString]] ) {
                                                        [[UIApplication sharedApplication] openURL:
                                                         [NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                    }
                                                }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"否"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                }]];
        
        [self.viewController presentViewController:alert animated:true completion:nil];
        
    }
}


- (void)tencentLBSLocationManager:(TencentLBSLocationManager *)manager
                didUpdateLocation:(TencentLBSLocation *)location {
    //定位结果
    NSLog(@"location:%@", location.location);
    AFHTTPSessionManager *afm = [AFHTTPSessionManager manager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithFloat:location.location.coordinate.latitude], @"latitude",
                                       [NSNumber numberWithFloat:location.location.coordinate.longitude], @"longitude",
                                       self.handoverno, @"handoverno",
                                       self.carplate, @"carplate",
                                       nil];
    [afm POST:self.url
   parameters:parameters
     progress:^(NSProgress * _Nonnull uploadProgress) {}
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {}
      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {}];
}

@end
