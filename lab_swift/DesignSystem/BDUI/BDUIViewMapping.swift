import UIKit

protocol BDUIViewMapping: AnyObject {
    func makeView(from model: BDUIView) -> UIView
}
