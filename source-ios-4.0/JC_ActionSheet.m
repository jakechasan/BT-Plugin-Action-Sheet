/*
 *	Copyright 2013-2017 Jake Chasan
 *  Current Revision January 2017, v1.2
 *
 *	All rights reserved.
 *
 *	Redistribution and use in source and binary forms, with or without modification, are
 *	permitted provided that the following conditions are met:
 *
 *	Redistributions of source code must retain the above copyright notice which includes the
 *	name(s) of the copyright holders. It must also retain this list of conditions and the
 *	following disclaimer.
 *
 *	Redistributions in binary form must reproduce the above copyright notice, this list
 *	of conditions and the following disclaimer in the documentation and/or other materials
 *	provided with the distribution.
 *
 *	The name of Jake Chasan, jakechasan.com, and the names of its contributors may not be
 *	used to endorse or promote products derived from this software without specific
 *	prior written permission, under any circumstances.
 *
 *	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *	IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 *	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *	NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 *	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 *	OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "BT_application.h"
#import "BT_strings.h"
#import "BT_viewUtilities.h"
#import "BT_item.h"
#import "BT_debugger.h"
#import "BT_fileManager.h"
#import "BT_color.h"
#import "BT_downloader.h"
#import "JC_ActionSheet.h"

@implementation JC_ActionSheet

//viewDidLoad
-(void)viewDidLoad
{
	[BT_debugger showIt:self theMessage:@"viewDidLoad"];
	[super viewDidLoad];
    
	//show alert...
    [self performSelector:(@selector(launchActionSheet)) withObject:nil afterDelay:.1];
}

//view will appear
-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[BT_debugger showIt:self theMessage:@"viewWillAppear"];

    //flag this as the current screen
	appDelegate.rootApp.currentScreenData = self.screenData;
}

//view did appear
-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[BT_debugger showIt:self theMessage:@"viewDidAppear"];
    
    //hide this view controller's view so it doesn't show...
    [self.navigationController popViewControllerAnimated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

}


-(void)launchActionSheet
{
	[BT_debugger showIt:self theMessage:@"Launching the Action Sheet"];
    
    //Title
    self.actionSheetTitle =  [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"actionSheetTitle" defaultValue:@""];
    [BT_debugger showIt:self theMessage:self.actionSheetTitle];
    
    //Create an array of buttons for each button that has a title, plus a CANCEL button.
    NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
    
    //button 1
    self.button1Title =  [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button1Title" defaultValue:@""];
    if([self.button1Title length] > 0){
        [buttonsArray addObject:self.button1Title];
    }

    //button 2
    self.button2Title =  [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button2Title" defaultValue:@""];
    if([self.button2Title length] > 0){
        [buttonsArray addObject:self.button2Title];
    }

    //button 3
    self.button3Title =  [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button3Title" defaultValue:@""];
    if([self.button3Title length] > 0){
        [buttonsArray addObject:self.button3Title];
    }

    //button 4
    self.button4Title =  [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button4Title" defaultValue:@""];
    if([self.button4Title length] > 0){
        [buttonsArray addObject:self.button4Title];
    }
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:self.actionSheetTitle
                                                    delegate:self
                                                    cancelButtonTitle:nil
                                                    destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    //add each button...
    for (int i = 0; i < [buttonsArray count]; i++){
        [self.actionSheet addButtonWithTitle:[buttonsArray objectAtIndex:i]];
    }
    
    //destructive button
    int buttonIndex = (int)[buttonsArray count];
    self.destructiveButtonTitle = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"actionSheetDestructiveButtonTitle" defaultValue:@""];
    if(self.destructiveButtonTitle.length > 0)
    {
        [self.actionSheet addButtonWithTitle:self.destructiveButtonTitle];
        self.actionSheet.destructiveButtonIndex = buttonIndex;
        buttonIndex++;
    }
    
    //cancel button
    self.cancelButtonTitle = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"actionSheetCancelButtonTitle" defaultValue:@"Cancel"];
    
    [self.actionSheet addButtonWithTitle:self.cancelButtonTitle];
    self.actionSheet.cancelButtonIndex = buttonIndex;
    
    //Launching the Action Sheet
    BT_navController *theNavController = [appDelegate getNavigationController];
    
    //Change Launch View for Tabbed Apps
    if([appDelegate.rootApp.getTabs count] > 0){
        [self.actionSheet showFromTabBar:[appDelegate.rootApp.rootTabBarController tabBar]];
    }else{
        [self.actionSheet showInView:[theNavController view]];
    }
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
 
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"Button - Title: %@", title]];
    
    //Uncomment to Store this in Preferences
    //[BT_strings setPrefString:@"actionSheetDidShow" valueOfPref:@"yes"];
    
    //get possible itemId of the screen to load
    NSString *loadScreenItemId = @"";
    
    //get possible nickname of the screen to load
    NSString *loadScreenNickname = @"";
    
    //get possible transition type for screen to load
    NSString *transitionType = @"";
    
    //possible screen to load...
    BT_item *screenObjectToLoad = nil;
    
    //what button was selected...
    if([title isEqualToString:self.button1Title]){
        
        loadScreenItemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button1Id" defaultValue:@""];
        loadScreenNickname = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button1Nickname" defaultValue:@""];
        transitionType = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button1TransitionType" defaultValue:@"fade"];
        
    }else if([title isEqualToString:self.button2Title]){
        
        loadScreenItemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button2Id" defaultValue:@""];
        loadScreenNickname = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button2Nickname" defaultValue:@""];
        transitionType = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button2TransitionType" defaultValue:@"fade"];
        
    }else if([title isEqualToString:self.button3Title]){
        
        loadScreenItemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button3Id" defaultValue:@""];
        loadScreenNickname = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button3Nickname" defaultValue:@""];
        transitionType = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button3TransitionType" defaultValue:@"fade"];
        
    }else if([title isEqualToString:self.button4Title]){
        
        loadScreenItemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button4Id" defaultValue:@""];
        loadScreenNickname = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button4Nickname" defaultValue:@""];
        transitionType = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"button4TransitionType" defaultValue:@"fade"];
        
    }else if([title isEqualToString:self.destructiveButtonTitle]){
        
        loadScreenItemId = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"destructiveButtonId" defaultValue:@""];
        loadScreenNickname = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"destructiveButtonNickname" defaultValue:@""];
        transitionType = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"destructiveButtonTransitionType" defaultValue:@"fade"];
        
    }
    
    //bail if load screen = "none"
    if([loadScreenItemId isEqualToString:@"none"]){
        return;
    }
    
    //did we find a load screen itemId?
    if([loadScreenItemId length] > 1){
        screenObjectToLoad = [appDelegate.rootApp getScreenDataByItemId:loadScreenItemId];
    }else{
        if([loadScreenNickname length] > 1){
            screenObjectToLoad = [appDelegate.rootApp getScreenDataByNickname:loadScreenNickname];
        }else{
        }
    }
    
    //we should not be here until we have already inited the screen object...
    
    //load next screen if it's not nil
    if(screenObjectToLoad != nil){
        
        //build a temp menu-item to pass to screen load method. We need this because the transition type is in the menu-item
        BT_item *tmpMenuItem = [[BT_item alloc] init];
        
        //build an NSDictionary of values for the jsonVars for the menu item...
        NSDictionary *tmpDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"unused", @"itemId",
                                       transitionType, @"transitionType",
                                       nil];
        
        NSMutableDictionary *tmpMutDictionary = [tmpDictionary mutableCopy];
        
        [tmpMenuItem setJsonVars:tmpMutDictionary];
        [tmpMenuItem setItemId:@"0"];
        
        
        /* NOTE
         
         We cannot use the parent classes handleTapToLoadScreen method because this view controller no longer
         has a navigation controller. self.navigationController is NIL here because we've already popped this
         view off the stack. We popped this view controller off the stack as soon as it appeared. 
        
         This means that instead of using the built in handleTapToLoadScreen method we need to create our
         own method that find the app's navigation controller and asks it to push the next view.
         
         This all means that instead of calling handleTapToLoadScreen (which exists in the parent class)
         we are doing self.handleButtonTap. This "handleButtonTap" method exists in this file.
         
        */
        
        //handle button tap...
        [self handleButtonTap:screenObjectToLoad theMenuItemData:tmpMenuItem];
   
    
    }
     
    //should not ever get here unless a button didn't have a load screen...
    return;
}



