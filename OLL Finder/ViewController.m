//
//  ViewController.m
//  OLL Finder
//
//  Created by Vortex on 28/02/15.
//  Copyright (c) 2015 Andres Sada Govela. All rights reserved.
//

#import "ViewController.h"
#import "OLLCase.h"
#import "CaseTableViewCell.h"


@interface ViewController ()
{
    NSArray *selectedCases;
    NSNumber *selectedCross;
    NSNumber *selectedCorners;
}
@property (strong, nonatomic) IBOutlet UITableView *casesTable;
@property (strong, nonatomic) IBOutlet UIImageView *largeImage;
@property (strong, nonatomic) IBOutlet UILabel *largeAlgorithmLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cornerButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *crossButtons;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (!self.managedObjectContext)
        [self useModelDocument];

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
    OLLCase *ollCase;
    NSArray *ollInfo = @[@[@"oll1.png",@"(R U2 R') (R' F R F') U2 (R' F R F')",@0,@0],
                               @[@"oll2.png",@"[F (R U R' U') F' ] [f (R U R' U') f']",@0,@0],
                               @[@"oll3.png",@"[f (R U R' U') f'] U [F (R U R' U') F' ]",@0,@1],
                               @[@"oll4.png",@"[f (R U R' U') f'] U' [F (R U R' U') F' ]",@0,@1],
                               @[@"oll5.png",@"(R U R' U) (R' F R F') U2 (R' F R F')",@0,@3],
                               @[@"oll6.png",@"[F (R U R' U) F'] y' U2 (R' F R F')",@0,@2],
                               @[@"oll7.png",@"M U (R U R' U') M' (R' F R F') ",@0,@2],
                               @[@"oll8.png",@"M U (R U R' U') M2 (U R U' r')",@0,@4],
                               @[@"oll9.png",@"R' U2 R2 U R' U R U2 x' U' R' U",@1,@0],
                               @[@"oll10.png",@"F (R U R' U') R F' (r U R' U') r'",@1,@0],
                               @[@"oll11.png",@"f (R U R' U') (R U R' U') f'",@1,@0],
                               @[@"oll12.png",@"(R U R' U) R d' R U' R' F'",@1,@0],
                               @[@"oll13.png",@"(r U R' U) (R U' R' U) R U2' r'",@2,@0],
                               @[@"oll14.png",@"l' U' L U' L' U L U' L' U2 l",@2,@0],
                               @[@"oll15.png",@"(R' F R' F') R2 U2 y (R' F R F')",@2,@0],
                               @[@"oll16.png",@"R' F R2 B' R2' F' R2 B R'",@2,@0],
                               @[@"oll17.png",@"F (R U R' U') (R U R' U') F'",@2,@0],
                               @[@"oll18.png",@"F' (L' U' L U) (L' U' L U) F",@2,@0],
                               @[@"oll19.png",@"(r U R' U) R U2 r'",@2,@1],
                               @[@"oll20.png",@"r' U' R U' R' U2 r",@2,@1],
                               @[@"oll21.png",@"[F (R U R' U') F'] U [F (R U R' U') F' ]",@2,@1],
                               @[@"oll22.png",@"[F' (L' U' L U) F] y [F (R U R' U') F']",@2,@1],
                               @[@"oll23.png",@"(R U R' U') R' F R2 U R' U' F'",@2,@1],
                               @[@"oll24.png",@"(R U R' U) (R' F R F') R U2 R'",@2,@1],
                               @[@"oll25.png",@"r' U2 (R U R' U) r",@2,@1],
                               @[@"oll26.png",@"r U2 R' U' R U' r'",@2,@1],
                               @[@"oll27.png",@"F U R U' R2 F' R (U R U' R')",@1,@1],
                               @[@"oll28.png",@"R' F R U R' F' R y' (R U' R')",@1,@1],
                               @[@"oll29.png",@"(r U r') (R U R' U') (r U' r')",@1,@1],
                               @[@"oll30.png",@"(l' U' l) (L' U' L U) (l' U l)",@1,@1],
                               @[@"oll31.png",@"[(R U R' U) R U2 R'] [F (R U R' U') F']",@2,@2],
                               @[@"oll32.png",@"(R' F R F') (R' F R F') (R U R' U') (R U R')",@2,@2],
                               @[@"oll33.png",@"(R2 U R' B' R) U' (R2 U R B R')",@2,@2],
                               @[@"oll34.png",@"(R U R' U') R U' R' F' U' F (R U R')",@2,@2],
                               @[@"oll35.png",@"R U B' U' R' U R B R'",@2,@2],
                               @[@"oll36.png",@"R' U' F U R U' R' F' R",@2,@2],
                               @[@"oll37.png",@"F R U' R' U' R U R' F'",@2,@3],
                               @[@"oll38.png",@"f (R U R' U') f'",@2,@2],
                               @[@"oll39.png",@"f ' (L' U' L U) f",@2,@2],
                               @[@"oll40.png",@"(R U2 R') (R' F R F') (R U2 R')",@2,@03],
                               @[@"oll41.png",@"F (R U R' U') F'",@01,@2],
                               @[@"oll42.png",@"(R U R' U') (R' F R F')",@1,@2],
                               @[@"oll43.png",@"R B' R' U' R U B U' R' ",@1,@03],
                               @[@"oll44.png",@"R' [F (R U R' U') F'] U R",@1,@3],
                               @[@"oll45.png",@"(R U R2 U') (R' F) (R U) (R U') F'",@1,@2],
                               @[@"oll46.png",@"R' U' (R' F R F') U R",@1,@2],
                               @[@"oll47.png",@"(R U R' U) (R U' R' U') (R' F R F')",@2,@3],
                               @[@"oll48.png",@"(L' U' L U') (L' U L U) (L F' L' F)",@2,@3],
                               @[@"oll49.png",@"algorithm",@3,@0],
                               @[@"oll50.png",@"algorithm",@3,@0],
                               @[@"oll51.png",@"algorithm",@3,@2],
                               @[@"oll52.png",@"algorithm",@3,@2],
                               @[@"oll53.png",@"algorithm",@3,@3],
                               @[@"oll54.png",@"algorithm",@3,@1],
                               @[@"oll55.png",@"algorithm",@3,@1],
                               @[@"oll56.png",@"M' U M U2 M' U M",@2,@4],
                               @[@"oll57.png",@"(R U R' U') M' (U R U' r')",@1,@4]];

    
    for (NSArray *ollData in ollInfo)
    {
        ollCase = [NSEntityDescription insertNewObjectForEntityForName:@"OLLCase" inManagedObjectContext:self.managedObjectContext];
        
        ollCase.file_name = ollData[0];
        ollCase.algorithm = ollData[1];
        ollCase.cross_type = ollData[2];
        ollCase.corners = ollData[3];
        ollCase.rotations = [NSNumber numberWithInteger:0];
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
        OLLCase *ollCase = selectedCases[num];
        self.largeImage.image = [UIImage imageNamed:ollCase.file_name];
        self.largeAlgorithmLabel.text = ollCase.algorithm;

    }
}

