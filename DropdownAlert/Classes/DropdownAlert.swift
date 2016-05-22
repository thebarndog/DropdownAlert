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

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .Center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .Center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Defaults

    private struct Defaults {
        static var BackgroundColor = UIColor.whiteColor()
        static var TextColor = UIColor.blackColor()
        static var Title = "Default Title"
        static var Message = "Default message!"
        static var AnimationDuration: Double = 0.25
        static var Duration: Double = 2
        static var Height: CGFloat = 90
        static var TitleFont: UIFont = UIFont.systemFontOfSize(Defaults.FontSize)
        static var MessageFont: UIFont = UIFont.systemFontOfSize(Defaults.FontSize)
        static var FontSize: CGFloat = 14 {
            didSet {
                TitleFont = TitleFont.fontWithSize(FontSize)
                MessageFont = MessageFont.fontWithSize(FontSize)
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
        let windows = UIApplication.sharedApplication().windows.filter { $0.windowLevel == UIWindowLevelNormal && !$0.hidden }
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
        let animatedConstraint = NSLayoutConstraint(item: dropdown, attribute: .Bottom, relatedBy: .Equal, toItem: window, attribute: .Top, multiplier: 1, constant: 0)

        // Add the drop downconstraint
        window.addConstraint(NSLayoutConstraint(item: dropdown, attribute: .Left, relatedBy: .Equal, toItem: window, attribute: .Left, multiplier: 1, constant: 0))
        window.addConstraint(NSLayoutConstraint(item: dropdown, attribute: .Right, relatedBy: .Equal, toItem: window, attribute: .Right, multiplier: 1, constant: 0))
        window.addConstraint(NSLayoutConstraint(item: dropdown, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Height, multiplier: 1, constant: Defaults.Height))
        window.addConstraint(animatedConstraint)
        // Add the padding view constraints
        window.addConstraint(NSLayoutConstraint(item: paddingView, attribute: .Width, relatedBy: .Equal, toItem: dropdown, attribute: .Width, multiplier: 1, constant: 0))
        window.addConstraint(NSLayoutConstraint(item: paddingView, attribute: .Height, relatedBy: .Equal, toItem: dropdown, attribute: .Height, multiplier: 1, constant: 0))
        window.addConstraint(NSLayoutConstraint(item: paddingView, attribute: .CenterX, relatedBy: .Equal, toItem: dropdown, attribute: .CenterX, multiplier: 1, constant: 0))
        window.addConstraint(NSLayoutConstraint(item: paddingView, attribute: .Bottom, relatedBy: .Equal, toItem: dropdown, attribute: .Top, multiplier: 1, constant: 0))

        window.layoutIfNeeded()

        let animation = self.popAnimationForAnimationType(animationType)
        animation.toValue = Defaults.Height
        animatedConstraint.pop_addAnimation(animation, forKey: "show-dropdown")

        dropdown.performSelector(#selector(dismiss), withObject: nil, afterDelay: duration + Defaults.AnimationDuration)
    }

    /**
     Dismiss the dropdown.

     - parameter dropdown: Dropdown object to dismiss.
     */
    private class func dismissAlert(dropdown: DropdownAlert) {
        guard let window = dropdown.superview as? UIWindow else {
            return
        }
        let constraints = window.constraints.filter { ($0.firstItem === dropdown || $0.secondItem === dropdown) && ($0.firstAttribute == .Bottom || $0.secondAttribute == .Bottom) && $0.active }
        guard let animatedConstraint = constraints.first else {
            return
        }
        let dismissAnimation = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        dismissAnimation.toValue = -Defaults.Height
        dismissAnimation.duration = Defaults.AnimationDuration
        animatedConstraint.pop_addAnimation(dismissAnimation, forKey: "dropdown-dismiss")
    }

    /**
     Dismiss the dropdown.
     */
    public func dismiss() {
        self.dynamicType.dismissAlert(self)
    }
}

// MARK: - Helpers
private extension DropdownAlert {

    /**
     Construct a full `POPAnimation` object for the corresponding animation types.

     - parameter animationType: `AnimationType` object that describes the desired animation.

     - returns: `POPPropertyAnimation` object.
     */
    class private func popAnimationForAnimationType(animationType: AnimationType) -> POPPropertyAnimation {
        switch animationType {
        case let .Basic(timingFunction):
            let animation = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            animation.duration = Defaults.AnimationDuration
            animation.timingFunction = timingFunction
            return animation
        case let .Spring(bounce, speed):
            let animation = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            animation.springBounciness = bounce
            animation.springSpeed = speed
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
private extension DropdownAlert {

    /**
     Common initialization function.
     */
    private func commonInit() {
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
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))

        self.addConstraint(NSLayoutConstraint(item: self.messageLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.messageLabel, attribute: .Top, relatedBy: .Equal, toItem: self.titleLabel, attribute: .Bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.messageLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.messageLabel, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        
        self.layoutIfNeeded()
        
    }
}

