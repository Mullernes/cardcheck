
#import "CheckingViewController.h"

#import "CardCheckedView.h"
#import "CardDefaultView.h"

@interface CheckingViewController ()<ReaderControllerDelegate, CardImagePickerDelegate, AuthViewDelegate, CardDefaultViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) KeyChainData *keyChain;
@property (nonatomic, strong) CardReader *currentReader;
@property (nonatomic, strong) InitializationData *devInitData;

@property (nonatomic, strong) ReaderController *readerController;
@property (nonatomic, strong) CardImagePicker *cardImagePickerController;

@property (nonatomic, strong) NSArray *stackOfResponse;

@property (nonatomic, strong) CardCheckedView *cardCheckedView;
@property (nonatomic, strong) CardDefaultView *cardDefaultView;

@end

@implementation CheckingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];

    self.readerController = [ReaderController sharedInstance];
    [self.readerController setDelegate: self];
    
    //Base init
    self.stackOfResponse = @[];
    self.keyChain = [KeyChainData sharedInstance];
    [self.keyChain reset];
    
    self.currentReader = [CardReader sharedInstance];
    self.cardImagePickerController = [[CardImagePicker alloc] initWithDelegate: self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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

- (void)showCardCheckedView:(CCheckResponseModel *)response
{
    [self.cardCheckedView prepareUi];
    [self.cardCheckedView setupWith: response];
    
    [self showView: self.cardCheckedView reverse: NO];
}

- (void)showCardDefaultView
{
    [self showView: self.cardDefaultView reverse: YES];
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

#pragma mark - Working

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
         NSLog(@" response = %@", [model debugDescription]);
         
         weakSelf.stackOfResponse = [weakSelf.stackOfResponse arrayByAddingObject: model];
         [alert dismissWithClickedButtonIndex:0 animated:YES];
         
         [weakSelf showCardCheckedView: model];
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
    AesTrackData *trackData = [AesTrackData demoData];
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
         NSLog(@" response = %@", [model debugDescription]);
         
         [image setID: model.imgID];
         weakSelf.stackOfResponse = [weakSelf.stackOfResponse arrayByAddingObject: image];
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

- (void)readerController:(ReaderController *)controller didUpdateWithReader:(CardReader *)reader
{
    [self handleReader: reader];
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

#pragma mark - AuthViewDelegate

- (void)continueCardChecking:(CardCheckedView *)view
{
    [self showCardDefaultView];
}

#pragma mark - CardDefaultViewDelegate

- (void)cardViewResetPressed:(CardDefaultView *)view
{
    [self.readerController reset];
    [self.currentReader setTrackData: nil];
}

- (void)cardViewCheckDemoPressed:(CardDefaultView *)view
{
    [self checkCardData: [AesTrackData demoData]];
}

@end
