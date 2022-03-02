//
//  CategoryVC.swift
//  Test
//
//  Created by Kunal's MacBook on 24/02/22.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryVC: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryArr: Results<Category>?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
        }
        navBar.backgroundColor = UIColor(hexString: "#1D9BF6")
        view.backgroundColor = UIColor(hexString: "#1D9BF6")
        
    }
    
    //MARK: - save item
    func saveItems(category: Category) {
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //MARK: - Delete item
    override func updateModel(at indexpath: IndexPath) {
        if let items = categoryArr?[indexpath.row]{
            do{
                try realm.write {
                    //MARK: - For delete data from realm
                    realm.delete(items)
                }
            }
            catch{
                print("Error updating \(error)")
            }
        }
    }

    @IBAction func addButtonAction(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) {  (action) in
            let newCat = Category()
            newCat.name = textField.text!
            newCat.colour = UIColor.randomFlat().hexValue()

            self.saveItems(category: newCat)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Read Data
    func loadData(){

        categoryArr = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryArr?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArr?[indexPath.row].name ?? "No Categories added yet"
        if let category = categoryArr?[indexPath.row] {
            guard let categoryColour = UIColor(hexString: category.colour) else {fatalError()}
            cell.backgroundColor = categoryColour
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TodoVC") as! TodoVC
        nav.selectedCategory = categoryArr?[indexPath.row]
        self.navigationController?.pushViewController(nav, animated: true)
    }
    
}
