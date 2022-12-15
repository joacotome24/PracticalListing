//
//  ViewController.swift
//  PracticalListing
//
//  Created by Joaquin Tome on 24/12/21.
//
import CoreData
import UIKit
import ChameleonFramework
import SwipeCellKit

class PracticalListViewController: UITableViewController, UISearchBarDelegate, SwipeTableViewCellDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    var listItems = [ListElement]()
    var carpeta : Carpeta? {
        didSet {
            cargar()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.backgroundColor = FlatPowderBlue()
        searchBar.barTintColor = FlatPowderBlue()
        tableView.rowHeight = 75.0
        // Do any additional setup after loading the view.
        searchBar.delegate = self
    }
    
    func guardar(){
        do {
            try context.save()
        } catch {
            print("\(error)")
        }
        tableView.reloadData()
    }
    func cargar(pred: NSPredicate? = nil){
        let request:NSFetchRequest<ListElement> = ListElement.fetchRequest()
        let p = NSPredicate(format: "carpeta.nombreCarpeta MATCHES %@", carpeta!.nombreCarpeta!)
        if let addP = pred {
            let compPred = NSCompoundPredicate(andPredicateWithSubpredicates: [p, addP])
            request.predicate = compPred
        } else {
            request.predicate = p
        }
        let sortD = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortD]
        do{
            listItems = try context.fetch(request)
        }catch{
            print("\(error)")
        }
    }
    func borrar(){
        //context.delete(listItems[indexPath.row])
        //listItems.remove(at: indexPath.row)
        //try context.save()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text! == "") {
            cargar()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let p = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        cargar(pred: p)
        tableView.reloadData()
    }
    @IBAction func agregarItem(_ sender: Any) {
        var textFromField = UITextField()
        let a = UIAlertController(title: "Add Element", message: "", preferredStyle: .alert)
        let b = UIAlertAction(title: "Add", style: .default) { result in
            
            if ((textFromField.text) == "") {
                print("error")
            } else {
                let elementoNuevo = ListElement(context: self.context)
                elementoNuevo.state = false
                elementoNuevo.name = textFromField.text!
                elementoNuevo.carpeta = self.carpeta
                self.listItems.append(elementoNuevo)
                self.guardar()
                self.tableView.reloadData()
            }
        }
        a.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        a.addTextField { textF in
            textF.placeholder = "Add Element"
            textFromField = textF
            
        }
        a.addAction(b)
        present(a, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listItems[indexPath.row].state = !listItems[indexPath.row].state
        guardar()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PracticalListCell", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = listItems[indexPath.row].name
        
        if let color = FlatMint().darken(byPercentage: CGFloat(indexPath.row) / CGFloat(listItems.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = FlatWhite()
        }
        
        cell.delegate = self
        if listItems[indexPath.row].state == false {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.context.delete(self.listItems[indexPath.row])
            self.listItems.remove(at: indexPath.row)
            do {
                try self.context.save()
            } catch {
                print("\(error)")
            }
        }
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    

}

