//
//  AddressBookManager.m
//  AddressBook
//
//  Created by 王晓东 on 16/5/31.
//  Copyright © 2016年 Ericdong. All rights reserved.
//

#import <AddressBookUI/ABPeoplePickerNavigationController.h>
//#import <AddressBook/ABPerson.h>
//#import <AddressBookUI/ABPersonViewController.h>
#import <objc/runtime.h>
#import "AddressBookManager.h"


#define IOS8_OR_LATER       ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending)
#define NULL_TO_NIL(k)      (k == NULL) ? nil : k


@interface AddressBookManager ()
@property (strong, nonatomic) ABPeoplePickerNavigationController *picker;

@end

static AddressBookManager *manager;
static dispatch_once_t onceToken;
const char blockKey;
@implementation AddressBookManager
#pragma OpenMethod
+ (void)selectContactWithBlock:(Result)result {
    [self resetManager];
    //检查是否具有通讯录访问权限
    [self askAuthorityForAddressBookWithSuccess:^(bool granted, ABAddressBookRef addressBook) {
        if (granted) {
            objc_setAssociatedObject([self sharedInstance], &blockKey, result, OBJC_ASSOCIATION_COPY);
            ABPeoplePickerNavigationController *picker = [self sharedInstance].picker;
            UIViewController *vc = [self getCurrentViewController];//获取当前应用中正在显示的控制器
            [vc presentViewController:picker animated:YES completion:^{
                
            }];
        }
    }];
}
+ (void)getAllContactsWithBlock:(Result)result {
    [self askAuthorityForAddressBookWithSuccess:^(bool granted, ABAddressBookRef addressBook) {
        if (granted) {
            CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(addressBook);
            CFIndex count = ABAddressBookGetPersonCount(addressBook);
            NSMutableArray *contacts = [NSMutableArray array];
            NSMutableDictionary *personInfo = nil ;
            for (int i = 0; i < count; i++) {
                personInfo = [NSMutableDictionary dictionary];
                ABRecordRef person = CFArrayGetValueAtIndex(allContacts, i);
                //处理姓名
                ABPropertyID properties[3] = {kABPersonFirstNameProperty,kABPersonMiddleNameProperty, kABPersonLastNameProperty};
                NSString *fullName = nil;
                NSString *propertyName = nil;
                for (int j = 0; j < 3; j++) {
                    propertyName = (__bridge NSString *)ABRecordCopyValue(person, properties[j]);
                    propertyName = NULL_TO_NIL(propertyName);
                    fullName = [NSString stringWithFormat:@"%@%@",fullName ? :@"", propertyName ? : @""];
                }
                [personInfo setObject:fullName forKey:@"name"];
                //处理电话
                ABMutableMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
                for (int j = 0; j < ABMultiValueGetCount(phones); j++) {
                    NSString *phone = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phones, j);
                    NSString *label = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phones, j);
                    ;
                    if ([label rangeOfString:@"<"].location != NSNotFound) {
                        NSRange rangeOne = [label rangeOfString:@"<"];
                        NSRange rangeTwo = [label rangeOfString:@">"];
                        NSString *type = [label substringWithRange:NSMakeRange(rangeOne.location + 1, rangeTwo.location - rangeOne.location - 1)];
                        [personInfo setObject:phone forKey:[NSString stringWithFormat:@"phone<%@>", type]];
                    }
                //处理邮箱
                    ABMutableMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
                    for (int j = 0; j < ABMultiValueGetCount(emails); j++) {
                        NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                        NSString *label = (__bridge  NSString *)ABMultiValueCopyLabelAtIndex(emails, j);
                        if ([label rangeOfString:@"<"].location != NSNotFound) {
                            NSRange rangeOne = [label rangeOfString:@"<"];
                            NSRange rangeTwo = [label rangeOfString:@">"];
                            NSString *type = [label substringWithRange:NSMakeRange(rangeOne.location + 1, rangeTwo.location - rangeOne.location - 1)];
                            [personInfo setObject:email forKey:[NSString stringWithFormat:@"email<%@>", type]];
                        }
                    }
                    //处理创建时间
                    NSString *creationDate = (__bridge NSString *)ABRecordCopyValue(person, kABPersonCreationDateProperty);
                    [personInfo setObject:(creationDate ? : [NSNull null]) forKey:@"creationDate"];
                    //处理工作
                    NSString *job = (__bridge NSString *)ABRecordCopyValue(person, kABPersonJobTitleProperty);
                    [personInfo setObject:job ? : @"" forKey:@"job"];
                    //处理生日
                    NSString *birthday = (__bridge NSString *)ABRecordCopyValue(person, kABPersonBirthdayProperty);
                    [personInfo setObject:birthday ? : @"" forKey:@"birthday"];
                    //处理联系人所在城市
                    
                    ABMutableMultiValueRef addresses = ABRecordCopyValue(person, kABPersonAddressProperty);
                    for (int j = 0; j < ABMultiValueGetCount(addresses); j++) {
                        NSDictionary *address = (__bridge  NSDictionary *)ABMultiValueCopyValueAtIndex(addresses, j);
                        NSString *country = address[@"Country"];
                        NSString *city = address[@"City"];
                        NSString *street = address[@"Street"];
                        NSString *addressString = [NSString stringWithFormat:@"%@%@%@", country ? : @"", city ? : @"", street ? : @""];
                        [personInfo setObject:addressString forKey:@"address"];
                    }
                }
                [contacts addObject:personInfo];
            }
            result(ContactCodeNormal, contacts);
        } else {
        }
    }];
}

