//
//  CustomGroupDetailImageCell.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 03/01/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import ThreemaFramework

class CustomGroupDetailImageCell: DKAssetGroupDetailBaseCell {
    
    class override func cellReuseIdentifier() -> String {
        return "CustomGroupDetailImageCell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.thumbnailImageView.frame = self.bounds
        self.thumbnailImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.addSubview(self.thumbnailImageView)
        
        self.checkView.frame = self.bounds
        self.checkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.checkView.checkImageView.tintColor = nil
        self.checkView.checkLabel.font = UIFont.boldSystemFont(ofSize: 14)
        self.checkView.checkLabel.textColor = UIColor.white
        self.contentView.addSubview(self.checkView)
        
        self.isAccessibilityElement = true
               
        if #available(iOS 11.0, *) {
           self.thumbnailImageView.accessibilityIgnoresInvertColors = true
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class DKImageCheckView: UIView {
        
        private class func stretchImgFromMiddle(_ image: UIImage) -> UIImage {
            let centerX = image.size.width / 2
            let centerY = image.size.height / 2
            return image.resizableImage(withCapInsets: UIEdgeInsets(top: centerY, left: centerX, bottom: centerY, right: centerX))
        }
        
        internal lazy var checkImageView: UIImageView = {
            let imageView = UIImageView(image: CustomGroupDetailImageCell.DKImageCheckView.stretchImgFromMiddle(StyleKit.checkedBackground))
            return imageView
        }()
        
        internal lazy var checkLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .right
            
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.addSubview(checkImageView)
            self.addSubview(checkLabel)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self.checkImageView.frame = self.bounds
            self.checkLabel.frame = CGRect(x: 0, y: 5, width: self.bounds.width - 5, height: 20)
        }
        
    } /* DKImageCheckView */
    
    override var thumbnailImage: UIImage? {
        didSet {
            self.thumbnailImageView.image = self.thumbnailImage
        }
    }
    override var index: Int {
        didSet {
            self.checkView.checkLabel.text =  "\(self.index + 1)"
        }
    }
    
    fileprivate lazy var thumbnailImageView: UIImageView = {
        let thumbnailImageView = UIImageView()
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        
        return thumbnailImageView
    }()
    
    internal let checkView = DKImageCheckView()
    
    override var isSelected: Bool {
        didSet {
            checkView.isHidden = !super.isSelected
        }
    }

    
} /* DKAssetGroupDetailCell */
