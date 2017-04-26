//
//  GLChatInputToolBar.m
//  66GoodLook
//
//  Created by Yanci on 17/4/20.
//  Copyright © 2017年 Yanci. All rights reserved.
//

#import "GLChatInputToolBar.h"
#import <Masonry/Masonry.h>
#import "GLPickEmojView.h"

typedef enum : NSUInteger {
    GLChatInputToolBarRightButtonBarType_Default,
    GLChatInputToolBarRightButtonBarType_Emoj,
    GLChatInputToolBarRightButtonBarType_Keyboard = GLChatInputToolBarRightButtonBarType_Default,
} GLChatInputToolBarRightButtonBarType;



@interface GLChatInputToolBar()<UITextViewDelegate,GLPickEmojViewDelegate>
@property (nonatomic,strong) UIButton *picBtn;
@property (nonatomic,strong) UIButton *videoBtn;
@property (nonatomic,strong) UIButton *emojBtn;
@property (nonatomic,strong) UIButton *sendBtn;
@property (nonatomic,strong) UITextView *inputTextField;
@property (nonatomic,assign) GLChatInputToolBarType barType;

/** 表情选择器,作为Pannel */
@property (nonatomic,strong) GLPickEmojView *pickEmojView;

@end

@implementation GLChatInputToolBar {
    BOOL _needsReload;  /*! 需要重载 */
    struct {

    }_datasourceHas;    /*! 数据源存在标识 */
    struct {
        unsigned didSelectToolBarType:1;
    }_delegateHas;      /*! 数据委托存在标识 */
}

#pragma mark - life cycle
- (id)initWithBarType:(GLChatInputToolBarType)barType {
    if (self = [super init]) {
        _barType = barType;
        [self commonInit];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setNeedsReload];
    }
    return self;
}

- (void)layoutSubviews {
    [self _reloadDataIfNeeded];
    [super layoutSubviews];
}

#pragma mark - datasource
#pragma mark - delegate

- (void)glPickEmojView:(id)sender didPickEmoj:(UIImage *)emojImage {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithAttributedString:self.inputTextField.attributedText];
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc]initWithData:nil ofType:nil];
    textAttachment.image = emojImage;
    textAttachment.bounds = CGRectMake(0, 0, 10, 10);
    
    NSAttributedString *emojAttriString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    const NSUInteger location = [self.inputTextField offsetFromPosition:self.inputTextField.beginningOfDocument toPosition:self.inputTextField.selectedTextRange.start];
    [attributeString insertAttributedString:emojAttriString atIndex:location];
    self.inputTextField.attributedText = attributeString;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self beginEditing];
}
#pragma mark - user events
- (void)showEmojPanel:(id)sender {
    NSLog(@"%s",__func__);
    if (_delegateHas.didSelectToolBarType) {
        if (_barType == GLChatInputToolBarType_Emoj) {
            _barType = GLChatInputToolBarType_Default;
            [_delegate glChatInputToolBar:self didSelectToolBarType:GLChatInputToolBarType_Default];
 
            [_inputTextField setInputView:nil];
            [_inputTextField reloadInputViews];
            [_inputTextField becomeFirstResponder];
        }
        else if(_barType == GLChatInputToolBarType_Default) {
            _barType = GLChatInputToolBarType_Emoj;
            [_delegate glChatInputToolBar:self didSelectToolBarType:GLChatInputToolBarType_Emoj];
 
            [_inputTextField setInputView:self.pickEmojView];
            [_inputTextField reloadInputViews];
            [_inputTextField becomeFirstResponder];
        }
        else if(_barType == GLChatInputToolBarType_Pic) {
            [self beginEditing];
        }
        else if(_barType == GLChatInputToolBarType_Video) {
            [self beginEditing];
        }
    }
}

