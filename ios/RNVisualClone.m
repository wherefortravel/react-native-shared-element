//
//  RNVisualClone.m
//  react-native-visual-clone
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import <UIKit/UIKit.h>
#import <React/RCTDefines.h>
#import <React/UIView+React.h>
#import "RNVisualClone.h"

RCT_EXTERN UIImage *RCTBlurredImageWithRadius(UIImage *inputImage, CGFloat radius);

#ifdef DEBUG
#define DebugLog(...) NSLog(__VA_ARGS__)
#else
#define DebugLog(...) (void)0
#endif

@implementation RNVisualClone
{
    RNVisualCloneSourceManager* _sourceManager;
    RNVisualCloneSource* _cloneSource;
    RNVisualCloneContentType _contentType;
    BOOL _needsSourceReload;
    BOOL _needsImageReload;
    UIImage* _sourceImage;
    
}

- (instancetype)initWithSourceManager:(RNVisualCloneSourceManager*)sourceManager
{
    if ((self = [super init])) {
        _sourceManager = sourceManager;
        _cloneSource = nil;
        _contentType = RNVisualCloneContentTypeSnapshot;
        _needsSourceReload = NO;
        _needsImageReload = NO;
    }
    
    return self;
}

- (void)dealloc
{
    if (_cloneSource != nil) {
        [_sourceManager release:_cloneSource];
        _cloneSource = nil;
    }
}

- (void)refresh
{
    [self loadSourceContent:YES];
}

- (void)setCloneSource:(NSNumber*)reactTag view:(UIView*)view {
    RNVisualCloneSource* source = [_sourceManager acquire:reactTag view:view];
    if (_cloneSource != nil) {
        [_sourceManager release:_cloneSource];
    }
    if (_cloneSource != source) {
        _cloneSource = source;
        _needsSourceReload = YES;
    }
}

- (void)setContentType:(RNVisualCloneContentType)contentType {
    if (_contentType != contentType) {
        _contentType = contentType;
        _needsSourceReload = YES;
    }
}

- (void)setResizeMode:(RCTResizeMode)resizeMode
{
    if (_resizeMode != resizeMode) {
        _resizeMode = resizeMode;
        
        if (_resizeMode == RCTResizeModeRepeat) {
            // Repeat resize mode is handled by the UIImage. Use scale to fill
            // so the repeated image fills the UIImageView.
            self.contentMode = UIViewContentModeScaleToFill;
        } else {
            self.contentMode = (UIViewContentMode)resizeMode;
        }
    }
}

- (void)setBlurRadius:(CGFloat)blurRadius
{
    if (blurRadius != _blurRadius) {
        _blurRadius = blurRadius;
        _needsImageReload = YES;
        [self reloadImage];
        
    }
}

- (void)setBlurOpacity:(CGFloat)blurOpacity
{
    if (blurOpacity != _blurOpacity) {
        _blurOpacity = blurOpacity;
        //_needsImageReload = YES;
        //[self reloadImage];
        
    }
}

- (void) didSetProps:(NSArray<NSString *> *)changedProps
{
    if (_needsSourceReload) {
        [self loadSourceContent:NO];
    }
    else if (_needsImageReload) {
        [self reloadImage];
    }
}

- (void) loadSourceContent:(BOOL)forceRefresh
{
    _needsSourceReload = NO;
    if (_cloneSource != nil) {
        switch (_contentType) {
            case RNVisualCloneContentTypeSnapshot:
                [_cloneSource requestSnapshotView:self useCache:!forceRefresh];
                break;
            case RNVisualCloneContentTypeImage:
                [_cloneSource requestSnapshotImage:self useCache:!forceRefresh];
                break;
            case RNVisualCloneContentTypeRawImage:
                [_cloneSource requestRawImage:self useCache:!forceRefresh];
                break;
        }
    }
}

- (void)updateWithImage:(UIImage *)image
{
    if (!image) {
        super.image = nil;
        return;
    }
    
    // Apply rendering mode
    /*if (_renderingMode != image.renderingMode) {
        image = [image imageWithRenderingMode:_renderingMode];
    }
    
    if (_resizeMode == RCTResizeModeRepeat) {
        image = [image resizableImageWithCapInsets:_capInsets resizingMode:UIImageResizingModeTile];
    } else if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, _capInsets)) {
        // Applying capInsets of 0 will switch the "resizingMode" of the image to "tile" which is undesired
        image = [image resizableImageWithCapInsets:_capInsets resizingMode:UIImageResizingModeStretch];
    }*/
    
    // Apply trilinear filtering to smooth out mis-sized images
    self.layer.minificationFilter = kCAFilterTrilinear;
    self.layer.magnificationFilter = kCAFilterTrilinear;
    
    super.image = image;
}

- (void)reloadImage
{
    _needsImageReload = NO;
    if (_sourceImage != nil && _blurRadius > __FLT_EPSILON__) {
        void (^setImageBlock)(UIImage *) = ^(UIImage *image) {
             [self updateWithImage: image];
        };
        
        // Blur on a background thread to avoid blocking interaction
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *blurredImage = RCTBlurredImageWithRadius(_sourceImage, self->_blurRadius);
            RCTExecuteOnMainQueue(^{
                setImageBlock(blurredImage);
            });
        });
    }
    else {
        [self updateWithImage: _sourceImage];
    }
}

- (void) snapshotImageComplete:(UIImage*) image
{
    _sourceImage = image;
    [self reloadImage];
}

- (void) rawImageComplete:(UIImage*) image
{
    _sourceImage = image;
    [self reloadImage];
}

- (void) snapshotViewComplete:(UIView*) view
{
    // Update snapshot
    /*if (snapshot != _snapshot) {
        if (snapshot != nil) {
            snapshot.frame = self.bounds;
            snapshot.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self addSubview:snapshot];
        }
        if (_snapshot != nil) {
            [_snapshot removeFromSuperview];
        }
        _snapshot = snapshot;
        DebugLog(@"Number of subviews: %ld", self.subviews.count);
    }*/
    
    /*
     if (_snapshot) {
     if (_snapshot.autoresizingMask != (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)) {
     _snapshot.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
     }
     }*/
}

@end
