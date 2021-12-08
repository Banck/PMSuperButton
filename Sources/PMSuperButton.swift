//
//  PMSuperButton.swift
//  PMSuperButton
//
//  Created by Paolo Musolino on 14/06/17.
//  Copyright © 2018 PMSuperButton. All rights reserved.
//

import UIKit

@IBDesignable
open class PMSuperButton: UIButton {
    
    //MARK: - General Appearance
    @IBInspectable open var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable open var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            if let gradientLayer = gradient {
                gradientLayer.cornerRadius = cornerRadius
            }
        }
    }
    
    @IBInspectable open var shadowColor: UIColor = .clear {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable open var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable open var shadowOffset: CGSize = .zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable open var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable open var gradientEnabled: Bool = false {
        didSet {
            setupGradient()
        }
    }
    
    //MARK: - Gradient Background
    @IBInspectable open var gradientStartColor: UIColor = .clear {
        didSet {
            setupGradient()
        }
    }
    
    @IBInspectable open var gradientEndColor: UIColor = .clear{
        didSet {
            setupGradient()
        }
    }
    
    @IBInspectable open var gradientHorizontal: Bool = false {
        didSet {
            setupGradient()
        }
    }
    
    var gradient: CAGradientLayer?
    
    func setupGradient() {
        gradient?.removeFromSuperlayer()
        
        guard gradientEnabled else { return }
        
        gradient = CAGradientLayer()
        guard let gradient = gradient else { return }
        
        gradient.frame = layer.bounds
        gradient.colors = [gradientStartColor.cgColor, gradientEndColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = gradientHorizontal ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 1)
        
        gradient.cornerRadius = cornerRadius
        
        layer.insertSublayer(gradient, below: imageView?.layer)
    }
    
    //MARK: - Animations
    @IBInspectable open var animatedScaleWhenHighlighted: CGFloat = 1.0
    @IBInspectable open var animatedScaleDurationWhenHighlighted: Double = 0.2
    
    override open var isHighlighted: Bool {
        didSet {
            guard animatedScaleWhenHighlighted != 1.0 else { return }
            
            if isHighlighted {
                UIView.animate(withDuration: animatedScaleDurationWhenHighlighted) {
                    self.transform = CGAffineTransform(scaleX: self.animatedScaleWhenHighlighted,
                                                       y: self.animatedScaleWhenHighlighted)
                }
            } else {
                UIView.animate(withDuration: animatedScaleDurationWhenHighlighted) {
                    self.transform = .identity
                }
            }
        }
    }
    
    @IBInspectable open var animatedScaleWhenSelected: CGFloat = 1.0
    @IBInspectable open var animatedScaleDurationWhenSelected: Double = 0.2
    
    override open var isSelected: Bool {
        didSet {
            guard animatedScaleWhenSelected != 1.0 else { return }
            
            UIView.animate(withDuration: animatedScaleDurationWhenSelected) {
                self.transform = CGAffineTransform(scaleX: self.animatedScaleWhenSelected,
                                                   y: self.animatedScaleWhenSelected)
            } completion: { _ in
                UIView.animate(withDuration: self.animatedScaleDurationWhenSelected) {
                    self.transform = .identity
                }
            }
        }
    }
    
    //MARK: - Ripple button
    @IBInspectable open var ripple: Bool = false {
        didSet {
            clipsToBounds = true
        }
    }
    
    @IBInspectable open var rippleColor: UIColor = UIColor(white: 1.0, alpha: 0.3)
    @IBInspectable open var rippleSpeed: Double = 1.0
    
    //MARK: - Checkbox
    @IBInspectable open var checkboxButton: Bool = false{
        didSet {
            guard checkboxButton else { return }
            setImage(uncheckedImage, for: .normal)
            setImage(checkedImage, for: .selected)
            addTarget(self, action: #selector(buttonChecked), for: .touchUpInside)
        }
    }
    
    @IBInspectable open var checkedImage: UIImage?
    @IBInspectable open var uncheckedImage: UIImage?
    
    @objc func buttonChecked() {
        isSelected = !isSelected
    }
    
    //MARK: - Image
    ///Image UIButton content mode
    @IBInspectable open var imageViewContentMode: Int = UIView.ContentMode.scaleToFill.rawValue {
        didSet {
            imageView?.contentMode = UIView.ContentMode(rawValue: imageViewContentMode) ?? .scaleToFill
        }
    }
    
    @IBInspectable open var imageAlpha: CGFloat = 1.0 {
        didSet {
            if let imageView = imageView {
                imageView.alpha = imageAlpha
            }
        }
    }
    
    //MARK: - Action Closure
    private var action: (() -> Void)?
    
    open func touchUpInside(action: (() -> Void)? = nil) {
        self.action = action
    }
    
    @objc func tapped(sender: PMSuperButton) {
        self.action?()
    }
    
    //MARK: - Loading
    let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    public var isLoading: Bool = false
    /**
     Show a loader inside the button, and enable or disable user interection while loading
     */
    open func showLoader(userInteraction: Bool = true, hideTitle: Bool = true, tintColor: UIColor? = nil) {
        guard !subviews.contains(indicator) else { return }
        
        isLoading = true
        isUserInteractionEnabled = userInteraction
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isUserInteractionEnabled = false
        
        addSubview(indicator)
        if hideTitle {
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: indicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: indicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            ])
        } else {
            contentEdgeInsets = UIEdgeInsets(top: contentEdgeInsets.top, left: contentEdgeInsets.left, bottom: contentEdgeInsets.bottom, right: contentEdgeInsets.right + 10)
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: indicator, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -10),
                NSLayoutConstraint(item: indicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            ])
        }

        layoutIfNeeded()
        
        if let tintColor = tintColor {
            indicator.color = tintColor
        }

        indicator.alpha = 0
        indicator.startAnimating()
        
        titleLabel?.alpha = 1.0
        imageAlpha = 0.0
        
        UIView.transition(with: self, duration: 0.25, options: .curveEaseOut) {
            self.titleLabel?.alpha = hideTitle ? 0.0 : 1.0
            self.imageAlpha = 0.0
            self.indicator.alpha = 1.0
        }
    }
    
    open func hideLoader() {
        guard subviews.contains(indicator) else { return }
        
        isLoading = false
        isUserInteractionEnabled = true
        
        indicator.stopAnimating()
        indicator.removeFromSuperview()
        
        if titleLabel?.alpha == 1.0 {
            contentEdgeInsets = UIEdgeInsets(top: contentEdgeInsets.top, left: contentEdgeInsets.left, bottom: contentEdgeInsets.bottom, right: contentEdgeInsets.right - 10)
        }
        
        UIView.transition(with: self, duration: 0.25, options: .curveEaseIn) {
            self.titleLabel?.alpha = 1.0
            self.imageAlpha = 1.0
            self.indicator.alpha = 0.0
        }
    }
    
    //MARK: - Interface Builder Methods
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        gradient?.frame = layer.bounds
        imageView?.alpha = imageAlpha
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
    
    override open func prepareForInterfaceBuilder() { }
}

