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
#import "CaseViewController.h"
#import "ImageButton.h"
#import "UICKeyChainStore.h"
#import "Firebase.h"

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
}
@property (strong, nonatomic) IBOutlet UITableView *casesTable;
@property (strong, nonatomic) IBOutletCollection(ImageButton) NSArray *crossButtons;
@property (strong, nonatomic) IBOutletCollection(ImageButton) NSArray *cornerButtons;
@property (strong, nonatomic) IBOutletCollection(ImageButton) NSArray *typeButtons;

@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsViewHeight;

@property (strong, nonatomic) NSArray *selectedCases;

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
    
    version = @"1.10";
    if (!self.managedObjectContext)
        [self useModelDocument];
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    firebaseRootRef = [[FIRDatabase database] reference];

    if (!viewAppeared)
    {
        for (ImageButton *button in self.crossButtons)
            [button imageNormal];

        for (ImageButton *button in self.cornerButtons)
            [button imageDisabled];
        
        viewAppeared = YES;

        self.buttonsViewHeight.constant = 72;
    }
    
    [self.casesTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)useModelDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Cases Data"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    #warning Remember to fix this.
    if (YES)
//        ![[UICKeyChainStore stringForKey:@"version"] isEqualToString:version] &
//        [[NSFileManager defaultManager] fileExistsAtPath:[url path]])
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
     @[@"12_1",@"(R U R' U) R d' R U' R' F'",@0],
     @[@"13_0",@"(r U2) (R' U' R U) (R' U' R U') r'",@-1],
     @[@"13_1",@"(r U R' U) (R U' R' U) R U2' r'",@0],
     @[@"14_0",@"(l' U' L U') (L' U L U') (L' U2 l)",@0],
     @[@"15_0",@"(r U') (r2 U r2 U) (r2 U' r)",@0],
     @[@"15_1",@"(R' F R' F') R2 U2 y (R' F R F')",@0],
     @[@"16_0",@"(R' F) (R2 B' R2' F') (R2 B R')",@0],
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
     @[@"28_0",@"(R' F) (R U R' F' R) (F U' F')",@0],
     @[@"28_1",@"(R' F) (R U R' F' R) y' (R U' R')",@0],
     @[@"29_0",@"(r U r') (R U R' U') (r U' r')",@0],
     @[@"30_0",@"(l' U' l) (L' U' L U) (l' U l)",@0],
     @[@"31_0",@"[(R U R' U) R U2 R'] [F (R U R' U') F']",@0],
     @[@"32_0",@"(R' U' R U' R' U2 R) (F R U R' U' F')",@-1],
     @[@"32_1",@"(R' F R F') (R' F R F') (R U R' U') (R U R')",@0],
     @[@"33_0",@"(F R' F) (R2 U' R' U') (R U R') F2",@2],
     @[@"33_1",@"(R2 U R' B' R) U' (R2 U R B R')",@0],
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
     @[@"57_0",@"(R U R' U') (M' U R U') r'",@0]];
    
