//
//  ViewController.swift
//  UndoManager
//
//  Created by HS-jianxin on 2024/11/15.
//

import UIKit

class ViewController: UIViewController {

    let dragView = UIView(frame: CGRectMake(20, 100, 200, 200))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jx_setupUI()
    }
    
    //MARK: - Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        undoManager?.beginUndoGrouping()
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let currentPosition = touch?.location(in: dragView) ?? .zero
        let prePosition = touch?.previousLocation(in: dragView) ?? CGPoint.zero
        let dul = (currentPosition.x - prePosition.x, currentPosition.y - prePosition.y)
        tagViewStatusAction(newTransform: NSValue(cgAffineTransform: CGAffineTransformTranslate(dragView.transform, dul.0, dul.1)))
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        undoManager?.endUndoGrouping()
    }
    @objc func tagViewStatusAction(newCenter: NSValue) {
        // 先注册undo事件 先前值记录
        undoManager?.registerUndo(withTarget: self, selector: #selector(tagViewStatusAction(newCenter:)), object: NSValue(cgPoint: dragView.center))
        undoManager?.setActionName("dragView: center change")
        dragView.center = newCenter.cgPointValue
    }
    @objc func tagViewStatusAction(newTransform: NSValue) {
        // 先注册undo事件 先前值记录
        undoManager?.registerUndo(withTarget: self, selector: #selector(tagViewStatusAction(newTransform:)), object: NSValue(cgAffineTransform: dragView.transform))
        undoManager?.setActionName("dragView: transform change")
        dragView.transform = newTransform.cgAffineTransformValue
    }
    
    var itemsArray = [Int]()
    @objc func addItem(_ item: NSValue) {
        undoManager?.beginUndoGrouping()
        if itemsArray.count > 0 {
            undoManager?.registerUndo(withTarget: self, selector: #selector(reduceItem(_:)), object: NSValue(nonretainedObject: itemsArray.last))
        }
        itemsArray.append(item.nonretainedObjectValue as! Int)
        print(itemsArray.map({"\($0)"}).joined(separator: ","))
        undoManager?.endUndoGrouping()
    }
    @objc func reduceItem(_ item: NSValue) {
        undoManager?.beginUndoGrouping()
        undoManager?.registerUndo(withTarget: self, selector: #selector(addItem(_:)), object: NSValue(nonretainedObject: itemsArray.last))
        itemsArray.removeLast()
        print(itemsArray.map({"\($0)"}).joined(separator: ","))
        undoManager?.endUndoGrouping()
    }
    
    //MARK: - 视图
    private func jx_setupUI() {
        view.addSubview(dragView)
        dragView.backgroundColor = .red
        
        let button = UIButton(type: .custom)
        button.frame = CGRectMake(10, 100, 50, 30)
        button.setTitle("Redo", for: .normal)
        button.addTarget(self, action: #selector(redoClick), for: .touchUpInside)
        button.backgroundColor = UIColor(white: 0, alpha: 0.3)
        view.addSubview(button)
        
        let button2 = UIButton(type: .custom)
        button2.frame = CGRectMake(100, 100, 50, 30)
        button2.setTitle("Undo", for: .normal)
        button2.addTarget(self, action: #selector(undoClick), for: .touchUpInside)
        button2.backgroundColor = UIColor(white: 0, alpha: 0.3)
        view.addSubview(button2)
    }
    
    @objc func redoClick() {
        if undoManager?.canRedo == true {
            undoManager?.redo()
        }
    }
    @objc func undoClick() {
        if undoManager?.canUndo == true {
            undoManager?.undo()
        }
    }
}
