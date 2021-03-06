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
    ContactCodeNormal,//正常状态，操作成功
    ContactCodeCancel,//未选择联系人直接退出
    ContactCodeDenied,//没有访问权限
    ContactCodeInvaild,//在属性选择页面没有选择电话，例如选择了共享联系人，发送短信或者打开邮箱等
    ContactCodeNoName,//选定的电话没有对象的联系人姓名
    ContactCodeNoPhone//选定的联系人没有电话号码
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


