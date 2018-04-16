Pod::Spec.new do |s|

   s.name              = 'IntelligenceSDK'
   s.version           = '2.7.0'
   s.summary           = 'Intellignce framework is to encapsulate Intelligence platform\'\s API\'\s'
   
   s.documentation_url = 'https://github.com/tigerspike/Intelligence-iOS-Framework/wiki/Intelligence-iOS-Framework'
   
   s.description = <<-DESC
   The goal of this Framework is to encapsulate in a developer-friendly manner the Intelligence platform\'\s API\'\s.
   
   Don't have account!! Get an account from intelligence.support@tigerspike.com and start integrating the framework.
   
   Features:
   1. Analytics Module
   This module allows developers to effortlessly track several predefined events or their own custom events which can be used to determine user engagement and behavioral insights.
   2. Identity Module
   Provides methods for user management within the Intelligence platform. Allowing users to register, login, update and retrieve information.
   3.Location Module
   Responsible for managing a user\'\s location in order to track entering/exiting geofences and add this information to analytics events.
   
   DESC
   
   s.homepage         =  'https://github.com/tigerspike/Intelligence-iOS-Framework'
   
   s.author           = { 'Intelligence Team' => 'intelligence@tigerspike.com' }
   
   s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
   
   
   s.platform          = :ios
   
   s.source            = { :git => 'https://github.com/tigerspike/Intelligence-iOS-Framework.git', :tag => s.version.to_s }
   
   s.ios.deployment_target = '9.0'

   s.source_files = 'IntelligenceSDK/**/*.swift'
end
