//
//  YTDAnimation.swift
//  YTDraggablePlayer
//
//  Created by Ana Paula on 6/6/16.
//  Copyright © 2016 Ana Paula. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum UIPanGestureRecognizerDirection {
    case undefined
    case up
    case down
    case left
    case right
}

extension YTFViewController {
    
    //MARK: Player Controls Animations
    
    func showPlayerControls() {
        if (!isMinimized) {
            UIView.animate(withDuration: 0.6, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.backPlayerControlsView.alpha = 0.55
                self.playerControlsView.alpha = 1.0
                self.minimizeButton.alpha = 1.0
                
                }, completion: nil)
            hideTimer?.invalidate()
            hideTimer = nil
            hideTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(YTFViewController.hidePlayerControls(_:)), userInfo: 1.0, repeats: false)
        }
    }
    
    func hidePlayerControls(_ dontAnimate: Bool) {
        if (dontAnimate) {
            self.backPlayerControlsView.alpha = 0.0
            self.playerControlsView.alpha = 0.0
        } else {
            if (isPlaying) {
                UIView.animate(withDuration: 0.6, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.backPlayerControlsView.alpha = 0.0
                    self.playerControlsView.alpha = 0.0
                    self.minimizeButton.alpha = 0.0
                    
                    }, completion: nil)
            }
        }
    }
    
    //MARK: Video Animations
    
    func setPlayerToFullscreen() {
        self.hidePlayerControls(true)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.minimizeButton.isHidden = true
            self.playerView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
            
            self.playerView.frame = CGRect(x: self.initialFirstViewFrame!.origin.x, y: self.initialFirstViewFrame!.origin.x, width: self.initialFirstViewFrame!.size.width, height: self.initialFirstViewFrame!.size.height)
            
            }, completion: { finished in
                self.isFullscreen = true
                self.fullscreen.setImage(UIImage(named: "unfullscreen"), for: UIControlState())
                
                let originY = self.initialFirstViewFrame!.size.width - self.playerControlsFrame!.height
                
                self.backPlayerControlsView.frame.origin.x = self.initialFirstViewFrame!.origin.x
                self.backPlayerControlsView.frame.origin.y = originY
                self.backPlayerControlsView.frame.size.width = self.initialFirstViewFrame!.size.height
                
                self.playerControlsView.frame.origin.x = self.initialFirstViewFrame!.origin.x
                self.playerControlsView.frame.origin.y = originY
                self.playerControlsView.frame.size.width = self.initialFirstViewFrame!.size.height
                
                self.showPlayerControls()
        })
    }
    
    func setPlayerToNormalScreen() {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.playerView.transform = CGAffineTransform(rotationAngle: 0)
            
            self.playerView.frame = CGRect(x: self.playerViewFrame!.origin.x, y: self.playerViewFrame!.origin.x, width: self.playerViewFrame!.size.width, height: self.playerViewFrame!.size.height)
            
            let originY = self.playerViewFrame!.size.height - self.playerControlsFrame!.height
            self.backPlayerControlsView.frame.origin.x = self.initialFirstViewFrame!.origin.x
            self.backPlayerControlsView.frame.origin.y = originY
            self.backPlayerControlsView.frame.size.width = self.playerViewFrame!.size.width
            
            self.playerControlsView.frame.origin.x = self.initialFirstViewFrame!.origin.x
            self.playerControlsView.frame.origin.y = originY
            self.playerControlsView.frame.size.width = self.playerViewFrame!.size.width
            
            }, completion: { finished in
                self.isFullscreen = false
                self.minimizeButton.isHidden = false
                self.fullscreen.setImage(UIImage(named: "fullscreen"), for: UIControlState())
        })
    }
    
    func panAction(_ recognizer: UIPanGestureRecognizer) {
        if (!isFullscreen) {
            let yPlayerLocation = recognizer.location(in: self.view?.window).y
            
            switch recognizer.state {
            case .began:
                onRecognizerStateBegan(yPlayerLocation, recognizer: recognizer)
                break
            case .changed:
                onRecognizerStateChanged(yPlayerLocation, recognizer: recognizer)
                break
            default:
                onRecognizerStateEnded(yPlayerLocation, recognizer: recognizer)
            }
        }
    }
    
    func onRecognizerStateBegan(_ yPlayerLocation: CGFloat, recognizer: UIPanGestureRecognizer) {
        tableViewContainer.backgroundColor = UIColor.white
        hidePlayerControls(true)
        panGestureDirection = UIPanGestureRecognizerDirection.undefined
        
        let velocity = recognizer.velocity(in: recognizer.view)
        detectPanDirection(velocity)
        
        touchPositionStartY = recognizer.location(in: self.playerView).y
        touchPositionStartX = recognizer.location(in: self.playerView).x
        
    }
    
    func onRecognizerStateChanged(_ yPlayerLocation: CGFloat, recognizer: UIPanGestureRecognizer) {
        if (panGestureDirection == UIPanGestureRecognizerDirection.down ||
            panGestureDirection == UIPanGestureRecognizerDirection.up) {
            let trueOffset = yPlayerLocation - touchPositionStartY!
            let xOffset = trueOffset * 0.35
            adjustViewOnVerticalPan(yPlayerLocation, trueOffset: trueOffset, xOffset: xOffset, recognizer: recognizer)
            
        } else {
            adjustViewOnHorizontalPan(recognizer)
        }
    }
    
    func onRecognizerStateEnded(_ yPlayerLocation: CGFloat, recognizer: UIPanGestureRecognizer) {
        if (panGestureDirection == UIPanGestureRecognizerDirection.down ||
            panGestureDirection == UIPanGestureRecognizerDirection.up) {
            if (self.view.frame.origin.y < 0) {
                expandViews()
                recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
                return
                
            } else {
                if (self.view.frame.origin.y > (initialFirstViewFrame!.size.height / 2)) {
                    minimizeViews()
                    recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
                    return
                } else {
                    expandViews()
                    recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
                }
            }
            
        } else if (panGestureDirection == UIPanGestureRecognizerDirection.left) {
            if (tableViewContainer.alpha <= 0) {
                if (self.view?.frame.origin.x < 0) {
                    removeViews()
                    
                } else {
                    animateViewToRightOrLeft(recognizer)
                    
                }
            }
            
        } else {
            if (tableViewContainer.alpha <= 0) {
                if (self.view?.frame.origin.x > initialFirstViewFrame!.size.width - 50) {
                    removeViews()
                    
                } else {
                    animateViewToRightOrLeft(recognizer)
                    
                }
                
            }
            
        }
    }
    
    func detectPanDirection(_ velocity: CGPoint) {
        minimizeButton.isHidden = true
        let isVerticalGesture = fabs(velocity.y) > fabs(velocity.x)
        
        if (isVerticalGesture) {
            
            if (velocity.y > 0) {
                panGestureDirection = UIPanGestureRecognizerDirection.down
            } else {
                panGestureDirection = UIPanGestureRecognizerDirection.up
            }
            
        } else {
            
            if (velocity.x > 0) {
                panGestureDirection = UIPanGestureRecognizerDirection.right
            } else {
                panGestureDirection = UIPanGestureRecognizerDirection.left
            }
        }
    }
    
    func adjustViewOnVerticalPan(_ yPlayerLocation: CGFloat, trueOffset: CGFloat, xOffset: CGFloat, recognizer: UIPanGestureRecognizer) {
        
        if (Float(trueOffset) >= (restrictTrueOffset! + 60) ||
            Float(xOffset) >= (restrictOffset! + 60)) {
            
            let trueOffset = initialFirstViewFrame!.size.height - 100
            let xOffset = initialFirstViewFrame!.size.width - 160
            
            //Use this offset to adjust the position of your view accordingly
            viewMinimizedFrame?.origin.y = trueOffset
            viewMinimizedFrame?.origin.x = xOffset - 6
            viewMinimizedFrame?.size.width = initialFirstViewFrame!.size.width
            
            playerViewMinimizedFrame!.size.width = self.view.bounds.size.width - xOffset
            playerViewMinimizedFrame!.size.height = 200 - xOffset * 0.5
            
            UIView.animate(withDuration: 0.05, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.playerView.frame = self.playerViewMinimizedFrame!
                self.view.frame = self.viewMinimizedFrame!
                self.tableViewContainer.alpha = 0.0
                }, completion: { finished in
                    self.isMinimized = true
            })
            recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
            
        } else {
            //Use this offset to adjust the position of your view accordingly
            viewMinimizedFrame?.origin.y = trueOffset
            viewMinimizedFrame?.origin.x = xOffset - 6
            viewMinimizedFrame?.size.width = initialFirstViewFrame!.size.width
            
            playerViewMinimizedFrame!.size.width = self.view.bounds.size.width - xOffset
            playerViewMinimizedFrame!.size.height = 200 - xOffset * 0.5
            
            let restrictY = initialFirstViewFrame!.size.height - playerView!.frame.size.height - 10
            
            if (self.tableView.frame.origin.y < restrictY && self.tableView.frame.origin.y > 0) {
                UIView.animate(withDuration: 0.09, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    self.playerView.frame = self.playerViewMinimizedFrame!
                    self.view.frame = self.viewMinimizedFrame!
                    
                    let percentage = (yPlayerLocation + 200) / self.initialFirstViewFrame!.size.height
                    self.tableViewContainer.alpha = 1.0 - percentage
                    self.transparentView!.alpha = 1.0 - percentage
                    
                    }, completion: { finished in
                        if (self.panGestureDirection == UIPanGestureRecognizerDirection.down) {
                            self.onView?.bringSubview(toFront: self.view)
                        }
                })
                
            } else if (viewMinimizedFrame!.origin.y < restrictY && viewMinimizedFrame!.origin.y > 0) {
                UIView.animate(withDuration: 0.09, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    self.playerView.frame = self.playerViewMinimizedFrame!
                    self.view.frame = self.viewMinimizedFrame!
                    
                    }, completion: nil)
            }
            
            recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
        }
    }
    
    func adjustViewOnHorizontalPan(_ recognizer: UIPanGestureRecognizer) {
        let x = self.view.frame.origin.x
        
        if (panGestureDirection == UIPanGestureRecognizerDirection.left ||
            panGestureDirection == UIPanGestureRecognizerDirection.right) {
            if (self.tableViewContainer.alpha <= 0) {
                let velocity = recognizer.velocity(in: recognizer.view)
                
                let isVerticalGesture = fabs(velocity.y) > fabs(velocity.x)
                
                let translation = recognizer.translation(in: self.view)
                self.view?.center = CGPoint(x: self.view!.center.x + translation.x, y: self.view!.center.y)
                
                if (!isVerticalGesture) {
                    recognizer.view?.alpha = detectHorizontalPanRecognizerViewAlpha(x, velocity: velocity, recognizer: recognizer)
                }
                recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
            }
            
        }
    }
    
    func detectHorizontalPanRecognizerViewAlpha(_ x: CGFloat, velocity: CGPoint, recognizer: UIPanGestureRecognizer) -> CGFloat {
        let percentage = x / self.initialFirstViewFrame!.size.width
        
        if (panGestureDirection == UIPanGestureRecognizerDirection.left) {
            return percentage
            
        } else {
            if (velocity.x > 0) {
                return 1.0 - percentage
            } else {
                return percentage
            }
        }
    }
    
    func animateViewToRightOrLeft(_ recognizer: UIPanGestureRecognizer) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.view.frame = self.viewMinimizedFrame!
            self.playerView!.frame = self.playerViewFrame!
            self.playerView.frame = CGRect(x: self.playerView!.frame.origin.x, y: self.playerView!.frame.origin.x, width: self.playerViewMinimizedFrame!.size.width, height: self.playerViewMinimizedFrame!.size.height)
            self.tableViewContainer!.alpha = 0.0
            self.playerView.alpha = 1.0
            
            }, completion: nil)
        
        recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
        
    }
    
    func minimizeViews() {
        tableViewContainer.backgroundColor = UIColor.white
        minimizeButton.isHidden = true
        hidePlayerControls(true)
        let trueOffset = initialFirstViewFrame!.size.height - 100
        let xOffset = initialFirstViewFrame!.size.width - 160
        
        viewMinimizedFrame!.origin.y = trueOffset + 2
        viewMinimizedFrame!.origin.x = xOffset - 6
        viewMinimizedFrame!.size.width = initialFirstViewFrame!.size.width
        
        playerViewMinimizedFrame!.size.width = self.view.bounds.size.width - xOffset
        playerViewMinimizedFrame!.size.height = playerViewMinimizedFrame!.size.width / (16/9)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.playerView.frame = self.playerViewMinimizedFrame!
            self.view.frame = self.viewMinimizedFrame!
            
            self.playerView.layer.borderWidth = 1
            self.playerView.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 0.5).cgColor
            
            self.tableViewContainer.alpha = 0.0
            self.transparentView?.alpha = 0.0
            }, completion: { finished in
                self.isMinimized = true
                if let playerGesture = self.playerTapGesture {
                    self.playerView.removeGestureRecognizer(playerGesture)
                }
                self.playerTapGesture = nil
                self.playerTapGesture = UITapGestureRecognizer(target: self, action: #selector(YTFViewController.expandViews))
                self.playerView.addGestureRecognizer(self.playerTapGesture!)
                
                self.view.frame.size.height = self.playerView.frame.height
                
                UIApplication.shared.setStatusBarHidden(false, with: .fade)
        })
    }
    
    func expandViews() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            self.playerView.frame = self.playerViewFrame!
            self.view.frame = self.initialFirstViewFrame!
            self.playerView.alpha = 1.0
            self.tableViewContainer.alpha = 1.0
            self.transparentView?.alpha = 1.0
            }, completion: { finished in
                self.isMinimized = false
                self.minimizeButton.isHidden = false
                self.playerView.removeGestureRecognizer(self.playerTapGesture!)
                self.playerTapGesture = nil
                self.playerTapGesture = UITapGestureRecognizer(target: self, action: #selector(YTFViewController.showPlayerControls))
                self.playerView.addGestureRecognizer(self.playerTapGesture!)
                self.tableViewContainer.backgroundColor = UIColor.black
                self.showPlayerControls()
        })
    }
    
    func finishViewAnimated(_ animated: Bool) {
        if (animated) {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.view.frame = CGRect(x: 0.0, y: self.view!.frame.origin.y, width: self.view!.frame.size.width, height: self.view!.frame.size.height)
                self.view.alpha = 0.0
                
                }, completion: { finished in
                    self.removeViews()
            })
        } else {
            removeViews()
        }
    }
    
    func removeViews() {
        self.view.removeFromSuperview()
        self.playerView.resetPlayer()
        self.playerView.removeFromSuperview()
        self.tableView.removeFromSuperview()
        self.tableViewContainer.removeFromSuperview()
        self.transparentView?.removeFromSuperview()
        self.playerControlsView.removeFromSuperview()
        self.backPlayerControlsView.removeFromSuperview()
    }
    
}
