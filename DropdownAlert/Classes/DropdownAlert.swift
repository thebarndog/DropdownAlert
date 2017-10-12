//
//  DropdownAlert.swift
//  Pods
//
//  Created by Brendan Conron on 5/22/16.
//
//

import UIKit
import pop

/// Inspired by: https://github.com/cwRichardKim/RKDropdownAlert
/// but that wasn't written in swift so...
/// Plus, it's powered by pop!
public class DropdownAlert: UIView {

    // MARK: - Animation

    /**
     Animation types the dropdown can be presented with.

     - Basic:  Basic, simple animation.
     - Spring: Spring animation.
     - Custom: Custom animation.
     */
    public enum AnimationType {
        case Basic(timingFunction: CAMediaTimingFunction)
        case Spring(bounce: CGFloat, speed: CGFloat)
        case Custom(POPPropertyAnimation)
    }

    // MARK: - Views

        /// Alert title label.
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

        /// Alert message label.
    fileprivate lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Defaults

    /**
     Class defaults.
     */
    public struct Defaults {
        static public var BackgroundColor = UIColor.white
        static public var TextColor = UIColor.black
        static public var Title = "Default Title"
        static public var Message = "Default message!"
        static public var AnimationDuration: Double = 0.25
        static public var Duration: Double = 2
        static public var Height: CGFloat = 90
        static public var TitleFont: UIFont = UIFont.systemFont(ofSize: Defaults.FontSize)
        static public var MessageFont: UIFont = UIFont.systemFont(ofSize: Defaults.FontSize)
        static public var FontSize: CGFloat = 14 {
            didSet {
                TitleFont = TitleFont.withSize(FontSize)
                MessageFont = MessageFont.withSize(FontSize)
            }
        }
    }

    // MARK: - Initialization

    convenience public init() {
        self.init(frame: CGRect.zero)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

}

public extension DropdownAlert {

    /**
     Show the dropdown alert.

     - parameter animationType:       The kind of animation that will be shown.
     - parameter title:           Dropdown title.
     - parameter message:         Dropdown message.
     - parameter backgroundColor: Background color of the dropdown.
     - parameter textColor:       Text color of the dropdown.
     - parameter duration:        How long the dropdown will be shown before it's automatically dismissmed.
     */
    class func showWithAnimation(animationType: AnimationType = .Basic(timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)),
                                 title: String = Defaults.Title,
                                 message: String = Defaults.Message,
                                 backgroundColor: UIColor = Defaults.BackgroundColor,
                                 textColor: UIColor = Defaults.TextColor,
                                 duration: Double = Defaults.Duration) {
        // Ensure that everything happens on the main queue
        
        DispatchQueue.main.async {
            let windows = UIApplication.shared.windows.filter { $0.windowLevel == UIWindowLevelNormal && !$0.isHidden }
            guard let window = windows.first else {
                return
            }
            let dropdown = DropdownAlert()
            dropdown.translatesAutoresizingMaskIntoConstraints = false
            dropdown.titleLabel.text = title
            dropdown.messageLabel.text = message
            dropdown.titleLabel.textColor = textColor
            dropdown.messageLabel.textColor = textColor
            dropdown.backgroundColor = backgroundColor
            
            // Construct a padding view that will cover the top of the dropdown in the case of a spring animation where it bounces past it's bounds
            let paddingView = UIView()
            paddingView.backgroundColor = backgroundColor
            paddingView.translatesAutoresizingMaskIntoConstraints = false
            
            window.addSubview(dropdown)
            window.addSubview(paddingView)
            
            // Constraint that'll be animated
            let animatedConstraint = NSLayoutConstraint(item: dropdown, attribute: .bottom, relatedBy: .equal, toItem: window, attribute: .top, multiplier: 1, constant: 0)
            
            // Add the drop downconstraint
            window.addConstraint(NSLayoutConstraint(item: dropdown, attribute: .left, relatedBy: .equal, toItem: window, attribute: .left, multiplier: 1, constant: 0))
            window.addConstraint(NSLayoutConstraint(item: dropdown, attribute: .right, relatedBy: .equal, toItem: window, attribute: .right, multiplier: 1, constant: 0))
            window.addConstraint(NSLayoutConstraint(item: dropdown, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: Defaults.Height))
            window.addConstraint(animatedConstraint)
            // Add the padding view constraints
            window.addConstraint(NSLayoutConstraint(item: paddingView, attribute: .width, relatedBy: .equal, toItem: dropdown, attribute: .width, multiplier: 1, constant: 0))
            window.addConstraint(NSLayoutConstraint(item: paddingView, attribute: .height, relatedBy: .equal, toItem: dropdown, attribute: .height, multiplier: 1, constant: 0))
            window.addConstraint(NSLayoutConstraint(item: paddingView, attribute: .centerX, relatedBy: .equal, toItem: dropdown, attribute: .centerX, multiplier: 1, constant: 0))
            window.addConstraint(NSLayoutConstraint(item: paddingView, attribute: .bottom, relatedBy: .equal, toItem: dropdown, attribute: .top, multiplier: 1, constant: 0))
            
            window.layoutIfNeeded()
            
            let animation = self.popAnimationForAnimationType(animationType: animationType)
            animation?.toValue = Defaults.Height
            animatedConstraint.pop_add(animation, forKey: "show-dropdown")
            
            dropdown.perform(#selector(DropdownAlert.dismiss), with: nil, afterDelay: duration + Defaults.AnimationDuration)
        }
    }

    /**
     Dismiss the dropdown.

     - parameter dropdown: Dropdown object to dismiss.
     */
    private class func dismissAlert(dropdown: DropdownAlert) {
        guard let window = dropdown.superview as? UIWindow else {
            return
        }
        let constraints = window.constraints.filter { ($0.firstItem === dropdown || $0.secondItem === dropdown) && ($0.firstAttribute == .bottom || $0.secondAttribute == .bottom) && $0.isActive }
        guard let animatedConstraint = constraints.first else {
            return
        }
        DispatchQueue.main.async {
            if let dismissAnimation = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant){
                dismissAnimation.toValue = -Defaults.Height
                dismissAnimation.duration = Defaults.AnimationDuration
                animatedConstraint.pop_add(dismissAnimation, forKey: "dropdown-dismiss")
            }
        }
    }

