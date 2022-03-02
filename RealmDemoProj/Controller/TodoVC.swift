//
//  TodoVC.swift
//  Test
//
//  Created by Kunal's MacBook on 16/02/22.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoVC: SwipeTableViewController{

    let realm  =  try! Realm()
    
    var todoArr: Results<Item>?
    
    @IBOutlet weak var searbarOut: UISearchBar!
    var selectedCategory: Category?{
        didSet{
            loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        tableView.separatorStyle = .none
        //loadData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colorHex = selectedCategory?.colour{
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller dose not exists")}
            navBar.tintColor = ContrastColorOf(UIColor(hexString: colorHex)!, returnFlat: true)
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(UIColor(hexString: colorHex)!, returnFlat: true)]
            navBar.backgroundColor = UIColor(hexString: colorHex)
//            searbarOut.barTintColor = UIColor(hexString: colorHex)
            view.backgroundColor = UIColor(hexString: colorHex)
        }
    }
    
    //MARK: - Add Button Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Note", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) {  (action) in
            if let currentCat = self.selectedCategory{
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.done = false
                        newItem.dateCreated = Date()
                        currentCat.items.append(newItem)
                    }
                }
                catch{
                    print("Error saving new item \(error)")
                }
                
            }
            
            self.tableView.reloadData()
            
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
        
        todoArr = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete data
    override func updateModel(at indexpath: IndexPath) {
        if let items = todoArr?[indexpath.row]{
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todoArr?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoArr?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage:( CGFloat(indexPath.row) / CGFloat(todoArr!.count))){
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
        }
        else{
            cell.textLabel?.text = "No item Added"
        }
        
        
                
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //MARK: - Update and delete
        if let items = todoArr?[indexPath.row]{
            do{
                try realm.write {
                    
                    //MARK: - For delete data from realm
                    //realm.delete(items)
                    
                    //MARK: - Update data from realm
                    items.done = !items.done //Update
                }
            }
            catch{
                print("Error updating \(error)")
            }
        }
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - Search Bar Method
extension TodoVC: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text?.count ?? 0 > 0{
            todoArr = todoArr?.filter("title CONTAINS[cd] %@", searchBar.text ?? "").sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
        self.view.endEditing(true)
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}

