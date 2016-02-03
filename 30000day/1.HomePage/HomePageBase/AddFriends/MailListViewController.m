//
//  MailListViewController.m
//  30000day
//
//  Created by wei on 16/2/2.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "MailListViewController.h"
#import <AddressBook/AddressBook.h>
#import "mailList.h"
#import "MailListTableViewCell.h"

@interface MailListViewController ()
@property (nonatomic,strong)NSMutableArray *mailListArray;
@property (weak, nonatomic) IBOutlet UITableView *mailListTable;

@property (weak, nonatomic) IBOutlet UITextField *searchText;
@property (weak, nonatomic) IBOutlet UIView *searchSuperView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@end

@implementation MailListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search.png"]];
    self.searchText.leftView = image;
    self.searchText.leftViewMode = UITextFieldViewModeUnlessEditing;
    
    [self.searchSuperView.layer setBorderWidth:1.0];
    [self.searchSuperView.layer setBorderColor:VIEWBORDERLINECOLOR.CGColor];
    
    self.mailListArray=[NSMutableArray array];
    [self loadPerson];
    
    [self.mailListTable setDelegate:self];
    [self.mailListTable setDataSource:self];
    
}

- (void)loadPerson{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error){
            
            CFErrorRef *error1 = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error1);
            [self copyAddressBook:addressBook];
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        [self copyAddressBook:addressBook];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新界面
            //[hud turnToError:@"没有获取通讯录权限"];
        });
    }
}

- (void)copyAddressBook:(ABAddressBookRef)addressBook{
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    for ( int i = 0; i < numberOfPeople; i++){
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++){
            //获取电话Label
            NSString * personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k));
            
            if ([personPhoneLabel isEqualToString:@"mobile"]) {
                //获取該Label下的电话值
                NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
                NSLog(@"%@",personPhone);
                NSString* name;
                mailList* ml=[[mailList alloc]init];
                if (firstName!=nil && lastName!=nil) {
                    name=[lastName stringByAppendingString:firstName];
                }
                
                if (firstName!=nil && lastName==nil) {
                    name=firstName;
                }
                
                if (firstName==nil && lastName!=nil) {
                    name=lastName;
                }
                
                ml.name=name;
                ml.mobilePhone=personPhone;
                
                [self.mailListArray addObject:ml];
                break;
            }
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.mailListArray.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID=@"MailListCell";
    MailListTableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"MailListTableViewCell" owner:nil options:nil]lastObject];
    }
    mailList* ml=self.mailListArray[indexPath.row];
    cell.textLabel.text=ml.name;
    
    [self createBtn:cell];
    return cell;
}

-(void)createBtn:(UITableViewCell *)cell{
    UIButton *invitationBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [invitationBtn setTitle:@"邀请" forState:UIControlStateNormal];
    [invitationBtn.titleLabel setTextColor:[UIColor whiteColor]];
    [invitationBtn setBackgroundColor:[UIColor colorWithRed:73.0/255 green:117.0/255 blue:188.0/255 alpha:1.0]];
    invitationBtn.layer.cornerRadius=6;
    invitationBtn.layer.masksToBounds=YES;
    [invitationBtn addTarget:self action:@selector(invitationBtnClick) forControlEvents:UIControlEventTouchUpInside];
    invitationBtn.translatesAutoresizingMaskIntoConstraints=NO;
    [cell addSubview:invitationBtn];
    
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[Healthybtn(61)]-15-|" options:0 metrics:nil views:@{@"Healthybtn":invitationBtn}]];
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[Healthybtn(30)]" options:0 metrics:nil views:@{@"Healthybtn":invitationBtn}]];
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:invitationBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

-(void)invitationBtnClick{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
