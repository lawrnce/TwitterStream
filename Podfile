# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

def testing_pods
  pod 'Nimble', '~> 3.2.0 '
end

target 'TwitterStream' do
  pod 'SwiftyJSON'
  pod 'HanekeSwift'
end

target 'TwitterStreamTests' do
  testing_pods
  pod 'SwiftyJSON'
end

target 'TwitterStreamUITests' do
  testing_pods
end

