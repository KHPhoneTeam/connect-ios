/*
 * Copyright (C) 2014 Xianwen Chen <xianwen@xianwenchen.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

#import "XCPjsua.h"
#import "pjsua.h"
#import "KHPhonePreferencesUtil.h"

@import AVFoundation;

#define THIS_FILE "XCPjsua.c"
static pjsua_acc_id _acc_id;
static pjsua_transport_id local_transport_id;
//static pjsua_call_id _call_id;

const size_t MAX_SIP_ID_LENGTH = 50;
const size_t MAX_SIP_REG_URI_LENGTH = 50;

static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata);
static void on_call_state(pjsua_call_id call_id, pjsip_event *e);
static void on_call_media_state(pjsua_call_id call_id);
static void on_reg_state2(pjsua_acc_id acc_id, pjsua_reg_info *info);
static void error_exit(const char *title, pj_status_t status);

NSString * const KHPhoneCallNotification = @"KHPhoneCallNotification";

@interface XCPjsua ()
@property BOOL isPreferencesSet;
@end

@implementation XCPjsua
{
    pjsua_acc_id _acc_id;
    pjsua_transport_id local_transport_id;
    pjsua_call_id _call_id;
    RegisterCallBack _registerCallBack;
}

+ (XCPjsua *)sharedXCPjsua
{
    static XCPjsua *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[XCPjsua alloc] init];
        initPjsip();
    });
    return sharedInstance;
}

- (void)stopPjsip{
    // stop call
    // unregister
    // destroy
    
    pj_status_t status;
    status = pjsua_destroy();
    NSLog(@"status :%@", @(status));
}

int initPjsip()
{
    
    pj_status_t status;
    _acc_id = -1;
    
    // Create pjsua first
    status = pjsua_create();
    
    if (status != PJ_SUCCESS) error_exit("Error in pjsua_create()", status);
    
    // Init pjsua
    
        // Init the config structure
        pjsua_config cfg;
        pjsua_config_default (&cfg);
        
        cfg.cb.on_incoming_call = &on_incoming_call;
        cfg.cb.on_call_media_state = &on_call_media_state;
        cfg.cb.on_call_state = &on_call_state;
        
        // Init the logging config structure
        pjsua_logging_config log_cfg;
        pjsua_logging_config_default(&log_cfg);
        log_cfg.console_level = 4;
        
        // Init the pjsua
        status = pjsua_init(&cfg, &log_cfg, NULL);
        if (status != PJ_SUCCESS) error_exit("Error in pjsua_init()", status);
        
        // opus
        pj_str_t codec_id = pj_str( "opus/48000" );
        
        if ( pjsua_codec_set_priority( &codec_id, PJMEDIA_CODEC_PRIO_HIGHEST ) != PJ_SUCCESS )
        {
            fprintf(stderr, "Warning: Failed to set opus/48000 codec at highest priority\n" );
        }
    
    
    // Add UDP transport.
    
        // Init transport config structure
        pjsua_transport_config udpcfg;
        pjsua_transport_config_default(&udpcfg);
        udpcfg.port = 5011;
        
        // Add TCP transport.
        status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &udpcfg, &local_transport_id);
        if (status != PJ_SUCCESS) error_exit("Error creating transport", status);
    
    
    // Add TCP transport.
    {
        // Init transport config structure
        pjsua_transport_config tcpcfg;
        pjsua_transport_config_default(&tcpcfg);
        tcpcfg.port = 5011;
        
        // Add TCP transport.
        status = pjsua_transport_create(PJSIP_TRANSPORT_TCP, &tcpcfg, NULL);
        if (status != PJ_SUCCESS) error_exit("Error creating transport", status);
    }
    
    // Initialization is done, now start pjsua
    status = pjsua_start();
    if (status != PJ_SUCCESS) error_exit("Error starting pjsua", status);
    
    //status = pjsua_acc_add_local(local_transport_id, true, &_acc_id);
    if (status != PJ_SUCCESS) error_exit("Error adding local account", status);
    //int result = registerAccount("0653703730", "khphone");
    pjsua_codec_info c[32];
    
    unsigned k, count = PJ_ARRAY_SIZE(c);
    
    printf("List of audio codecs:\n");
    
    pjsua_enum_codecs(c, &count);
    
    for (k=0; k<count; ++k) {
        
        printf("  %d\t%.*s\n", c[k].priority, (int)c[k].codec_id.slen,
               
               c[k].codec_id.ptr);
        
    }
    return 0;
}

int registerAccount(char *sipUser, char* sipDomain){
    if (_acc_id == 0) {
        //unregister it first
        pjsua_acc_del(_acc_id);
    }
    // Register the account on local sip server
    pj_status_t status;
    pjsua_acc_config cfg;
    pjsua_acc_config_default(&cfg);
    
    char sipId[MAX_SIP_ID_LENGTH];
    sprintf(sipId, "sip:%s@%s", sipUser, sipDomain);
    cfg.id = pj_str(sipId);
    
    char regUri[MAX_SIP_REG_URI_LENGTH];
    sprintf(regUri, "sip:%s", sipDomain);
    //cfg.reg_uri = pj_str(regUri);
    
    status = pjsua_acc_add(&cfg, PJ_TRUE, &_acc_id);
    if (status != PJ_SUCCESS) error_exit("Error adding account", status);
    return 0;
}

- (void)sendHashTone{
    pj_status_t status;
    pj_str_t tone = pj_str("#");
    status =  pjsua_call_dial_dtmf	(_call_id ,&tone)	;
    
}

- (void)sendTone{
    pj_status_t status;
    pj_str_t tone = pj_str("#");
    status =  pjsua_call_dial_dtmf(_call_id ,&tone)	;
    
}

- (void)sendAsteriskTone{
    pj_status_t status;
    pj_str_t tone = pj_str("*");
    status =  pjsua_call_dial_dtmf(_call_id ,&tone)	;
    
}

- (BOOL)makeCallTo:(NSString *)destUri
{
    char *sipUser = (char*) [[KHPhonePrefUtil returnUserPhoneNumber] UTF8String];
    //char *sipDomain = (char*)[[KHPhonePrefUtil returnCongregationName] UTF8String];
    int registerStatus = registerAccount(sipUser, "khphone.nl");
    
    char *cDestUri = (char*)[destUri UTF8String];
    pj_status_t status;
    pj_str_t uri = pj_str(cDestUri);
    NSLog(@"Making call to %s", cDestUri);
    status = pjsua_call_make_call(_acc_id, &uri, 0, NULL, NULL, &_call_id);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error making call: %i", status);
        return NO;
    } else {
        [UIDevice currentDevice].proximityMonitoringEnabled = YES;
        return YES;
    }

}

- (void)endCall
{
    pjsua_call_hangup(_acc_id, 0, NULL, NULL);
    //pjsua_call_hangup_all();
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
}

- (void)endAllCalls
{
    //pjsua_call_hangup(_acc_id, 0, NULL, NULL);
    pjsua_call_hangup_all();
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
}

- (void)switchSpeaker:(BOOL)speakerStatus{
   
    BOOL success;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
    success = [session setCategory:AVAudioSessionCategoryPlayAndRecord
                       withOptions:AVAudioSessionCategoryOptionMixWithOthers
                             error:&error];
    if (!success) NSLog(@"AVAudioSession error setCategory: %@", [error localizedDescription]);
    if (speakerStatus) {
        
        success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        if (!success) NSLog(@"AVAudioSession error overrideOutputAudioPort: %@", [error localizedDescription]);
    } else {
        
        success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        if (!success) NSLog(@"AVAudioSession error overrideOutputAudioPort: %@", [error localizedDescription]);
    }
    
    success = [session setActive:YES error:&error];
    if (!success) NSLog(@"AVAudioSession error setActive: %@", [error localizedDescription]);
    
}

- (void)handleRegistrationStateChangeWithRegInfo: (pjsua_reg_info *)info
{
    switch (info->cbparam->code) {
        case 200:
            // register success
            _registerCallBack(YES);
            break;
        case 401:
            // illegal credential
            _registerCallBack(NO);
            break;
        default:
            break;
    }
}

@end

/* Callback called by the library when registration state has changed */
static void on_reg_state2(pjsua_acc_id acc_id, pjsua_reg_info *info)
{
    NSLog(@"info:%@", info);
    [[XCPjsua sharedXCPjsua] handleRegistrationStateChangeWithRegInfo: info];
}

