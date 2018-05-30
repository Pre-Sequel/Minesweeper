//
//  Cell.h
//  Minesweeper
//
//  Created by Steve McQueen on 17.02.2018.
//  Copyright © 2018 Steve McQueen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Cell : UIImageView {
    CGPoint coordinates;
    CGFloat cellType;
    CGFloat indexOfCell;
    BOOL used;
}
@property (nonatomic, assign) CGPoint coordinates;
@property (nonatomic, assign) CGFloat cellType;
@property (nonatomic, assign) CGFloat indexOfCell;
@property (nonatomic, assign) BOOL used;
@end
