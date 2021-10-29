//
//  ArchiveFloatingPanel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/06.
//

import UIKit
import FloatingPanel

class ArchiveFloatingPanel {
    
    private var floatingPanel = FloatingPanelController()
    private var vc: UIViewController?
    private var adMobManager = AdMobManager()
    var successfullyAddedAction: () -> Void = {}
    
    init(vc: UIViewController) {
        self.vc = vc
        configureAppearance()
    }
    
    private func configureAppearance() {
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 32
        
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.gray
        shadow.offset = CGSize(width: 0, height: 16)
        shadow.radius = 16
        shadow.spread = 8
        appearance.shadows = [shadow]
        
        floatingPanel.removeFromParent()
        floatingPanel.contentMode = .fitToBounds
        floatingPanel.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        floatingPanel.surfaceView.appearance = appearance
        floatingPanel.surfaceView.grabberHandle.barColor = ColorSet.floatingPanelHandleColor
        floatingPanel.layout = PopUpArchiveFloatingPanelLayout()
    }
    
    private func configureAction(selectedSong: Song) {
        guard let vc = vc else { return }

        floatingPanel.removeFromParent()
        
        guard let popUpArchiveVC = vc.storyboard?.instantiateViewController(identifier: "popUpArchiveStoryboard") as? PopUpSongFolderListViewController else { return }
        
        popUpArchiveVC.delegate = self
        popUpArchiveVC.selectedSong = selectedSong
        popUpArchiveVC.exitButtonAction = { [weak self] in
            self?.floatingPanel.hide(animated: true)
        }
        
        floatingPanel.set(contentViewController: popUpArchiveVC)
        floatingPanel.addPanel(toParent: vc)
    }
    
    public func show(selectedSong: Song, animated: Bool) {
        configureAction(selectedSong: selectedSong)
        floatingPanel.show(animated: true, completion: nil)
        floatingPanel.move(to: .half, animated: true)
    }
    
    public func hide(animated: Bool) {
        floatingPanel.hide(animated: animated)
    }
}

extension ArchiveFloatingPanel: PopUpArchiveViewDelegate {
    func popUpArchiveView(isSuccessfullyAdded: Bool) {
        if isSuccessfullyAdded {
            guard let vc = vc else { return }
            
            floatingPanel.hide(animated: true)
            successfullyAddedAction()
            
            adMobManager.presentAdMob(vc: vc)
        }
    }
}