    /**
     Dismiss the dropdown.
     */
    @objc public func dismiss() {
        type(of: self).dismissAlert(dropdown: self)
    }
}

// MARK: - Helpers
fileprivate extension DropdownAlert {

    /**
     Construct a full `POPAnimation` object for the corresponding animation types.

     - parameter animationType: `AnimationType` object that describes the desired animation.

     - returns: `POPPropertyAnimation` object.
     */
    class fileprivate func popAnimationForAnimationType(animationType: AnimationType) -> POPPropertyAnimation? {
        switch animationType {
        case let .Basic(timingFunction):
            let animation = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            animation?.duration = Defaults.AnimationDuration
            animation?.timingFunction = timingFunction
            return animation
        case let .Spring(bounce, speed):
            let animation = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            animation?.springBounciness = bounce
            animation?.springSpeed = speed
            return animation
        case let .Custom(a):
            return a
        }
    }
}


// MARK: Default Modifiers
public extension DropdownAlert {

    public class var defaultBackgroundColor: UIColor {
        get { return Defaults.BackgroundColor }
        set { Defaults.BackgroundColor = newValue }
    }

    public class var defaultTextColor: UIColor {
        get { return Defaults.TextColor }
        set { Defaults.TextColor = newValue }
    }

    public class var defaultTitle: String {
        get { return Defaults.Title }
        set { Defaults.Title = newValue }
    }

    public class var defaultMessage: String {
        get { return Defaults.Message }
        set { Defaults.Message = newValue }
    }

    public class var defaultAnimationDuration: Double {
        get { return Defaults.AnimationDuration }
        set { Defaults.AnimationDuration = newValue }
    }

    public class var defaultDuration: Double {
        get { return Defaults.Duration }
        set { Defaults.Duration = newValue }
    }

    public class var defaultHeight: CGFloat {
        get { return Defaults.Height }
        set { Defaults.Height = newValue }
    }

    public class var defaultTitleFont: UIFont {
        get { return Defaults.TitleFont }
        set { Defaults.TitleFont = newValue }
    }

    public class var defaultMessageFont: UIFont {
        get { return Defaults.MessageFont }
        set { Defaults.MessageFont = newValue }
    }

    public class var defaultFontSize: CGFloat {
        get { return Defaults.FontSize }
        set { Defaults.FontSize = newValue }
    }
}

// MARK: - Setup
fileprivate extension DropdownAlert {

    /**
     Common initialization function.
     */
    fileprivate func commonInit() {
        self.titleLabel.font = Defaults.TitleFont
        self.messageLabel.font = Defaults.MessageFont

        self.addSubview(self.titleLabel)
        self.addSubview(self.messageLabel)
        self.setupConstraints()
    }

    /**
     Setup the constraints for the dropdown's labels.
     */
    private func setupConstraints() {
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0))

        self.addConstraint(NSLayoutConstraint(item: self.messageLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.messageLabel, attribute: .top, relatedBy: .equal, toItem: self.titleLabel, attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.messageLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.messageLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0))

        self.layoutIfNeeded()

    }
}
