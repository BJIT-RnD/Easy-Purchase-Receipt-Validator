#
#  Be sure to run `pod spec lint Easy_Purchase_Receipt_Validator.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "Easy_Purchase_Receipt_Validator"
  spec.version      = "1.0.2"
  spec.summary      = "This is a minimalistic, entirely Swift-based library designed for locally interpreting and authenticating Apple In-App Purchase Receipts."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  #spec.description  = ""

  spec.homepage     = "https://github.com/BJIT-RnD/Easy-Purchase-Receipt-Validator"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  spec.license       = "MIT"
  spec.author        = { "BJIT" => "rnd@bjitgroup.com" }
  #spec.documentation_url = "https://github.com/BJIT-RnD/EasyPurchase#cocoapods"
  spec.platform      = :ios, "11.0"
  spec.source        = { :git => "https://github.com/BJIT-RnD/Easy-Purchase-Receipt-Validator.git", :tag => "1.0.2" }
  spec.source_files  = "Sources/Easy-Purchase-Receipt-Validator/**/*"
  spec.requires_arc  = true
  spec.swift_version = "5.0"

end
