//
//  ViewController.swift
//  Googly Eyes
//
//  Created by Emily Blackwell on 11/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import Cocoa
import SpriteKit


class ViewController: NSViewController, DragAndDropViewDelegate {
	
	@IBOutlet weak var sceneView: SKView!
	@IBOutlet weak var scrollView: NSScrollView!
	@IBOutlet weak var processingIndicator: NSProgressIndicator!
	
	var dndView: DragAndDropView! {
		return (self.view as! DragAndDropView)
	}

	override func viewDidLoad() {
	
		super.viewDidLoad()

		self.dndView.delegate = self
		sceneView.frame.size = .zero
	}
	
	// MARK: D&D Delegate
	
	func imageDropped(image: NSImage) {
		self.setPhoto(photo: image)
	}
}

