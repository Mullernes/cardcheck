
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


#define lInfo                       NSLocalizedStringFromTable(@"handle_track_info",        @"Common", @"Track Data")
#define lNoneRead                   NSLocalizedStringFromTable(@"handle_track_none_read",   @"Common", @"Track Data")
#define lTrack1Read                 NSLocalizedStringFromTable(@"handle_track_track1_read", @"Common", @"Track Data")
#define lTrack2Read                 NSLocalizedStringFromTable(@"handle_track_track2_read", @"Common", @"Track Data")

#define lRepeatReading              NSLocalizedStringFromTable(@"handle_track_repeat_reading", @"Common", @"Track Data")
#define lSendRequest                NSLocalizedStringFromTable(@"handle_track_send_request",   @"Common", @"Track Data")


@interface CheckingViewController ()<ReaderControllerDelegate, CardImagePickerDelegate, AuthViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) CardCheckedView *cardCheckedView;
@property (nonatomic, strong) CardDefaultView *cardDefaultView;

@property (nonatomic, strong) NSArray *stackOfResponse;
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
    self.stackOfResponse = @[];
    self.cardImagePickerController = [[CardImagePicker alloc] initWithDelegate: self];
    
    [self.readerController setDelegate: self];
    [self.readerController resetReaderController];
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

- (void)showCardCheckedView:(CCheckResponseModel *)response
{
    if (NO == self.readerController.isStaging) {
        [self.readerController startStageMode];
    }
    
    [self.cardCheckedView prepareUi];
    [self.cardCheckedView setupWith: response];
    
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

- (CCheckResponseModel *)lastCheckResponse
{
    __block CCheckResponseModel *target = nil;
    [self.stackOfResponse enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass: [CCheckResponseModel class]]) {
            target = obj;
            *stop = YES;
        }
    }];
    
    return target;
}

- (NSArray<CardImage *> *)fakeCardImages
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF != %@", [self lastCheckResponse]];
    return [self.stackOfResponse filteredArrayUsingPredicate: predicate];
}

- (void)sendCheckCard:(TrackData *)trackData
{
    self.stackOfResponse = @[];
    
    CryptoController *crp = [CryptoController sharedInstance];
    NSData *cipherData = [crp aes256EncryptHexData: trackData.plainHexData
                                        withHexKey: [self.keyChain appDataKey]];
    [trackData setCipherHexData: [HexCvtr hexFromData: cipherData]];
    [self.currentReader setTrackData: trackData];
    
    CCheckRequestModel *request = [CCheckRequestModel requestWithReader: self.currentReader];
    __weak CheckingViewController *weakSelf = self;
    [[APIController sharedInstance] sendCCheckRequest: request
                                       withCompletion:^(CCheckResponseModel *model, NSError *error)
     {
         if (model.isCorrect) {
             weakSelf.stackOfResponse = [weakSelf.stackOfResponse arrayByAddingObject: model];
             [weakSelf showCardCheckedView: model];
         }
         else {
             [weakSelf showAlertWithError: error];
         }
         
         NSLog(@" response = %@", [model debugDescription]);
     }];
}

- (void)sendCompleteCheckCard
{
    TrackData *trackData = [TrackData demoTrack];
    trackData.plainHexData = [NSString stringWithFormat:@"%@%@", trackData.plainHexData, DEMO_PAN];
    
    CryptoController *crp = [CryptoController sharedInstance];
    NSData *cipherData = [crp aes256EncryptHexData: trackData.plainHexData
                                        withHexKey: [self.keyChain appDataKey]];
    [trackData setCipherHexData: [HexCvtr hexFromData: cipherData]];
    [self.currentReader setTrackData: trackData];
    
    CFinishCheckRequestModel *request = [CFinishCheckRequestModel requestWithReader: self.currentReader];
    [request setCheckResponse: [self lastCheckResponse]];
    [request setupFakeCardWithImages: [self fakeCardImages]];
    
    //__weak ViewController *weakSelf = self;
    [[APIController sharedInstance] sendCFinishCheckRequest: request
                                             withCompletion:^(CFinishCheckResponseModel *model, NSError *error)
     {
         NSLog(@" response = %@", [model debugDescription]);
     }];
}

- (void)uploadCardImage
{
    [self.cardImagePickerController presentInView: self];
}

- (void)sendUploadImage:(CardImage *)image
{
    CCheckResponseModel *report = [self lastCheckResponse];
    CUploadRequestModel *request = [CUploadRequestModel requestWithReportID: report.reportID
                                                                 reportTime: report.time
                                                                  cardImage: image];
    
    __weak CheckingViewController *weakSelf = self;
    [[APIController sharedInstance] uploadImageRequest: request
                                        withCompletion:^(CUploadResponseModel *model, NSError *error)
     {
         if (model.isCorrect) {
             [image setID: model.imgID];
             weakSelf.stackOfResponse = [weakSelf.stackOfResponse arrayByAddingObject: image];
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
        [self sendCheckCard: data];
        [self.cardDefaultView updateWithStatus: lSendingRequest];
    }
    else if ((NO == data.isReadableTrack1) && (NO == data.isReadableTrack2)) {
        [self showAlertWithTitle: lInfo andMessage: lNoneRead];
    }
    else if (NO == data.isReadableTrack1) {
        [self showAlertWithTitle: lInfo andMessage: lTrack1Read];
    }
    else if (NO == data.isReadableTrack2) {
        [self showAlertWithTitle: lInfo andMessage: lTrack2Read];
    }
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    AlertViewController *controller = [AlertViewController alertControllerWithTitle: title
                                                                            message: message];
    
    [controller addAction:[AlertAction actionWithTitle: lRepeatReading style:UIAlertActionStyleCancel handler:^(AlertAction *action) {
        [self.readerController resetReaderController];
    }]];
    
    [controller addAction:[AlertAction actionWithTitle: lSendingRequest style:UIAlertActionStyleDefault handler:^(AlertAction *action) {
        [self sendCheckCard: self.currentReader.trackData];
        [self.cardDefaultView updateWithStatus: lSendingRequest];
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
    
    NSLog(@"%@", [NSString stringWithFormat:@"%@ - %i", CURRENT_METHOD, counter]);
    
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

- (void)cardViewDemoPressed:(CardDefaultView *)view
{
    [self sendCheckCard: [TrackData demoTrack]];
}

- (void)cardViewResetPressed:(CardDefaultView *)view
{
    [self.readerController resetReaderController];
}

- (void)cardViewContinuePressed:(CardCheckedView *)view
{
    [self showCardDefaultView];
    
    [self.readerController resetReaderController];
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
