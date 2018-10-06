/********* qqlocation.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <TencentLBS/TencentLBS.h>
@interface qqlocation : CDVPlugin<TencentLBSLocationManagerDelegate> {
  // Member variables go here.
}
@property (nonatomic, strong) TencentLBSLocationManager* locationManager;
@property (nonatomic, strong) CDVInvokedUrlCommand* command;
- (void)getLocation:(CDVInvokedUrlCommand*)command;
@end

@implementation qqlocation

- (void)getLocation:(CDVInvokedUrlCommand*)command
{
    self.command = command;
    [self configLocationManager];
    [self startSingleLocation];
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
}
@end
