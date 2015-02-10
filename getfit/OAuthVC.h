//
//  OAuthVC.h
//  GetFit
//
//  Created by Albert Carter on 12/5/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MinuteTVC;

@protocol OAuthVCDelegate <NSObject>
@required
- (void) didDismissOAuthVCWithSuccessfulExtraction:(BOOL)success;
@end




@interface OAuthVC : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, UIAlertViewDelegate>


- (id) initWithDelegate:(UIViewController<OAuthVCDelegate> *)delegateVC;

@property (weak, nonatomic) MinuteTVC *minuteTVC;
@property (strong, atomic) UIViewController<OAuthVCDelegate> *delegate;

@end

/* HAPPY PATH FOR URLS:
 
 START:
 about:blank
 
 FINISH:
 https://wayf.mit.edu/WAYF?shire=https%3A%2F%2Fgetfit.mit.edu%2FShibboleth.sso%2FSAML%2FPOST&time=1423535993&target=cookie%3A62c4d9f7&providerId=https%3A%2F%2Fgetfit.mit.edu%2Fshibboleth
 
 
 START:
 https://wayf.mit.edu/WAYF?shire=https%3A%2F%2Fgetfit.mit.edu%2FShibboleth.sso%2FSAML%2FPOST&time=1423535993&target=cookie%3A62c4d9f7&providerId=https%3A%2F%2Fgetfit.mit.edu%2Fshibboleth
 
 FINISH:
 https://idp.mit.edu/idp/Authn/MIT
 
 START:
 https://idp.mit.edu/idp/Authn/MIT
 
 FINISH:
 https://idp.mit.edu/idp/profile/Shibboleth/SSO
 
 START:
 https://idp.mit.edu/idp/profile/Shibboleth/SSO
 
 FINISH:
 https://getfit.mit.edu/?q=dashboard
 */

/* SAD PATH FOR URLS
 
 FINISH:
 https://wayf.mit.edu/WAYF?shire=https%3A%2F%2Fgetfit.mit.edu%2FShibboleth.sso%2FSAML%2FPOST&time=1423536175&target=cookie%3A2d511812&providerId=https%3A%2F%2Fgetfit.mit.edu%2Fshibboleth
 
 START:
 https://wayf.mit.edu/WAYF?shire=https%3A%2F%2Fgetfit.mit.edu%2FShibboleth.sso%2FSAML%2FPOST&time=1423536175&target=cookie%3A2d511812&providerId=https%3A%2F%2Fgetfit.mit.edu%2Fshibboleth
 
 FINISH:
 https://idp.mit.edu/idp/Authn/MIT
 
 START:
 https://idp.mit.edu/idp/Authn/MIT
 
 FINISH:
 https://idp.mit.edu/idp/Authn/UsernamePassword
 
 
 */