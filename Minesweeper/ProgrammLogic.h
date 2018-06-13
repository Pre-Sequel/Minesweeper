//
//  MinesweeperLogic.h
//  Minesweeper
//
//  Created by Steve McQueen on 02.06.2018.
//  Copyright © 2018 Steve McQueen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProgrammLogic : NSObject

CGFloat heightCell; //переменная отвечает за высоту ячейки
CGFloat widthCell;  //переменная отвечает за ширину ячейки
NSMutableArray *Cells; //массив всех ячеек
NSMutableArray *arrayOfProcessedCells; //массив ячеек которые будут обработаны процедурой
NSMutableArray *emptyCellsGroup; //массив пустых ячеек
NSMutableArray *arrayOfNeighboringCells; //массив соседних ячеек
BOOL Flag;
BOOL used;

//@property (weak, nonatomic) NSString *blabla;
@property (nonatomic, assign) CGFloat heightCell;
@property (nonatomic, assign) CGFloat widthCell;
@property (nonatomic, strong) NSMutableArray *Cells;
@property (nonatomic, strong) NSMutableArray *arrayOfProcessedCells;
@property (nonatomic, strong) NSMutableArray *emptyCellsGroup;
@property (nonatomic, strong) NSMutableArray *arrayOfNeighboringCells;
@property (nonatomic, assign) BOOL Flag;
@property (nonatomic, assign) BOOL used;

//-(void)printSomething;
//-(void)whjkwegrhjwegjqf;
@end
