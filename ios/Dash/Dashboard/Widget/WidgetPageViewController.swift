//
//  WidgetPageViewController.swift
//  Dash
//
//  Created by Yuji Nakayama on 2020/11/21.
//  Copyright © 2020 Yuji Nakayama. All rights reserved.
//

import UIKit

class WidgetPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    let pageControlHeight: CGFloat = 28
    let pageControlBottomMargin: CGFloat = 4

    lazy var widgetViewControllers: [UIViewController] = [
        RearviewWidgetViewController(),
        storyboard!.instantiateViewController(identifier: "LocationInformationWidgetViewController"),
        storyboard!.instantiateViewController(identifier: "GMeterWidgetViewController"),
        storyboard!.instantiateViewController(identifier: "AltitudeWidgetViewController"),
    ]

    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = widgetViewControllers.count
        pageControl.hidesForSinglePage = true

        view.addSubview(pageControl)

        pageControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: pageControlHeight),
            view.bottomAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: pageControlBottomMargin)
        ])

        return pageControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = self

        additionalSafeAreaInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: pageControlHeight + pageControlBottomMargin,
            right: 0
        )

        view.translatesAutoresizingMaskIntoConstraints = false
        _ = pageControl
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // We should not do this in viewDidLoad()
        // because setViewControllers() invokes the view controller's viewWillAppear() unintentionally.
        if viewControllers == nil || viewControllers!.isEmpty {
            setViewControllers([widgetViewControllers.first!], direction: .forward, animated: false)
            adaptPageControlColorToCurrentViewController()
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let nextIndex = widgetViewControllers.firstIndex(of: viewController) else { return nil }
        return widgetViewController(at: nextIndex - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let previousIndex = widgetViewControllers.firstIndex(of: viewController) else { return nil }
        return widgetViewController(at: previousIndex + 1)
    }

    private func widgetViewController(at index: Int) -> UIViewController? {
        let indexRange = widgetViewControllers.startIndex..<widgetViewControllers.endIndex

        if indexRange.contains(index) {
            return widgetViewControllers[index]
        } else {
            return nil
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentViewController = viewControllers?.first else { return }

        if let index = widgetViewControllers.firstIndex(of: currentViewController) {
            pageControl.currentPage = index
        }

        UIView.animate(withDuration: 0.5) {
            // We don't set `pageControl.overrideUserInterfaceStyle` here
            // since it's not animatable.
            self.adaptPageControlColorToCurrentViewController()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            adaptPageControlColorToCurrentViewController()
        }
    }

    private func adaptPageControlColorToCurrentViewController() {
        guard let currentViewController = viewControllers?.first else { return }
        let traitCollection = currentViewController.traitCollection
        pageControl.currentPageIndicatorTintColor = .secondaryLabel.resolvedColor(with: traitCollection)
        pageControl.pageIndicatorTintColor = .quaternaryLabel.resolvedColor(with: traitCollection)
    }
}
