//
//  ViewController.m
//  RxAddressBook
//
//  Created by RXL on 17/3/13.
//  Copyright © 2017年 RXL. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
#import "personModel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *redBtn;

@property (nonatomic, strong) NSMutableArray *phoneArr;

@property (nonatomic, strong) NSMutableArray *initialList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (IBAction)redbtnclick:(id)sender {

    [self loadPerson];
    
    
    
    
}


-(void)sectionAllData{
    
    NSMutableArray * tmpArray = [[NSMutableArray alloc]init];
    for (NSInteger i =0; i <27; i++) {
        //给临时数组创建27个数组作为元素，用来存放A-Z和#开头的联系人
        NSMutableArray * array = [[NSMutableArray alloc]init];
        [tmpArray addObject:array];
    }
    
    for (personModel * model in self.phoneArr) {
        //AddressMode是联系人的数据模型
        //转化为首拼音并取首字母
        model.initial = [self returnFirstWordWithString:model.name];
        
        
        int firstWord = [model.initial characterAtIndex:0];
        
        //把字典放到对应的数组中去
        
        if (firstWord >= 65 && firstWord <= 90) {
            //如果首字母是A-Z，直接放到对应数组
            NSMutableArray * array = tmpArray[firstWord - 65];
            [array addObject:model];
            
        }else{
            //如果不是，就放到最后一个代表#的数组
            NSMutableArray * array =[tmpArray lastObject];
            [array addObject:model];
        }
    }
    
    
    [self.phoneArr removeAllObjects];
    
    [self.phoneArr addObjectsFromArray:tmpArray];
}


- (NSString *)returnFirstWordWithString:(NSString *)str{
    NSMutableString * mutStr = [NSMutableString stringWithString:str];
    
    //将mutStr中的汉字转化为带音标的拼音（如果是汉字就转换，如果不是则保持原样）
    CFStringTransform((__bridge CFMutableStringRef)mutStr, NULL, kCFStringTransformMandarinLatin, NO);
    //将带有音标的拼音转换成不带音标的拼音（这一步是从上一步的基础上来的，所以这两句话一句也不能少）
    CFStringTransform((__bridge CFMutableStringRef)mutStr, NULL, kCFStringTransformStripCombiningMarks, NO);
    if (mutStr.length >0) {
        //全部转换为大写    取出首字母并返回
        NSString * res = [[mutStr uppercaseString] substringToIndex:1];
        
        NSLog(@"首字母 ---- %@",res);
        
        return res;
    }
    else
        return @"#";
    
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
//            [hud turnToError:@"没有获取通讯录权限"];
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
        
        
        
        if (firstName.length || lastName.length) {
            
            //拼接姓名
            
            NSString *name = firstName;
            
            if (lastName.length) {
                if (name.length) {
                    name = [lastName stringByAppendingString:firstName];
                }else{
                    name = lastName;
                }
            }
            
            
            //电话号码
            //读取电话多值
            ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            NSString *phoneNum = @"";
            
            for (int k = 0; k<ABMultiValueGetCount(phone); k++)
            {
                //获取电话Label
                NSString * personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k));
                //获取該Label下的电话值
                NSString *personNum = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
                
                if (personNum.length) {
                    
                    phoneNum = personNum;
                    
                    
                    break;
                }
                
            }

            
            if (phoneNum.length) {
                
                personModel *model = [[personModel alloc] init];
                
                model.name = name;
                
                model.phoneNum = phoneNum;
                
                [self.phoneArr addObject:model];
                
            }
            
        }
        
