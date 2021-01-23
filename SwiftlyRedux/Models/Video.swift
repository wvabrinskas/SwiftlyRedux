//
//  Video.swift
//  Homes
//
//  Created by William Vabrinskas on 8/26/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation

public struct Video: Media {
  public var url: String?
  public var videoId: String?
  
  public init(videoId: String) {
    self.videoId = videoId
  }
}
