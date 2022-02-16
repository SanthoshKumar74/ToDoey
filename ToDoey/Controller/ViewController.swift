//
//  ViewController.swift
//  ToDoey
//
//  Created by Santhosh Kumar on 27/12/21.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    var itemArray = [Items]()
    var selectedCategory : Categories? {
        didSet{
            loadItems()}
    }
    @IBOutlet weak var searchBar: UISearchBar!
    //let defaults = UserDefaults.standard
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
    }
    // Mark - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        self.saveItems()
    }
    
    @IBAction func AddItem(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let item = Items(context: context)
        let alert = UIAlertController(title: "Add a ToDo Item", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            item.title = textField.text!
            item.parentCategory = self.selectedCategory
            self.itemArray.append(item)
            self.saveItems()
           
        }
        alert.addAction(action)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create a new Item"
            textField = alertTextField
            
        }
        present(alert, animated: true, completion: nil)
     
    }
    
    func saveItems(){
        //let encoder = PropertyListEncoder()
        do{
            //let data = try encoder.encode(self.itemArray)
           // try data.write(to: self.dataFilePath!)
            try context.save()}
            catch{
                print("Error Saving Data\(error)")
            }
        //self.defaults.set(self.itemArray, forKey: "ToDoItemArray")
        self.tableView.reloadData()
    }
    func loadItems(with recquest:NSFetchRequest<Items> = Items.fetchRequest(), predicate: NSPredicate? = nil)
    {
//        if let data = try? Data(contentsOf: dataFilePath!){
//        let decoder = PropertyListDecoder()
//            do{
//                itemArray =  try decoder.decode([Items].self, from: data)}
//            catch{
//                print("Error Decoding Data\(error)")
//            }
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate{
       
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate,categoryPredicate])
            recquest.predicate = compoundPredicate}
        else{
            recquest.predicate = categoryPredicate
        }
        do{
            self.itemArray = try context.fetch(recquest)
        }
        catch{
            print("Error Reading Data from CoreData\(error)")
        }
        tableView.reloadData()
}

}
extension ViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let recquest: NSFetchRequest<Items> = Items.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        recquest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: recquest,predicate: predicate)
        print("Search")
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count == 0{
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                self.loadItems()
            }
        }
    }
}