extension PMSuperButton: CAAnimationDelegate {
    
    //MARK: Material touch animation for ripple button
    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard ripple else { return true }
        
        let tapLocation = touch.location(in: self)
        
        let aLayer = CALayer()
        aLayer.backgroundColor = rippleColor.cgColor
        let initialSize: CGFloat = 20.0
        
        aLayer.frame = CGRect(x: 0, y: 0, width: initialSize, height: initialSize)
        aLayer.cornerRadius = initialSize / 2
        aLayer.masksToBounds = true
        aLayer.position = tapLocation
        layer.insertSublayer(aLayer, below: titleLabel?.layer)
        
        // Create a basic animation changing the transform.scale value
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        // Set the initial and the final values+
        animation.toValue = 10.5 * max(frame.size.width, frame.size.height) / initialSize
        
        // Set duration
        animation.duration = rippleSpeed
        
        // Set animation to be consistent on completion
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        
        // Add animation to the view's layer
        let fade = CAKeyframeAnimation(keyPath: "opacity")
        fade.values = [1.0, 1.0, 0.5, 0.5, 0.0]
        fade.duration = 0.5
        
        let animGroup = CAAnimationGroup()
        animGroup.duration = 0.5
        animGroup.delegate = self
        animGroup.animations = [animation, fade]
        animGroup.setValue(aLayer, forKey: "animationLayer")
        aLayer.add(animGroup, forKey: "scale")
        
        return true
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let layer: CALayer? = anim.value(forKeyPath: "animationLayer") as? CALayer
        if layer != nil {
            layer?.removeAnimation(forKey: "scale")
            layer?.removeFromSuperlayer()
        }
    }
}