#pragma ask for authority
+ (void)askAuthorityForAddressBookWithSuccess:(void(^)(bool granted,ABAddressBookRef addressBook))success  {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            success(granted, addressBook);
        } else {
            success(granted, nil);
            [[[UIAlertView alloc]initWithTitle:@"无通讯录权限" message:@"请在“设置”-“隐私”-“通讯录”中允许功夫贷访问您的通讯录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }
        
    });
}

#pragma iOS8_OR_LATER
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier NS_AVAILABLE_IOS(8_0) {
    Result result = objc_getAssociatedObject(self , &blockKey);
    if(kABPersonPhoneProperty != property) {
        result(ContactCodeInvaild, @{});
    } else {
        NSString *fullName = nil;
        int32_t properties[3] = {kABPersonFirstNameProperty, kABPersonMiddleNameProperty, kABPersonLastNameProperty};
        NSString *propertyName = nil;
        for(int i = 0; i < 3;i++) {
            propertyName = (__bridge NSString *)ABRecordCopyValue(person, properties[i]);
            propertyName = NULL_TO_NIL(propertyName);
            fullName = [NSString stringWithFormat:@"%@%@", fullName ? : @"",propertyName ? :@""];
             NSLog(@"full name : %@", fullName);
        }
        
        ABMultiValueRef phone = ABRecordCopyValue(person, property);
        long index = ABMultiValueGetIndexForIdentifier(phone,identifier);
        NSString *phoneNO = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, index);
        if(!fullName || !fullName.length) {
            result(ContactCodeNoName, @{});
            
        } else if (!phoneNO || !phoneNO.length) {
            result(ContactCodeNoPhone, @{});
        } else {
            result(ContactCodeNormal, @{@"name" : fullName, @"phone" : phoneNO});
            
        }
        
    }
    
}
#pragma iOS7
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;//返回YES，允许显示被选择联系人的详细信息，例如电话号码，邮箱，家庭住址等。
}
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    Result result = objc_getAssociatedObject(self, &blockKey);
    if (property != kABPersonPhoneProperty) {
        result(ContactCodeInvaild, @{});
    }
    NSString *fullName = nil;
    int32_t properties[3] = {kABPersonFirstNameProperty, kABPersonMiddleNameProperty, kABPersonLastNameProperty};
    NSString *propertyName = nil;
    for(int i = 0; i < 3;i++) {
        propertyName = (__bridge NSString *)ABRecordCopyValue(person, properties[i]);
        propertyName = NULL_TO_NIL(propertyName);
        fullName = [NSString stringWithFormat:@"%@%@", fullName ? : @"",propertyName ? :@""];
        NSLog(@"full name : %@", fullName);
    }
    
    ABMultiValueRef phone = ABRecordCopyValue(person, property);
    long index = ABMultiValueGetIndexForIdentifier(phone,identifier);
    NSString *phoneNO = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, index);
    if(!fullName || !fullName.length) {
        result(ContactCodeNoName, @{});
        
    } else if (!phoneNO || !phoneNO.length) {
        result(ContactCodeNoPhone, @{});
    } else {
        result(ContactCodeNormal, @{@"name" : fullName, @"phone" : phoneNO});
        
    }
    return NO;//如果希望对某一属性做进一步的操作，例如发送邮件或者消息等，返回YES，否则，返回NO

}
#pragma ABPeopleNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:^{
    }];
}

+ (AddressBookManager *)sharedInstance {
    dispatch_once(&onceToken, ^{
        manager = [[AddressBookManager alloc] init];
        
    });
    return manager;
}
/**
 *  重置单例对象
 */
+ (void)resetManager {
    manager = nil;
    onceToken = 0;
}
/**
 *  获取应用当前正在显示的控制器
 *
 *  @return 当前正在显示的控制器
 */
+ (UIViewController *)getCurrentViewController {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    return [window visibleViewController];
    
}
/**
 *  lazy load
 *
 *  @return 创建一个ABPeoplePickerNavigationController对象
 */
- (ABPeoplePickerNavigationController *)picker {
    if (!_picker) {
        _picker = [[ABPeoplePickerNavigationController alloc] init];
        _picker.peoplePickerDelegate = self;
        if (IOS8_OR_LATER) {
            _picker.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:NO];
        }
    }
    return _picker;
}
@end



@implementation UIWindow (VisibleViewController)

- (UIViewController *)visibleViewController {
    UIViewController *rootViewController = self.rootViewController;
    return [UIWindow getVisibleViewControllerFrom:rootViewController];
}

+ (UIViewController *) getVisibleViewControllerFrom:(UIViewController *) vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [UIWindow getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [UIWindow getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [UIWindow getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}
@end