- (void)showKeyboardPanel:(id)sender {
     NSLog(@"%s",__func__);
    if (_delegateHas.didSelectToolBarType) {
        if (_barType == GLChatInputToolBarType_Emoj) {
            _barType = GLChatInputToolBarType_Default;
            [_delegate glChatInputToolBar:self didSelectToolBarType:GLChatInputToolBarType_Default];
 
            [_inputTextField setInputView:nil];
            [_inputTextField reloadInputViews];
            [_inputTextField becomeFirstResponder];
            [self setLeftKeyBoardToPic];
            [self setLeftKeyBoardToVideo];
            
        }
        else if(_barType == GLChatInputToolBarType_Default) {
            _barType = GLChatInputToolBarType_Emoj;
            [_delegate glChatInputToolBar:self didSelectToolBarType:GLChatInputToolBarType_Emoj];
 
            [_inputTextField setInputView:self.pickEmojView];
            [_inputTextField reloadInputViews];
            [_inputTextField becomeFirstResponder];
            [self setLeftKeyBoardToPic];
            [self setLeftKeyBoardToVideo];
        }
        else if(_barType == GLChatInputToolBarType_Pic) {
            if (_inputTextField.inputView == nil) {
                _barType = GLChatInputToolBarType_Default;
            }
            else {
                _barType = GLChatInputToolBarType_Emoj;
            }
            [self setLeftKeyBoardToVideo];
            [self setLeftKeyBoardToPic];
            [_delegate glChatInputToolBar:self didSelectToolBarType:_barType];
            [_inputTextField becomeFirstResponder];
        }
        else if(_barType == GLChatInputToolBarType_Video) {
            if (_inputTextField.inputView == nil) {
                _barType = GLChatInputToolBarType_Default;
            }
            else {
                _barType = GLChatInputToolBarType_Emoj;
            }
            
            [self setLeftKeyBoardToVideo];
            [self setLeftKeyBoardToPic];
            [_delegate glChatInputToolBar:self didSelectToolBarType:_barType];
            [_inputTextField becomeFirstResponder];
        }
    }
}

- (void)showVideoPanel:(id)sender {
     NSLog(@"%s",__func__);
    if (_delegateHas.didSelectToolBarType) {
        if (_barType == GLChatInputToolBarType_Default
            || _barType == GLChatInputToolBarType_Emoj) {
            _barType = GLChatInputToolBarType_Video;
            [_delegate glChatInputToolBar:self didSelectToolBarType:GLChatInputToolBarType_Video];
            [self setLeftVideoToKeyBoard];
        }
        else if(_barType == GLChatInputToolBarType_Video) {
            [self beginEditing];
            
            if (_inputTextField.inputView == nil) {
                if (_delegateHas.didSelectToolBarType) {
                    _barType = GLChatInputToolBarType_Default;
                    [_delegate glChatInputToolBar:self
                             didSelectToolBarType:GLChatInputToolBarType_Default];
                }
            }
            else if(_inputTextField.inputView == self.pickEmojView) {
                if (_delegateHas.didSelectToolBarType) {
                    _barType = GLChatInputToolBarType_Emoj;
                    [_delegate glChatInputToolBar:self
                             didSelectToolBarType:GLChatInputToolBarType_Emoj];
                }
            }
            
        }
    }

}

- (void)showPicPanel:(id)sender {
     NSLog(@"%s",__func__);
  
    if (_delegateHas.didSelectToolBarType) {
        if (_barType == GLChatInputToolBarType_Default
            || _barType == GLChatInputToolBarType_Emoj) {
            _barType = GLChatInputToolBarType_Pic;
            [_delegate glChatInputToolBar:self didSelectToolBarType:GLChatInputToolBarType_Pic];
            [self setLeftPicToKeyBoard];
        }
        else if(_barType == GLChatInputToolBarType_Pic) {
            [self beginEditing];
            
            if (_inputTextField.inputView == nil) {
                if (_delegateHas.didSelectToolBarType) {
                    _barType = GLChatInputToolBarType_Default;
                    [_delegate glChatInputToolBar:self
                             didSelectToolBarType:GLChatInputToolBarType_Default];
                }
            }
            else if(_inputTextField.inputView == self.pickEmojView) {
                if (_delegateHas.didSelectToolBarType) {
                    _barType = GLChatInputToolBarType_Emoj;
                    [_delegate glChatInputToolBar:self
                             didSelectToolBarType:GLChatInputToolBarType_Emoj];
                }
            }
  
        }
    }
}

