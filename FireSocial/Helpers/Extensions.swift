//
//  Extensions.swift
//  FireSocial
//
//  Created by Manu on 06/02/24.
//

import Foundation
import UIKit

extension UIView{
    func addShadow() {
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }
    
    func activityStartAnimating(activityColor: UIColor = .gray, backgroundColor: UIColor = .clear, style: UIActivityIndicatorView.Style = .medium) {
        if viewWithTag(475647) != nil{ return }
        let backgroundView = UIView()
        backgroundView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        backgroundView.backgroundColor = backgroundColor
        backgroundView.tag = 475647
        
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.color = activityColor
        activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false
        
        backgroundView.addSubview(activityIndicator)

        self.addSubview(backgroundView)
    }

    func activityStopAnimating() {
        if let background = viewWithTag(475647){
            background.removeFromSuperview()
        }
        self.isUserInteractionEnabled = true
    }
}


extension UIViewController{
    func showMessagePrompt(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showLoadingVC(){
        let loadingVC = UIViewController()
        loadingVC.view.activityStartAnimating()
        loadingVC.view.backgroundColor = .gray
        loadingVC.view.layer.opacity = 0.5
        self.present(loadingVC, animated: false)
    }
    
}

