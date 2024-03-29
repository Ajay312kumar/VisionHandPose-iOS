
import UIKit

protocol SwipeCardsDataSource {
    func numberOfCardsToShow() -> Int
    func card(at index: Int) -> TinderCardView
    func emptyView() -> UIView?
    
}

protocol SwipeCardsDelegate {
    func swipeDidEnd(on view: TinderCardView)
}

class TinderCardView : UIView {
   
    //MARK: - Properties
    var swipeImageView: UIImageView!
    var delegate: SwipeCardsDelegate?
    
    var dataSource: DataModel? {
        didSet {
            swipeImageView.image = dataSource?.image
        }
    }
    
    //MARK: - Init
     override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureSwipeView()
        addPanGestureOnCards()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configuration
    
    func configureSwipeView() {
           swipeImageView = UIImageView()
           swipeImageView.contentMode = .scaleAspectFill // Adjust content mode as needed
           swipeImageView.layer.cornerRadius = 15
           swipeImageView.clipsToBounds = true
           addSubview(swipeImageView)
           
           swipeImageView.translatesAutoresizingMaskIntoConstraints = false
           swipeImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
           swipeImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
           swipeImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
           swipeImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
       }
    
    
    func addPanGestureOnCards() {
        self.isUserInteractionEnabled = true
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)))
    }
    
    func leftSwipeClicked(stackContainerView: StackContainerView)
    {
        let finishPoint = CGPoint(x: center.x - frame.size.width * 2, y: center.y)
        UIView.animate(withDuration: 0.4, animations: {() -> Void in

            self.center = finishPoint
            self.transform = CGAffineTransform(rotationAngle: -1)

        }, completion: {(_ complete: Bool) -> Void in
            stackContainerView.swipeDidEnd(on: self)
            self.removeFromSuperview()

        })
    }

    func rightSwipeClicked(stackContainerView: StackContainerView)
    {
        let finishPoint = CGPoint(x: center.x + frame.size.width * 2, y: center.y)
        UIView.animate(withDuration: 0.4, animations: {() -> Void in

            self.center = finishPoint
            self.transform = CGAffineTransform(rotationAngle: 1)

        }, completion: {(_ complete: Bool) -> Void in
            stackContainerView.swipeDidEnd(on: self)
            self.removeFromSuperview()

        })
    }
    
    //MARK: - Handlers
    @objc func handlePanGesture(sender: UIPanGestureRecognizer){
        let card = sender.view as! TinderCardView
        let point = sender.translation(in: self)
        let centerOfParentContainer = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        card.center = CGPoint(x: centerOfParentContainer.x + point.x, y: centerOfParentContainer.y + point.y)
        
        switch sender.state {
        case .ended:
            if (card.center.x) > 400 {
                delegate?.swipeDidEnd(on: card)
                UIView.animate(withDuration: 0.2) {
                    card.center = CGPoint(x: centerOfParentContainer.x + point.x + 200, y: centerOfParentContainer.y + point.y + 75)
                    card.alpha = 0
                    self.layoutIfNeeded()
                }
                return
            }else if card.center.x < -65 {
                delegate?.swipeDidEnd(on: card)
                UIView.animate(withDuration: 0.2) {
                    card.center = CGPoint(x: centerOfParentContainer.x + point.x - 200, y: centerOfParentContainer.y + point.y + 75)
                    card.alpha = 0
                    self.layoutIfNeeded()
                }
                return
            }
            UIView.animate(withDuration: 0.2) {
                card.transform = .identity
                card.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
                self.layoutIfNeeded()
            }
        case .changed:
            let rotation = tan(point.x / (self.frame.width * 2.0))
            card.transform = CGAffineTransform(rotationAngle: rotation)
            
        default:
            break
        }
    }
}