#pragma mark - functions


- (void)commonInit {
    [self addSubview:self.picBtn];
    [self addSubview:self.videoBtn];
    [self addSubview:self.emojBtn];
    [self addSubview:self.sendBtn];
    [self addSubview:self.inputTextField];
    
    [self.picBtn setImage:[UIImage imageNamed:@"shuru_images_icon"]
                 forState:UIControlStateNormal];
    [self.picBtn addTarget:self action:@selector(showPicPanel:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.videoBtn setImage:[UIImage imageNamed:@"shuru_shipin_icon"]
                   forState:UIControlStateNormal];
    [self.videoBtn addTarget:self action:@selector(showVideoPanel:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.emojBtn setImage:[UIImage imageNamed:@"shuru_biaoqing_icon"] forState:UIControlStateNormal];
    [self.sendBtn setImage:[UIImage imageNamed:@"shuru_fasong_01"] forState:UIControlStateNormal];
    
    if (self.barType == GLChatInputToolBarType_Default) {
        [self setKeyBoardBtn];
    }
    else if(self.barType == GLChatInputToolBarType_Emoj){
        [self setEmojBtn];
    }

    
    [self.picBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(10.0);
        make.width.offset(35.0);
        make.height.offset(35.0);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(10.0);
        make.width.offset(35.0);
        make.height.offset(35.0);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-10);
        make.width.offset(35.0);
        make.height.offset(35.0);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.emojBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.sendBtn.mas_left).offset(-10);
        make.width.offset(35.0);
        make.height.offset(35.0);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.picBtn.mas_right).offset(10);
        make.right.mas_equalTo(self.emojBtn.mas_left).offset(-10);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.offset(35.0);
    }];
    
    if (_barType == GLChatInputToolBarType_Default) {
        self.videoBtn.hidden = YES;
        self.picBtn.hidden = NO;
        [self.inputTextField becomeFirstResponder];
    }
    else if(_barType == GLChatInputToolBarType_Video) {
        self.videoBtn.hidden = NO;
        self.picBtn.hidden = YES;
        _barType = GLChatInputToolBarType_Video;
        [_delegate glChatInputToolBar:self didSelectToolBarType:GLChatInputToolBarType_Video];
        [self setLeftPicToKeyBoard];
        [self.inputTextField resignFirstResponder];
    }
    else if(_barType == GLChatInputToolBarType_Pic) {
        self.videoBtn.hidden = YES;
        self.picBtn.hidden = NO;
        _barType = GLChatInputToolBarType_Pic;
        [_delegate glChatInputToolBar:self didSelectToolBarType:GLChatInputToolBarType_Pic];
        [self setLeftPicToKeyBoard];
        [self.inputTextField resignFirstResponder];
    }
}

- (void)setBarType:(GLChatInputToolBarType)barType {
    _barType = barType;
}

- (BOOL)isEditing {
    return [self.inputTextField isFirstResponder];
}

- (void)beginEditing {
    if (_inputTextField.inputView == nil) {
        _barType = GLChatInputToolBarType_Default;
    }
    else if(_inputTextField.inputView == self.pickEmojView){
        _barType = GLChatInputToolBarType_Emoj;
    }
    [self setLeftKeyBoardToVideo];
    [self setLeftKeyBoardToPic];
    [self.inputTextField becomeFirstResponder];
    
    if (_delegateHas.didSelectToolBarType) {
       [_delegate glChatInputToolBar:self didSelectToolBarType:_barType];
    }
    
}

- (void)beginOpenPhoto {
    _barType = GLChatInputToolBarType_Pic;
    [_delegate glChatInputToolBar:self didSelectToolBarType:GLChatInputToolBarType_Pic];
    [self setLeftPicToKeyBoard];
    [self.inputTextField resignFirstResponder];
    self.videoBtn.hidden = YES;
    self.picBtn.hidden = NO;
}

