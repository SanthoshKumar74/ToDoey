//
//  CategoryViewController.swift
//  ToDoey
//
//  Created by Santhosh Kumar on 27/12/21.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categories = [Categories]()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()

}
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ViewController
        if let  indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories[indexPath.row]}
    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let category = Categories(context: context)
        let alert = UIAlertController(title: "Add a Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add a Category", style: .default) { action in
            category.name = textField.text!
            self.categories.append(category)
            self.saveCategory()
            self.tableView.reloadData()
        
        }
        alert.addAction(action)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create a New Category"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
    func saveCategory(){
        do{
            try context.save()
        }catch{
            print("Error saving\(error)")
        }
    }
    func loadCategory(with recquest: NSFetchRequest<Categories> = Categories.fetchRequest())
    {
        do{
        try categories = context.fetch(recquest)
        }catch{
            print("error Loading Data\(error)")
        }
        tableView.reloadData()
    }
    
    
}
