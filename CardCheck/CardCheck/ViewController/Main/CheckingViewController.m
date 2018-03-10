
#import "CheckingViewController.h"

#import "CardDefaultView.h"
#import "CardCheckedView.h"
#import "CardTypePanView.h"
#import "CardTypeCommentView.h"

#import "ITKeyboardObserver.h"
#import "ITTextFieldValidator.h"

#import "NotificationManager.h"

#define TAG_CARD_PAN_ID             300
#define TAG_CARD_COMMENT_ID         301

#define lPreparingForReading        NSLocalizedStringFromTable(@"animation_preparing_for_reading", @"Common", @"Animation View")
#define lPreparingForTestReading    NSLocalizedStringFromTable(@"animation_preparing_for_test_reading", @"Common", @"Animation View")

#define lSwipeCard                  NSLocalizedStringFromTable(@"animation_swipe_card", @"Common", @"Animation View")
#define lSwipeTestCard              NSLocalizedStringFromTable(@"animation_swipe_test_card", @"Common", @"Animation View")

#define lGettingData                NSLocalizedStringFromTable(@"animation_getting_data_from_reader", @"Common", @"Animation View")
#define lGettingTestData            NSLocalizedStringFromTable(@"animation_getting_test_data_from_reader", @"Common", @"Animation View")

#define lSendingRequest             NSLocalizedStringFromTable(@"animation_sending_request", @"Common", @"Animation View")


#define lInfo                       NSLocalizedStringFromTable(@"handle_track_info_title",          @"Common", @"Alert View")
#define lNoneRead                   NSLocalizedStringFromTable(@"handle_track_none_read_message",   @"Common", @"Alert View")
#define lTrack1Read                 NSLocalizedStringFromTable(@"handle_track_track1_read_message", @"Common", @"Alert View")
#define lTrack2Read                 NSLocalizedStringFromTable(@"handle_track_track2_read_message", @"Common", @"Alert View")

#define lRepeatReading              NSLocalizedStringFromTable(@"handle_track_button_repeat_reading", @"Common", @"Alert View")
#define lSendRequest                NSLocalizedStringFromTable(@"handle_track_button_send_request",   @"Common", @"Alert View")

#define lAbortCheck                 NSLocalizedStringFromTable(@"card_check_abort_message",    @"Common", @"Alert View")
#define lCompleteCheck              NSLocalizedStringFromTable(@"card_check_complete_message",    @"Common", @"Alert View")
#define lCloseApp                   NSLocalizedStringFromTable(@"card_check_button_close",        @"Common", @"Alert View")
#define lContinue                   NSLocalizedStringFromTable(@"card_check_button_continue",     @"Common", @"Alert View")

#define lExtraInfo                  NSLocalizedStringFromTable(@"add_extra_info_title",         @"Common", @"Alert View")
#define lExtraInfoYes               NSLocalizedStringFromTable(@"add_extra_info_button_yes",    @"Common", @"Alert View")
#define lExtraInfoNo                NSLocalizedStringFromTable(@"add_extra_info_button_no",     @"Common", @"Alert View")



@interface CheckingViewController ()<ReaderControllerDelegate, CardImagePickerDelegate, AuthViewDelegate, ITValidationDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) CardCheckedView *cardCheckedView;
@property (nonatomic, strong) CardDefaultView *cardDefaultView;
@property (nonatomic, strong) CardTypePanView *cardTypePanView;
@property (nonatomic, strong) CardTypeCommentView *cardTypeCommentView;

@property (nonatomic, strong) CardCheckReport *cardCheckReport;
@property (nonatomic, strong) CardPickerController *cardImagePickerController;

@property (nonatomic, strong) ITKeyboardObserver *keyboardObserver;
@property (nonatomic, strong) ITTextFieldValidator *textFieldValidator;


@property (weak, nonatomic) NotificationManager *notifyManager;

@end

@implementation CheckingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showCardDefaultView];
    [self baseSetup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self.readerController setDelegate: self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)baseSetup
{
    [self.readerController resetReaderController];
    
    self.cardImagePickerController = [[CardPickerController alloc] initWithDelegate: self];
    self.textFieldValidator = [[ITTextFieldValidator alloc] initWithValidationDelegate: self];
}

#pragma mark - Accessors

- (AuthView *)authView
{
    return [[self.contentView subviews] firstObject];
}

- (CardCheckedView *)cardCheckedView
{
    if (!_cardCheckedView) {
        _cardCheckedView = [CardCheckedView viewWithDelegate: self];
        _cardCheckedView.frame = self.contentView.bounds;
    }
    
    return _cardCheckedView;
}

- (CardDefaultView *)cardDefaultView
{
    if (!_cardDefaultView) {
        _cardDefaultView = [CardDefaultView viewWithDelegate: self];
        _cardDefaultView.frame = self.contentView.bounds;
    }
    
    return _cardDefaultView;
}

