//
//  SKButton.swift
//  Asteroid Blaster
//
//  Created by Brandon Groff on 12/6/15.
//  Copyright © 2015 Brandon Groff. All rights reserved.
//

import SpriteKit

@objc protocol SKButtonDelegate {
    optional func buttonTapDown(sender: SKButton)
    func buttonTapRelease(sender: SKButton)
}

class SKButton: SKNode {

    var delegate: SKButtonDelegate?
    private var defaultButton: SKSpriteNode
    private var onTapButton: SKSpriteNode
    //private var action: ()? -> Void
    static let font = "Chalkduster"
    static let fontSize:CGFloat = 32
    private var label:SKLabelNode?
    
    init(defaultButtonImage: String, onTapButtonImage: String, buttonText: String?){
        self.defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        self.onTapButton = SKSpriteNode(imageNamed: onTapButtonImage)
        self.onTapButton.hidden = true
        //action = buttonAction
        if (buttonText != nil){
            self.label = SKButton.createLabel(buttonText!)
        }
        
        super.init()
        self.name = "SKButton"
        userInteractionEnabled = true
        addChild(self.defaultButton)
        addChild(self.onTapButton)
        if (self.label != nil){
            self.label?.position = CGPoint(x: self.defaultButton.position.x , y: self.defaultButton.position.y - 10)
            addChild(self.label!)
        }
    }
    
    convenience init(defaultButtonImage: String, onTapButtonImage: String) {
        self.init(defaultButtonImage: defaultButtonImage, onTapButtonImage: onTapButtonImage, buttonText: nil)
    }
    
    private class func createLabel(text: String) -> SKLabelNode{
        let newLabel = SKLabelNode(text: text)
        newLabel.zPosition = 10
        newLabel.fontColor = UIColor.whiteColor()
        newLabel.fontName = SKButton.font
        newLabel.fontSize = SKButton.fontSize
        return newLabel
    }
    
    /**
     Required so XCode doesn't throw warnings
     */
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.onTapButton.hidden = false
        self.defaultButton.hidden = true
        self.delegate?.buttonTapDown?(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.defaultButton.hidden = false
        self.onTapButton.hidden = true
        self.delegate?.buttonTapRelease(self)
    }
}
