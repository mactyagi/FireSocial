//
//  LoadingOverLay.swift
//  FireSocial
//
//  Created by Manu on 07/02/24.
//

import Foundation
import UIKit

class LoadingOverlay: UIView {

    let activityIndicator = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLoader()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLoader()
    }

    private func setupLoader() {
        // Add blur effect
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        addSubview(blurView)
        
        // Add activity indicator
        addSubview(activityIndicator)
        activityIndicator.tintColor = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func startAnimating() {
        activityIndicator.startAnimating()
    }

    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}
