//
//  PopUpArchiveFloatingPanelLayout.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit
import FloatingPanel

class PopUpArchiveFloatingPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .tip
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 196, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}
