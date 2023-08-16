import UIKit

class SecondScreen: UIViewController {
    let BackButton = UIButton();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details Screen"
        setUpBackButton()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles  = true
    }
    
    func setUpBackButton(){
        view.addSubview(BackButton)
        BackButton.configuration = .filled()
        BackButton.configuration?.title = "Back"
        BackButton.configuration?.baseBackgroundColor = .systemPink
        BackButton.translatesAutoresizingMaskIntoConstraints = false
        BackButton.addTarget(self, action: #selector(GoBack), for: .touchUpInside)
        NSLayoutConstraint.activate([
            BackButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            BackButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            BackButton.widthAnchor.constraint(equalToConstant: 200),
            BackButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func GoBack(){
        navigationController?.popViewController(animated: true)
    }
}
