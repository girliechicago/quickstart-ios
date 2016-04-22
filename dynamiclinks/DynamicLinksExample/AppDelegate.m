//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "AppDelegate.h"
// [START import]
@import FirebaseDynamicLinks;
// [END import]

@import Firebase;
@import GoogleSignIn;

static NSString *const CUSTOM_URL_SCHEME = @"gindeeplinkurl";

@implementation AppDelegate

// [START didfinishlaunching]
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Set deepLinkURLScheme to the custom URL scheme you defined in your
  // Xcode project.
  [FIROptions defaultOptions].deepLinkURLScheme = CUSTOM_URL_SCHEME;
  [FIRApp configure];

  return YES;
}
// [END didfinishlaunching]

// [START openurl]
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options {
  return [self application:app openURL:url sourceApplication:nil annotation:@{}];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  if ([[GIDSignIn sharedInstance] handleURL:url
                          sourceApplication:sourceApplication
                                 annotation:annotation]) {
    return YES;
  }

  FIRDynamicLink *dynamicLink =
  [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];

  if (dynamicLink) {
    // Handle the deep link. For example, show the deep-linked content or
    // apply a promotional offer to the user's account.
    // [START_EXCLUDE]
    // In this sample, we just open an alert.
    NSString *matchConfidence;
    if (dynamicLink.matchConfidence == FIRDynamicLinkMatchConfidenceWeak) {
      matchConfidence = @"Weak";
    } else {
      matchConfidence = @"Strong";
    }
    NSString *message = [NSString stringWithFormat:@"App URL: %@\n"
                         @"Match Confidence: %@\n",
                         dynamicLink.url, matchConfidence];
    [self showDeepLinkAlertViewWithMessage:message];
    // [END_EXCLUDE]
    return YES;
  }

  // [START_EXCLUDE silent]
  // Show the deep link that the app was called with.
  [self showDeepLinkAlertViewWithMessage:[NSString stringWithFormat:@"openURL:\n%@", url]];
  // [END_EXCLUDE]
  return NO;
}
// [END openurl]

// [START continueuseractivity]
- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray *))restorationHandler {

  // [START_EXCLUDE silent]
  BOOL handled = NO;

  __weak AppDelegate *weakSelf = self;
  // [END_EXCLUDE]
  handled = [[FIRDynamicLinks dynamicLinks]
             handleUniversalLink:userActivity.webpageURL
             completion:^(FIRDynamicLink * _Nullable dynamicLink,
                          NSError * _Nullable error) {
               // [START_EXCLUDE]
               AppDelegate *strongSelf = weakSelf;
               // the source application needs to be safari or chrome, otherwise
               // GIDSignIn will not handle the URL.
               NSString *sourceApplication = @"com.apple.mobilesafari";
               [strongSelf application:application
                               openURL:dynamicLink.url
                     sourceApplication:sourceApplication
                            annotation:@{}];
               // [END_EXCLUDE]
             }];

  // [START_EXCLUDE silent]
  if (!handled) {
    // Show the deep link URL from userActivity.
    NSString *message =
    [NSString stringWithFormat:@"continueUserActivity webPageURL:\n%@", userActivity.webpageURL];
    [self showDeepLinkAlertViewWithMessage:message];
  }
  // [END_EXCLUDE]

  return handled;
}
// [END continueuseractivity]

- (void)showDeepLinkAlertViewWithMessage:(NSString *)message {
  UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                     NSLog(@"OK");
                                                   }];

  UIAlertController *alertController =
      [UIAlertController alertControllerWithTitle:@"Deep-link Data"
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
  [alertController addAction:okAction];
  [self.window.rootViewController presentViewController:alertController
                                               animated:YES
                                             completion:nil];
}

@end