- (CardTypePanView *)cardTypePanView
{
    if (!_cardTypePanView) {
        _cardTypePanView = [CardTypePanView viewWithDelegate: self];
        _cardTypePanView.frame = self.contentView.bounds;
    }
    
    return _cardTypePanView;
}

- (CardTypeCommentView *)cardTypeCommentView
{
    if (!_cardTypeCommentView) {
        _cardTypeCommentView = [CardTypeCommentView viewWithDelegate: self];
        _cardTypeCommentView.frame = self.contentView.bounds;
    }
    
    return _cardTypeCommentView;
}

- (NotificationManager *)notifyManager {
    return [NotificationManager sharedInstance];
}

#pragma mark - Ui

- (void)showCardDefaultView
{
    [self.cardDefaultView prepareUi];
    [self showView: self.cardDefaultView reverse: YES];
}

- (void)showCardTypePanView
{
    [self.cardImagePickerController dismissInView: self completion:^{
        [self.cardTypePanView prepareUi];
        [self showView: self.cardTypePanView reverse: NO];
    }];
}

- (void)showCardTypeCommentView
{
    [self.cardTypeCommentView prepareUi];
    
    [self showView: self.cardTypeCommentView reverse: NO];
}

- (void)showCardCheckedView:(CardCheckReport *)report
{
    [self.cardCheckedView prepareUi];
    [self.cardCheckedView setupWith: report];
    
    [self showView: self.cardCheckedView reverse: NO];
}

- (void)showView:(UIView *)view reverse:(BOOL)reverse
{
    CGFloat offset = reverse? -(self.view.bounds.size.width) : +(self.view.bounds.size.width);
    UIView *oldView = self.contentView.subviews.firstObject;
    
    view.frame = CGRectOffset(self.contentView.bounds, offset, 0.0);
    view.alpha = 0.0;
    
    [self.contentView addSubview: view];
    [UIView animateWithDuration:0.25 animations:^{
        oldView.frame = CGRectOffset(oldView.frame, -offset, 0.0);
        view.frame = self.contentView.bounds;
        oldView.alpha = 0.0;
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [oldView removeFromSuperview];
        [self resetFocusFrame];
    }];
}

- (void)resetFocusFrame
{
    UIView *subview = [[self.contentView subviews] firstObject];
    UIView *btnView = [subview viewWithTag: 401];
    
    CGRect focusFrame = [subview convertRect: btnView.frame toView: self.view];
    self.keyboardObserver.focusFrame = focusFrame;
}


- (NSString *)currentReaderStatus:(ReaderState)state
{
    NSString *title = nil;
    BOOL isStaging = self.readerController.isStaging;
    
    switch (state) {
        case ReaderStatePreparing:
            title = isStaging? lPreparingForReading : lPreparingForTestReading;
            break;
            
        case ReaderStateReady:
            title = isStaging? lSwipeCard : lSwipeTestCard;
            break;
            
        case ReaderStateGettingData:
            title = isStaging? lGettingData : lGettingTestData;
            break;
            
        default:
            title = nil;
            break;
    }
    
    return title;
}

#pragma mark - Working

- (void)checkTrackData:(TrackData *)data
{
    NSLog(@"%@: trackData => %@", CURRENT_METHOD, [data debugDescription]);
    
    //1
    [self.currentReader setTrackData: data];
    
    //2
    if (data.isReadableTrack1 && data.isReadableTrack2)
    {
        [self sendCheckCard];
    }
    else if ((NO == data.isReadableTrack1) && (NO == data.isReadableTrack2)) {
        [self showTrackAlertWithMessage: lNoneRead];
    }
    else if (NO == data.isReadableTrack1) {
        [self showTrackAlertWithMessage: lTrack1Read];
    }
    else if (NO == data.isReadableTrack2) {
        [self showTrackAlertWithMessage: lTrack2Read];
    }
}

- (void)uploadCardImage
{
    [self.cardImagePickerController presentInView: self];
}

#pragma mark - Request

- (void)sendCheckCard
{
    [self.cardDefaultView updateWithStatus: lSendingRequest];
    
    //0
    self.cardCheckReport = nil;
    
    //1
    TrackData *trackData = self.currentReader.trackData;
    CryptoController *crp = [CryptoController sharedInstance];
    NSData *cipherData = [crp aes256EncryptHexData: trackData.plainHexData withHexKey: [self.keyChain appDataKey]];
    [trackData setCipherHexData: [HexCvtr hexFromData: cipherData]];
    
    //2
    CCheckRequestModel *request = [CCheckRequestModel requestWithReader: self.currentReader];
    
    //3
    __weak CheckingViewController *weakSelf = self;
    [[APIController sharedInstance] sendCCheckRequest: request
                                       withCompletion:^(CCheckResponseModel *model, NSError *error)
     {
         if (model.isCorrect) {
             weakSelf.cardCheckReport = [[CardCheckReport alloc] initWithCheckResponse: model];
             [weakSelf showCardCheckedView: weakSelf.cardCheckReport];
         }
         else {
             [weakSelf showCardCheckAlert: error];
         }
         
         NSLog(@" response = %@", [model debugDescription]);
     }];
}

