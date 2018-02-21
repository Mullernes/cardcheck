
#import "CheckingViewController.h"

#import "CardCheckedView.h"
#import "CardDefaultView.h"

#import "NotificationManager.h"

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

#define lCompleteCheck              NSLocalizedStringFromTable(@"handle_track_complete_message",    @"Common", @"Alert View")
#define lCloseApp                   NSLocalizedStringFromTable(@"handle_track_button_close",        @"Common", @"Alert View")
#define lContinue                   NSLocalizedStringFromTable(@"handle_track_button_continue",     @"Common", @"Alert View")



@interface CheckingViewController ()<ReaderControllerDelegate, CardImagePickerDelegate, AuthViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) CardCheckedView *cardCheckedView;
@property (nonatomic, strong) CardDefaultView *cardDefaultView;

@property (nonatomic, strong) CardCheckReport *cardCheckReport;
@property (nonatomic, strong) CardImagePicker *cardImagePickerController;

@property (weak, nonatomic) NotificationManager *notifyManager;

@end

@implementation CheckingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showCardDefaultView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];

    [self baseSetup];
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
    [self.readerController setDelegate: self];
    [self.readerController resetReaderController];
    
    self.cardImagePickerController = [[CardImagePicker alloc] initWithDelegate: self];
}

#pragma mark - Accessors

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

- (NotificationManager *)notifyManager {
    return [NotificationManager sharedInstance];
}

#pragma mark - Ui

- (void)showCardDefaultView
{
    [self.cardDefaultView prepareUi];
    [self showView: self.cardDefaultView reverse: YES];
}

- (void)showCardCheckedView:(CardCheckReport *)report
{
    BOOL stage = self.readerController.isStaging;
    
    if (NO == stage) {
        [self.readerController startStageMode];
    }
    
    [self.cardCheckedView prepareUi];
    [self.cardCheckedView setupWith: report andStage: stage];
    
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
    }];
}

- (NSString *)readerStatus:(ReaderState)state
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

#pragma mark - Request

- (void)sendCheckCard
{
    [self.cardDefaultView updateWithStatus: lSendingRequest];
    
    //0
    self.cardCheckReport = nil;
    
    //1
    TrackData *trackData = self.currentReader.trackData;
    CryptoController *crp = [CryptoController sharedInstance];
    NSData *cipherData = [crp aes256EncryptHexData: trackData.plainHexData
                                        withHexKey: [self.keyChain appDataKey]];
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
             [weakSelf showAlertWithError: error];
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
    
    NSString *plainData = [NSString stringWithFormat:@"%@%@", trackData.plainHexData, self.cardCheckReport.pan3];
    NSData *cipherData = [crp aes256EncryptHexData: plainData
                                        withHexKey: [self.keyChain appDataKey]];
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
                 [weakSelf showCompleteAlert];
             });
         }
         else {
             [weakSelf showAlertWithError: error];
         }

         NSLog(@" response = %@", [model debugDescription]);
     }];
}

- (void)uploadCardImage
{
    [self.cardImagePickerController presentInView: self];
}

- (void)sendUploadImage:(CardImage *)image
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
         }
         else {
             [weakSelf showAlertWithError: error];
         }
         
         NSLog(@" response = %@", [model debugDescription]);
     }];
}

- (void)showAlertWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"ERROR"
                                                    message: error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle: @"Ok" otherButtonTitles:nil];
    [alert show];
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

- (void)showCompleteAlert
{
    AlertViewController *controller = [AlertViewController alertControllerWithTitle: lInfo
                                                                            message: lCompleteCheck];
    
    [controller addAction:[AlertAction actionWithTitle: lCloseApp style:UIAlertActionStyleDefault handler:^(AlertAction *action) {
        UIApplication *app = [UIApplication sharedApplication];
        [app performSelector:@selector(suspend)];
    }]];
    
    [controller addAction:[AlertAction actionWithTitle: lContinue style:UIAlertActionStyleDefault handler:^(AlertAction *action) {
        [self.readerController resetReaderController];
    }]];
    
    [self.notifyManager showAlert: controller];
}

#pragma mark - ReaderControllerDelegate

- (void)readerController:(ReaderController *)controller didUpdateWithState:(ReaderState)state
{
    XT_EXEPTION_NOT_MAIN_THREAD;
    
    NSLog(@"%@", [NSString stringWithFormat:@"%@ - %@", CURRENT_METHOD, [self readerStatus: state]]);
    
    [self.cardDefaultView updateWithStatus: [self readerStatus: state]];
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
    [self checkTrackData: [TrackData demoTrack1]];
}

- (void)cardViewResetPressed:(UIView *)view
{
    [self.readerController resetReaderController];
}

- (void)cardViewContinuePressed:(UIView *)view
{
    [self showCardDefaultView];
    
    [self.readerController resetReaderController];
}

- (void)cardViewYesPressed:(UIView *)view
{
    [self showCardDefaultView];
    
    [self sendCompleteCheckCard];
}

- (void)cardViewNoPressed:(UIView *)view
{
    self.cardCheckReport.fakeCard = YES;
}

#pragma mark - CardImagePickerDelegate

- (void)cardPicker:(CardImagePicker *)picker didPickCardImage:(CardImage *)image
{
    [picker dismissInView: self];
    
    [self sendUploadImage: image];
}

- (void)cardPickerDidCancelPicking:(CardImagePicker *)picker
{
    [picker dismissInView: self];
}

@end
