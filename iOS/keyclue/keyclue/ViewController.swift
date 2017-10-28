//
//  ViewController.swift
//  keyclue
//
//  Created by Faaiz Ahmed on 10/7/17.
//  Copyright © 2017 personal. All rights reserved.
//

import UIKit
import WebKit
import NVActivityIndicatorView
import FirebaseAnalytics
import FirebasePerformance
class ViewController: UIViewController , WKUIDelegate, WKNavigationDelegate{
    
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var nativeWebView: UIWebView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var mainView: UIView!
    var webView: WKWebView!
    var popupWebView: WKWebView!
    var popUpOpened = false
    let cartLink = "http://keyclue.co.kr/order/basket.html"
    let myPageLink = "http://keyclue.co.kr/myshop/index.html"
    let keyClueLink = "http://m.keyclue.co.kr"
    
    func SetBarColor()
    {
            let remoteConfigGetter = RCValues.sharedInstance
            remoteConfigGetter.fetchCloudValues()
        navigationBarView.backgroundColor = remoteConfigGetter.color(forKey: ValueKey(rawValue: "appPrimaryColor")!)
        
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetBarColor()
        let trace = Performance.startTrace(name: "Page loading trace")
        let frame = CGRect(x: (progressView.frame.width / 2) - 20 , y: progressView.frame.height / 2, width: 45, height: 45)
        let activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                            type: NVActivityIndicatorType.ballSpinFadeLoader , color: UIColor.black)
        progressView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        webView = WKWebView(frame: mainView.frame, configuration: WKWebViewConfiguration() )
        webView = WKWebView(frame: mainView.bounds, configuration: WKWebViewConfiguration())
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        let webViewKeyPathsToObserve = ["loading", "estimatedProgress"]
        for keyPath in webViewKeyPathsToObserve {
            webView.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)
        }
        
        self.mainView.addSubview(webView)
        self.mainView.addSubview(progressView)
        self.webView.allowsBackForwardNavigationGestures = true
        webView.load(GetURL(link: keyClueLink))
        trace?.stop()
    }
    
    private func GetURL(link:String)->URLRequest
    {
        return URLRequest(url: URL(string: link)!)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        switch keyPath {
            
        case "loading":
            print("loading")
            
        case "estimatedProgress":
            progressView.isHidden = false
            
        default:
            break
        }

    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlStr = navigationAction.request.url?.absoluteString{
            Analytics.logEvent("Navigation", parameters: [
                "name": "User Navigated" as NSObject,
                "link": urlStr as NSObject
                ])
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView?
    {
        if (navigationAction.targetFrame == nil) {
            popupWebView = WKWebView(frame: self.mainView.frame, configuration: configuration)
            popupWebView.uiDelegate = self
            self.mainView.addSubview(popupWebView)
            popUpOpened = true
            return popupWebView
        }
        return nil;
    }
    
    func webViewDidClose(_ webView: WKWebView) {
         webView.removeFromSuperview()
    }
    
    @IBAction func MyPageTapped(_ sender: Any)
    {
        let trace = Performance.startTrace(name: "MyPage Tapped trace")
        webView.load(GetURL(link: myPageLink))
        Analytics.logEvent("MyPageTapped", parameters: [
            "Name": "MyPage" as NSObject,
            "Description": "MyPage Button Tapped" as NSObject
            ])
        trace?.stop()
    }
    @IBAction func NextTapped(_ sender: Any)
    {
        let trace = Performance.startTrace(name: "Next Tapped trace")
        if (webView.canGoForward)
        {
            webView.goForward()
        }
        Analytics.logEvent("ForwardTapped", parameters: [
            "Name": "Forward" as NSObject,
            "Description": "Forward Button Tapped" as NSObject
            ])
        trace?.stop()
    }
    @IBAction func BackTapped(_ sender: Any)
    {
        let trace = Performance.startTrace(name: "Back Tapped trace")
        if (popUpOpened)
        {
            popupWebView.removeFromSuperview()
            popUpOpened = false
        }
        if (webView.canGoBack)
        {
            webView.goBack()
        }
        Analytics.logEvent("BackTapped", parameters: [
            "Name": "Back" as NSObject,
            "Description": "Forward Button Tapped" as NSObject
            ])
        trace?.stop()
    }

    @IBAction func CartTapped(_ sender: Any)
    {
        let trace = Performance.startTrace(name: "Cart Tapped trace")
        webView.load(GetURL(link: cartLink))
        Analytics.logEvent("CartTapped", parameters: [
            "Name": "Cart" as NSObject,
            "Description": "Cart Button Tapped" as NSObject
            ])
        trace?.stop()
    }
    
    override var prefersStatusBarHidden: Bool{
        return true;
    }


}

