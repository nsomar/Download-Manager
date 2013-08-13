//
//  ViewController.m
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import "ViewController.h"
#import "IADownloadManager.h"
#import "ImageCell.h"
#import "IASequentialDownloadManager.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSArray *images;
    __weak IBOutlet UISegmentedControl *segmentController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    segmentController.selectedSegmentIndex = 1;
    [self setArrayForParallel:segmentController.selectedSegmentIndex == 0];
}

- (IBAction)segmentChanged:(id)sender
{
    [self setArrayForParallel:segmentController.selectedSegmentIndex == 0];
}

- (void)setArrayForParallel:(BOOL)parallel
{
    if (parallel)
    {
        images =
        @[
          [NSURL URLWithString:@"http://yourpfpro.com/wp-content/uploads/2012/12/apple-products-computers-iphone-ipod-macbook-worth-the-extra-money.jpg"],
          [NSURL URLWithString:@"http://images.all-free-download.com/images/graphiclarge/gray_apple_39.jpg"],
          [NSURL URLWithString:@"http://yourpfpro.com/wp-content/uploads/2012/12/apple-products-computers-iphone-ipod-macbook-worth-the-extra-money.jpg"],
          [NSURL URLWithString:@"http://images.all-free-download.com/images/graphiclarge/gray_apple_39.jpg"],
          [NSURL URLWithString:@"http://images.all-free-download.com/images/graphiclarge/gray_apple_39.jpg"],
          [NSURL URLWithString:@"http://images.all-free-download.com/images/graphiclarge/gray_apple_39.jpg"],
          [NSURL URLWithString:@"http://images.all-free-download.com/images/graphiclarge/gray_apple_39.jpg"],
          [NSURL URLWithString:@"http://www.wired.com/images_blogs/gadgetlab/2012/08/080612-APPLE-SCREENS-ICLOUD-001edit.jpg"],
          [NSURL URLWithString:@"http://www.wired.com/images_blogs/gadgetlab/2012/08/080612-APPLE-SCREENS-ICLOUD-001edit.jpg"],
          [NSURL URLWithString:@"http://www.wired.com/images_blogs/gadgetlab/2012/08/080612-APPLE-SCREENS-ICLOUD-001edit.jpg"],
          [NSURL URLWithString:@"http://www.wired.com/images_blogs/gadgetlab/2012/08/080612-APPLE-SCREENS-ICLOUD-001edit.jpg"],
          [NSURL URLWithString:@"http://www.wired.com/images_blogs/gadgetlab/2012/08/080612-APPLE-SCREENS-ICLOUD-001edit.jpg"],
          [NSURL URLWithString:@"http://4.bp.blogspot.com/-nTKlby2RaLs/T9qTqPaWGvI/AAAAAAAAAjI/6aCIFv_kaBw/s1600/Apple-Wallpaper-52.png"],
          [NSURL URLWithString:@"http://b-i.forbesimg.com/spleverage/files/2013/04/silver-apple-logo-apple-picture.jpg"],
          [NSURL URLWithString:@"http://b-i.forbesimg.com/spleverage/files/2013/04/silver-apple-logo-apple-picture.jpg"],
          [NSURL URLWithString:@"http://www.wired.com/images_blogs/gadgetlab/2012/08/080612-APPLE-SCREENS-ICLOUD-001edit.jpg"],
          [NSURL URLWithString:@"http://www.topnews.in/files/Apple-logo_5.jpg"],
          [NSURL URLWithString:@"http://api.ning.com/files/Fd0Hyt-VB-mLJyE6xLYZ**QLu2VVQfvnaIEzyxSO11rwdkqRti2q4ra1ES1p8jr1BpSEJSaRTmqdCOv-6CXzMGxmhyl-gUex/applelogo.gif"],
          [NSURL URLWithString:@"http://www.the-digital-reader.com/wp-content/uploads/2011/12/ws-space-apple-logo1.jpg"],
          [NSURL URLWithString:@"http://electricsproket.files.wordpress.com/2012/01/applelogo.png"],
          [NSURL URLWithString:@"http://www.wallpaperdev.com/stock/best-apple-spectrum-by-gfsx-mac.jpg"],
          [NSURL URLWithString:@"http://www.cert.gov.az/userfiles/Apple-Hd.jpg"],
          [NSURL URLWithString:@"http://www.wired.com/images_blogs/gadgetlab/2012/08/080612-APPLE-SCREENS-ICLOUD-001edit.jpg"],
          [NSURL URLWithString:@"http://emerginggrowth.com/wp-content/uploads/2013/05/Apple-logo-1.jpeg"],
          [NSURL URLWithString:@"http://www.techgig.com/files/photo_1374950405_temp.jpg.pagespeed.ce.V_5E_KxWXh.jpg"],
          [NSURL URLWithString:@"http://yourpfpro.com/wp-content/uploads/2012/12/apple-products-computers-iphone-ipod-macbook-worth-the-extra-money.jpg"],
          [NSURL URLWithString:@"http://www.philebrity.com/wp-content/uploads/2013/06/Apple_gray_logo.png"]];
    }
    else
    {
        images =
        @[
          @[[NSURL URLWithString:@"http://images.all-free-download.com/images/graphiclarge/gray_apple_39.jpg"],
            [NSURL URLWithString:@"http://images.all-free-download.com/images/graphiclarge/gray_apple_39.jpg"],
            [NSURL URLWithString:@"http://images.all-free-download.com/images/graphiclarge/gray_apple_39.jpg"]],
          @[[NSURL URLWithString:@"http://yourpfpro.com/wp-content/uploads/2012/12/apple-products-computers-iphone-ipod-macbook-worth-the-extra-money.jpg"],
            [NSURL URLWithString:@"http://images.all-free-download.com/images/graphiclarge/gray_apple_39.jpg"],
            [NSURL URLWithString:@"http://4.bp.blogspot.com/-nTKlby2RaLs/T9qTqPaWGvI/AAAAAAAAAjI/6aCIFv_kaBw/s1600/Apple-Wallpaper-52.png"
             ]],
          @[[NSURL URLWithString:@"http://images.all-free-download.com/images/graphiclarge/gray_apple_39.jpg"],
            [NSURL URLWithString:@"http://www.wired.com/images_blogs/gadgetlab/2012/08/080612-APPLE-SCREENS-ICLOUD-001edit.jpg"],
            [NSURL URLWithString:@"http://www.wired.com/images_blogs/gadgetlab/2012/08/080612-APPLE-SCREENS-ICLOUD-001edit.jpg"]]
          ,
          @[[NSURL URLWithString:@"http://www.wired.com/images_blogs/gadgetlab/2012/08/080612-APPLE-SCREENS-ICLOUD-001edit.jpg"],
            [NSURL URLWithString:@"http://www.wired.com/images_blogs/gadgetlab/2012/08/080612-APPLE-SCREENS-ICLOUD-001edit.jpg"],
            [NSURL URLWithString:@"http://www.wired.com/images_blogs/gadgetlab/2012/08/080612-APPLE-SCREENS-ICLOUD-001edit.jpg"]]
          ,
          @[[NSURL URLWithString:@"http://4.bp.blogspot.com/-nTKlby2RaLs/T9qTqPaWGvI/AAAAAAAAAjI/6aCIFv_kaBw/s1600/Apple-Wallpaper-52.png"],
            [NSURL URLWithString:@"http://b-i.forbesimg.com/spleverage/files/2013/04/silver-apple-logo-apple-picture.jpg"],
            [NSURL URLWithString:@"http://b-i.forbesimg.com/spleverage/files/2013/04/silver-apple-logo-apple-picture.jpg"]]
          ,
          @[[NSURL URLWithString:@"http://www.wired.com/images_blogs/gadgetlab/2012/08/080612-APPLE-SCREENS-ICLOUD-001edit.jpg"],
            [NSURL URLWithString:@"http://www.topnews.in/files/Apple-logo_5.jpg"],
            [NSURL URLWithString:@"http://api.ning.com/files/Fd0Hyt-VB-mLJyE6xLYZ**QLu2VVQfvnaIEzyxSO11rwdkqRti2q4ra1ES1p8jr1BpSEJSaRTmqdCOv-6CXzMGxmhyl-gUex/applelogo.gif"]]
          ,
          @[[NSURL URLWithString:@"http://www.the-digital-reader.com/wp-content/uploads/2011/12/ws-space-apple-logo1.jpg"],
            [NSURL URLWithString:@"http://electricsproket.files.wordpress.com/2012/01/applelogo.png"],
            [NSURL URLWithString:@"http://www.wallpaperdev.com/stock/best-apple-spectrum-by-gfsx-mac.jpg"]]
          ,
          @[[NSURL URLWithString:@"http://www.cert.gov.az/userfiles/Apple-Hd.jpg"],
            [NSURL URLWithString:@"http://www.wired.com/images_blogs/gadgetlab/2012/08/080612-APPLE-SCREENS-ICLOUD-001edit.jpg"],
            [NSURL URLWithString:@"http://emerginggrowth.com/wp-content/uploads/2013/05/Apple-logo-1.jpeg"]]
          ,
          @[[NSURL URLWithString:@"http://www.techgig.com/files/photo_1374950405_temp.jpg.pagespeed.ce.V_5E_KxWXh.jpg"],
            [NSURL URLWithString:@"http://yourpfpro.com/wp-content/uploads/2012/12/apple-products-computers-iphone-ipod-macbook-worth-the-extra-money.jpg"],
            [NSURL URLWithString:@"http://www.philebrity.com/wp-content/uploads/2013/06/Apple_gray_logo.png"]]
          ];
    }
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return images.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"cell";
    
    ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
	{
        cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (segmentController.selectedSegmentIndex == 0)
    {
        NSURL *url = images[indexPath.row];
        [cell setImageWithURL:url];
    }
    else
    {
        NSArray *urls = images[indexPath.row];
        [cell setImageWithURLs:urls];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell *cell = (ImageCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell stopDownloading];
}
@end
