//
//  SongOptionFloatingPanleView.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/12/14.
//

import UIKit
import FloatingPanel

class SongOptionFloatingPanelView {
    
    private var floatingPanel = FloatingPanelController()
    private weak var parentViewController: UIViewController?
    private weak var contentViewDelegate: PopUpSongOptionViewDelegate?
    
    init(parentViewConroller: UIViewController, delegate: PopUpSongOptionViewDelegate) {
        self.parentViewController = parentViewConroller
        self.contentViewDelegate = delegate
        
        setup()
    }
    
    private func setup() {
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 28
        
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
        floatingPanel.surfaceView.grabberHandle.barColor = UIColor.lightGray
        floatingPanel.layout = SongOptionFloatingPanelLayout()
    }

    public func show(_ selectedSong: ArchiveSong) {
        prepareForShow(selectedSong)
        floatingPanel.show(animated: true)
        floatingPanel.move(to: .half, animated: true)
    }
    
    public func hide(animated: Bool) {
        floatingPanel.hide(animated: animated) { [weak self] in
            self?.floatingPanel.removeFromParent()
        }
    }
    
    private func prepareForShow(_ selectedSong: ArchiveSong) {
        guard let parentVC = parentViewController,
              let storyboard = parentVC.storyboard else {
            return
        }
        
        let songOptionVC = storyboard.instantiateViewController(identifier: "popUpSongOptionStoryboard") { [weak self] coder -> PopUpSongOptionViewController in
            guard let self = self else { return PopUpSongOptionViewController(.init()) }
            
            let viewModel = PopUpSongOptionViewModel(parentViewController: self.parentViewController!, selectedSong: selectedSong)
            return .init(coder, viewModel) ?? PopUpSongOptionViewController(.init())
        }
        
        songOptionVC.delegate = contentViewDelegate
        songOptionVC.exitButtonAction = { [weak self] in
            self?.hide(animated: true)
        }
        
        floatingPanel.removeFromParent()
        floatingPanel.set(contentViewController: songOptionVC)
        floatingPanel.addPanel(toParent: parentViewController!)
    }
}
