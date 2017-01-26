//
//  ViewController.swift
//  Colors
//
//  Created by Juan Manuel Jimenez Sanchez on 25/01/17.
//  Copyright © 2017 Juan Manuel Jimenez Sanchez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var btnSwitch: UIButton!
    @IBOutlet weak var imgKnobBase: UIImageView!
    @IBOutlet weak var imgKnob: UIImageView!
    
    private var deltaAngle: CGFloat?
    private var startTransform: CGAffineTransform?
    
    //El punto de arriba
    private var setPointAngle = M_PI_2
    
    //Aquí establecemos nuestros limites tomando como referencia un angulo de 30%
    private var maxAngle = 7 * M_PI / 6
    private var minAngle = 0 - (M_PI / 6)
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imgKnob.isHidden = true
        self.imgKnobBase.isHidden = true
        self.imgKnob.isUserInteractionEnabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        self.btnSwitch.setImage(#imageLiteral(resourceName: "img_switch_off"), for: .normal)
        self.btnSwitch.setImage(#imageLiteral(resourceName: "img_switch_on"), for: .selected)
    }

    @IBAction func btnSwitchPressed(_ sender: UIButton) {
        self.btnSwitch.isSelected = !self.btnSwitch.isSelected
        if self.btnSwitch.isSelected {
            self.resetKnob()
            self.imgKnob.isHidden = false
            self.imgKnobBase.isHidden = false
        } else {
            self.view.backgroundColor = UIColor(hue: 0.5, saturation: 0, brightness: 0.2, alpha: 1.0)
            self.imgKnob.isHidden = true
            self.imgKnobBase.isHidden = true
        }
    }
    
    func resetKnob() {
        self.view.backgroundColor = UIColor(hue: 0.5, saturation: 0.5, brightness: 0.75, alpha: 1.0)
        
        //Le decimos que vuelva al punto donde estaba cuando fue creado
        self.imgKnob.transform = CGAffineTransform.identity
        
        self.setPointAngle = M_PI_2
    }
    
    private func touchIsInKnobWithDistance(distance: CGFloat) -> Bool {
        if distance > (self.imgKnob.bounds.height / 2) {//Estamos calculando el radio
            return false
        }
        
        return true
    }
    
    //Este es el teorema de pitagoras
    private func calculateDistanceFromCenter(_ point: CGPoint) -> CGFloat {
        let center = CGPoint(x: self.imgKnob.bounds.size.width / 2, y: self.imgKnob.bounds.size.height / 2)
        let dx = point.x - center.x
        let dy = point.y - center.y
        
        return sqrt((dx * dx) + (dy * dy))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let delta = touch.location(in: self.imgKnob)
            let dist = self.calculateDistanceFromCenter(delta)
            
            if self.touchIsInKnobWithDistance(distance: dist) {
                self.startTransform = self.imgKnob.transform
                let center = CGPoint(x: self.imgKnob.bounds.size.width / 2, y: self.imgKnob.bounds.size.height / 2)
                let deltaX = delta.x - center.x
                let deltaY = delta.y - center.y
                self.deltaAngle = atan2(deltaY, deltaX)
            }
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == self.imgKnob {
                self.deltaAngle = nil
                self.startTransform = nil
            }
        }
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let deltaAngle = self.deltaAngle, let startTransform = self.startTransform, touch.view == self.imgKnob {
            let position = touch.location(in: self.imgKnob)
            let dist = self.calculateDistanceFromCenter(position)
            if self.touchIsInKnobWithDistance(distance: dist) {
                //Vamos a calcular el angulo según arrastramos
                let center = CGPoint(x: self.imgKnob.bounds.size.width / 2, y: self.imgKnob.bounds.size.height / 2)
                let deltaX = position.x - center.x
                let deltaY = position.y - center.y
                let angle = atan2(deltaY, deltaX)
                
                //Y calculamos la distancia con el anterior
                let angleDif = deltaAngle - angle
                let newTransform = startTransform.rotated(by: -angleDif)//Para la imagen
                let lastSetPointAngle = self.setPointAngle
                
                //comprobamos que no nos hemos pasado de los limites mínimo y máximo.
                //Al anterior le sumamos lo que nos hemos movido
                self.setPointAngle = self.setPointAngle + Double(angleDif)
                if self.setPointAngle >= minAngle && self.setPointAngle <= maxAngle {
                    //Si está dentro de los margenes, cambiamos el color y le aplicamos la transformada
                    view.backgroundColor = UIColor(hue: self.colorValueFromAngle(angle: setPointAngle), saturation: 0.75, brightness: 0.75, alpha: 1.0)
                    self.imgKnob.transform = newTransform
                    self.startTransform = newTransform
                } else {
                    //Si se pasa lo dejamos en el limite
                    self.setPointAngle = lastSetPointAngle
                }
            }
        }
        super.touchesMoved(touches, with: event)
    }
    
    private func colorValueFromAngle(angle: Double) -> CGFloat {
        let hueValue = (angle - self.minAngle) * (360 / (self.maxAngle - self.minAngle))
        return CGFloat(hueValue / 360)
    }
}

