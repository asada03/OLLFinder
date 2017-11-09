//
//  ViewController.m
//  OLL Finder
//
//  Created by Vortex on 28/02/15.
//  Copyright (c) 2015 Andres Sada Govela. All rights reserved.
//

#import "ViewController.h"
#import "OLLCase+CoreDataProperties.h"
#import "Algorithm+CoreDataProperties.h"
#import "Video+CoreDataProperties.h"
#import "Video+CoreDataProperties.h"
#import "CaseTableViewCell.h"
#import "ImageButton.h"
#import "UICKeyChainStore.h"
#import "Firebase.h"

//#define testing

#ifdef testing
#warning hide alg number in storyboard
#endif

@interface ViewController ()
{
    FIRDatabaseReference *firebaseRootRef;
    CaseViewController *caseView;

    NSString *version;
    NSMutableArray *caseTypes;
    NSNumber *selectedCross;
    NSNumber *selectedCorners;
    NSString *selectedType;
    OLLCase *ollCase;
    BOOL isIpad;
    BOOL viewAppeared;
    
    int numCasesViewed;
}
@property (strong, nonatomic) IBOutlet UITableView *casesTable;
@property (strong, nonatomic) IBOutletCollection(ImageButton) NSArray *crossButtons;
@property (strong, nonatomic) IBOutletCollection(ImageButton) NSArray *cornerButtons;
@property (strong, nonatomic) IBOutletCollection(ImageButton) NSArray *typeButtons;

@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsViewHeight;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerHeightConstraint;

@property (strong, nonatomic) NSArray *selectedCases;
@property(nonatomic, strong) GADInterstitial *interstitial;

@end

@implementation ViewController

- (void)setSelectedCases:(NSArray *)selectedCases
{
    _selectedCases = selectedCases;
    
    if ([selectedCases count] > 0)
    {
        ollCase = selectedCases[0];
        
        if (caseView)
            caseView.ollCase = ollCase;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    version = @"2.0";
    if (!self.managedObjectContext)
        [self useModelDocument];
    
    numCasesViewed = [[UICKeyChainStore stringForKey:@"numCasesViewed"] intValue];
    
    isIpad = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad );
    
    if (isIpad)
    {
        self.buttonsView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.buttonsView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        self.buttonsView.layer.shadowOpacity = .7f;
        self.buttonsView.layer.shadowRadius = 4.0f;
        
        self.casesTable.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.casesTable.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        self.casesTable.layer.shadowOpacity = .7f;
        self.casesTable.layer.shadowRadius = 4.0f;
    }
    
    self.bannerView.adUnitID = @"ca-app-pub-9875593345175318/5308705309";
    self.bannerView.rootViewController = self;
    self.bannerView.delegate = self;
    GADRequest *request = [GADRequest request];
    
#ifdef testing
#warning remove
    request.testDevices = @[ kGADSimulatorID,            // All simulators
                             @"515ea915fcd3eccfbad7e21041c3bffb",
                             @"f930daf8742bd0b6d7ee35788403872e" ]; // Sample device ID
#endif


    [self.bannerView loadRequest:request];
    
    [self hideBanner];
    
    [self createAndLoadInterstitial];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    [self showInterstital];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    firebaseRootRef = [[FIRDatabase database] reference];

    if (!viewAppeared)
    {
        [self resetButtons];
        viewAppeared = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self createAndLoadInterstitial];
}

- (void)useModelDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Cases Data"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
#ifdef testing
#warning Remember to fix this.
    
    if (YES)
#else
    if (![[UICKeyChainStore stringForKey:@"version"] isEqualToString:version] &
        [[NSFileManager defaultManager] fileExistsAtPath:[url path]])
#endif
    {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:[url path] error:&error];
        NSLog(@"Deleting");
    }

    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]])
    {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  self.managedObjectContext = document.managedObjectContext;
                  [self populate];
              }
          }];
    }
    else if (document.documentState == UIDocumentStateClosed)
    {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
                [self start];
            }
        }];
    }
    else
    {
        self.managedObjectContext = document.managedObjectContext;
        [self start];
    }
    
    [UICKeyChainStore setString:version forKey:@"version"];
}

