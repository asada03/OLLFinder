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
#import "CaseTableViewCell.h"
#import "CaseViewController.h"
#import "ImageButton.h"
#import "UICKeyChainStore.h"
#import "Firebase.h"

@interface ViewController ()
{
    FIRDatabaseReference *firebaseRootRef;

    NSString *version;
    NSArray *selectedCases;
    NSMutableArray *caseTypes;
    NSNumber *selectedCross;
    NSNumber *selectedCorners;
    NSString *selectedType;
    OLLCase *ollCase;
    BOOL isIpad;
    BOOL viewAppeared;
}
@property (strong, nonatomic) IBOutlet UITableView *casesTable;
@property (strong, nonatomic) IBOutlet UIImageView *largeImage;
@property (strong, nonatomic) IBOutlet UILabel *largeAlgorithmLabel;
@property (strong, nonatomic) IBOutletCollection(ImageButton) NSArray *crossButtons;
@property (strong, nonatomic) IBOutletCollection(ImageButton) NSArray *cornerButtons;
@property (strong, nonatomic) IBOutletCollection(ImageButton) NSArray *typeButtons;

@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsViewHeight;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    version = @"1.1";
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
    
    if (![[UICKeyChainStore stringForKey:@"version"] isEqualToString:version] &
        [[NSFileManager defaultManager] fileExistsAtPath:[url path]])
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
                     @[@"2_0",@"[F (R U R' U') F' ] [f (R U R' U') f']",@0],
                     @[@"3_0",@"[f (R U R' U') f'] U [F (R U R' U') F' ]",@0],
                     @[@"4_0",@"[f (R U R' U') f'] U' [F (R U R' U') F' ]",@0],
                     @[@"5_0",@"(R U R' U) (R' F R F') U2 (R' F R F')",@0],
                     @[@"6_0",@"[F (R U R' U) F'] y' U2 (R' F R F')",@0],
                     @[@"7_0",@"M U (R U R' U') M' (R' F R F') ",@0],
                     @[@"8_0",@"M U (R U R' U') M2 (U R U' r')",@0],
                     @[@"9_0",@"R' U2 R2 U R' U R U2 x' U' R' U",@0],
                     @[@"10_0",@"F (R U R' U') R F' (r U R' U') r'",@0],
                     @[@"11_0",@"f (R U R' U') (R U R' U') f'",@0],
                     @[@"12_0",@"(R U R' U) R d' R U' R' F'",@0],
                     @[@"13_0",@"(r U R' U) (R U' R' U) R U2' r'",@0],
                     @[@"14_0",@"l' U' L U' L' U L U' L' U2 l",@0],
                     @[@"15_0",@"(R' F R' F') R2 U2 y (R' F R F')",@0],
                     @[@"16_0",@"R' F R2 B' R2' F' R2 B R'",@0],
                     @[@"17_0",@"F (R U R' U') (R U R' U') F'",@0],
                     @[@"18_0",@"F' (L' U' L U) (L' U' L U) F",@0],
                     @[@"19_0",@"(r U R' U) R U2 r'",@0],
                     @[@"20_0",@"r' U' R U' R' U2 r",@0],
                     @[@"21_0",@"[F (R U R' U') F'] U [F (R U R' U') F' ]",@0],
                     @[@"22_0",@"[F' (L' U' L U) F] y [F (R U R' U') F']",@0],
                     @[@"23_0",@"(R U R' U') R' F R2 U R' U' F'",@0],
                     @[@"24_0",@"(R U R' U) (R' F R F') R U2 R'",@0],
                     @[@"25_0",@"r' U2 (R U R' U) r",@0],
                     @[@"26_0",@"r U2 R' U' R U' r'",@0],
                     @[@"27_0",@"F U R U' R2 F' R (U R U' R')",@0],
                     @[@"28_0",@"R' F R U R' F' R y' (R U' R')",@0],
                     @[@"29_0",@"(r U r') (R U R' U') (r U' r')",@0],
                     @[@"30_0",@"(l' U' l) (L' U' L U) (l' U l)",@0],
                     @[@"31_0",@"[(R U R' U) R U2 R'] [F (R U R' U') F']",@0],
                     @[@"32_0",@"(R' F R F') (R' F R F') (R U R' U') (R U R')",@0],
                     @[@"33_0",@"(R2 U R' B' R) U' (R2 U R B R')",@0],
                     @[@"34_0",@"(R U R' U') R U' R' F' U' F (R U R')",@0],
                     @[@"35_0",@"R U B' U' R' U R B R'",@0],
                     @[@"36_0",@"R' U' F U R U' R' F' R",@0],
                     @[@"37_0",@"F R U' R' U' R U R' F'",@0],
                     @[@"38_0",@"f (R U R' U') f'",@0],
                     @[@"39_0",@"f ' (L' U' L U) f",@0],
                     @[@"40_0",@"(R U2 R') (R' F R F') (R U2 R')",@0],
                     @[@"41_0",@"F (R U R' U') F'",@0],
                     @[@"42_0",@"(R U R' U') (R' F R F')",@0],
                     @[@"43_0",@"R B' R' U' R U B U' R' ",@0],
                     @[@"44_0",@"R' [F (R U R' U') F'] U R",@0],
                     @[@"45_0",@"(R U R2 U') (R' F) (R U) (R U') F'",@0],
                     @[@"46_0",@"R' U' (R' F R F') U R",@0],
                     @[@"47_0",@"(R U R' U) (R U' R' U') (R' F R F')",@0],
                     @[@"48_0",@"(L' U' L U') (L' U L U) (L F' L' F)",@0],
                     @[@"49_0",@"F (R U R' U') (R U R' U') (R U R' U') F'",@0],
                     @[@"50_0",@"[f (R U R' U') f'] [F (R U R' U') F']",@0],
                     @[@"51_0",@"R2 [D (R' U2) R] [D' (R' U2) R']",@0],
                     @[@"52_0",@"(r U R' U') (r' F R F')",@0],
                     @[@"53_0",@"F' (r U R' U') (r' F R )",@0],
                     @[@"54_0",@"R U2 R' U' R U' R'",@0],
                     @[@"55_0",@"(R U R' U) R U2 R'",@0],
                     @[@"56_0",@"M' U M U2 M' U M",@0],
                     @[@"57_0",@"(R U R' U') M' (U R U' r')",@0]];
    
