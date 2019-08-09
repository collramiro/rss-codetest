//
//  WebViewController.swift
//  cove
//
//  Created by Ramiro Coll Doñetz on 2019-01-31.
//  Copyright © 2019 Charly. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, UIGestureRecognizerDelegate {
    
    static var animationDuration:Double = 0.3
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var topDecoratorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var webViewContainerView: UIView!
    @IBOutlet weak var navigationControlsView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var decoratorTopConstraint: NSLayoutConstraint!
    
    //buttons
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    //interaction
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    fileprivate var isInteractive = false
    fileprivate var interactiveStartingPoint: CGPoint? = nil
    
    var url: URL! {
        didSet {
            
        }
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    class func createWebViewContainer(url: URL) -> WebViewController{
        let webViewController = WebViewController(nibName: "WebViewController", bundle: nil)
        webViewController.url = url
        return webViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        decoratorTopConstraint.constant = topPadding + 20.0
        
        setupButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCoveWebView()
        initialAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        topDecoratorView.layer.cornerRadius = topDecoratorView.frame.height/2
    }
    
    fileprivate func setupButtons() {
        //        //hide buttons stackview if we don't need it
        //        if leftButtonText == nil, self.rightButtonText == nil {
        //            self.buttonsStackView.removeFromSuperview()
        //            //            self.setNeedsLayout()
        //        } else {
        //            //set buttons
        //            if let leftButtonText = self.leftButtonText {
        //                self.leftButton.setTitle(leftButtonText, for: .normal)
        //                self.leftButton.backgroundColor = self.leftButtonColor
        //            } else {
        //                self.leftButton.isHidden = true
        //            }
        //
        //            if let rightButtonText = self.rightButtonText {
        //                self.rightButton.setTitle(rightButtonText, for: .normal)
        //                self.rightButton.backgroundColor = self.rightButtonColor
        //            } else {
        //                self.rightButton.isHidden = true
        //            }
        //        }
    }
    
    // MARK: - CoveWebView
    fileprivate func setupCoveWebView() {
        self.navigationControlsView.clipsToBounds = true
        self.navigationControlsView.layer.cornerRadius = 16
        self.navigationControlsView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        self.webView.navigationDelegate = self
        self.webView.load(URLRequest(url: self.url))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    func showProgressView() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.progressView.alpha = 1
        }, completion: nil)
    }
    
    func hideProgressView() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.progressView.alpha = 0
        }, completion: nil)
    }
    
    // MARK: - ActionSheet
    func showMoreActionSheet(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let reloadAction = UIAlertAction(title: NSLocalizedString("Reload", comment: ""), style: .default) { (action:UIAlertAction) in
            self.webView.reload()
        }
        
        let safariAction = UIAlertAction(title: NSLocalizedString("Open in Safari", comment: ""), style: .default) { (action:UIAlertAction) in
                UIApplication.shared.open(self.url, options: [:], completionHandler: nil)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action:UIAlertAction) in
            
        }
        
        alertController.addAction(reloadAction)
        alertController.addAction(safariAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: - Actions
    @IBAction func closePressed(_ sender: Any) {
        //dismiss
        self.finishTransition(isInteractive: false)
    }
    
    @IBAction func morePressed(_ sender: Any) {
        self.showMoreActionSheet()
    }
    
    // MARK: - handle gesture and animations
    
    var offset = CGPoint.zero
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func handleGesture(sender: UIPanGestureRecognizer) {
        
        let percentThreshold:CGFloat = 0.4
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        let location = sender.location(in: view)
        let locationInParent = sender.location(in: view)
        let centerInParent = CGPoint(x: locationInParent.x + offset.x, y: locationInParent.y + offset.y)
        
        switch sender.state {
        case .began:
            hasStarted = true
            offset = CGPoint(
                x: view.bounds.midX - location.x,
                y: view.bounds.midY - location.y)
        case .changed:
            shouldFinish = progress > percentThreshold
            updateInteractiveTransition(progress, yPosition: centerInParent.y)
        case .cancelled:
            hasStarted = false
            cancelInteractiveTransition()
        case .ended:
            hasStarted = false
            //dirty solution for velocity, but it works. It's just to avoid the case when you try to dismiss dragging fast before the percentThreshold
            (shouldFinish || sender.velocity(in: view).y > 1200) ? finishTransition(isInteractive: true) : cancelInteractiveTransition()
        default:
            break
        }
    }
    
    var hasStarted = false
    var shouldFinish = false
    
    fileprivate func updateInteractiveTransition(_ progress: CGFloat, yPosition: CGFloat) {
        self.viewContainer.center = CGPoint(x: self.backgroundView.center.x, y: yPosition)
        self.backgroundView.alpha = 1 - progress
    }
    
    fileprivate func cancelInteractiveTransition() {
        UIView.animate(withDuration: WebViewController.animationDuration * 1.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            self.backgroundView.alpha = 1
            self.viewContainer.center = CGPoint(x: self.backgroundView.center.x, y:self.backgroundView.center.y)
        }) { (complete) in
            
        }
    }
    
    func finishTransition(isInteractive: Bool) {
        UIView.animate(withDuration: WebViewController.animationDuration / 2.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.backgroundView.alpha = 0
        }, completion: { (complete) in
            if complete{
                
            }
        })
        
        UIView.animate(withDuration: WebViewController.animationDuration * (isInteractive ? 1.5 : 3.0), delay: isInteractive ? 0 : WebViewController.animationDuration / 3.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            self.viewContainer.center = CGPoint(x: self.backgroundView.center.x, y:self.backgroundView.center.y + self.viewContainer.bounds.size.height)
        }) { (complete) in
            if complete {
                self.dismiss(animated: false, completion: nil)
//                ((UIApplication.shared.delegate as? CoveAppDelegate)?.currentCoordinator())?.transitionToRoot()
            }
        }
    }
    
    fileprivate func initialAnimation() {
        self.backgroundView.alpha = 0
        
        UIView.animate(withDuration: WebViewController.animationDuration / 2.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.backgroundView.alpha = 1
        }, completion: { (complete) in
            if complete{
                
            }
        })
        
        viewContainer.center = CGPoint(x: self.backgroundView.center.x, y:self.backgroundView.center.y + viewContainer.bounds.size.height)
        
        UIView.animate(withDuration: WebViewController.animationDuration * 1.5, delay: WebViewController.animationDuration / 3.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            self.viewContainer.center = CGPoint(x: self.backgroundView.center.x, y:self.backgroundView.center.y)
        }) { (complete) in
            
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideProgressView()
        
        if let webTitle = webView.title {
            self.titleLabel.alpha = 0
            self.titleLabel.text = webTitle
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.titleLabel.alpha = 1
            }, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.showProgressView()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideProgressView()
    }
}
