//
//  HzTagLabel.m
//  KevinExample
//
//  Created by 何 峙 on 14-4-9.
//  Copyright (c) 2014年 何 峙. All rights reserved.
//

#import "HzTagLabel.h"
#import "HzLabel.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

#define kColorTagBackgroundDefault [UIColor colorWithRed:24.0 / 255 green:156.0 / 255 blue:86.0/ 255 alpha:1.0]

//static CGFloat const kDefaultLineSpace = 5.0f;

@interface HzTagLabel ()

+ (NSString *)generateActualTextWithTag:(NSString *)tag main:(NSString *)main font:(UIFont *)font;


@end

@implementation HzTagLabel


- (void)dealloc{
    [_tagText release]; _tagText = nil;
    [_mainText release]; _mainText = nil;
    [_mainTextColor release]; _mainTextColor = nil;
    [_mainTextFont release]; _mainTextFont = nil;
    [_tagTextFont release]; _tagTextFont = nil;
    
    [super dealloc];
}

- (void)layoutSubviews{
//    self.backgroundColor = [UIColor redColor];

    NSString *actualMainText = [HzTagLabel generateActualTextWithTag:_tagText main:_mainText font:_mainTextFont];
    HzLabel *mainLabel = [[HzLabel alloc] init];
    mainLabel.text = actualMainText;
    mainLabel.textColor = _mainTextColor;
    mainLabel.lineSpace = _lineSpace;
    mainLabel.font = _mainTextFont;
    mainLabel.backgroundColor = [UIColor clearColor];
    CGFloat height = [HzTagLabel calculateHeightForWidth:self.frame.size.width mainText:_mainText tagText:_tagText font:_mainTextFont lineSpace:_lineSpace];
    mainLabel.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, height);
    [self addSubview:mainLabel];
    [mainLabel release];
    
    if((NSNull *)_tagText != [NSNull null] && _tagText && _tagText.length > 0){
        CGSize tagSize = [_tagText sizeWithFont:_mainTextFont constrainedToSize:CGSizeMake(self.frame.size.width, 70.0f) lineBreakMode:NSLineBreakByWordWrapping];
        UIButton *tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [tagBtn addTarget:self action:@selector(clickTag:) forControlEvents:UIControlEventTouchUpInside];
        tagBtn.frame = CGRectMake(0.0f, 0.0f, tagSize.width, tagSize.height);
        [tagBtn setImage:[UIImage imageNamed:@"button_tag_normal_iPhone"] forState:UIControlStateNormal];
        [tagBtn setImage:[UIImage imageNamed:@"button_tag_highlighted_iPhone"] forState:UIControlStateHighlighted];
        tagBtn.layer.cornerRadius = 3.0;
        tagBtn.layer.masksToBounds = YES;
        [self addSubview:tagBtn];
        
        UILabel *btnLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        btnLabel.backgroundColor = [UIColor clearColor];
        btnLabel.font = _tagTextFont;
        btnLabel.textColor = [UIColor whiteColor];
        btnLabel.textAlignment = NSTextAlignmentCenter;
        btnLabel.text = _tagText;
        btnLabel.frame = CGRectMake(0.0f, 0.0f, tagBtn.frame.size.width, tagBtn.frame.size.height);
        [tagBtn addSubview:btnLabel];
        [btnLabel release];
    }
    
//    NSLog(@"%s, subViews: %@", __FUNCTION__, self.subviews);
}

#pragma mark - Private methods

+ (NSString *)generateActualTextWithTag:(NSString *)tagText main:(NSString *)main font:(UIFont *)font{
    if(!main){
        return nil;
    }
    
    if((NSNull *)tagText == [NSNull null] || !tagText || tagText.length <= 0){
        return [NSString stringWithString:main];
    }
    else{
        NSString *spaceText = @" ";
        CGSize spaceSize = [spaceText sizeWithFont:font constrainedToSize:CGSizeMake(100.0f, 70.0f) lineBreakMode:NSLineBreakByWordWrapping];
        CGSize tagSize = [tagText sizeWithFont:font constrainedToSize:CGSizeMake(200.0f, 70.0f) lineBreakMode:NSLineBreakByWordWrapping];
        NSInteger extraSpaceCounts = 3; //补足一些误差
        NSInteger spaceCount = tagSize.width / spaceSize.width + extraSpaceCounts;
        NSMutableString *spaceStr = [[NSMutableString alloc] init];
        for(NSInteger i = 0; i < spaceCount; i++){
            [spaceStr appendString:spaceText];
        }
        NSString *actualMainText = [NSString stringWithFormat:@"%@%@", spaceStr, main];
        [spaceStr release];
        
        return actualMainText;
    }
}

#pragma mark - Control action

- (void)clickTag:(id)sender{
    if(_delegate && [_delegate respondsToSelector:@selector(didClickTag:)]){
        [_delegate didClickTag:self];
    }
}

#pragma mark - Public methods

- (void)refresh{
    for(UIView *subView in self.subviews){
        [subView removeFromSuperview];
    }
    
    [self setNeedsLayout];
}

+ (CGFloat)calculateHeightForWidth:(CGFloat)w mainText:(NSString *)main tagText:(NSString *)tag font:(UIFont *)font lineSpace:(CGFloat)space{
    
    if(!main || !font || space < 0){
        return -1.0f;
    }
    
    NSString *text = [HzTagLabel generateActualTextWithTag:tag main:main font:font];
    if(!text){
        return -1.0f;
    }
    
    //设置断行方式
    CTParagraphStyleSetting lineBreak;
    CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
    lineBreak.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreak.value = &lineBreakMode;
    lineBreak.valueSize = sizeof(CTLineBreakMode);
    
    //设置行距
    CTParagraphStyleSetting lineSpacing;
    CGFloat spacing = space;
    lineSpacing.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
    lineSpacing.value = &spacing;
    lineSpacing.valueSize = sizeof(CGFloat);
    
    CTParagraphStyleSetting settings[] = {lineBreak, lineSpacing};
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 2);
    
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:
                               (id)ctFont, kCTFontAttributeName,
                               (id)paragraphStyle, kCTParagraphStyleAttributeName, nil];
    NSAttributedString *attributedString = [[[NSAttributedString alloc] initWithString:text attributes:attribute] autorelease];
    
    CFRelease(paragraphStyle);
    CFRelease(ctFont);
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), NULL, CGSizeMake(w, 10000), NULL);
    
    CFRelease(frameSetter);
    
    return suggestedSize.height;
}



@end
