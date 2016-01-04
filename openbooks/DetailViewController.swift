//
//  DetailViewController.swift
//  openbooks
//
//  Created by wififer on 31/12/15.
//  Copyright © 2015 wififer. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var titulo: UITextView!
    
    @IBOutlet weak var autor: UITextView!
    
    @IBOutlet weak var portada: UIImageView!
    
    var logo = UIImage(named: "portada_libro")
    
    
    @IBOutlet weak var imgIndicator: UIActivityIndicatorView!
    var toPassBook = BookRecord(image: "", title: "", autores: [])


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let _ = self.detailItem {
            if let tituloTv = self.titulo {
                tituloTv.text = toPassBook.title
            }
            
         var   autorTxt = ""
            for name in toPassBook.autores {
                
                if let miAutor = name["name"] {
                    print("miAutor: ",miAutor!)
                    autorTxt += "\(miAutor!) \n"
                    
                }
                if let autorTv = self.autor {
                    autorTv.text = autorTxt
                }
                
            }
            if (toPassBook.image != ""){
                descargarImgPrincipal(toPassBook.image)
            }
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func descargarImgPrincipal(url:String) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.imgIndicator.startAnimating()
        })
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { ()
            
            
            let url:NSURL = NSURL(string: url)!
            let session = NSURLSession.sharedSession()
            
            let task = session.downloadTaskWithURL(url) {
                (
                let location, let response, let error) in
                
                guard let _:NSURL = location, let _:NSURLResponse = response  where error == nil else {
                    print("error")
                    return
                }
                
                if   let imageData = NSData(contentsOfURL: location!) {
                    guard let image = UIImage(data: imageData) else {
                        // throw an error, return from your function, whatever
                        print ("fallo en : ",url)
                        return
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Pongo imagen:  \(image)")
                        self.portada.image = image
                        self.imgIndicator.stopAnimating()
                        
                        return
                    })
                    
                }
                
            }
            
            task.resume()
        })
        
        
    }



}

