
Pod::Spec.new do |s|
  s.name             = 'InfiniteLoopScrollView'
  s.version          = '0.1.0'
  s.summary          = 'Infinite loop scroll view'
  s.description      = <<-DESC
Simple way to implement infinite loop scroll view.
                       DESC

  s.homepage         = 'https://github.com/yanyin1986/InfiniteLoopScrollView'
  s.license          = { :type => 'MIT',
                         :file => 'LICENSE' }
  s.swift_version    = '4.0'
  s.author           = { 'Leon.yan' => 'yanyin1986@gmail.com' }
  s.source           = { :git => 'https://github.com/yanyin1986/InfiniteLoopScrollView.git',
                         :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'InfiniteLoopScrollView/**/*.swift'
  s.frameworks = 'UIKit'
end
