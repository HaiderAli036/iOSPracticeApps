import UIKit

class CustomToast: UIView {

    private let messageLabel = UILabel()

    init(error:Bool=true,message: String) {
        super.init(frame: CGRect.zero)
        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.textColor = UIColor.white
        if error == true{
            messageLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)
        }else{
            messageLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
        }
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.layer.cornerRadius = 12
        messageLabel.layer.masksToBounds = true
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1),
            messageLabel.heightAnchor.constraint(equalToConstant: 50),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        layer.cornerRadius = 10
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(in view: UIView, duration: TimeInterval = 2.0) {
        view.addSubview(self)
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -40),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.removeFromSuperview()
        }
    }
}


