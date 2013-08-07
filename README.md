##iOS download manager

###A Minimalist download manager for iOS

Download a set of files in parallel or sequential order.

###What it provides
* Easy to integrate and use iOS download manager.
* Easily download file with the very robust [AFNetworking](https://github.com/AFNetworking/AFNetworking) library.
* Deal only with NSURL, you will never have to keep strong or weak references of the Download managers.
* Download files in sequential and parallel order.
* Make sure each file (NSURL) is being downloaded only once.
* Have multiple listener/delegates on a single download operation.
* Download operation unique by URL, never download a URL twice.
* Cache the downloaded file in Memory and on Disk using [EGOCache](https://github.com/enormego/EGOCache).
* Easily add and remove listeners to observe the download operations.
* Singleton classes for fast access and minimum memory overhead.
* Ensure that the UI Thread is never blocked.
* Delegate or Block event callbacks.
* All of the above in two lines of code.

###Motivation 

Ever wanted to download a set of images in a parallel or sequential order, like creating a table cell view that resembles Facebook timeline cell that contains multiple images.
If you tried to create such thing, then you realised that some images has to be downloaded before the others, namely the first image in the timeline cell must be downloaded before the second image in this same cell (remember we have multi images inside the same cell)

IADownloadManager, will help you download images or any other files in a parallel order.
IASequentialDownloadManager, will help you download a set of urls in a sequential order.

###Prerequisite 
To use the download manager you should have:

* iOS 5
* ARC

Third party needed (included within the sources of the project):
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)
* [EGOCache](https://github.com/enormego/EGOCache)

###Installation

1. Copy all the files from IADownloadManager directory to your project.
2. Copy the files from ThirdParty directory to your project
3. Add `CFNetwork.framework` and `Security.framework` to the project, if you are not sure on how to  add frameworks read the following SO [answer](http://stackoverflow.com/questions/6334966/adding-framework-in-xcode-4)

###How to use

Every download operation is identified by the NSURL of the file that is getting downloaded,
The NSURL will be unique and cached against.

####Download files in parallel order using delegate callback.

Start the download operation  

	//Start the download operation, if the download operation is already started for this url,
	//the urls will never be downloaded twice
    [IADownloadManager downloadItemWithURL:url useCache:YES];
    
Attach Listener

	//Attach a listener to the url
    [IADownloadManager attachListener:self toURL:url];

Detach Listener    

	//Detach a listener to the url
    [IADownloadManager detachListener:self];
    
Delegate methods

	- (void)downloadManagerDidProgress:(float)progress;
	- (void)downloadManagerDidFinish:(BOOL)success response:(id)response;
	
####Download files in Sequential order using delegate callback.

Start the download operation	

	//Start the download operation, if the download operation is already started for these urls,
	//the urls will never be downloaded twice
    [IASequentialDownloadManager downloadItemWithURLs:urls useCache:YES];
    
Attach Listener

	//Attach a listener to the urls
	[IASequentialDownloadManager attachListener:self toURLs:urls];
    
Detach Listener    

	//Detach a listener to the url
    [IASequentialDownloadManager detachListener:self];
    
Delegate methods

	- (void)sequentialManagerProgress:(float)progress atIndex:(int)index;
	- (void)sequentialManagerDidFinish:(BOOL)success response:(id)response atIndex:(int)index;

####Block based callback.

There are also a set of blocks to be informed about the event of the download, For blocks based callbacks please refer to the demo.