/* Callback called by the library upon receiving incoming call */
static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id,
                             pjsip_rx_data *rdata)
{
    pjsua_call_info ci;
    
    PJ_UNUSED_ARG(acc_id);
    PJ_UNUSED_ARG(rdata);
    
    pjsua_call_get_info(call_id, &ci);
    
    PJ_LOG(3,(THIS_FILE, "Incoming call from %.*s!!",
              (int)ci.remote_info.slen,
              ci.remote_info.ptr));
    
    /* Automatically answer incoming calls with 200/OK */
    pjsua_call_answer(call_id, 200, NULL, NULL);
}

/* Callback called by the library when call's state has changed */
static void on_call_state(pjsua_call_id call_id, pjsip_event *e)
{
    NSLog(@"on_call_state called");
    pjsua_call_info ci;
    
    PJ_UNUSED_ARG(e);
    
    pjsua_call_get_info(call_id, &ci);
    PJ_LOG(3,(THIS_FILE, "Call %d state=%.*s", call_id,
              (int)ci.state_text.slen,
              ci.state_text.ptr));
    
     if (ci.state == PJSIP_INV_STATE_DISCONNECTED) {
         NSLog(@"Call is disconnected!");
         NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
         NSNotification *notification = [NSNotification notificationWithName:KHPhoneCallNotification
                                                                      object:nil
                                                                    userInfo:@{@"state" : @"disconnected"}
                                         ];
         
         [center postNotification:notification];
         
         [UIDevice currentDevice].proximityMonitoringEnabled = NO;
     }
}

/* Callback called by the library when call's media state has changed */
static void on_call_media_state(pjsua_call_id call_id)
{
    NSLog(@"on_call_media_state called");
    
    pjsua_call_info ci;
    
    pjsua_call_get_info(call_id, &ci);
    
    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        // When media is active, connect call to sound device.
        pjsua_conf_connect(ci.conf_slot, 0);
        pjsua_conf_connect(0, ci.conf_slot);
    }
}

/* Display error and exit application */
static void error_exit(const char *title, pj_status_t status)
{
    pjsua_perror(THIS_FILE, title, status);
    pjsua_destroy();
    exit(1);
}
