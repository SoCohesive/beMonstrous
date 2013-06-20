//
//  ProjectListViewController.m
//  MonsterAPP_Storyboard_Wireframes
//
//  Created by Erin Hochstatter on 6/11/13.
//  Copyright (c) 2013 Sonam Dhingra. All rights reserved.
//

#import "ProjectListViewController.h"
#import "AppDelegate.h"
#import "CreateNewProjectCell.h"
#import "ExistingProjectCell.h"
#import "CompletedProjectsCell.h"
#import "ProjectPickerVC.h"
#import "TaskDetail.h"
#import "TaskListViewController.h"

@interface ProjectListViewController ()

{
    NSMutableArray              *projectsBySection;
    NSMutableArray              *existingTasksArray;
    
   
}

@property (strong, nonatomic) NSFetchedResultsController  *taskResultsController;
@property (strong, nonatomic) NSString *thumbPath;

@end

@implementation ProjectListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    //do an array where we have random greetings, random between name/nickname
    NSString *welcome = [NSString stringWithFormat:@"Welcome back, %@", self.currentUser.firstName];
    UIFont *lunchBoxBold = [UIFont fontWithName:@"LunchBox-Light" size:self.welcomeLabel.font.pointSize];
    self.welcomeLabel.font = lunchBoxBold;
    self.welcomeLabel.text = welcome;
    
    NSString *firstCellString = @"Create a New Project.";
    projectsBySection = [[NSMutableArray alloc] initWithObjects: [NSArray arrayWithObject: firstCellString], [NSMutableArray array], [NSMutableArray array], nil];

    [self setupTasksFetchController];
    
    NSLog(@"the existing tasks in project list have these steps %@",self.existingTask.taskDetails);
    

    [self.projectsTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma
#pragma CoreData


-(void)setupTasksFetchController
{
    NSManagedObjectContext *managedObjectContext = ((AppDelegate *)([UIApplication sharedApplication].delegate)).managedObjectContext;
    
    NSFetchRequest *taskFetchRequest = [[NSFetchRequest alloc] init];
    
//    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"user = %@", self.currentUser];  user.tasks?
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext];
    [taskFetchRequest setEntity:entity];
  //  [taskFetchRequest setPredicate:userPredicate];
    
//once Tasks save taskDetails, switch name to taskDetails
    taskFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"taskName" ascending:NO]];
    
    self.taskResultsController = [[NSFetchedResultsController alloc]
                                    initWithFetchRequest:taskFetchRequest
                                    managedObjectContext:managedObjectContext
                                    sectionNameKeyPath:@"taskComplete" //taskComplete
                                    cacheName:@"nil"];
   
    NSError *error;
    BOOL success = [self.taskResultsController performFetch:&error];
    if (!success) {
        NSLog(@"Task Fetch Error: %@", error.description);
    }

    
}




#pragma
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.staticesqueTable) {
        
        return 1;
        
    } else {
   
        return [[self.taskResultsController sections] count];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.staticesqueTable) {
        
        return 1;
        
    } else {

    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.taskResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
static NSString *cellID1 = @"newProjectCell";
static NSString *cellID2 = @"existingProjectCell";
static NSString *cellID3 = @"completedProjectCell";

CreateNewProjectCell *newProjectCell =[[CreateNewProjectCell alloc] init];
ExistingProjectCell *existingProjectCell =[[ExistingProjectCell alloc] init];
CompletedProjectsCell *completedProjectCell =[[CompletedProjectsCell alloc] init];

    if (tableView == self.staticesqueTable) {
        
    
        newProjectCell = [tableView dequeueReusableCellWithIdentifier:cellID1];
        newProjectCell.createLabel.text = [projectsBySection[0] objectAtIndex:indexPath.row];
        
        return newProjectCell;
        
    } else {
    
    if ([[self.taskResultsController sections] objectAtIndex:0]) {
        //confirm that this will always be completedTasks, should I use key?    
        existingProjectCell = [tableView dequeueReusableCellWithIdentifier:cellID2 forIndexPath:indexPath];
        
        self.existingTask = [self.taskResultsController objectAtIndexPath:indexPath];
        existingProjectCell.existingTitle.text = self.existingTask.taskName;
        existingProjectCell.subtitle.text = self.existingTask.taskType;
    
        
        NSSet *evolutions = [self.existingTask.monster evolutions];
        NSSortDescriptor *sortByEvoComplete = [[NSSortDescriptor alloc] initWithKey:@"currentEvolution"
            ascending:NO];
        
        NSArray *sortedEvolutions = [evolutions sortedArrayUsingDescriptors: [NSArray arrayWithObject:sortByEvoComplete]];
        
        self.thumbPath = ((Evolution*)sortedEvolutions[0]).thumbnailName;
        NSLog(@"evolution marked as current %@", ((Evolution*)sortedEvolutions[0]).evolutionDescription);
        NSLog(@"thumbPath: %@", self.thumbPath);
        
        UIImage *cellThumb = [UIImage imageNamed:self.thumbPath];
        existingProjectCell.monsterProfilePic.image = cellThumb;
        
        NSString *dateString =  [[NSString alloc] initWithFormat:@"%@", [self.existingTask.projectedEndDate descriptionWithLocale:[NSLocale currentLocale]]];
        existingProjectCell.deadlineReminderLabel.text = dateString;
                
        return existingProjectCell;
        
    } else {
        completedProjectCell = [tableView dequeueReusableCellWithIdentifier:cellID3 forIndexPath:indexPath];
        
        Task *completedTask = [self.taskResultsController objectAtIndexPath:indexPath];
        completedProjectCell.completedTitle.text = completedTask.taskName;
        completedProjectCell.completedSubtitle.text = completedTask.taskType;
        
        NSString *dateString =  [[NSString alloc] initWithFormat:@"%@", [completedTask.projectedEndDate descriptionWithLocale:[NSLocale currentLocale]]];
        completedProjectCell.completedLabel.text = dateString;
        
        return completedProjectCell;

    }
   
    }
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)
indexPath
{
    if (tableView == self.staticesqueTable) {
        
        [self.staticesqueTable deselectRowAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"segueToCreateProject" sender:self];
        
    } else {
        
        
        [self.projectsTableView deselectRowAtIndexPath:indexPath animated:YES];
       
        self.tappedTask= [self.taskResultsController objectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"segueToExistingTaskDetail" sender:self];
        
    }

}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
if ([segue.identifier isEqualToString:@"segueToExistingTaskDetail"]) {
    

    ((TaskListViewController *)segue.destinationViewController).selectedTask = self.tappedTask;
    }
    
if ([segue.identifier isEqualToString:@"segueToCreateProject"]) {
    ((ProjectPickerVC*)(segue.destinationViewController)).projPickerCurrentUser = self.currentUser;
    NSLog(@"making new project");
    }
    
}



@end
