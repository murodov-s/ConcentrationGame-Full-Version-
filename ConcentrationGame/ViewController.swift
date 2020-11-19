//
//  ViewController.swift
//  ConcentrationGame
//
//  Created by user181171 on 11/12/20.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    

    @IBOutlet weak var TimerLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var model = CardModel()
    var cardArray = [Card]()
    
    var firstFlippedCardIndex:IndexPath?
    
    var timer:Timer?
    var milliseconds:Float = 60 * 1000 //60 seconds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Call the getCards method of the card model
        cardArray = model.getCards()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Create timer
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerElapsed), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any recources that can be recreated.
    }
    
    // MARK: - Timer Methods
    
    @objc func timerElapsed(){
        milliseconds -= 1
        
        //Convertn miliseconds to seconds
        let seconds = String(format: "%.2f", milliseconds / 1000)
        
        //Set label
        TimerLabel.text = "Time Remaining: \(seconds)"
        
        //When the timer has reached 0...
        if milliseconds <= 0 {
            
            //Stop the timer
            timer?.invalidate()
            TimerLabel.textColor = UIColor.red
            
            //Check if there is any cards unmatched
            checkGameEnded()
        }
        
    }
    
    // MARK: - UICollectionView Protocol Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return cardArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get a CardCollectionViewCell object
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        
        // Get the card that the collectionView is trying to display
        let card = cardArray[indexPath.row]
        
        cell .setCard(card)
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Check if there is any time left
        if milliseconds <= 0 {
            return
        }
        
        // Get the cell that the user selected
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        
        //Get the card that the user selected
        let card = cardArray[indexPath.row]
    
        if card.isFlipped == false && card.isMatched == false {
            
            //Flip the card
            cell.flip()
            
            //Set the status of the card
            card.isFlipped = true
            
            //Determine if it is the first card or the second cartd that is flipped over
            
            if firstFlippedCardIndex == nil {
                
                //This is the first card being flipped
                
                firstFlippedCardIndex = indexPath
            }
            else {
                
                //This is the second card being flipped
                
                //Preform the matching logic
                checkForMatches(indexPath)
            }
        }
        
    }
    
    // MARK: -> Game Logic Methods
    
    func checkForMatches(_ secondFlippedCardIndex:IndexPath){
        
        //Get the cells for the two cards that were revealed
        
        let cardOneCell = collectionView.cellForItem(at: firstFlippedCardIndex!) as? CardCollectionViewCell
        
        let cardTwoCell = collectionView.cellForItem(at: secondFlippedCardIndex) as? CardCollectionViewCell
        
        let cardOne = cardArray[firstFlippedCardIndex!.row]
        let cardTwo = cardArray[secondFlippedCardIndex.row]
        
        //Compare the two cards
        if cardOne.imageName == cardTwo.imageName {
            
            //It's a match
            
            //Set the statuses of the cards
            cardOne.isMatched = true
            cardTwo.isMatched = true
            
            //Remove them from the grid
            cardOneCell?.remove()
            cardTwoCell?.remove()
            
            //Check if there are any cards left unmached
            checkGameEnded()
            
        }
        else{
            
            //It's not a match
            
            //Set the statuses of the cards
            cardOne.isFlipped = false
            cardTwo.isFlipped = false
            
            //Flip both cards back
            cardOneCell?.flipBack()
            cardTwoCell?.flipBack()
            
        }
        // Tell the collection view to reload the cell of the first card if it is nil
        if cardOneCell == nil {
            collectionView.reloadItems(at: [firstFlippedCardIndex!])
        }
        
        // Reset the property that tracks the first card flipped
        firstFlippedCardIndex = nil
    }
    
    func checkGameEnded() {
        
        // Determine if there are any cards unmatched
        var isWon = true
        
        for card in cardArray{
            
            if card.isMatched == false {
                isWon = false
                break
            }
        }
        // Messaging variables
        var title = ""
        var message = ""
        
        
        // If not, then user has won, stop the timer
        if isWon == true {
            
            if milliseconds > 0 {
                timer?.invalidate()
            }
            title = "Congratulations!"
            message = "You've won"
            
        }
        else {
            // If there are unmatched cards, check if there is any time left
            
            if milliseconds > 0 {
                return
            }
            title = "Game Over!"
            message = "You've Lost"
        }
        // Show won/lose messages
        showAlert(title, message: message)
        
    }
    
    func showAlert(_ title:String, message:String) {
    
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