- (void)populate
{
    NSArray *ollCases = @[@[@"1",@0,@0,@""],
                               @[@"2",@0,@0,@""],
                               @[@"3",@0,@1,@""],
                               @[@"4",@0,@1,@""],
                               @[@"5",@0,@3,@""],
                               @[@"6",@0,@2,@""],
                               @[@"7",@0,@2,@""],
                               @[@"8",@0,@4,@""],
                               @[@"9",@1,@0,@""],
                               @[@"10",@1,@0,@""],
                               @[@"11",@1,@0,@""],
                               @[@"12",@1,@0,@""],
                               @[@"13",@2,@0,@""],
                               @[@"14",@2,@0,@""],
                               @[@"15",@2,@0,@""],
                               @[@"16",@2,@0,@""],
                               @[@"17",@2,@0,@""],
                               @[@"18",@2,@0,@""],
                               @[@"19",@2,@1,@"S"],
                               @[@"20",@2,@1,@"S"],
                               @[@"21",@2,@1,@"S"],
                               @[@"22",@2,@1,@"S"],
                               @[@"23",@2,@1,@"F"],
                               @[@"24",@2,@1,@"F"],
                               @[@"25",@2,@1,@"O"],
                               @[@"26",@2,@1,@"O"],
                               @[@"27",@1,@1,@""],
                               @[@"28",@1,@1,@""],
                               @[@"29",@1,@1,@""],
                               @[@"30",@1,@1,@""],
                               @[@"31",@2,@2,@"Y"],
                               @[@"32",@2,@2,@"Y"],
                               @[@"33",@2,@2,@"Y"],
                               @[@"34",@2,@2,@"Y"],
                               @[@"35",@2,@2,@"P"],
                               @[@"36",@2,@2,@"P"],
                               @[@"37",@2,@3,@"Q"],
                               @[@"38",@2,@2,@"P"],
                               @[@"39",@2,@2,@"P"],
                               @[@"40",@2,@3,@"Q"],
                               @[@"41",@1,@2,@"T"],
                               @[@"42",@1,@2,@"T"],
                               @[@"43",@1,@3,@""],
                               @[@"44",@1,@3,@""],
                               @[@"45",@1,@2,@"C"],
                               @[@"46",@1,@2,@"C"],
                               @[@"47",@2,@3,@"M"],
                               @[@"48",@2,@3,@"M"],
                               @[@"49",@3,@0,@""],
                               @[@"50",@3,@0,@""],
                               @[@"51",@3,@2,@""],
                               @[@"52",@3,@2,@""],
                               @[@"53",@3,@3,@""],
                               @[@"54",@3,@1,@""],
                               @[@"55",@3,@1,@""],
                               @[@"56",@2,@4,@""],
                               @[@"57",@1,@4,@""]];

 NSArray *ollAlgs =@[@[@"1_0",@"(R U2 R') (R' F R F') U2 (R' F R F')",@0],
     @[@"2_0",@"(r U r') (U2 R U2 R' U2) (r U' r')",@1],
     @[@"2_1",@"[F (R U R' U') F' ] [f (R U R' U') f']",@0],
     @[@"3_0",@"[f (R U R' U') f'] U [F (R U R' U') F' ]",@0],
     @[@"4_0",@"[f (R U R' U') f'] U' [F (R U R' U') F' ]",@0],
     @[@"5_0",@"(R U R' U) (R' F R F') U2 (R' F R F')",@0],
     @[@"6_0",@"(R U2) (R2 F R F') U2 (M' U R U' r')",@-1],
     @[@"6_1",@"[F (R U R' U) F'] y' U2 (R' F R F')",@0],
     @[@"7_0",@"M U (R U R' U') M' (R' F R F') ",@0],
     @[@"8_0",@"(M' U2 M) U2 (M' U' M) U2 (M' U2 M)",@0],
     @[@"8_1",@"r U R' U' M2 U R U' R' U' M'",@0],
     @[@"8_2",@"M U (R U R' U') M2 (U R U' r')",@0],
     @[@"9_0",@"(R' F R) U (R U' R2 F') (R2 U' R') U (R U R')",@1],
     @[@"9_1",@"R' U2 R2 U R' U R U2 x' U' R' U",@0],
     @[@"10_0",@"r' U' r (U' R' U R) (U' R' U R) r' U r",@0],
     @[@"10_1",@"F (R U R' U') R F' (r U R' U') r'",@0],
     @[@"11_0",@"F (U R U' R') (U R U' R') F'",@2],
     @[@"11_1",@"f (R U R' U') (R U R' U') f'",@0],
     @[@"12_0",@"(R U R' U) (R U') (B U' B' R)",@0],
     @[@"12_1",@"(R' U' R U' R' U) y' (R' U R) B",@0],
     @[@"12_2",@"(R U R' U) R d' R U' R' F'",@0],
     @[@"13_0",@"(r U2) (R' U' R U) (R' U' R U') r'",@-1],
     @[@"13_1",@"(r U R' U) (R U' R' U) R U2' r'",@0],
     @[@"14_0",@"(l' U' L U') (L' U L U') (L' U2 l)",@0],
     @[@"15_0",@"(r U') (r2 U r2 U) (r2 U' r)",@0],
     @[@"15_1",@"(R' F R' F') R2 U2 y (R' F R F')",@0],
     @[@"16_0",@"(R' F) (R2 B' R2' F') (R2 B R')",@0],
     @[@"16_1",@"r' U r2 U' r2 U' r2 U r'",@2],
     @[@"17_0",@"F (R U R' U') (R U R' U') F'",@0],
     @[@"18_0",@"F' (L' U' L U) (L' U' L U) F",@0],
     @[@"19_0",@"(r U R' U) R U2 r'",@0],
     @[@"20_0",@"l' U' L U' L' U2 l",@2],
     @[@"20_1",@"r' U' R U' R' U2 r",@0],
     @[@"21_0",@"M' (R' U' R U' R' U2 R) U' M",@-1],
     @[@"21_1",@"[F (R U R' U') F'] U [F (R U R' U') F' ]",@0],
     @[@"22_0",@"M (R U R' U R U2 R') U M'",@-1],
     @[@"22_1",@"[F' (L' U' L U) F] y [F (R U R' U') F']",@0],
     @[@"23_0",@"(R U R' U' R' F) (R2 U R' U' F')",@0],
     @[@"24_0",@"(R U R' U) (R' F R F') (R U2 R')",@0],
     @[@"25_0",@"l' U2 L U L' U l",@2],
     @[@"25_1",@"r' U2 (R U R' U) r",@0],
     @[@"26_0",@"r U2 R' U' R U' r'",@0],
     @[@"27_0",@"F U R U' R2 F' R (U R U' R')",@0],
     @[@"27_1",@"(r U' r) (U' r U r') y' (R' U R)",@0],
     @[@"28_0",@"(R' F) (R U R' F' R) (F U' F')",@0],
     @[@"28_1",@"(R' F) (R U R' F' R) y' (R U' R')",@0],
     @[@"29_0",@"(r U r') (R U R' U') (r U' r')",@0],
     @[@"30_0",@"(l' U' l) (L' U' L U) (l' U l)",@0],
     @[@"30_1",@"(r' U' r) (R' U' R U) (r' U r)",@0],
     @[@"31_0",@"[(R U R' U) R U2 R'] [F (R U R' U') F']",@0],
     @[@"32_0",@"(R' U' R U' R' U2 R) F (R U R' U') F'",@-1],
     @[@"32_1",@"(R' F R F') (R' F R F') (R U R' U') (R U R')",@0],
     @[@"33_0",@"(F R' F) (R2 U' R' U') (R U R') F2",@2],
     @[@"33_1",@"F U (R U2 R' U') (R U2 R' U') F'",@2],
     @[@"33_2",@"(R2 U R' B' R) U' (R2 U R B R')",@0],
     @[@"34_0",@"r2 D' (r U r') D r2 U' (r' U' r)",@-1],
     @[@"34_1",@"(R U R' U') R U' R' F' U' F (R U R')",@0],
     @[@"35_0",@"(R U B') U' R' U (R B R')",@0],
     @[@"36_0",@"(R' U') F (U R U' R') F' R",@0],
     @[@"37_0",@"F (R U') (R' U' R U) (R' F')",@0],
     @[@"38_0",@"F (U R U' R') F",@2],
     @[@"38_1",@"f (R U R' U') f'",@0],
     @[@"39_0",@"R'(U' F' U F) R",@1],
     @[@"39_1",@"f ' (L' U' L U) f",@0],
     @[@"40_0",@"(R U2) (R2 F) (R F' R U2 R')",@0],
     @[@"41_0",@"F (R U R' U') F'",@0],
     @[@"42_0",@"(R U R' U') (R' F R F')",@0],
     @[@"43_0",@"(L F') (L' U' L U) F U' L'",@2],
     @[@"43_1",@"R B' R' U' R U B U' R'",@0],
     @[@"44_0",@"(R' F) (R U R' U') F' U R",@0],
     @[@"45_0",@"(R U R' U') y' (r' U' R U M')",@0],
     @[@"45_1",@"(R U R2 U') (R' F) (R U) (R U') F'",@0],
     @[@"46_0",@"(R' U') (R' F R F') (U R)",@0],
     @[@"47_0",@"(R U R' U) (R U' R' U') (R' F R F')",@0],
     @[@"48_0",@"(L' U' L U') (L' U L U) (L F' L' F)",@0],
     @[@"48_1",@"(R' U' R U') (R' U R U) l U' R' U x",@2],
     @[@"49_0",@"(R U2) (R' U' R U R' U' R U' R)",@0],
     @[@"49_1",@"F (R U R' U') (R U R' U') (R U R' U') F'",@0],
     @[@"50_0",@"(R U2) (R2 U') (R2 U') (R2 U2 R)",@0],
     @[@"50_1",@"[f (R U R' U') f'] [F (R U R' U') F']",@0],
     @[@"51_0",@"R2 [D (R' U2) R] [D' (R' U2) R']",@0],
     @[@"52_0",@"(r U R' U') (r' F R F')",@0],
     @[@"53_0",@"(F R' F' r U) (R U' r')",@-1],
     @[@"53_1",@"F' (r U R' U') (r' F R )",@0],
     @[@"54_0",@"R U2 R' U' R U' R'",@0],
     @[@"55_0",@"(R U R' U) R U2 R'",@0],
     @[@"56_0",@"M' U' M U2 M' U' M",@1],
                     @[@"56_1",@"M' U M U2 M' U M",@0],
                     @[@"56_2",@"(r U R' U') M (U R U' R')",@2],
     @[@"57_0",@"(R U R' U') (M' U R U') r'",@0]];
    
NSArray *ollVids =@[@[@"55_0",@"UberCuber",@39, @6, @"Qr1ETRAQPKI"],
                    @[@"54_0",@"UberCuber",@48, @6.7, @"Qr1ETRAQPKI"],
                    @[@"52_0_",@"UberCuber",@55, @7.7, @"Qr1ETRAQPKI"],
                    @[@"51_0",@"UberCuber",@64, @9.9, @"Qr1ETRAQPKI"],
                    @[@"53_0",@"UberCuber",@75, @7, @"Qr1ETRAQPKI"],
                    @[@"50_0",@"UberCuber",@83, @10.2, @"Qr1ETRAQPKI"],
                    @[@"49_0",@"UberCuber",@97, @8.1, @"Qr1ETRAQPKI"],
                    @[@"1_0",@"UberCuber",@113, @8.4, @"Qr1ETRAQPKI"],
                    @[@"2_0",@"UberCuber",@124, @9.9, @"Qr1ETRAQPKI"],
                    @[@"4_0",@"UberCuber",@136, @10.6, @"Qr1ETRAQPKI"],
                    @[@"3_0",@"UberCuber",@147, @11.7, @"Qr1ETRAQPKI"],
                    @[@"5_0",@"UberCuber",@160, @8.3, @"Qr1ETRAQPKI"],
                    @[@"6_0",@"UberCuber",@170, @11.1, @"Qr1ETRAQPKI"],
                    @[@"7_0",@"UberCuber",@1822, @11.6, @"Qr1ETRAQPKI"],
                    @[@"8_0",@"UberCuber",@2000, @10.1, @"Qr1ETRAQPKI"],
                    @[@"8_1",@"UberCuber",@211, @9.8, @"Qr1ETRAQPKI"],
                    @[@"36_0",@"UberCuber",@224, @9, @"Qr1ETRAQPKI"],
                    @[@"35_0",@"UberCuber",@236, @9.5, @"Qr1ETRAQPKI"],
                    @[@"38_0",@"UberCuber",@246, @8, @"Qr1ETRAQPKI"],
                    @[@"39_0",@"UberCuber",@255, @4.8, @"Qr1ETRAQPKI"],
                    @[@"48_0",@"UberCuber",@265, @10, @"Qr1ETRAQPKI"],
                    @[@"47_0",@"UberCuber",@277, @7.6, @"Qr1ETRAQPKI"],
                    @[@"18_0",@"UberCuber",@290, @5.7, @"Qr1ETRAQPKI"],
                    @[@"17_0",@"UberCuber",@296, @6.1, @"Qr1ETRAQPKI"],
                    @[@"15_0",@"UberCuber",@303, @6.4, @"Qr1ETRAQPKI"],
                    @[@"16_0",@"UberCuber",@310, @6, @"Qr1ETRAQPKI"],
                    @[@"14_0",@"UberCuber",@317, @6.9, @"Qr1ETRAQPKI"],
                    @[@"13_0",@"UberCuber",@326, @7.4, @"Qr1ETRAQPKI"],
                    @[@"46_0",@"UberCuber",@338, @5.2, @"Qr1ETRAQPKI"],
                    @[@"45_0",@"UberCuber",@345, @7.3, @"Qr1ETRAQPKI"],
                    @[@"41_0",@"UberCuber",@358, @6.2, @"Qr1ETRAQPKI"],
                    @[@"42_0",@"UberCuber",@365, @6.5, @"Qr1ETRAQPKI"],
                    @[@"11_0",@"UberCuber",@377, @5.4, @"Qr1ETRAQPKI"],
                    @[@"12_0",@"UberCuber",@385, @7, @"Qr1ETRAQPKI"],
                    @[@"9_0",@"UberCuber",@394, @7.4, @"Qr1ETRAQPKI"],
                    @[@"10_0",@"UberCuber",@402, @6.5, @"Qr1ETRAQPKI"],
                    @[@"25_0",@"UberCuber",@415, @7.9, @"Qr1ETRAQPKI"],
                    @[@"26_0",@"UberCuber",@424, @7.9, @"Qr1ETRAQPKI"],
                    @[@"43_0",@"UberCuber",@436, @5.9, @"Qr1ETRAQPKI"],
                    @[@"44_0",@"UberCuber",@443, @5.9, @"Qr1ETRAQPKI"],
                    @[@"19_0",@"UberCuber",@454, @7.22, @"Qr1ETRAQPKI"],
                    @[@"20_0",@"UberCuber",@462, @6.24, @"Qr1ETRAQPKI"],
                    @[@"22_0",@"UberCuber",@469, @10.1, @"Qr1ETRAQPKI"],
                    @[@"21_0",@"UberCuber",@481, @8.7, @"Qr1ETRAQPKI"],
                    @[@"23_0",@"UberCuber",@494, @9.1, @"Qr1ETRAQPKI"],
                    @[@"24_0",@"UberCuber",@504, @9, @"Qr1ETRAQPKI"],
                    @[@"40_0",@"UberCuber",@513, @8.5, @"Qr1ETRAQPKI"],
                    @[@"37_0",@"UberCuber",@522, @6.7, @"Qr1ETRAQPKI"],
                    @[@"27_0",@"UberCuber",@533, @9.9, @"Qr1ETRAQPKI"],
                    @[@"28_0",@"UberCuber",@544, @3.8, @"Qr1ETRAQPKI"],
                    @[@"30_0",@"UberCuber",@549, @6.7, @"Qr1ETRAQPKI"],
                    @[@"29_0",@"UberCuber",@559, @6.9, @"Qr1ETRAQPKI"],
                    @[@"34_0",@"UberCuber",@570, @8.9, @"Qr1ETRAQPKI"],
                    @[@"33_0",@"UberCuber",@579, @6.4, @"Qr1ETRAQPKI"],
                    @[@"31_0",@"UberCuber",@586, @7.9, @"Qr1ETRAQPKI"],
                    @[@"32_0",@"UberCuber",@595, @6.9, @"Qr1ETRAQPKI"],
                    @[@"56_0",@"UberCuber",@605, @6.9, @"Qr1ETRAQPKI"],
                    @[@"57_0",@"UberCuber",@613, @5.5, @"Qr1ETRAQPKI"],
                    @[@"54_0",@"Feliks Zemdegs",@9, @9.3, @"IasVqtCHoj0"],
                    @[@"55_0",@"Feliks Zemdegs",@20, @7.4, @"IasVqtCHoj0"],
                    @[@"49_0",@"Feliks Zemdegs",@28, @11.6, @"IasVqtCHoj0"],
                    @[@"50_0",@"Feliks Zemdegs",@41, @10.5, @"IasVqtCHoj0"],
                    @[@"52_0",@"Feliks Zemdegs",@52, @6.1, @"IasVqtCHoj0"],
                    @[@"53_0",@"Feliks Zemdegs",@59, @8.1, @"IasVqtCHoj0"],
                    @[@"51_0",@"Feliks Zemdegs",@69, @14.7, @"IasVqtCHoj0"],
                    @[@"42_0",@"Feliks Zemdegs",@99, @6.5, @"IasVqtCHoj0"],
                    @[@"41_0",@"Feliks Zemdegs",@107, @6.8, @"IasVqtCHoj0"],
                    @[@"25_1",@"Feliks Zemdegs",@115, @9.9, @"IasVqtCHoj0"],
                    @[@"26_0",@"Feliks Zemdegs",@126, @8.9, @"IasVqtCHoj0"],
                    @[@"45_1",@"Feliks Zemdegs",@136, @12.5, @"IasVqtCHoj0"],
                    @[@"46_0",@"Feliks Zemdegs",@150, @9.2, @"IasVqtCHoj0"],
                    @[@"48_1",@"Feliks Zemdegs",@160, @14.1, @"IasVqtCHoj0"],
                    @[@"47_0",@"Feliks Zemdegs",@175, @10.4, @"IasVqtCHoj0"],
                    @[@"56_2",@"Feliks Zemdegs",@198, @10, @"IasVqtCHoj0"],
                    @[@"75_0",@"Feliks Zemdegs",@209, @7.3, @"IasVqtCHoj0"],
                    @[@"36_0",@"Feliks Zemdegs",@217, @7.3, @"IasVqtCHoj0"],
                    @[@"35_0",@"Feliks Zemdegs",@226, @9.8, @"IasVqtCHoj0"],
                    @[@"39_0",@"Feliks Zemdegs",@236, @6.5, @"IasVqtCHoj0"],
                    @[@"38_1",@"Feliks Zemdegs",@244, @6.2, @"IasVqtCHoj0"],
                    @[@"11_1",@"Feliks Zemdegs",@263, @8.5, @"IasVqtCHoj0"],
                    @[@"10_0",@"Feliks Zemdegs",@272, @1.9, @"IasVqtCHoj0"],
                    @[@"12_1",@"Feliks Zemdegs",@285, @9.7, @"IasVqtCHoj0"],
                    @[@"9_0",@"Feliks Zemdegs",@296, @11.7, @"IasVqtCHoj0"],
                    @[@"23_0",@"Feliks Zemdegs",@308, @10.9, @"IasVqtCHoj0"],
                    @[@"24_0",@"Feliks Zemdegs",@320, @10.9, @"IasVqtCHoj0"],
                    @[@"40_0",@"Feliks Zemdegs",@332, @10.2, @"IasVqtCHoj0"],
                    @[@"37_0",@"Feliks Zemdegs",@343, @7.2, @"IasVqtCHoj0"],
                    @[@"27_1",@"Feliks Zemdegs",@363, @9.3, @"IasVqtCHoj0"],
                    @[@"28_0",@"Feliks Zemdegs",@373, @8.5, @"IasVqtCHoj0"],
                    @[@"29_0",@"Feliks Zemdegs",@382, @8.5, @"IasVqtCHoj0"],
                    @[@"30_1",@"Feliks Zemdegs",@392, @8.7, @"IasVqtCHoj0"],
                    @[@"34_1",@"Feliks Zemdegs",@402, @10.3, @"IasVqtCHoj0"],
                    @[@"33_1",@"Feliks Zemdegs",@413, @11.1, @"IasVqtCHoj0"],
                    @[@"31_0",@"Feliks Zemdegs",@425, @11.7, @"IasVqtCHoj0"],
                    @[@"32_0",@"Feliks Zemdegs",@437, @13.7, @"IasVqtCHoj0"],
                    @[@"17_0",@"Feliks Zemdegs",@463, @9.9, @"IasVqtCHoj0"],
                    @[@"18_0",@"Feliks Zemdegs",@473, @8.6, @"IasVqtCHoj0"],
                    @[@"15_0",@"Feliks Zemdegs",@483, @10.4, @"IasVqtCHoj0"],
                    @[@"16_1",@"Feliks Zemdegs",@494, @9.9, @"IasVqtCHoj0"],
                    @[@"13_1",@"Feliks Zemdegs",@517, @7.8, @"IasVqtCHoj0"],
                    @[@"19_0",@"Feliks Zemdegs",@537, @9.0, @"IasVqtCHoj0"],
                    @[@"20_1",@"Feliks Zemdegs",@547, @10.6, @"IasVqtCHoj0"],
                    @[@"22_0",@"Feliks Zemdegs",@559, @10.7, @"IasVqtCHoj0"],
                    @[@"21_0",@"Feliks Zemdegs",@571, @12.6, @"IasVqtCHoj0"],
                    @[@"43_0",@"Feliks Zemdegs",@585, @9.9, @"IasVqtCHoj0"],
                    @[@"44_0",@"Feliks Zemdegs",@596, @9.0, @"IasVqtCHoj0"],
                    @[@"1_0",@"Feliks Zemdegs",@618, @11.8, @"IasVqtCHoj0"],
                    @[@"2_0",@"Feliks Zemdegs",@631, @13.6, @"IasVqtCHoj0"],
                    @[@"4_0",@"Feliks Zemdegs",@646, @12.0, @"IasVqtCHoj0"],
                    @[@"3_0",@"Feliks Zemdegs",@659, @12.2, @"IasVqtCHoj0"],
                    @[@"6_0",@"Feliks Zemdegs",@673, @13.0, @"IasVqtCHoj0"],
                    @[@"7_0",@"Feliks Zemdegs",@687, @10.6, @"IasVqtCHoj0"],
                    @[@"5_0",@"Feliks Zemdegs",@699, @11.1, @"IasVqtCHoj0"],
                    @[@"8_2",@"Feliks Zemdegs",@712, @11.5, @"IasVqtCHoj0"]
                    ];
    
    
OLLCase *oll;
Algorithm *alg;
Video *vid;

    for (NSArray *ollData in ollCases)
    {
        oll = [NSEntityDescription insertNewObjectForEntityForName:@"OLLCase" inManagedObjectContext:self.managedObjectContext];
        
        oll.uid = ollData[0];
        oll.cross_type = ollData[1];
        oll.corners = ollData[2];
        oll.type = ollData[3];

        for (NSArray *algData in ollAlgs)
        {
            NSString *compsString = algData[0];
            NSArray *comps = [compsString componentsSeparatedByString:@"_"];
            NSString *thisCase = comps[0];
            NSString *algUid = comps[1];
            
            if ([thisCase isEqualToString:oll.uid])
            {
                BOOL foundVid = NO;
                for (NSArray *vidData in ollVids)
                {
                    if ([compsString isEqualToString:vidData[0]])
                    {
                        foundVid = YES;
                        alg = [NSEntityDescription insertNewObjectForEntityForName:@"Algorithm" inManagedObjectContext:self.managedObjectContext];
                        
                        alg.ollCase = oll;
                        alg.uid = algUid;
                        alg.algorithm = algData[1];
                        alg.rotations = algData[2];
                        
                        if (!oll.main)
                            oll.main = alg;

                        vid = [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:self.managedObjectContext];
                        
                        vid.algorithm = alg;
                        vid.author = vidData[1];
                        
                        vid.start = [NSNumber numberWithFloat:[vidData[2] floatValue]];
                        vid.duration = vidData[3];
                        vid.vidId = vidData[4];
                    }
                }
                
                if (!foundVid)
                {
                    alg = [NSEntityDescription insertNewObjectForEntityForName:@"Algorithm" inManagedObjectContext:self.managedObjectContext];
                    
                    alg.ollCase = oll;
                    alg.uid = algUid;
                    alg.algorithm = algData[1];
                    alg.rotations = algData[2];
                    
                    if (!oll.main)
                        oll.main = alg;
                }

            }
        }
//        NSDictionary *algData = @{@"case": oll.uid,
//                                  @"alg": oll.algorithm,
//                                  @"rotations": @0
//                                  };
//    
//        FIRDatabaseReference *devicesRef = [firebaseRootRef child:[NSString stringWithFormat:@"Algs/%@-0", oll.file_name]];
//        
//        [devicesRef setValue: algData];
}
    
    
    
    
    

    
    [self start];
}

