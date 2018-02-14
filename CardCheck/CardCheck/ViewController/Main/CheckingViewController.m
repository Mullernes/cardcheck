
#import "CheckingViewController.h"

#import "CardCheckedView.h"
#import "CardDefaultView.h"


#define lPreparingForReading        NSLocalizedStringFromTable(@"animation_preparing_for_reading", @"Common", @"Animation View")
#define lPreparingForTestReading    NSLocalizedStringFromTable(@"animation_preparing_for_test_reading", @"Common", @"Animation View")

#define lSwipeCard                  NSLocalizedStringFromTable(@"animation_swipe_card", @"Common", @"Animation View")
#define lSwipeTestCard              NSLocalizedStringFromTable(@"animation_swipe_test_card", @"Common", @"Animation View")

#define lGettingData                NSLocalizedStringFromTable(@"animation_getting_data_from_reader", @"Common", @"Animation View")
#define lGettingTestData            NSLocalizedStringFromTable(@"animation_getting_test_data_from_reader", @"Common", @"Animation View")

#define lSendingRequest             NSLocalizedStringFromTable(@"animation_sending_request", @"Common", @"Animation View")


@interface CheckingViewController ()<ReaderControllerDelegate, CardImagePickerDelegate, AuthViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) CardCheckedView *cardCheckedView;
@property (nonatomic, strong) CardDefaultView *cardDefaultView;

@property (nonatomic, strong) NSArray *stackOfResponse;
@property (nonatomic, strong) CardImagePicker *cardImagePickerController;

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

#pragma mark - Ui

- (void)showCardDefaultView
{
    [self showView: self.cardDefaultView reverse: YES];
}

- (void)showCardCheckedView:(CCheckResponseModel *)response
{
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

- (void)showReaderState:(ReaderState)state
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
            
        case ReaderStateProcessing:
            title = isStaging? lGettingData : lGettingTestData;
            break;
            
        default:
            title = nil;
            break;
    }
    
    NSLog(@"%@ - %@", CURRENT_METHOD, title);
    [self.cardDefaultView startAnimating: title];
}

#pragma mark - Working

- (void)showAlertWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"ERROR"
                                                    message: error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle: @"Ok" otherButtonTitles:nil];
    [alert show];
}

- (void)checkCardData:(AesTrackData *)trackData
{
    self.stackOfResponse = @[];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Sending track data..."
                                                   delegate:nil
                                          cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    
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
         
         [alert dismissWithClickedButtonIndex:0 animated:YES];
         NSLog(@" response = %@", [model debugDescription]);
     }];
}

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

- (void)completeCheckCard
{
    AesTrackData *trackData = [AesTrackData demoTrack];
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

- (void)uploadImage:(CardImage *)image
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

- (void)handleReader:(CardReader *)reader
{
    NSLog(@"%@: reader => %@", CURRENT_METHOD, [reader debugDescription]);
    
    if ([reader.trackData isExist]) {
        [self checkCardData: reader.trackData];
    }
    else {
        [self showCardDefaultView];
    }
}

#pragma mark - ReaderControllerDelegate

- (void)readerController:(ReaderController *)controller didUpdateWithState:(ReaderState)state
{
    NSLog(@"%@", CURRENT_METHOD);
    XT_EXEPTION_NOT_MAIN_THREAD;
    
    [self showReaderState: state];
}

- (void)readerController:(ReaderController *)controller didUpdateWithReader:(CardReader *)reader
{
    NSLog(@"%@", CURRENT_METHOD);
    XT_EXEPTION_NOT_MAIN_THREAD;
    
    //[self handleReader: reader];
}

- (void)readerController:(ReaderController *)controller didReceiveTrackData:(AesTrackData *)data
{
    NSLog(@"%@", CURRENT_METHOD);
    XT_EXEPTION_NOT_MAIN_THREAD;
}

#pragma mark - AuthViewDelegate

- (void)cardViewDemoPressed:(CardDefaultView *)view
{
    [self checkCardData: [AesTrackData demoTrack]];
}

- (void)cardViewResetPressed:(CardDefaultView *)view
{
    [self.readerController resetReaderController];
}

- (void)cardViewContinuePressed:(CardCheckedView *)view
{
    [self showCardDefaultView];
}

#pragma mark - CardImagePickerDelegate

- (void)cardPicker:(CardImagePicker *)picker didPickCardImage:(CardImage *)image
{
    [picker dismissInView: self];
    
    [self uploadImage: image];
}

- (void)cardPickerDidCancelPicking:(CardImagePicker *)picker
{
    [picker dismissInView: self];
}

@end
