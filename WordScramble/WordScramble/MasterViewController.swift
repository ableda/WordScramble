//
//  MasterViewController.swift
//  WordScramble
//
//  Created by Alex Bleda on 14/04/16.
//  Copyright © 2016 Alex Bleda. All rights reserved.
//

import UIKit
import GameplayKit

class MasterViewController: UITableViewController {

   // var detailViewController: DetailViewController? = nil
    var objects = [String]()
    var allwords = [String]()
    
    let scoreBoard = UIBarButtonItem()
    var timerLabel = NSTimer()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "promptForAnswer")
        
        if let startWordsPath = NSBundle.mainBundle().pathForResource("start", ofType: ".txt"){
            if let startWords = try? String(contentsOfFile: startWordsPath, usedEncoding: nil){
                allwords = startWords.componentsSeparatedByString("\n")
            }
        }
        else {
            allwords = ["silkworm"]
        }
        
        
        scoreBoard.title = "Score: 0"
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.setToolbarItems([scoreBoard], animated: true)
        self.navigationController.
        
        startGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let object = objects[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }
    
    

    
    // MARK: GAME
    
    func startGame() {
        let ac1 = UIAlertController(title: "Welcome to Word Scramble!", message: "The goal of this game is to find as many hidden words as you can inside the title string given. Good Luck!", preferredStyle: .Alert)
        ac1.addAction(UIAlertAction(title: "Play", style: .Default, handler: nil))
        presentViewController(ac1, animated: true, completion: nil)
        
        allwords = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(allwords) as! [String]
        title = allwords[0]
        objects.removeAll(keepCapacity: true)
        tableView.reloadData()
    }
    
    func promptForAnswer(){
        let ac = UIAlertController(title: "Enter Answer:", message: nil, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler(nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Default){
            [unowned self, ac] action in let  answer = ac.textFields![0]
            self.submitAnswer(answer.text!)
        }
        
        ac.addAction(submitAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    
    var count = 0
    
    func submitAnswer(answer: String){
        let lowerAnswer = answer.lowercaseString
        
        let errorTitle: String
        let errorMessage: String
        
        if wordIsPossible(lowerAnswer){
            if wordIsOriginal(lowerAnswer){
                if wordIsReal(lowerAnswer){
                    objects.insert(answer, atIndex: 0)
                    
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    
                    count += 1
                    scoreBoard.title = "Score: \(count)"
                    
                    return
                }
                else {
                    errorTitle = "Word not recognized"
                    errorMessage = "You can't just make them up you know"
                }
            }
            else {
                errorTitle = "Word already used"
                errorMessage = "Be original, don't repeat!"
            }
        }
        else {
            errorTitle = "Word not possible"
            errorMessage = " You can't spell that word from '\(title!.lowercaseString)'!"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func wordIsPossible(word: String) -> Bool {
        var tempWord = title!.lowercaseString
        
        for letter in word.characters{
            if let pos = tempWord.rangeOfString(String(letter)){
                tempWord.removeAtIndex(pos.startIndex)
            }
            else { return false }
        }
        return true
    }
    
    func wordIsOriginal(word: String) -> Bool {
        return !objects.contains(word)
    }
    
    func wordIsReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.characters.count)
        let misspelledRange = checker.rangeOfMisspelledWordInString(word, range: range, startingAt: 0, wrap: false, language: "en")
        
        if word.characters.count < 2 {
            return false
        }
        return misspelledRange.location == NSNotFound
    }

}

