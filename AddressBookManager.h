//
//  AddressBookManager.h
//  AddressBook
//
//  Created by 王晓东 on 16/5/31.
//  Copyright © 2016年 Ericdong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

typedef NS_ENUM(NSInteger, ContactCode) {
    ContactCodeNormal,
    ContactCodeDenied,
    ContactCodeInvaild,
    ContactCodeNoName,
    ContactCodeNoPhone
};
typedef void(^Result) (ContactCode code, id response);

@interface AddressBookManager : NSObject<ABPeoplePickerNavigationControllerDelegate>
/**
 *  选择单个联系人
 *
 *  @param result code 是ContactCode枚举类型，
                     response如果code ＝ ContactCodeNormal，则返回包含name和phone两个key的字典类型；否则response为空字典
 */
+ (void)selectContactWithBlock:(Result)result;
/**
 *  获取整个通讯录
 *
 *  @param result code：是ContactCode枚举类型，
                response：如果code ＝ ContactCodeNormal，则返回包含name和phone两个key的字典类型；否则response为空字典
 */
+ (void)getAllContactsWithBlock:(Result)result;

@end

@interface UIWindow (VisibleViewController)
/**
 *  获取应用正在显示的控制器
 *
 *  @return 当前正在显示的控制器
 */
- (UIViewController *)visibleViewController;

@end