//handleButtonTap...
-(void)handleButtonTap:(BT_item *)theScreenData theMenuItemData:(BT_item *)theMenuItemData{
    [BT_debugger showIt:self message:[NSString stringWithFormat:@"handleTapToLoadScreen (super) loading nickname: \"%@\" itemId: %@ itemType: %@", [theScreenData itemNickname], [theScreenData itemId], [theScreenData itemType]]];
    
    //if the loadScreenItemId == "none".....
    if([[BT_strings getJsonPropertyValue:theMenuItemData.jsonVars nameOfProperty:@"loadScreenWithItemId" defaultValue:@""] isEqualToString:@"none"]){
        return;
    }
    
    //if the screen we are loading requires a login, we can't continue unless the user is logged in.
    //assume that the screen does not require a login.
    BOOL allowNextScreen = TRUE;
    if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"loginRequired" defaultValue:@"0"] isEqualToString:@"1"]){
        if(![[appDelegate.rootUser userIsLoggedIn] isEqualToString:@"1"]){
            allowNextScreen = FALSE;
        }
    }
    
    //show password protected message or continue...
    if(!allowNextScreen){
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"loginRequired",@"~ Login Required ~")
                                                            message:NSLocalizedString(@"loginRequiredMessage", @"You are not logged in. A login is required to access this screen.")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"ok", "OK")
                                                  otherButtonTitles:nil];
        [alertView setTag:101];
        [alertView show];
        
        //bail
        return;
        
    }
    if(allowNextScreen){
        
        //remember current button (whatever was tapped, could be a row, button, etc)...
        [appDelegate.rootApp setCurrentButtonData:theMenuItemData];
        
        //remember current screen object...
        [appDelegate.rootApp setCurrentScreenData:theScreenData];
        
        //remember previous screen object...
        [appDelegate.rootApp setPreviousScreenData:self.screenData];
        
        //some screens aren't screens at all! Like "Call Us" and "Email Us" item. In these cases, we only
        //trigger a method and do not load a BT_screen view controller.
        
        //place call
        if([[theScreenData itemType] isEqualToString:@"BT_screen_call"] ||
           [[theScreenData itemType] isEqualToString:@"BT_placeCall"]){
            
            if([appDelegate.rootDevice canMakePhoneCalls]){
                
                //trigger the place-call method
                [self placeCallWithScreenData:theScreenData];
                
            }else{
                
                //show error message
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"callsNotSupportedTitle",@"Calls Not Supported")
                                                                    message:NSLocalizedString(@"callsNotSupportedMessage", @"Placing calls is not supported on this device.")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"ok", "OK")
                                                          otherButtonTitles:nil];
                [alertView setTag:102];
                [alertView show];
            }
            
            //bail
            return;
        }
        
        //send email or share email
        if([[theScreenData itemType] isEqualToString:@"BT_screen_email"] ||
           [[theScreenData itemType] isEqualToString:@"BT_sendEmail"] ||
           [[theScreenData itemType] isEqualToString:@"BT_shareEmail"] ||
           [[theScreenData itemType] isEqualToString:@"BT_screen_shareEmail"]){
            
            if([appDelegate.rootDevice canSendEmails]){
                
                //trigger the email method
                [self sendEmailWithScreenData:theScreenData imageAttachment:nil imageAttachmentName:nil];
                
            }else{
                
                //show error message
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"emailsNotSupportedTitle",@"Email Not Supported")
                                                                    message:NSLocalizedString(@"emailsNotSupportedMessage", @"Sending eamils is not supported on this device.")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"ok", "OK")
                                                          otherButtonTitles:nil];
                [alertView setTag:103];
                [alertView show];
                
            }
            
            //bail
            return;
            
        }
        
        //send SMS or share SMS
        if([[theScreenData itemType] isEqualToString:@"BT_screen_sms"] ||
           [[theScreenData itemType] isEqualToString:@"BT_sendSms"] ||
           [[theScreenData itemType] isEqualToString:@"BT_sendSMS"] ||
           [[theScreenData itemType] isEqualToString:@"BT_shareSms"] ||
           [[theScreenData itemType] isEqualToString:@"BT_shareSMS"] ||
           [[theScreenData itemType] isEqualToString:@"BT_screen_shareSms"]){
            
            if([appDelegate.rootDevice canSendSMS]){
                
                //trigger the SMS method
                [self sendTextMessageWithScreenData:theScreenData];
                
            }else{
                
                //show error message
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"textMessageNotSupportedTitle", "SMS Not Supported")
                                                                    message:NSLocalizedString(@"textMessageNotSupportedMessage",  "Sending SMS / Text messages is not supported on this device.")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"ok", "OK")
                                                          otherButtonTitles:nil];
                [alertView setTag:104];
                [alertView show];
            }
            
            //bail
            return;
            
        }
        
        //BT_screen_video
        if([[theScreenData itemType] isEqualToString:@"BT_screen_video"]){
            
            NSString *localFileName = [BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"localFileName" defaultValue:@""];
            NSString *dataURL = [BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"dataURL" defaultValue:@""];
            NSURL *escapedUrl = nil;
            
            /*
             video file
             --------------------------------
             a)	No dataURL is provided in the screen data - use the localFileName configured in the screen data
             b)	A dataURL is provided, check for local copy, download if not available
             
             */
            if([dataURL length] < 3){
                if([localFileName length] > 3){
                    if([BT_fileManager doesFileExistInBundle:localFileName]){
                        NSString *rootPath = [[NSBundle mainBundle] resourcePath];
                        NSString *filePath = [rootPath stringByAppendingPathComponent:localFileName];
                        escapedUrl = [NSURL fileURLWithPath:filePath isDirectory:NO];
                    }
                }
            }else{
                //merge possible varialbes in url
                dataURL = [BT_strings mergeBTVariablesInString:dataURL];
                escapedUrl = [NSURL URLWithString:[dataURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
            
            //show movie player controller...
            if(escapedUrl != nil){
                [BT_debugger showIt:self message:[NSString stringWithFormat:@"Showing moving player controller%@", @""]];
                MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:escapedUrl];
                [moviePlayerController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                [self presentViewController:moviePlayerController animated:TRUE completion:^{}];
            }
            
            //bail
            return;
            
        }//end if video
        
        //BT_screen_launchNativeApp
        if([[theScreenData itemType] isEqualToString:@"BT_screen_launchNativeApp"] ||
           [[theScreenData itemType] isEqualToString:@"BT_launchNativeApp"]){
            /*
             Launching native app requires an "appType" and a "dataURL"
             App Types:	browser, youTube, googleMaps, musicStore, appStore, mail, dialer, sms
             */
            NSString *appToLaunch = [BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"appToLaunch" defaultValue:@""];
            NSString *dataURL = [BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"dataURL" defaultValue:@""];
            NSString *encodedURL = @"";
            NSString *alertTitle = @"";
            NSString *alertMessage = @"";
            if([dataURL length] > 1){
                encodedURL =  [dataURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            }
            if([appToLaunch length] > 1 && [encodedURL length] > 3){
                
                //browser, musicStore, appStore
                if([appToLaunch isEqualToString:@"browser"] || [appToLaunch isEqualToString:@"googleMaps"]
                   || [appToLaunch isEqualToString:@"musicStore"] || [appToLaunch isEqualToString:@"appStore"]
                   || [appToLaunch isEqualToString:@"youTube"]){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedURL]];
                }
                
                //google maps
                if([appToLaunch isEqualToString:@"googleMaps"]){
                    NSString *toAddress = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", encodedURL];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:toAddress]];
                }
                
                //mail
                if([appToLaunch isEqualToString:@"mail"]){
                    if([appDelegate.rootDevice canSendEmails]){
                        NSString *emailAddress = [NSString stringWithFormat:@"mailto:%@", encodedURL];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailAddress]];
                    }else{
                        alertTitle = NSLocalizedString(@"emailsNotSupportedTitle", "Email Not Supported");
                        alertMessage = NSLocalizedString(@"emailsNotSupportedMessage", "Sending emails is not supported on this device");
                    }
                }
                
                //dialer
                if([appToLaunch isEqualToString:@"dialer"]){
                    if([appDelegate.rootDevice canMakePhoneCalls]){
                        NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@", encodedURL];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
                    }else{
                        alertTitle = NSLocalizedString(@"callsNotSupportedTitle", "Calls Not Supported");
                        alertMessage = NSLocalizedString(@"emailsNotSupportedTitle", "Placing calls is not supported on this device");
                    }
                }
                
                //sms
                if([appToLaunch isEqualToString:@"sms"]){
                    if([appDelegate.rootDevice canSendSMS]){
                        NSString *smsAddress = [NSString stringWithFormat:@"sms:%@", encodedURL];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:smsAddress]];
                    }else{
                        alertTitle = NSLocalizedString(@"textMessageNotSupportedTitle", "SMS Not Supported");
                        alertMessage = NSLocalizedString(@"textMessageNotSupportedMessage", "Sending SMS / Text messages is not supported on this device");
                    }
                }
                
                
                //book store URL
                if([appToLaunch isEqualToString:@"bookStore"]){
                    NSString *iBooksAddress = [NSString stringWithFormat:@"itms-books:%@", encodedURL];
                    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:iBooksAddress]]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iBooksAddress]];
                    }else{
                        alertTitle = NSLocalizedString(@"customURLSchemeNotSupported", "Can't Open Application");
                        alertMessage = NSLocalizedString(@"customURLSchemeNotSupportedMessage", "This device cannot open the application with this URL Scheme");
                    }
                }
                
                
                //customURLScheme
                if([appToLaunch isEqualToString:@"customURLScheme"]){
                    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:encodedURL]]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedURL]];
                    }else{
                        alertTitle = NSLocalizedString(@"customURLSchemeNotSupported", "Can't Open Application");
                        alertMessage = NSLocalizedString(@"customURLSchemeNotSupportedMessage", "This device cannot open the application with this URL Scheme");
                    }
                }
                
                //show alert?
                if([alertMessage length] > 3){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                        message:alertMessage
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"ok", "OK")
                                                              otherButtonTitles:nil];
                    [alertView setTag:105];
                    [alertView show];
                }
                
                
            }//dataURL, encodedURL length
            
            //bail
            return;
            
        }//end if launching native app
        
        
        ////////////////////////////////////////////////////////////////////////
        //if we are here, we are loading a new screen object
        UIViewController *theNextViewController = [appDelegate.rootApp getViewControllerForScreen:theScreenData];
        if(theNextViewController != nil){
            
            //always hide the lower tab-bar when screens transition in unless it's overridden
            BOOL hideBottomBar = FALSE;
            if([[BT_strings getJsonPropertyValue:appDelegate.rootApp.rootTheme.jsonVars nameOfProperty:@"hideBottomTabBarWhenScreenLoads" defaultValue:@""] isEqualToString:@"1"]){
                hideBottomBar = TRUE;
            }
            if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"hideBottomTabBarWhenScreenLoads" defaultValue:@""] length] > 0){
                if([[BT_strings getJsonPropertyValue:theScreenData.jsonVars nameOfProperty:@"hideBottomTabBarWhenScreenLoads" defaultValue:@"1"] isEqualToString:@"0"]){
                    hideBottomBar = FALSE;
                }else{
                    hideBottomBar = TRUE;
                }
            }
            
            //always hide the bottom tab-bar for quiz screens
            if([[theScreenData itemType] isEqualToString:@"BT_screen_quiz"]){
                hideBottomBar = TRUE;
            }
            
            //always hide the "back" button...
            [theNextViewController.navigationItem setHidesBackButton:TRUE];
            
            //hide bottom bar if needed
            [theNextViewController setHidesBottomBarWhenPushed:hideBottomBar];
            
            //push view...
            [[self getNavController] pushViewController:theNextViewController animated:TRUE];
            
        }//theNextViewController...
    }//allowNextScreen
}

@end
