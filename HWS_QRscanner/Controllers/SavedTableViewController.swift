//
//  SavedTableViewController.swift
//  HWS_QRscanner
//
//  Created by Artjoms Vorona on 19/12/2019.
//  Copyright © 2019 Artjoms Vorona. All rights reserved.
//

import CoreData
import UIKit

class SavedTableViewController: UITableViewController {
    
    var items = [Item]()
    var context: NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    //MARK: - Core Data functions
    
    func loadData() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        do {
            items = try (context?.fetch(request))!
        } catch  {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    func saveData() {
        do {
            try context?.save()
        } catch {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)

        let item = items[indexPath.row]
        cell.textLabel?.text = "QR code: " + item.qrCode!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        cell.detailTextLabel?.text = "Scan date: " + dateFormatter.string(from: item.scanDate!)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = items[indexPath.row]
            self.items.remove(at: indexPath.row)
            self.context?.delete(itemToDelete)
            self.saveData()
        }   
    }

    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let webViewVC = storyboard.instantiateViewController(withIdentifier: "WebViewSBID") as? WebViewController else { return }
        
        let item = items[indexPath.row].qrCode!
        guard let url = URL(string: item) else { return }
        if UIApplication.shared.canOpenURL(url) {
            webViewVC.qrCode = item
            present(webViewVC, animated: true, completion: nil)
        } else {
            basicAlert(title: nil, message: "This is not correct web adress. Please try another.")
        }
    }

}
