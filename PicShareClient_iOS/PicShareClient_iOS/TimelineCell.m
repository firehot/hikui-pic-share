//
//  TimelineCell.m
//  PicShareClient_iOS
//
//  Created by 缪和光 on 12-3-28.
//  Copyright (c) 2012年 Shanghai University. All rights reserved.
//

#import "TimelineCell.h"
#import "UIImageView+AsyncImageContainer.h"
#import "UIImageView+Resize.h"
#import "ASIDownloadCache.h"
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface TimelineCell ()

- (void)downloadMainImage;

@end

@implementation TimelineCell

@synthesize avatarImageView,usernameButton,boardNameButton,picDescriptionLabel,mainImageView,repinButton,commentTextField,pictureStatus,viaButton,progressView,request;

- (void)dealloc
{
    [request clearDelegatesAndCancel];
    [request release];
    [avatarImageView release];
    [usernameButton release];
    [boardNameButton release];
    [picDescriptionLabel release];
    [mainImageView release];
    [repinButton release];
    [commentTextField release];
    [viaButton release];
    [progressView release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        avatarImageView = [[UIImageView alloc]init];
        usernameButton = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
        boardNameButton = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
        picDescriptionLabel = [[UILabel alloc]init];
        mainImageView = [[UIImageView alloc]init];
        repinButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect]retain];
        commentTextField = [[UITextField alloc]init];
        viaButton = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
        progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
        [self.contentView addSubview:avatarImageView];
        [self.contentView addSubview:usernameButton];
        [self.contentView addSubview:boardNameButton];
        [self.contentView addSubview:picDescriptionLabel];
        [self.contentView addSubview:mainImageView];
        [self.contentView addSubview:repinButton];
        loadImgComplete = NO;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layout
{
    NSLog(@"layoutSubviews");
    if (self.pictureStatus != nil) {
        NSLog(@"updateview");
        avatarImageView.frame = CGRectMake(10, 20, 30, 30);
        [avatarImageView setImageWithUrl:[NSURL URLWithString:pictureStatus.owner.avatarUrl] placeholderImage:[UIImage imageNamed:@"anonymous.png"]];
        
        
        
        CGSize nameButtonSize = [pictureStatus.owner.username sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(147, 18) lineBreakMode:UILineBreakModeTailTruncation];
        CGRect nameButtonFrame = CGRectMake(48, 32, nameButtonSize.width, nameButtonSize.height);
        usernameButton.frame = nameButtonFrame;
        [usernameButton setTitle:pictureStatus.owner.username forState:UIControlStateNormal];
        [usernameButton setTitleColor:RGBA(66, 66, 66, 1) forState:UIControlStateNormal];
        usernameButton.titleLabel.font = [UIFont systemFontOfSize:14];
        usernameButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [usernameButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        
        CGSize boardNameButtonSize = [pictureStatus.boardName sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(97, 18) lineBreakMode:UILineBreakModeTailTruncation];
        CGRect boardNameButtonFrame = CGRectMake(nameButtonFrame.origin.x+nameButtonSize.width+8, nameButtonFrame.origin.y, boardNameButtonSize.width, boardNameButtonSize.height);
        boardNameButton.frame = boardNameButtonFrame;
        [boardNameButton setTitle:pictureStatus.boardName forState:UIControlStateNormal];
        [boardNameButton setTitleColor:RGBA(130, 131, 146, 1) forState:UIControlStateNormal];
        boardNameButton.titleLabel.font = [UIFont systemFontOfSize:14];
        boardNameButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [boardNameButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        
        CGRect viaButtonFrame = CGRectMake(0, 0, 0, 0);
        if (pictureStatus.via !=nil) {
            UILabel *viaLabel = [[UILabel alloc]initWithFrame:CGRectMake(nameButtonFrame.origin.x, nameButtonFrame.origin.y+nameButtonSize.height+4, 35, 18)];
            viaLabel.text = @"转自";
            [self.contentView addSubview:viaLabel];
            [viaLabel release];
            
            CGSize viaButtonSize = [pictureStatus.via.username sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(320-8-(viaLabel.frame.origin.x+viaLabel.frame.size.width), 18) lineBreakMode:UILineBreakModeTailTruncation];
            viaButtonFrame = CGRectMake(viaLabel.frame.origin.x+viaLabel.frame.size.width+8, viaLabel.frame.origin.y, viaButtonSize.width, viaButtonSize.height);
            viaButton.frame = viaButtonFrame;
            [viaButton setTitle:pictureStatus.via.username forState:UIControlStateNormal];
            [viaButton setTitleColor:RGBA(93, 145, 166, 1) forState:UIControlStateNormal];
            [viaButton setContentVerticalAlignment:UIControlContentHorizontalAlignmentLeft];
            
        }
        
        
        CGSize mainImageViewSize = CGSizeMake(300, 255);
        CGRect mainImageViewFrame = CGRectMake(avatarImageView.frame.origin.x, avatarImageView.frame.origin.y+avatarImageView.frame.size.height+viaButtonFrame.size.height+8, mainImageViewSize.width, mainImageViewSize.height);
        mainImageView.frame = mainImageViewFrame;
        progressView.frame = CGRectMake((mainImageViewSize.width-150)/2, (mainImageViewSize.height-11)/2, 150, 11);
        if (!loadImgComplete) {
            mainImageView.image = nil;
            [mainImageView addSubview:progressView];
            [self downloadMainImage];
        }
        
        
        CGSize picDescriptionLabelSize = [pictureStatus.picDescription sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(300, 2000) lineBreakMode:UILineBreakModeWordWrap];
        CGRect picDescriptionLabelFrame = CGRectMake(avatarImageView.frame.origin.x, mainImageViewFrame.origin.y+mainImageViewFrame.size.height+8, picDescriptionLabelSize.width, picDescriptionLabelSize.height);
        picDescriptionLabel.frame = picDescriptionLabelFrame;
        picDescriptionLabel.text = pictureStatus.picDescription;
        picDescriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
        picDescriptionLabel.numberOfLines = 0;
        picDescriptionLabel.font = [UIFont systemFontOfSize:14];
        
        
        
        
        CGRect repinButtonFrame = CGRectMake(picDescriptionLabelFrame.origin.x, picDescriptionLabelFrame.origin.y+picDescriptionLabelFrame.size.height+8, 80, 30);
        repinButton.frame = repinButtonFrame;
        [repinButton setTitle:@"转发" forState:UIControlStateNormal];
        repinButton.titleLabel.font = [UIFont systemFontOfSize:14];
        // to be continued
#warning comments
    }
}

-(void)downloadMainImage
{
    self.request = [[[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:pictureStatus.pictureUrl]]autorelease];
    [self.request setDelegate:self];
    [self.request setNumberOfTimesToRetryOnTimeout:1];
    [self.request setTimeOutSeconds:10]; // 10 seconds
    [self.request setDownloadCache:[ASIDownloadCache sharedCache]];
    [self.request setCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy];
    [self.request setDownloadProgressDelegate:self.progressView];
    [self.request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)aRequest
{
    UIImage *tempImage = [UIImage imageWithData:[aRequest responseData]];
    [self.progressView removeFromSuperview];
    loadImgComplete = YES;
    tempImage = [UIImageView imageWithImage:tempImage scaledToSizeWithSameAspectRatio:self.mainImageView.frame.size];
    self.mainImageView.image = tempImage;
}

- (void)setPictureStatusThenRefresh:(PictureStatus *)aPictureStatus
{
    self.pictureStatus = aPictureStatus;
    loadImgComplete = NO;
    [self layout];
}

+ (CGFloat)calculateCellHeightWithPictureStatus:(PictureStatus *)aPictureStatus
{
    CGFloat height = 403.0f;
    if (aPictureStatus.via == nil) {
        height-=22;
    }
    CGSize picDescriptionLabelSize = [aPictureStatus.picDescription sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(300, 2000) lineBreakMode:UILineBreakModeWordWrap];
    height += picDescriptionLabelSize.height;
    return  height;
}

@end