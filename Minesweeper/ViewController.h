//
//  ViewController.h
//  Minesweeper
//
//  Created by Steve McQueen on 07.02.2018.
//  Copyright © 2018 Steve McQueen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
CGFloat heightCell; //переменная отвечает за высоту ячейки
CGFloat widthCell;  //переменная отвечает за ширину ячейки
NSMutableArray *Cells; //массив всех ячеек
NSMutableArray *indices;
NSMutableArray *arrayOfProcessedCells; //массив ячеек которые будут обработаны процедурой
NSMutableArray *emptyCellsGroup; //массив пустых ячеек
NSMutableArray *arrayOfNeighboringCells; //массив соседних ячеек
NSMutableArray *arrayObrabotannie;
    BOOL Flag;
    
}
@property (nonatomic, assign) CGFloat heightCell;
@property (nonatomic, assign) CGFloat widthCell;
@property (nonatomic, strong) NSMutableArray *Cells;
@property (nonatomic, strong) NSMutableArray *indices;
@property (nonatomic, strong) NSMutableArray *arrayOfProcessedCells;
@property (nonatomic, strong) NSMutableArray *emptyCellsGroup;
@property (nonatomic, strong) NSMutableArray *arrayOfNeighboringCells;
@property (nonatomic, strong) NSMutableArray *arrayObrabotannie;
@property (nonatomic, assign) BOOL Flag;


//прописываем константы
#define numberOfGorizontalCells 3 //число горизонтальных ячеек
#define numberOfVerticalCells 4 //число вертикальных ячеек
#define spaceBetweenCells 1 //расстояние между ячейками
#define numberOfMines 1 //число мин на поле
@end