- (void)createAndLoadInterstitial {
    self.interstitial = [[GADInterstitial alloc]
                         initWithAdUnitID:@"ca-app-pub-9875593345175318/9560130874"];
    GADRequest *request = [GADRequest request];

#ifdef testing
#warning remove
    request.testDevices = @[ kGADSimulatorID,            // All simulators
                             @"515ea915fcd3eccfbad7e21041c3bffb",
                             @"f930daf8742bd0b6d7ee35788403872e" ]; // Sample device ID
#endif

    self.interstitial.delegate = self;
    [self.interstitial loadRequest:request];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    [self createAndLoadInterstitial];
}
- (void)showInterstital
{
    if (numCasesViewed > 14 && numCasesViewed % 3 == 0)
    {
        if (self.interstitial.isReady) {
            [self.interstitial presentFromRootViewController:self];
        } else {
            NSLog(@"Ad wasn't ready");
        }
    }
}
- (void)hideBanner
{
    self.bannerTrailingConstraint.constant = - self.bannerHeightConstraint.constant;
}

- (void)resetButtons
{
    selectedCross = [NSNumber numberWithInteger:-1];
    for (ImageButton *button in self.crossButtons)
        [button imageNormal];
    
    for (ImageButton *button in self.cornerButtons)
        [button imageHidden];
    
    for (ImageButton *button in self.typeButtons)
        [button imageHidden];

    self.buttonsViewHeight.constant = 72;
}
- (void)start
{
    [self chooseAll];
}

