# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'roomEscape_re' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for roomEscape_re


# Reactive
  pod 'RxSwift'
  pod 'RxGesture'
  pod 'RxAlamofire'
pod 'Charts'
  # Firebase
  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'

  # Network
  pod 'Alamofire'
  pod 'SwiftyJSON'
  pod 'CodableAlamofire'
  pod 'Moya'
  pod 'Moya/RxSwift'

  # Logs
  pod 'CocoaLumberjack/Swift'
  pod 'Then'

  # Image
  pod 'CropViewController'

  # Download and Caching Images
pod 'Kingfisher', :git => 'https://github.com/onevcat/Kingfisher.git', :branch => 'version6-xcode13'
  pod 'SDWebImage'
  pod 'DKImagePickerController'

  # Keybaord
  pod 'IQKeyboardManagerSwift', '6.4.2'

  # UI
  pod 'XLPagerTabStrip'
  pod 'PopupDialog'
  pod 'JGProgressHUD'
  pod 'FSPagerView'
  pod 'IGListKit'
  pod 'DropDown'
  pod 'Hero'
  pod 'Segmentio'
  pod 'Cosmos'
  pod 'SideMenu'
  pod 'FSCalendar'
  pod 'RangeSeekSlider'

post_install do |pi|
    pi.pods_project.targets.each do |t|
        t.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
        end
    end
end

end