- (void)sendCompleteCheckCard
{
    [self.cardDefaultView updateWithStatus: lSendingRequest];
    
    //0
    TrackData *trackData = self.currentReader.trackData;
    CryptoController *crp = [CryptoController sharedInstance];
    
    NSString *plainData = [NSString stringWithFormat:@"%@%@", trackData.plainHexData, self.cardCheckReport.pan3Hex];
    NSData *cipherData = [crp aes256EncryptHexData: plainData withHexKey: [self.keyChain appDataKey]];
    [trackData setCipherHexData: [HexCvtr hexFromData: cipherData]];
    
    //1
    CFinishCheckRequestModel *request = [CFinishCheckRequestModel requestWithReader: self.currentReader];
    [request setupWithReport: self.cardCheckReport];
    
    //2
    __weak CheckingViewController *weakSelf = self;
    [[APIController sharedInstance] sendCFinishCheckRequest: request
                                             withCompletion:^(CFinishCheckResponseModel *model, NSError *error)
     {
         if (model.isCorrect) {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [weakSelf showCardCheckCompleteAlert: nil];
             });
         }
         else {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [weakSelf showCardCheckCompleteAlert: error];
             });
         }

         NSLog(@" response = %@", [model debugDescription]);
     }];
}

- (void)sendUploadCardImage:(CardImage *)image
{
    CUploadRequestModel *request = [CUploadRequestModel requestWithReportID: self.cardCheckReport.reportID
                                                                 reportTime: self.cardCheckReport.time
                                                                  cardImage: image];
    
    __weak CheckingViewController *weakSelf = self;
    [[APIController sharedInstance] uploadImageRequest: request
                                        withCompletion:^(CUploadResponseModel *model, NSError *error)
     {
         if (model.isCorrect) {
             [image setID: model.imgID];
             [weakSelf.cardCheckReport setupWithCardImage: image];
             
             if (!weakSelf.cardCheckReport.backImgID || !weakSelf.cardCheckReport.frontImgID) {
                 [weakSelf.cardImagePickerController didSendImage: YES];
             }
             else {
                 [self showCardTypePanView];
             }
         }
         else {
             [weakSelf.cardImagePickerController didSendImage: NO];
         }
         
         NSLog(@" response = %@", [model debugDescription]);
     }];
}

#pragma mark - AlertView

- (void)showTrackAlertWithMessage:(NSString *)message
{
    AlertViewController *controller = [AlertViewController alertControllerWithTitle: lInfo
                                                                            message: message];
    
    [controller addAction:[AlertAction actionWithTitle: lRepeatReading style:UIAlertActionStyleDefault handler:^(AlertAction *action) {
        [self.readerController resetReaderController];
    }]];
    
    [controller addAction:[AlertAction actionWithTitle: lSendRequest style:UIAlertActionStyleDefault handler:^(AlertAction *action) {
        [self sendCheckCard];
    }]];
    
    [self.notifyManager showAlert: controller];
}

- (void)showCardCheckAlert:(NSError *)error
{
    AlertViewController *controller = [AlertViewController alertControllerWithTitle: lAbortCheck
                                                                            message: [error readableDescription]];
    
    [controller addAction:[AlertAction actionWithTitle: lCloseApp style:UIAlertActionStyleDefault handler:^(AlertAction *action) {
        [self.rootViewController closeApp];
    }]];
    
    [controller addAction:[AlertAction actionWithTitle: lContinue style:UIAlertActionStyleDefault handler:^(AlertAction *action) {
        [self.readerController resetReaderController];
    }]];
    
    [self.notifyManager showAlert: controller];
}

- (void)showCardCheckCompleteAlert:(NSError *)error
{
    AlertViewController *controller = [AlertViewController alertControllerWithTitle: lInfo
                                                                            message: error? [error readableDescription] : lCompleteCheck];
    
    [controller addAction:[AlertAction actionWithTitle: lCloseApp style:UIAlertActionStyleDefault handler:^(AlertAction *action) {
        [self.rootViewController closeApp];
    }]];
    
    if (error && (error.code != 17)) {
        [controller addAction:[AlertAction actionWithTitle: lContinue style:UIAlertActionStyleDefault handler:^(AlertAction *action) {
            [self sendCompleteCheckCard];
        }]];

    }
    else if (!error || (error.code == 17)) {
        [controller addAction:[AlertAction actionWithTitle: lContinue style:UIAlertActionStyleDefault handler:^(AlertAction *action) {
            [self.readerController resetReaderController];
        }]];
    }
    
    [self.notifyManager showAlert: controller];
}

