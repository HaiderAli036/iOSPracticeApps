import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var playerCard: UIImageView!
    @IBOutlet weak var PlayerScore: UILabel!
    @IBOutlet weak var CPUScore: UILabel!
    var hit:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func DealButton(_ sender: Any) {
        
        if var scoreValue = Int(PlayerScore.text ?? "") {
            scoreValue += 1
            if hit {
                if let newImage = UIImage(named: "card3") {
                    playerCard.image = newImage
                }
                PlayerScore.text = String(scoreValue)
                hit.toggle()
            }
            else{
                CPUScore.text = String(scoreValue)
                hit.toggle()
            }
        } else {
            CPUScore.text = String("0")
        }
    }
    
    
}

