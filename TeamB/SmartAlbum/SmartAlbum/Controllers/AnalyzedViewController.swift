//
//  AnalyzedViewController.swift
//  SmartAlbum
//
//  Created by 진형탁 on 2017. 11. 24..
//  Copyright © 2017년 team-b. All rights reserved.
//

import UIKit
import RealmSwift

class AnalyzedViewController: UIViewController {
    
    fileprivate var numberOfSections = 1
    fileprivate let sectionInsets = UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
    fileprivate let itemsPerRow: CGFloat = 4
    var selectedObjs: [AnalysisAsset] = [AnalysisAsset]()
    var titleTxt: String?
    
    @IBOutlet weak var analyzedCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCollectionView()
        
        if let title = self.titleTxt {
            self.title = title
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationItem.title = " "
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.titleTxt
    }
    
    // MARK: - Navigation control
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AssetPreviewVC" {
            guard let assetPreviewVC = segue.destination as? AssetPreviewViewController else { return }
            guard let selectedIndexPath = sender as? IndexPath else { return }
            
            assetPreviewVC.numberOfSections = self.numberOfSections
            assetPreviewVC.passedIndexPath = selectedIndexPath
            assetPreviewVC.selectedObjs = self.selectedObjs
            
        }
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource {

extension AnalyzedViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func initCollectionView() {
        self.analyzedCollectionView.dataSource = self
        self.analyzedCollectionView.delegate = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedObjs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnalyzedThumbnailCell", for: indexPath) as! AnalyzedThumbnailCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // show full image
        self.performSegue(withIdentifier: "AssetPreviewVC", sender: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AnalyzedViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let cell = cell as! AnalyzedThumbnailCell
        cell.analyzedThumbnailImg.image = nil
        cell.analyzedThumbnailImg.contentMode = .scaleAspectFill
        cell.analyzedThumbnailImg.clipsToBounds = true
        cell.playImg.isHidden = true
        
        DispatchQueue.global(qos: .background).async {
            let url = self.selectedObjs[indexPath.row].url
            let isVideo = self.selectedObjs[indexPath.row].isVideo
            DispatchQueue.main.async {
                if isVideo { cell.playImg.isHidden = false }
                cell.analyzedThumbnailImg.imageFromAssetURL(assetURL: url)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow+1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}


