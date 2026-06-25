import UIKit
import MetalKit

class ViewController: UIViewController {
    private var metalView: MTKView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0)
        initializeBevy()
    }

    private func initializeBevy() {
        DispatchQueue.global(qos: .userInitiated).async {
            main_rs()
        }
    }
}
