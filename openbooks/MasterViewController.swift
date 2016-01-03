//
//  MasterViewController.swift
//  openbooks
//
//  Created by wififer on 31/12/15.
//  Copyright © 2015 wififer. All rights reserved.
//
// http://www.raywenderlich.com/113772/uisearchcontroller-tutorial
// https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:978-84-376-0494-7
// https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:978-84-9928-071-4  COVER

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    let searchController = UISearchController(searchResultsController: nil)
    var miTitulo = ""
    var books = [BookRecord]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        //searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            return
        })    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let bookDetails = books[indexPath.row]
        cell.textLabel?.text = bookDetails.title
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //print("Unresolved error \(error), \(error.userInfo)")
             abort()
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    func buscar(cadena: String) {
        print("Entro en buscar")
        let urlBase = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"

        
        var isbn = cadena
        let url:NSURL = NSURL(string: urlBase+isbn)!
        let session = NSURLSession.sharedSession()
        if Reachability.isConnectedToNetwork() {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            let task = session.downloadTaskWithURL(url) {
                (
                let location, let response, let error) in
                
                guard let _:NSURL = location, let _:NSURLResponse = response  where error == nil else {
                    print("error")
                    return
                    
                }
                
                if   let data = NSData(contentsOfURL: location!) {
                    
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves)
                        
                        print("json.count: ",json.count)
                        
                        if (json.count != 0) {
                            
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                            
                            var  autorTxt = ""
                            let dico1 = json as! NSDictionary
                            isbn = "ISBN:"+isbn
                            let dico2 = dico1[isbn] as! NSDictionary
                            print("dico2: ",dico2)
                            let title = dico2["title"] as! NSString as String
                            

                            
                            print("title: ",title)
                            let autores = dico2["authors"] as! NSArray
                            print("autores: ",autores)
                            for name in autores {
                                
                                if let miAutor = name["name"] {
                                    print("miAutor: ",miAutor!)
                                    autorTxt += "\(miAutor!) \n"
                                    
                                }
                                
                            }
                            
                            var urlPortada = ""
                            if let p = dico2["cover"] {
                                let portadas = p as! NSDictionary
                                 urlPortada = portadas["large"] as! NSString as String
                                print("portada: ",urlPortada)
                                //self.descargarImgPrincipal(urlPortada)
                                
                            }
                            let record = BookRecord(image:urlPortada,title:title,autores:autores)
                            self.books.append(record)
                            print("books: ",self.books[0])
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                //  let texto = NSString(data: data, encoding: NSUTF8StringEncoding)
                               // self.titulo.text = title
                               // self.autor.text = autorTxt
                               // self.searchBar.endEditing(true)
                                let alertController = UIAlertController(title: title, message:
                                    "+ para añadirlo", preferredStyle: UIAlertControllerStyle.Alert)
                                alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                                
                            })
                        }else{
                            dispatch_async(dispatch_get_main_queue(), {
                                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                                print("Ningún resultado")
                              //  self.searchBar.endEditing(true)
                                
                                let alertController = UIAlertController(title: "Atención!", message:
                                    "No hay ningún libro con ese ISBN", preferredStyle: UIAlertControllerStyle.Alert)
                                alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                            })
                        }
                        
                        
                    }catch _{
                        
                    }
                    
                }
            }
            task.resume()
        }else {
            print("Internet connection not available")
            let alertController = UIAlertController(title: "Atención!", message:
                "No hay conexión a internet", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        
    }
    
    

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

extension MasterViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        buscar(searchBar.text!)
    }
}
class BookRecord {
    
    var image = ""
    var autores = []
    var title = ""
    init( image:String, title:String, autores:NSArray) {
        self.image = image
        self.title = title
        self.autores = autores
        
    }
}