- (void)chooseAll
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"OLLCase"];
    //    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date_scanned" ascending:YES]];
    
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
    
    [self setLargeImageTo:0];
    [self.casesTable reloadData];
}

#pragma mark - button actions
- (IBAction)crossAction:(UIButton *)sender
{
    selectedCross = [NSNumber numberWithInteger:sender.tag];
    
    for (UIButton *button in self.crossButtons)
    {
        if (button.tag == sender.tag)
            button.alpha = 1;
        else
            button.alpha = .4;
    }
    for (UIButton *button in self.cornerButtons)
    {
        button.alpha = 1;
    }
    
    [self chooseCross];
}

- (IBAction)cornerAction:(UIButton *)sender
{
    selectedCorners = [NSNumber numberWithInteger:sender.tag];

    for (UIButton *button in self.cornerButtons)
    {
        if (button.tag == sender.tag)
            button.alpha = 1;
        else
            button.alpha = .5;
    }

    [self chooseCorners];
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
    OLLCase *ollCase = selectedCases[indexPath.row];
    
    cell.caseImage.image = [UIImage imageNamed:ollCase.file_name];
    cell.caseImage.contentMode = UIViewContentModeScaleAspectFit;
    cell.algorithmLabel.text = ollCase.algorithm;
    cell.algorithmLabel.adjustsFontSizeToFitWidth = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setLargeImageTo:(int)indexPath.row];

}



//prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"asg"])
//    {
//    }
//}


@end
