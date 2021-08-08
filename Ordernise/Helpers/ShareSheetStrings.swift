//
//  MyStringItemSource.swift
//  Ordernise
//
//  Created by Aaron on 05/08/2021.
//

import UIKit
import LinkPresentation


class ShareSheetStrings: NSObject, UIActivityItemSource {
    


  public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
    return "toitssd"
  }
    
    public func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
       let metadata = LPLinkMetadata()

       metadata.title = "Share Ordernise" // Preview Title

     

      // Set URL for sharing
         //  metadata.originalURL = myUrl // Add this if you want to have a url in your share message.

       return metadata
   }
    
    let shareTitle = "Hey checkout ordernise"

    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
    if activityType == UIActivity.ActivityType.message {
      return "String for message"
    } else if activityType == UIActivity.ActivityType.mail {
      return "String for mail"
    } else if activityType == UIActivity.ActivityType.postToTwitter {
      return "String for twitter"
    } else if activityType == UIActivity.ActivityType.postToFacebook {
      return "String for facebook"
    }
    return nil
  }

    public func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
    if activityType == UIActivity.ActivityType.message {
      return shareTitle
    } else if activityType == UIActivity.ActivityType.mail {
      return shareTitle
    } else if activityType == UIActivity.ActivityType.postToTwitter {
      return shareTitle
    } else if activityType == UIActivity.ActivityType.postToFacebook {
      return shareTitle
    }
    return ""
  }

    public func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
        if activityType == UIActivity.ActivityType.message {
      return UIImage(named: "AppIcon")
        } else if activityType == UIActivity.ActivityType.mail {
      return UIImage(named: "AppIcon")
        } else if activityType == UIActivity.ActivityType.postToTwitter {
      return UIImage(named: "AppIcon")
        } else if activityType == UIActivity.ActivityType.postToFacebook {
      return UIImage(named: "AppIcon")
    }
        
   

    return UIImage(named: "AppIcon")
  }

}
