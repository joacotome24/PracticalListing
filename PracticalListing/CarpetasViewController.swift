//
//  CarpetasViewController.swift
//  PracticalListing
//
//  Created by Joaquin Tome on 30/12/21.
//
import UIKit
import SwipeCellKit
import ChameleonFramework
import CoreData

class CarpetasViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    var carpetas = [Carpeta]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 75.0
        tableView.backgroundColor = FlatPowderBlue()
        cargar()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    @IBAction func agregarCarpeta(_ sender: Any) {
        var textFromField = UITextField()
        let a = UIAlertController(title: "Add List", message: "", preferredStyle: .alert)
        let b = UIAlertAction(title: "Add", style: .default) { result in
            if ((textFromField.text) == "") {
                print("error")
            } else {
                let elementoNuevo = Carpeta(context: self.context)
                elementoNuevo.nombreCarpeta = textFromField.text!
                self.carpetas.append(elementoNuevo)
                self.guardar()
                self.tableView.reloadData()
            }
        }
        a.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        a.addTextField { textF in
            textF.placeholder = "Add List"
            textFromField = textF
            
        }
        a.addAction(b)
        present(a, animated: true, completion: nil)
    }
    func guardar(){
        do {
            try context.save()
        } catch {
            print("\(error)")
        }
        tableView.reloadData()
    }
    
    func cargar(){
        let request:NSFetchRequest<Carpeta> = Carpeta.fetchRequest()
        do{
            carpetas = try context.fetch(request)
        }catch{
            print("\(error)")
        }
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return carpetas.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PracticalCarpetaCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = carpetas[indexPath.row].nombreCarpeta
        // Configure the cell...
        if let color = FlatSkyBlue().darken(byPercentage: CGFloat(indexPath.row) / CGFloat(carpetas.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = FlatWhite()
        }
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.context.delete(self.carpetas[indexPath.row])
            self.carpetas.remove(at: indexPath.row)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showListElements", sender: self)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let nextVC = segue.destination as! PracticalListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            nextVC.carpeta = carpetas[indexPath.row]
        }
    }
    

}
