//
//  TimeDurationPicker.swift
//  Dash
//
//  Created by Yuji Nakayama on 2021/05/01.
//  Copyright © 2021 Yuji Nakayama. All rights reserved.
//

import UIKit

@IBDesignable class TimeDurationPicker: UIControl, UIPickerViewDataSource, UIPickerViewDelegate {
    var durations: [TimeInterval] = [] {
        didSet {
            pickerView.reloadAllComponents()
            invalidateIntrinsicContentSize()
        }
    }

    var selectedDuration: TimeInterval? {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        guard selectedRow <= durations.count - 1 else { return nil }
        return durations[selectedRow]
    }

    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()

    private lazy var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        return formatter
    }()

    private var heightConstraint: NSLayoutConstraint?

    private let fontMetrics = UIFontMetrics(forTextStyle: .title2)
    private lazy var font = fontMetrics.scaledFont(for: UIFont.monospacedDigitSystemFont(ofSize: 23, weight: .regular))

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
        durations = [TimeInterval(30) * 60]
    }

    private func commonInit() {
        clipsToBounds = true

        addSubview(pickerView)

        pickerView.translatesAutoresizingMaskIntoConstraints = false

        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        updateHeightConstraint()

        NSLayoutConstraint.activate([
            heightConstraint!,
            pickerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            pickerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    private func updateHeightConstraint() {
        guard let heightConstraint = heightConstraint else { return }
        heightConstraint.constant = rowHeight + 2
        setNeedsLayout()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: maxLabelWidth + 40, height: heightConstraint?.constant ?? 0)
    }

    private var maxLabelWidth: CGFloat {
        let label = makeLabel()

        let widths: [CGFloat] = durations.map { (duration) in
            label.text = formatter.string(from: duration)
            label.sizeToFit()
            return label.frame.width
        }

        return widths.max() ?? 0
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return durations.count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? makeLabel()
        label.text = formatter.string(from: durations[row])
        return label
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return rowHeight
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sendActions(for: .valueChanged)
    }

    private var rowHeight: CGFloat {
        return fontMetrics.scaledValue(for: 35)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateHeightConstraint()
        pickerView.setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    private func makeLabel() -> UILabel {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = font
        label.textAlignment = .center
        return label
    }
}
