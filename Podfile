# Uncomment the next line to define a global platform for your project
platform :ios, '10.3'

target 'LinkedNote' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'PocketAPI', :git => 'https://github.com/tasuwo/Pocket-ObjC-SDK'
  pod 'SwiftyJSON'
  pod 'RealmSwift'
  pod 'DynamicColor'
  pod 'SwiftFormat/CLI'

  plugin 'cocoapods-keys', {
    :project => "LinkedNote",
    :keys => [
      "PocketAPIConsumerKey",
      "PocketAppID"
    ]
  }

  # Pods for LinkedNote

  target 'LinkedNoteTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'LinkedNoteUITests' do
    inherit! :search_paths
    # Pods for testing
  end
end