- (void)chooseAll
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"OLLCase"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]];
    
//    NSArray *predicates = @[[NSPredicate predicateWithFormat:@"session = %@",self.currentSession],
//                            [NSPredicate predicateWithFormat:@"boarded == NO"],
//                            [NSPredicate predicateWithFormat:@"main_passenger = nil"]];
//    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
//    
    // Execute the fetch
    
    NSError *error = nil;
    self.selectedCases = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    [self.casesTable reloadData];
}

- (void)chooseCross
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"OLLCase"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]];
    
//    NSArray *predicates = @[[NSPredicate predicateWithFormat:@"cross_type = %@",crossNumber],
//                            [NSPredicate predicateWithFormat:@"boarded == NO"],
//                            [NSPredicate predicateWithFormat:@"main_passenger = nil"]];
//    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
//    
    request.predicate = [NSPredicate predicateWithFormat:@"cross_type = %@",selectedCross];
    //
    // Execute the fetch
    
    NSError *error = nil;
    self.selectedCases = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    self.buttonsViewHeight.constant = 134;

    [self.casesTable reloadData];
}

- (void)chooseCorners
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"OLLCase"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]];
        
        NSArray *predicates = @[[NSPredicate predicateWithFormat:@"cross_type = %@",selectedCross],
                                [NSPredicate predicateWithFormat:@"corners == %@",selectedCorners]];
        request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        
        NSError *error = nil;
        self.selectedCases = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        caseTypes = [[NSMutableArray alloc] init];
        
        for (OLLCase *oll in self.selectedCases)
        {
            if (![oll.type isEqualToString:@""])
            {
                if (![caseTypes containsObject:oll.type])
                {
                    [caseTypes addObject:oll.type];
                }
            }
        }
        
        self.buttonsViewHeight.constant = 134;

        for (int i = 0; i < [caseTypes count]; i++)
        {
            NSUInteger numCaseTypes = [caseTypes count];
            self.buttonsViewHeight.constant = 194;
            NSString *thisType = caseTypes[i];
            
            if (i == 1 && numCaseTypes == 2)
                i++;

            for (ImageButton *button in self.typeButtons)
            {
                if (button.tag == i)
                {
                    button.type = thisType;
                }
            }
        }
        
        [self.casesTable reloadData];
    }
    
