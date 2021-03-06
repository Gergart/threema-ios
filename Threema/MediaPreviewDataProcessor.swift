//  _____ _
// |_   _| |_  _ _ ___ ___ _ __  __ _
//   | | | ' \| '_/ -_) -_) '  \/ _` |_
//   |_| |_||_|_| \___\___|_|_|_\__,_(_)
//
// Threema iOS Client
// Copyright (c) 2021 Threema GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License, version 3,
// as published by the Free Software Foundation.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

import Foundation
import CocoaLumberjackSwift
import ThreemaFramework

@objc class MediaPreviewDataProcessor : MediaPreviewURLDataProcessor {
    
    @objc var addMore: (([Any], [MediaPreviewItem]) -> Void)?
    @objc var returnToMe: (([DKAsset], [MediaPreviewItem]) -> Void)?
    
    override func loadItems(dataArray : [Any]) -> (items: [MediaPreviewItem], errors: [PhotosPickerError]) {
        var mediaData = [MediaPreviewItem]()
        var errorList = [PhotosPickerError]()
        for index in 0..<dataArray.count {
            guard let item = self.loadItem(item: dataArray[index]) else {
                errorList.append(PhotosPickerError.unknown)
                continue
            }
            mediaData.append(item)
        }
        return (mediaData, errorList)
    }
    
    override func loadItem(item : Any) -> MediaPreviewItem? {
        switch item {
            case is DKAsset:
                let data = item as! DKAsset
                let mediaItem = self.mediaPreviewItemFromDKAsset(asset: data)
                
                return mediaItem
            case is PHAsset:
                guard let phasset = item as? PHAsset else {
                    return nil
                }
                return self.mediaPreviewItemFromDKAsset(asset: DKAsset(originalAsset: phasset))
            default:
                return super.loadItem(item: item)
        }
    }

    override func returnAction(mediaData : [MediaPreviewItem]) {
        var returnVal: [Any] = []
        for item in mediaData {
            if let originalAsset = item.originalAsset as? DKAsset {
                returnVal.append(originalAsset)
            } else if let originalAssetUrl = item.itemUrl {
                returnVal.append(originalAssetUrl)
            } else {
                let err = "Original Asset is unavailable."
                DDLogError(err)
                fatalError(err)
            }
        }
        self.addMore?(returnVal, mediaData)
    }
    
    private func handleImageItem(item : ImagePreviewItem) -> Any? {
        if item.originalAsset != nil {
            guard let originalAsset = item.originalAsset as? DKAsset else {
                return nil
            }
            guard let asset = originalAsset.originalAsset else {
                let err = "Original Asset is unavailable."
                DDLogError(err)
                fatalError(err)
            }
            return asset
            
        } else {
            guard let assetUrl = item.itemUrl else {
                return nil
            }
            return assetUrl
        }
    }
    
    private func handleVideoItem(item: VideoPreviewItem) -> Any? {
        return sendAsFile ? item.getOriginalItem() : item.getTranscodedItem()
    }
    
    override func processItemForSending(item : MediaPreviewItem) -> Any? {
        if item is ImagePreviewItem {
            return self.handleImageItem(item: item as! ImagePreviewItem)
        }
        
        if item is VideoPreviewItem {
            return self.handleVideoItem(item: item as! VideoPreviewItem)
        }
        
        return super.processItemForSending(item: item)
    }
    
    @objc public static func equals(asset: DKAsset, item: MediaPreviewItem) -> Bool {
        guard let a = item.originalAsset as? DKAsset else {
            return false
        }
        return a == asset
    }
    
    @objc public static func contains(asset: DKAsset, itemList: [MediaPreviewItem]) -> Int {
        for index in 0..<itemList.count {
            if equals(asset: asset, item: itemList[index]) {
                return index
            }
        }
        return -1
    }
    
    private func mediaPreviewItemFromDKAsset(asset : DKAsset) -> MediaPreviewItem {
        var mediaItem : MediaPreviewItem
        if asset.isVideo {
            mediaItem = VideoAssetPreviewItem(originalAsset: asset)
        } else {
            mediaItem = ImageAssetPreviewItem(originalAsset: asset)
        }
        return mediaItem
    }
}
