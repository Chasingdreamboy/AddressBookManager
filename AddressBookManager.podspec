#
#  Be sure to run `pod spec lint AddressBookManager.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "AddressBookManager"
  s.version      = "0.0.1"
  s.summary      = "获取单个联系人和全部通讯录的方法封装"
  s.homepage     = "https://github.com/Chasingdreamboy/AddressBookManager"
  s.license      = "MIT (example)"
  s.author             = { "Chasingdreamboy" => "email@address.com" }
  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/Chasingdreamboy/AddressBookManager.git", :commit => "5236c0ff8476a8249bdc11d77299992ac6f1dfe5" }
  s.source_files  = "*.{h,m}"
  s.framework  = "AddressBook.framework", "AddressBookUI.framework"
  s.requires_arc = true

end