OLLCase *oll;
Algorithm *alg;


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
                alg = [NSEntityDescription insertNewObjectForEntityForName:@"Algorithm" inManagedObjectContext:self.managedObjectContext];
                
                alg.ollCase = oll;
                alg.uid = algUid;
                alg.algorithm = algData[1];
                alg.rotations = algData[2];
                
                if (!oll.main)
                    oll.main = alg;
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

- (void)setLargeImageTo:(int)num
{
    
    if ([selectedCases count] > num)
    {
        ollCase = selectedCases[num];
        self.largeImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"oll%@.png", ollCase.uid]];
        self.largeAlgorithmLabel.text = ollCase.main.algorithm;
        self.largeAlgorithmLabel.adjustsFontSizeToFitWidth = YES;
        
        CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, .5 * M_PI * [ollCase.main.rotations integerValue]);
        self.largeAlgorithmLabel.transform = transform;
    }
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
    selectedCases = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    [self setLargeImageTo:0];
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
    selectedCases = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    self.buttonsViewHeight.constant = 134;

    [self setLargeImageTo:0];
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
        selectedCases = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        caseTypes = [[NSMutableArray alloc] init];
        
        for (OLLCase *oll in selectedCases)
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
        
        [self setLargeImageTo:0];
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
    selectedCases = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    caseTypes = [[NSMutableArray alloc] init];
    
    [self setLargeImageTo:0];
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

    return [selectedCases count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CaseCell"];
    OLLCase *oll = selectedCases[indexPath.row];
    
    cell.caseImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"oll%@.png", oll.uid]];
    cell.caseImage.contentMode = UIViewContentModeScaleAspectFit;
    cell.algorithmLabel.text = oll.main.algorithm;
    cell.algorithmLabel.adjustsFontSizeToFitWidth = YES;
    cell.algNumLabel.text = oll.uid;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setLargeImageTo:(int)indexPath.row];
    
    if (!isIpad)
        [self performSegueWithIdentifier:@"toLargeImege" sender:self];

}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toLargeImege"])
    {
        CaseViewController *caseView = segue.destinationViewController;
        caseView.ollCase = ollCase;
    }
}


@end
