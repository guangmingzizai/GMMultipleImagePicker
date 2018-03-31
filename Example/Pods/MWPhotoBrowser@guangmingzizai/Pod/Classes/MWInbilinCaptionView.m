//
//  MWInbilinCaptionView.m
//  Pods
//
//  Created by 柬斐 王 on 15/9/28.
//
//

#import "MWInbilinCaptionView.h"
#import "MWCommon.h"

static const CGFloat horizontalPadding = 12;
static const CGFloat verticalPadding = 10;

@interface MWInbilinCaptionView () {
    UITextView *_textView;
}

@end

@implementation MWInbilinCaptionView
@synthesize photo = _photo;

// Init
- (id)initWithPhoto:(id<MWPhoto>)photo {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)]; // Random initial frame
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        
        self.photo = photo;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _textView.frame = CGRectMake(horizontalPadding, verticalPadding, self.bounds.size.width - 2 * horizontalPadding, self.bounds.size.height - 2 * verticalPadding);
}


- (void)setPhoto:(id<MWPhoto>)photo {
    _photo = photo;
    [self setupCaption];
}

- (void)setupCaption {
    if (!_textView) {
        UIFont *font = [UIFont systemFontOfSize:14];
        _textView = [[UITextView alloc] initWithFrame:self.bounds];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.font = font;
        _textView.textColor = [UIColor whiteColor];
        _textView.showsVerticalScrollIndicator = NO;
        _textView.showsHorizontalScrollIndicator = NO;
        _textView.editable = NO;
        _textView.textContainerInset = UIEdgeInsetsZero;
        _textView.textContainer.lineFragmentPadding = 0;
        [self addSubview:_textView];
    }
    if (_photo && [_photo respondsToSelector:@selector(caption)]) {
        NSString *text = [_photo caption] ? [_photo caption] : @" ";
        _textView.attributedText = [[NSAttributedString alloc] initWithString:text attributes:[self attrbutes]];
        _textView.contentOffset = CGPointMake(0, 0);
    }
    
    _textView.textAlignment = NSTextAlignmentLeft;
    
    if (_textView.attributedText == nil ||
        _textView.attributedText.length == 0) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

// Override -sizeThatFits: and return a CGSize specifying the height of your
// custom caption view. With width property is ignored and the caption is displayed
// the full width of the screen
- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat maxHeight = _textView.font.lineHeight * 5;
    CGSize textSize = [_textView.attributedText.string boundingRectWithSize:CGSizeMake(self.bounds.size.width-horizontalPadding*2, MAXFLOAT)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:[self attrbutes]
                                                                    context:nil].size;
    CGFloat height = (textSize.height > maxHeight ? maxHeight : textSize.height);
    return CGSizeMake(size.width, height + 2 * verticalPadding);
}

- (NSDictionary *)attrbutes {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 0.0f;
    
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle,
                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSFontAttributeName: [UIFont systemFontOfSize:14]};
    return attributes;
}

@end
