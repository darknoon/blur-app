//
//  DNBlurViewController.m
//  Blur
//
//  Created by Andrew Pouliot on 4/5/14.
//  Copyright (c) 2014 Darknoon. All rights reserved.
//

#import "DNBlurViewController.h"
#import "DNBlurController.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface DNBlurViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation DNBlurViewController
{
	DNBlurController *_blur;
	UINavigationBar *_nb;
	UISlider *_slider;
	UIImageView *_iv;
	UIImage *_source;
	UIImage *_blurred;
	UIActivityIndicatorView *_indicator;
	BOOL _saving;
	int32_t _lastEnqueued;
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) return nil;
		
    return self;
}

- (void)_createBar
{
	_nb = [[UINavigationBar alloc] initWithFrame:CGRectZero];
	_nb.barStyle = UIBarStyleBlack;
	UINavigationItem *ni = [[UINavigationItem alloc] initWithTitle:@"Image"];
	
	UIBarButtonItem *openItem = [[UIBarButtonItem alloc] initWithTitle:@"Open"
																 style:UIBarButtonItemStylePlain
																target:self
																action:@selector(openImage:)];
	
	UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
																  style:UIBarButtonItemStylePlain
																 target:self
																 action:@selector(saveImage:)];
	[ni setLeftBarButtonItem:openItem];
	[ni setRightBarButtonItem:saveItem];
	
	[_nb pushNavigationItem:ni animated:NO];
	
	[self.view addSubview:_nb];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor grayColor];
	

	_iv = [[UIImageView alloc] init];
	_iv.frame = self.view.bounds;
	_iv.image = _source;
	_iv.contentMode = UIViewContentModeScaleAspectFill;
	_iv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:_iv];
	
	_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[self.view addSubview:_indicator];
	
	_slider = [[UISlider alloc] initWithFrame:(CGRect){50, 400, 320-100, 30}];
	_slider.alpha = 0.0;
	_slider.value = 0.5;
	[_slider addTarget:self action:@selector(amountChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:_slider];

	[self _createBar];

	_blur = [[DNBlurController alloc] init];
}


- (void)_enqueueWithFactor:(CGFloat)f
{
	if (!_indicator.isAnimating) {
		[_indicator startAnimating];
	}
	_lastEnqueued = [_blur blurImage:_source factor:f completion:^(UIImage *blurred, int32_t expected) {
		if (blurred) {
			_iv.image = blurred;
			_blurred = blurred;
			if (expected == _lastEnqueued) {
				[_indicator stopAnimating];
			}
		}
	}];	
}

- (void)amountChanged:(UISlider *)sender
{
	[self _enqueueWithFactor:sender.value];
}

- (void)openImage:(id)sender
{
	UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
	[ipc setDelegate:self];
	
	[self presentViewController:ipc animated:YES completion:NULL];
}

#pragma mark -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	_source = nil;

	NSURL *source = info[UIImagePickerControllerReferenceURL];

	ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
	[assetLibrary assetForURL:source resultBlock:^(ALAsset *asset) {
		ALAssetRepresentation *rep = [asset defaultRepresentation];
		
		UIImage *image = [UIImage imageWithCGImage: [rep fullResolutionImage]];
		_source = image;
		_slider.alpha = 1.0;
		[self _enqueueWithFactor:_slider.value];
		
		[picker dismissViewControllerAnimated:YES completion:NULL];
		
	} failureBlock:^(NSError *err) {
		
		[[[UIAlertView alloc] initWithTitle:@"Error"
									message:[err localizedDescription]
								   delegate:nil
						  cancelButtonTitle:@"Cancel"
						  otherButtonTitles:nil] show];
	}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -

- (void)saveImage:(id)sender
{
	if (_saving) return;
	_saving = YES;
	UIImageWriteToSavedPhotosAlbum(_blurred, self, @selector(saveImageCompleted:error:contextInfo:), nil);
}

- (void)saveImageCompleted:(UIImage *)image
					 error:(NSError *)error
			   contextInfo:(void *)contextInfo
{
	_saving = NO;
	[[[UIAlertView alloc] initWithTitle:@"Saved"
							   message:@"Photo Saved"
							  delegate:nil
					 cancelButtonTitle:@"OK"
					 otherButtonTitles:nil] show];
}

- (void)viewWillLayoutSubviews
{
	CGRect bounds = self.view.bounds;

	_indicator.center = (CGPoint){CGRectGetMidX(bounds), CGRectGetMidY(bounds)};
	
	[_nb setFrame:(CGRect){0, 0, bounds.size.width, 44.f}];
}

@end