- (void)chooseType
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"OLLCase"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]];
    
    NSArray *predicates = @[[NSPredicate predicateWithFormat:@"cross_type = %@",selectedCross],
                            [NSPredicate predicateWithFormat:@"corners == %@",selectedCorners],
                            [NSPredicate predicateWithFormat:@"type == %@",selectedType]];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    
    NSError *error = nil;
    self.selectedCases = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    caseTypes = [[NSMutableArray alloc] init];
    
    [self.casesTable reloadData];
}
    
-(void) cleanTypes
{
    for (ImageButton *button in self.typeButtons)
    {
        [button imageHidden];
    }
}


#pragma mark - button actions
- (IBAction)crossAction:(UIButton *)sender
{
    if (!selectedCorners && [selectedCross integerValue] == sender.tag)
    {
        //reset cross
        [self resetButtons];
        [self start];
    }
    else
    {
        selectedCross = [NSNumber numberWithInteger:sender.tag];
        
        for (ImageButton *button in self.crossButtons)
        {
            if (button.tag == sender.tag)
            {
                [button imageSelected];
            }
            else
            {
                [button imageNotSelected];
            }
        }
        for (ImageButton *button in self.cornerButtons)
        {
            [button imageNormal];
        }

        selectedCorners = nil;
        [self chooseCross];
        [self cleanTypes];
    }
}

