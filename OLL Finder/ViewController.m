//
//  ViewController.m
//  OLL Finder
//
//  Created by Vortex on 28/02/15.
//  Copyright (c) 2015 Andres Sada Govela. All rights reserved.
//

#import "ViewController.h"
#import "OLLCase+CoreDataProperties.h"
#import "CaseTableViewCell.h"
#import "CaseViewController.h"
#import "ImageButton.h"


@interface ViewController ()
{
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
    
    if (!self.managedObjectContext)
        [self useModelDocument];
    
    isIpad = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad );
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!viewAppeared)
    {
        for (ImageButton *button in self.cornerButtons)
            [button imageDisabled];
        
        viewAppeared = YES;
    }
    self.buttonsViewHeight.constant = 72;
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
}

- (void)populate
{
    OLLCase *oll;
    NSArray *ollInfo = @[@[@"1",@"(R U2 R') (R' F R F') U2 (R' F R F')",@0,@0,@""],
                               @[@"2",@"[F (R U R' U') F' ] [f (R U R' U') f']",@0,@0,@""],
                               @[@"3",@"[f (R U R' U') f'] U [F (R U R' U') F' ]",@0,@1,@""],
                               @[@"4",@"[f (R U R' U') f'] U' [F (R U R' U') F' ]",@0,@1,@""],
                               @[@"5",@"(R U R' U) (R' F R F') U2 (R' F R F')",@0,@3,@""],
                               @[@"6",@"[F (R U R' U) F'] y' U2 (R' F R F')",@0,@2,@""],
                               @[@"7",@"M U (R U R' U') M' (R' F R F') ",@0,@2,@""],
                               @[@"8",@"M U (R U R' U') M2 (U R U' r')",@0,@4,@""],
                               @[@"9",@"R' U2 R2 U R' U R U2 x' U' R' U",@1,@0,@""],
                               @[@"10",@"F (R U R' U') R F' (r U R' U') r'",@1,@0,@""],
                               @[@"11",@"f (R U R' U') (R U R' U') f'",@1,@0,@""],
                               @[@"12",@"(R U R' U) R d' R U' R' F'",@1,@0,@""],
                               @[@"13",@"(r U R' U) (R U' R' U) R U2' r'",@2,@0,@""],
                               @[@"14",@"l' U' L U' L' U L U' L' U2 l",@2,@0,@""],
                               @[@"15",@"(R' F R' F') R2 U2 y (R' F R F')",@2,@0,@""],
                               @[@"16",@"R' F R2 B' R2' F' R2 B R'",@2,@0,@""],
                               @[@"17",@"F (R U R' U') (R U R' U') F'",@2,@0,@""],
                               @[@"18",@"F' (L' U' L U) (L' U' L U) F",@2,@0,@""],
                               @[@"19",@"(r U R' U) R U2 r'",@2,@1,@"S"],
                               @[@"20",@"r' U' R U' R' U2 r",@2,@1,@"S"],
                               @[@"21",@"[F (R U R' U') F'] U [F (R U R' U') F' ]",@2,@1,@"S"],
                               @[@"22",@"[F' (L' U' L U) F] y [F (R U R' U') F']",@2,@1,@"S"],
                               @[@"23",@"(R U R' U') R' F R2 U R' U' F'",@2,@1,@"F"],
                               @[@"24",@"(R U R' U) (R' F R F') R U2 R'",@2,@1,@"F"],
                               @[@"25",@"r' U2 (R U R' U) r",@2,@1,@"O"],
                               @[@"26",@"r U2 R' U' R U' r'",@2,@1,@"O"],
                               @[@"27",@"F U R U' R2 F' R (U R U' R')",@1,@1,@""],
                               @[@"28",@"R' F R U R' F' R y' (R U' R')",@1,@1,@""],
                               @[@"29",@"(r U r') (R U R' U') (r U' r')",@1,@1,@""],
                               @[@"30",@"(l' U' l) (L' U' L U) (l' U l)",@1,@1,@""],
                               @[@"31",@"[(R U R' U) R U2 R'] [F (R U R' U') F']",@2,@2,@"Y"],
                               @[@"32",@"(R' F R F') (R' F R F') (R U R' U') (R U R')",@2,@2,@"Y"],
                               @[@"33",@"(R2 U R' B' R) U' (R2 U R B R')",@2,@2,@"Y"],
                               @[@"34",@"(R U R' U') R U' R' F' U' F (R U R')",@2,@2,@"Y"],
                               @[@"35",@"R U B' U' R' U R B R'",@2,@2,@"P"],
                               @[@"36",@"R' U' F U R U' R' F' R",@2,@2,@"P"],
                               @[@"37",@"F R U' R' U' R U R' F'",@2,@3,@"Q"],
                               @[@"38",@"f (R U R' U') f'",@2,@2,@"P"],
                               @[@"39",@"f ' (L' U' L U) f",@2,@2,@"P"],
                               @[@"40",@"(R U2 R') (R' F R F') (R U2 R')",@2,@03,@"Q"],
                               @[@"41",@"F (R U R' U') F'",@01,@2,@"T"],
                               @[@"42",@"(R U R' U') (R' F R F')",@1,@2,@"T"],
                               @[@"43",@"R B' R' U' R U B U' R' ",@1,@03,@""],
                               @[@"44",@"R' [F (R U R' U') F'] U R",@1,@3,@""],
                               @[@"45",@"(R U R2 U') (R' F) (R U) (R U') F'",@1,@2,@"C"],
                               @[@"46",@"R' U' (R' F R F') U R",@1,@2,@"C"],
                               @[@"47",@"(R U R' U) (R U' R' U') (R' F R F')",@2,@3,@"M"],
                               @[@"48",@"(L' U' L U') (L' U L U) (L F' L' F)",@2,@3,@"M"],
                               @[@"49",@"F (R U R' U') (R U R' U') (R U R' U') F'",@3,@0,@""],
                               @[@"50",@"[f (R U R' U') f'] [F (R U R' U') F']",@3,@0,@""],
                               @[@"51",@"R2 [D (R' U2) R] [D' (R' U2) R']",@3,@2,@""],
                               @[@"52",@"(r U R' U') (r' F R F')",@3,@2,@""],
                               @[@"53",@"F' (r U R' U') (r' F R )",@3,@3,@""],
                               @[@"54",@"R U2 R' U' R U' R'",@3,@1,@""],
                               @[@"55",@"(R U R' U) R U2 R'",@3,@1,@""],
                               @[@"56",@"M' U M U2 M' U M",@2,@4,@""],
                               @[@"57",@"(R U R' U') M' (U R U' r')",@1,@4,@""]];

    
    for (NSArray *ollData in ollInfo)
    {
        oll = [NSEntityDescription insertNewObjectForEntityForName:@"OLLCase" inManagedObjectContext:self.managedObjectContext];
        
        oll.file_name = ollData[0];
        oll.algorithm = ollData[1];
        oll.cross_type = ollData[2];
        oll.corners = ollData[3];
        oll.type = ollData[4];
        oll.rotations = [NSNumber numberWithInteger:0];
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
        self.largeImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"oll%@.png", ollCase.file_name]];
        self.largeAlgorithmLabel.text = ollCase.algorithm;
        self.largeAlgorithmLabel.adjustsFontSizeToFitWidth = YES;
    }
}

- (void)chooseAll
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"OLLCase"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"file_name" ascending:YES]];
    
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
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"file_name" ascending:YES]];
    
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
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"file_name" ascending:YES]];
        
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
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"file_name" ascending:YES]];
    
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
    
    cell.caseImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"oll%@.png", oll.file_name]];
    cell.caseImage.contentMode = UIViewContentModeScaleAspectFit;
    cell.algorithmLabel.text = oll.algorithm;
    cell.algorithmLabel.adjustsFontSizeToFitWidth = YES;
    cell.algNumLabel.text = oll.file_name;
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