//        //读取middlename
//        NSString *middlename = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
//        //读取prefix前缀
//        NSString *prefix = (__bridge NSString*)ABRecordCopyValue(person, kABPersonPrefixProperty);
//        //读取suffix后缀
//        NSString *suffix = (__bridge NSString*)ABRecordCopyValue(person, kABPersonSuffixProperty);
//        //读取nickname呢称
//        NSString *nickname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNicknameProperty);
//        //读取firstname拼音音标
//        NSString *firstnamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNamePhoneticProperty);
//        //读取lastname拼音音标
//        NSString *lastnamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNamePhoneticProperty);
//        //读取middlename拼音音标
//        NSString *middlenamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNamePhoneticProperty);
//        //读取organization公司
//        NSString *organization = (__bridge NSString*)ABRecordCopyValue(person, kABPersonOrganizationProperty);
//        //读取jobtitle工作
//        NSString *jobtitle = (__bridge NSString*)ABRecordCopyValue(person, kABPersonJobTitleProperty);
//        //读取department部门
//        NSString *department = (__bridge NSString*)ABRecordCopyValue(person, kABPersonDepartmentProperty);
//        //读取birthday生日
//        NSDate *birthday = (__bridge NSDate*)ABRecordCopyValue(person, kABPersonBirthdayProperty);
//        //读取note备忘录
//        NSString *note = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNoteProperty);
//        //第一次添加该条记录的时间
//        NSString *firstknow = (__bridge NSString*)ABRecordCopyValue(person, kABPersonCreationDateProperty);
//        NSLog(@"第一次添加该条记录的时间%@\n",firstknow);
//        //最后一次修改該条记录的时间
//        NSString *lastknow = (__bridge NSString*)ABRecordCopyValue(person, kABPersonModificationDateProperty);
//        NSLog(@"最后一次修改該条记录的时间%@\n",lastknow);
//        
//        //获取email多值
//        ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
//        int emailcount = ABMultiValueGetCount(email);
//        for (int x = 0; x < emailcount; x++)
//        {
//            //获取email Label
//            NSString* emailLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(email, x));
//            //获取email值
//            NSString* emailContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(email, x);
//        }
//        //读取地址多值
//        ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
//        int count = ABMultiValueGetCount(address);
//        
//        for(int j = 0; j < count; j++)
//        {
//            //获取地址Label
//            NSString* addressLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(address, j);
//            //获取該label下的地址6属性
//            NSDictionary* personaddress =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(address, j);
//            NSString* country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
//            NSString* city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
//            NSString* state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
//            NSString* street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
//            NSString* zip = [personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];
//            NSString* coutntrycode = [personaddress valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
//        }
//        
//        //获取dates多值
//        ABMultiValueRef dates = ABRecordCopyValue(person, kABPersonDateProperty);
//        int datescount = ABMultiValueGetCount(dates);
//        for (int y = 0; y < datescount; y++)
//        {
//            //获取dates Label
//            NSString* datesLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(dates, y));
//            //获取dates值
//            NSString* datesContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(dates, y);
//        }
//        //获取kind值
//        CFNumberRef recordType = ABRecordCopyValue(person, kABPersonKindProperty);
//        if (recordType == kABPersonKindOrganization) {
//            // it's a company
//            NSLog(@"it's a company\n");
//        } else {
//            // it's a person, resource, or room
//            NSLog(@"it's a person, resource, or room\n");
//        }
//        
//        
//        //获取IM多值
//        ABMultiValueRef instantMessage = ABRecordCopyValue(person, kABPersonInstantMessageProperty);
//        for (int l = 1; l < ABMultiValueGetCount(instantMessage); l++)
//        {
//            //获取IM Label
//            NSString* instantMessageLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(instantMessage, l);
//            //获取該label下的2属性
//            NSDictionary* instantMessageContent =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(instantMessage, l);
//            NSString* username = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageUsernameKey];
//            
//            NSString* service = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageServiceKey];
//        }
//        

//        
//        //获取URL多值
//        ABMultiValueRef url = ABRecordCopyValue(person, kABPersonURLProperty);
//        for (int m = 0; m < ABMultiValueGetCount(url); m++)
//        {
//            //获取电话Label
//            NSString * urlLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(url, m));
//            //获取該Label下的电话值
//            NSString * urlContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(url,m);
//        }
//        
//        //读取照片
//        NSData *image = (__bridge NSData*)ABPersonCopyImageData(person);


        
    }
    
    
    [self sectionAllData];
    
    NSMutableArray *arr = [NSMutableArray array];
    
    for (NSArray *tempArr in self.phoneArr) {
        
        if (tempArr.count) {
            
            [arr addObject:tempArr];
            
            personModel *model = tempArr[0];
            
            
            [self.initialList addObject:model.initial];
        }
        
    }
    
    self.phoneArr = arr;
}

-(NSMutableArray *)phoneArr{
    if (_phoneArr == nil) {
        _phoneArr = [[NSMutableArray alloc] init];
    }
    return _phoneArr;
}
-(NSMutableArray *)initialList{
    if (_initialList == nil) {
        _initialList = [[NSMutableArray alloc] init];
    }
    return _initialList;
}

@end