- (void)showAddExtraInfoAlert
{
    AlertViewController *controller = [AlertViewController alertControllerWithTitle: lInfo
                                                                            message: lExtraInfo];
    
    [controller addAction:[AlertAction actionWithTitle: lExtraInfoNo style:UIAlertActionStyleDefault handler:^(AlertAction *action) {
        [self showCardDefaultView];
        [self sendCompleteCheckCard];
    }]];
    
    [controller addAction:[AlertAction actionWithTitle: lExtraInfoYes style:UIAlertActionStyleDefault handler:^(AlertAction *action) {
        [self uploadCardImage];
    }]];
    
    [self.notifyManager showAlert: controller];
}

#pragma mark - ITValidationDelegate

- (void)validatorDidCheckTextField:(ITTextField *)textField withResult:(BOOL)isValid
{
    if (isValid == NO) {
        [self.authView failedStateWithText: textField.validationWarning];
    }
    else if (textField.tag == TAG_CARD_PAN_ID) {
        [self.cardCheckReport setupWithManualPan: textField.text];
        [self showCardTypeCommentView];
    }
    else if (textField.tag == TAG_CARD_COMMENT_ID) {
        [self.cardCheckReport setNotes: textField.text];
        
        [self showCardDefaultView];

        [self sendCompleteCheckCard];
    }
}

- (void)validatorCheckingTextField:(ITTextField *)textField withResult:(BOOL)isValid
{
    if (!isValid) {
        [self.authView failedStateWithText: textField.validationWarning];
    }
    else {
        [self.authView resetState];
    }
}

#pragma mark - ReaderControllerDelegate

- (void)readerController:(ReaderController *)controller didUpdateWithState:(ReaderState)state
{
    XT_EXEPTION_NOT_MAIN_THREAD;
    
    NSLog(@"%@", [NSString stringWithFormat:@"%@ - %@", CURRENT_METHOD, [self currentReaderStatus: state]]);
    
    [self.cardDefaultView updateWithStatus: [self currentReaderStatus: state]];
}

- (void)readerController:(ReaderController *)controller didUpdateWithCounter:(NSUInteger)counter
{
    XT_EXEPTION_NOT_MAIN_THREAD;
    
    NSLog(@"%@", [NSString stringWithFormat:@"%@ - %lu", CURRENT_METHOD, (unsigned long)counter]);
    
    [self.cardDefaultView updateWithCounter: counter];
}

- (void)readerController:(ReaderController *)controller didUpdateWithReader:(CardReader *)reader
{
    XT_EXEPTION_NOT_MAIN_THREAD;
    
    NSLog(@"%@", CURRENT_METHOD);
}

- (void)readerController:(ReaderController *)controller didReceiveTrackData:(TrackData *)data
{
    XT_EXEPTION_NOT_MAIN_THREAD;
    
    NSLog(@"%@", CURRENT_METHOD);
    
    [self checkTrackData: data];
}

#pragma mark - AuthViewDelegate

- (void)cardViewDemoPressed:(UIView *)view
{
    [self.readerController generateDemoTrack];
}

- (void)cardViewResetPressed:(UIView *)view
{
    [self.readerController resetReaderController];
}

- (void)cardViewContinuePressed:(UIView *)view isFake:(BOOL)fake
{
    if (self.readerController.isStaging)
    {
        if (fake) {
            [self showAddExtraInfoAlert];
        }
        else {
            [self showCardDefaultView];
            [self.readerController resetReaderController];
        }
    }
    else {
        [self showCardDefaultView];
        [self.readerController startStageMode];
        [self.readerController resetReaderController];
    }
}

- (void)cardViewYesPressed:(UIView *)view
{
    [self showCardDefaultView];
    
    [self sendCompleteCheckCard];
}

- (void)cardViewNoPressed:(UIView *)view
{
    self.cardCheckReport.fakeCard = YES;
    
    [self showAddExtraInfoAlert];
}

- (id<UITextFieldDelegate>)textFieldDelegate
{
    return self.textFieldValidator;
}

- (void)authView:(UIView *)view checkCardPanDidEnter:(ITTextField *)textField
{
    [self validatorDidCheckTextField: textField withResult: YES];
}

- (void)authView:(UIView *)view checkCardCommentDidEnter:(ITTextField *)textField
{
    [self validatorDidCheckTextField: textField withResult: YES];
}

#pragma mark - CardImagePickerDelegate

- (void)cardPicker:(CardPickerController *)picker didPickCardImage:(CardImage *)image
{
    [self sendUploadCardImage: image];
}

- (void)cardPickerDidCancelPicking:(CardPickerController *)picker
{
    [picker dismissInView: self completion: nil];
}

@end
