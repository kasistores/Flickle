//
//  MoviesViewController.swift
//  Flickle
//
//  Created by Kevin Asistores on 1/8/16.
//  Copyright © 2016 Kevin Asistores. All rights reserved.
//

import UIKit
import AFNetworking
import EZLoadingActivity
import MBProgressHUD
import SwiftHEXColors

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    //var font = UIFont.systemFontOfSize(21)
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EZLoadingActivity.show("Waiting...", disableUI: true)
        let color = UIColor(hexString: "#ff8942")
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = color
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        //self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(25)]
        self.tabBarController?.tabBar.translucent = true
        self.tabBarController?.tabBar.tintColor = color
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                          
                            EZLoadingActivity.hide(success: true, animated: true)
                            
                            
                    }
                }
                else {
                    EZLoadingActivity.hide(success: false, animated: true)
                }
        });
        task.resume()
        

        // Do any additional setup after loading the view.
    }
    
    
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
       
        if let movies = movies {
            return movies.count
        }
        else {
            return 0
        }
        
    }
    

    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.overviewLabel.text = overview
        cell.titleLabel.text = title
        
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURLRequest(URL: NSURL(string: baseUrl + posterPath)!)
            cell.posterView.setImageWithURLRequest(
                imageUrl,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterView.image = image
                    }
                },
                failure: { (imageUrl, imageResponse, error) -> Void in
                    //leave blank
            })
        }
        
        print("row \(indexPath.row)")
        return cell
    }
    
    
    
    
    //@IBAction func onTap(sender: AnyObject) {
      //  view.endEditing(true)
    //}


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewcontroller = segue.destinationViewController as! DetailViewController
        detailViewcontroller.movie = movie
        
        
        
        print("Prepare for Segue Called")
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