- (IBAction)cornerAction:(UIButton *)sender
{
    selectedCorners = [NSNumber numberWithInteger:sender.tag];

    for (ImageButton *button in self.cornerButtons)
    {
        if (button.tag == sender.tag)
        {
            [button imageSelected];
        }
        else
        {
            [button imageNotSelected];
        }
    }

    [self cleanTypes];
    [self chooseCorners];
}

- (IBAction)typeAction:(ImageButton *)sender
{
    selectedType = sender.type;
    
    for (ImageButton *button in self.typeButtons)
    {
        if (button.tag == sender.tag)
        {
            [button imageSelected];
        }
        else
        {
            [button imageNotSelected];
        }
    }

    [self chooseType];
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.selectedCases count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CaseCell"];
    OLLCase *oll = self.selectedCases[indexPath.row];
    
    cell.caseImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"oll%@.png", oll.uid]];
    cell.caseImage.contentMode = UIViewContentModeScaleAspectFit;
    cell.algorithmLabel.text = oll.main.algorithm;
    cell.algorithmLabel.adjustsFontSizeToFitWidth = YES;
    cell.algNumLabel.text = oll.uid;
    cell.rotations = [oll.main.rotations integerValue];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ollCase = self.selectedCases[indexPath.row];
    numCasesViewed++;
    [UICKeyChainStore setString:[NSString stringWithFormat:@"%d",numCasesViewed] forKey:@"numCasesViewed"];


    if (isIpad)
    {
        caseView.ollCase = ollCase;
        caseView.delegate = self;
        
        [self showInterstital];
    }
    else
    {
        [self performSegueWithIdentifier:@"toLargeImege" sender:self];
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toLargeImege"])
    {
        caseView = segue.destinationViewController;
        caseView.delegate = self;
        caseView.ollCase = ollCase;
    }
}

#pragma mark - CaseVCDelegate

- (void)mainAlgChanged{
    [self.casesTable reloadData];
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:2.0 animations:^{
        self.bannerTrailingConstraint.constant = 0;
    }];
}
@end