- (void)beginOpenVideo {
    _barType = GLChatInputToolBarType_Video;
    [_delegate glChatInputToolBar:self didSelectToolBarType:GLChatInputToolBarType_Video];
    [self setLeftVideoToKeyBoard];
    [self.inputTextField resignFirstResponder];
    self.videoBtn.hidden = NO;
    self.picBtn.hidden = YES;
}
 
- (CGFloat)contentHeight {
    return 44.0;
}

- (void)setEmojBtn {
     [self.emojBtn setImage:[UIImage imageNamed:@"shuru_biaoqing_icon"]
                   forState:UIControlStateNormal];
    [self.emojBtn removeTarget:self action:@selector(showKeyboardPanel:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.emojBtn addTarget:self action:@selector(showEmojPanel:)
           forControlEvents:UIControlEventTouchUpInside];
}

- (void)setKeyBoardBtn {
    [self.emojBtn setImage:[UIImage imageNamed:@"shuru_biaoqing_icon"]
                   forState:UIControlStateNormal];
    [self.emojBtn removeTarget:self action:@selector(showEmojPanel:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.emojBtn addTarget:self action:@selector(showKeyboardPanel:)
           forControlEvents:UIControlEventTouchUpInside];
}

- (void)setLeftPicToKeyBoard {
    [self.picBtn setImage:[UIImage imageNamed:@"shuru_jianpan_icon"] forState:UIControlStateNormal];
}

- (void)setLeftVideoToKeyBoard {
    [self.videoBtn setImage:[UIImage imageNamed:@"shuru_jianpan_icon"] forState:UIControlStateNormal];
}

- (void)setLeftKeyBoardToPic {
    [self.picBtn setImage:[UIImage imageNamed:@"shuru_images_icon"] forState:UIControlStateNormal];
}

- (void)setLeftKeyBoardToVideo {
    [self.videoBtn setImage:[UIImage imageNamed:@"shuru_shipin_icon"] forState:UIControlStateNormal];
}


- (void)setDataSource:(id<GLChatInputToolBarDataSource>)dataSource {}

- (void)setDelegate:(id<GLChatInputToolBarDelegate>)delegate {
    _delegate = delegate;
    if ([delegate respondsToSelector:@selector(glChatInputToolBar:didSelectToolBarType:)]) {
        _delegateHas.didSelectToolBarType = 1;
    }
}

- (void)setNeedsReload {
    _needsReload = YES;
    [self setNeedsLayout];
}
- (void)_reloadDataIfNeeded {
    if (_needsReload) {
        [self reloadData];
    }
}
- (void)reloadData {}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}


#pragma mark - notification

#pragma mark - getter and setter
- (UIButton *)picBtn {
    if (!_picBtn) {
        _picBtn = [[UIButton alloc]init];
    }
    return _picBtn;
}

- (UIButton *)videoBtn {
    if (!_videoBtn) {
        _videoBtn = [[UIButton alloc]init];
    }
    return _videoBtn;
}

- (UIButton *)emojBtn {
    if (!_emojBtn) {
        _emojBtn = [[UIButton alloc]init];
    }
    return _emojBtn;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [[UIButton alloc]init];
    }
    return _sendBtn;
}

- (UITextView *)inputTextField {
    if (!_inputTextField) {
        _inputTextField = [[UITextView alloc]init];
        _inputTextField.layer.cornerRadius = 5.0;
        _inputTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _inputTextField.layer.borderWidth = 0.3;
        _inputTextField.delegate = self;
    }
    return _inputTextField;
}


- (GLPickEmojView *)pickEmojView {
    if (!_pickEmojView) {
        _pickEmojView = [[GLPickEmojView alloc]init];
        [_pickEmojView sizeWith:CGSizeMake([UIScreen mainScreen].bounds.size.width, [_pickEmojView contentHeight])];
        _pickEmojView.delegate = self;
    }
    return _pickEmojView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