NSArray *ollVids =@[@[@"55_0",@"UberCuber",@0, @39, @6, @"Qr1ETRAQPKI"],
                    @[@"54_0",@"UberCuber",@0, @48, @6.7, @"Qr1ETRAQPKI"],
                    @[@"52_0_",@"UberCuber",@0, @55, @7.7, @"Qr1ETRAQPKI"],
                    @[@"51_0",@"UberCuber",@1, @4, @9.9, @"Qr1ETRAQPKI"],
                    @[@"53_0",@"UberCuber",@1, @15, @7, @"Qr1ETRAQPKI"],
                    @[@"50_0",@"UberCuber",@1, @23, @10.2, @"Qr1ETRAQPKI"],
                    @[@"49_0",@"UberCuber",@1, @37, @8.1, @"Qr1ETRAQPKI"],
                    @[@"1_0",@"UberCuber",@1, @53, @8.4, @"Qr1ETRAQPKI"],
                    @[@"2_0",@"UberCuber",@2, @4, @9.9, @"Qr1ETRAQPKI"],
                    @[@"4_0",@"UberCuber",@2, @16, @10.6, @"Qr1ETRAQPKI"],
                    @[@"3_0",@"UberCuber",@2, @27, @11.7, @"Qr1ETRAQPKI"],
                    @[@"5_0",@"UberCuber",@2, @40, @8.3, @"Qr1ETRAQPKI"],
                    @[@"6_0",@"UberCuber",@2, @50, @11.1, @"Qr1ETRAQPKI"],
                    @[@"7_0",@"UberCuber",@3, @2, @11.6, @"Qr1ETRAQPKI"],
                    @[@"8_0",@"UberCuber",@3, @20, @10.1, @"Qr1ETRAQPKI"],
                    @[@"8_1",@"UberCuber",@3, @31, @9.8, @"Qr1ETRAQPKI"],
                    @[@"36_0",@"UberCuber",@3, @44, @9, @"Qr1ETRAQPKI"],
                    @[@"35_0",@"UberCuber",@3, @56, @9.5, @"Qr1ETRAQPKI"],
                    @[@"38_0",@"UberCuber",@4, @6, @8, @"Qr1ETRAQPKI"],
                    @[@"39_0",@"UberCuber",@4, @15, @4.8, @"Qr1ETRAQPKI"],
                    @[@"48_0",@"UberCuber",@4, @25, @10, @"Qr1ETRAQPKI"],
                    @[@"47_0",@"UberCuber",@4, @37, @7.6, @"Qr1ETRAQPKI"],
                    @[@"18_0",@"UberCuber",@4, @50, @5.7, @"Qr1ETRAQPKI"],
                    @[@"17_0",@"UberCuber",@4, @56, @6.1, @"Qr1ETRAQPKI"],
                    @[@"15_0",@"UberCuber",@5, @3, @6.4, @"Qr1ETRAQPKI"],
                    @[@"16_0",@"UberCuber",@5, @10, @6, @"Qr1ETRAQPKI"],
                    @[@"14_0",@"UberCuber",@5, @17, @6.9, @"Qr1ETRAQPKI"],
                    @[@"13_0",@"UberCuber",@5, @26, @7.4, @"Qr1ETRAQPKI"],
                    @[@"46_0",@"UberCuber",@5, @38, @5.2, @"Qr1ETRAQPKI"],
                    @[@"45_0",@"UberCuber",@5, @45, @7.3, @"Qr1ETRAQPKI"],
                    @[@"41_0",@"UberCuber",@5, @58, @6.2, @"Qr1ETRAQPKI"],
                    @[@"42_0",@"UberCuber",@6, @5, @6.5, @"Qr1ETRAQPKI"],
                    @[@"11_0",@"UberCuber",@6, @17, @5.4, @"Qr1ETRAQPKI"],
                    @[@"12_0",@"UberCuber",@6, @25, @6.7, @"Qr1ETRAQPKI"],
                    @[@"9_0",@"UberCuber",@6, @34, @7.4, @"Qr1ETRAQPKI"],
                    @[@"10_0",@"UberCuber",@6, @42, @6.5, @"Qr1ETRAQPKI"],
                    @[@"25_0",@"UberCuber",@6, @55, @7.9, @"Qr1ETRAQPKI"],
                    @[@"26_0",@"UberCuber",@7, @4, @7.9, @"Qr1ETRAQPKI"],
                    @[@"43_0",@"UberCuber",@7, @16, @5.9, @"Qr1ETRAQPKI"],
                    @[@"44_0",@"UberCuber",@7, @23, @5.9, @"Qr1ETRAQPKI"],
                    @[@"19_0",@"UberCuber",@7, @34, @7.22, @"Qr1ETRAQPKI"],
                    @[@"20_0",@"UberCuber",@7, @42, @6.24, @"Qr1ETRAQPKI"],
                    @[@"22_0",@"UberCuber",@7, @49, @10.1, @"Qr1ETRAQPKI"],
                    @[@"21_0",@"UberCuber",@8, @1, @8.7, @"Qr1ETRAQPKI"],
                    @[@"23_0",@"UberCuber",@8, @14, @9.1, @"Qr1ETRAQPKI"],
                    @[@"24_0",@"UberCuber",@8, @24, @9, @"Qr1ETRAQPKI"],
                    @[@"40_0",@"UberCuber",@8, @33, @8.5, @"Qr1ETRAQPKI"],
                    @[@"37_0",@"UberCuber",@8, @42, @6.7, @"Qr1ETRAQPKI"],
                    @[@"27_0",@"UberCuber",@8, @53, @9.9, @"Qr1ETRAQPKI"],
                    @[@"28_0",@"UberCuber",@9, @4, @3.8, @"Qr1ETRAQPKI"],
                    @[@"30_0",@"UberCuber",@9, @9, @6.7, @"Qr1ETRAQPKI"],
                    @[@"29_0",@"UberCuber",@9, @19, @6.9, @"Qr1ETRAQPKI"],
                    @[@"34_0",@"UberCuber",@9, @30, @8.9, @"Qr1ETRAQPKI"],
                    @[@"33_0",@"UberCuber",@9, @39, @6.4, @"Qr1ETRAQPKI"],
                    @[@"31_0",@"UberCuber",@9, @46, @7.9, @"Qr1ETRAQPKI"],
                    @[@"32_0",@"UberCuber",@9, @55, @6.9, @"Qr1ETRAQPKI"],
                    @[@"56_0",@"UberCuber",@10, @5, @6.9, @"Qr1ETRAQPKI"],
                    @[@"57_0",@"UberCuber",@10, @13, @5.5, @"Qr1ETRAQPKI"],
                    @[@"54_0",@"Feliks Zemdegs",@0, @9, @9.3, @"IasVqtCHoj0"],
                    @[@"55_0",@"Feliks Zemdegs",@0, @20, @7.4, @"IasVqtCHoj0"],
                    @[@"49_0",@"Feliks Zemdegs",@0, @28, @11.6, @"IasVqtCHoj0"],
                    @[@"50_0",@"Feliks Zemdegs",@0, @41, @10.5, @"IasVqtCHoj0"],
                    @[@"52_0",@"Feliks Zemdegs",@0, @52, @6.1, @"IasVqtCHoj0"],
                    @[@"53_0",@"Feliks Zemdegs",@0, @59, @8.1, @"IasVqtCHoj0"],
                    @[@"51_0",@"Feliks Zemdegs",@1, @9, @14.7, @"IasVqtCHoj0"],
                    @[@"_0",@"Feliks Zemdegs",@1, @39, @6.5, @"IasVqtCHoj0"]];
    
    
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
                    NSLog(@"%@ @%@, ");
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
                        
                        float minutes = [vidData[2] floatValue];
                        float seconds = [vidData[3] floatValue];
                        vid.start = [NSNumber numberWithFloat:minutes*60 + seconds];
                        vid.duration = vidData[4];
                        vid.vidId = vidData[5];
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
    
    [self chooseCross];
    [self cleanTypes];
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

    if (isIpad)
        caseView.ollCase = ollCase;
    else
        [self performSegueWithIdentifier:@"toLargeImege" sender:self];

}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toLargeImege"])
    {
        caseView = segue.destinationViewController;
        caseView.ollCase = ollCase;
    }
}


@end
