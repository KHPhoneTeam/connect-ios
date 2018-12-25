import UIKit

protocol ToolbarPickerViewDelegate: class {
  func didTapDone()
  func didTapCancel()
}

class ToolbarPickerView: UIPickerView {
  
  public private(set) var toolbar: UIToolbar?
  public weak var toolbarDelegate: ToolbarPickerViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.commonInit()
  }
  
  private func commonInit() {
    let toolBar = UIToolbar()
    toolBar.barStyle = UIBarStyle.default
    toolBar.isTranslucent = true
    toolBar.tintColor = .black
    toolBar.sizeToFit()
    
    let doneButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(self.doneTapped))
    let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    let cancelButton = UIBarButtonItem(title: "Annnuleer", style: .plain, target: self, action: #selector(self.cancelTapped))
    
    toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
    toolBar.isUserInteractionEnabled = true
    
    self.toolbar = toolBar
  }
  
  @objc func doneTapped() {
    self.toolbarDelegate?.didTapDone()
  }
  
  @objc func cancelTapped() {
    self.toolbarDelegate?.didTapCancel()
  }
}
