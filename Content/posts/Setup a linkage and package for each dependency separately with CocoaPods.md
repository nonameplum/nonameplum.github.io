---
date: 2022-02-28 10:48
description: Setup a linkage and package for each dependency separately with CocoaPods
tags: 
tagColors: 
---
# How to set up the linkage and package method separately for each dependency with CocoaPods

CocoaPods doesn't allow the setup of the linkage and package method separately for each dependency.
It is possible to setup the linkage method but only for the whole target like:

```ruby
target :DynamicTarget do
    use_frameworks! :linkage => :dynamic
    
    pod 'DynamicPod' # This will be linked dynamically
end

target :StaticTarget do
    use_frameworks! :linkage => :static

    pod 'StaticPod' # This will be linked statically
end
```

Microsoft iOS team made a plugin to allow it:
https://github.com/microsoft/cocoapods-pod-linkage

If you don't what to use the plugin you can still make it work on your own by using the CocoaPods `pre_install` hook.

```ruby
pre_install do |installer|
  installer.pod_targets.each do |pod|
    if pod.name == "Podname"
      def pod.build_type
        Pod::BuildType.new(:linkage => :dynamic, :packaging => :framework)
      end
    end
  end
end
```

All possible `BuildType`s are defined here https://github.com/CocoaPods/Core/blob/master/lib/cocoapods-core/build_type.rb.