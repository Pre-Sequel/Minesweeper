
#import "ViewController.h"
#import "Cell.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *gameArea;

@end

@implementation ViewController
////////////////////////////////////////////////////////////////////////
@synthesize heightCell = heightCell; //высота ячейки
@synthesize widthCell = widthCell; //ширина ячейки
@synthesize Cells = _Cells; //массив ячеек
@synthesize indices = _indices; //массив индексов для массива соседних ячеек
@synthesize arrayOfProcessedCells = _arrayOfProcessedCells; //массив обрабатываемых ячеек
@synthesize emptyCellsGroup = _emptyCellsGroup; //массив пустых ячеек
@synthesize arrayOfNeighboringCells = _arrayOfNeighboringCells; //массив соседних ячеек
@synthesize arrayObrabotannie = _arrayObrabotannie; //массив уже обработанных ячеек
@synthesize Flag = _Flag;

//@synthesize cellType = _cellType;
//@synthesize coordinates = _coordinates;

//Функция создает игоровое поле, делит его на фрагменты, пробуем заменить фрагменты
-(void) initGameField { //создаем игровое поле
    _Cells = [[NSMutableArray alloc] init]; //инициализируем все массивы, которые потребуются в процессе работы
    _indices = [[NSMutableArray alloc] init]; //
    _arrayOfProcessedCells = [[NSMutableArray alloc] init]; //
    _emptyCellsGroup =[[NSMutableArray alloc] init]; //
    int index = 0; //переменная индекс ячейки
    
    [_Cells removeAllObjects]; //очищаем массив ячеек (если он не пустой)
    
    UIImage *battleField = [UIImage imageNamed:@"320x568_light_gray"]; //создаем переменную типа Изображение
    CGRect frameBattleField = CGRectMake(0, 88, 320, (numberOfVerticalCells>12)?480: 40*numberOfVerticalCells); //создаем рамку
    _gameArea.frame = frameBattleField; //_gameArea это связь с нашим игровым полем Game Area. Назначаем рамку для нашего игрового поля
    widthCell = (_gameArea.frame.size.width-(numberOfGorizontalCells-1))/numberOfGorizontalCells; //определяем количество пикселей по горизонтали для одного сектора
    heightCell = (_gameArea.frame.size.height-(numberOfVerticalCells-1))/numberOfVerticalCells; //определяем количество пикселей по вертикали для одного сектора
    
    //блок формирует множество ячеек методом наложения рамки. также задаются начальные параметры для ячейки
    for (int y=0; y < numberOfVerticalCells; y++) {
        for (int x=0; x < numberOfGorizontalCells; x++) {
            //CGRect frame = CGRectMake(39 * x, 39 * y, 39, 39); //39 пикселей - сторона одной ячейки
            CGRect frame = CGRectMake(widthCell * x, heightCell * y, widthCell, heightCell); //формирование рамки для каждой будущей ячейки
            CGImageRef cellImageRef = CGImageCreateWithImageInRect(battleField.CGImage, frame); //вырезаем кусок картинки рамкой
            UIImage *cellImage = [UIImage imageWithCGImage: cellImageRef]; //создаем из этого  куска переменную типа Изображение
            CGRect frameWithSpace = CGRectMake((widthCell+spaceBetweenCells)*x, (heightCell+spaceBetweenCells)*y, widthCell, heightCell);//39 сторона ячейки и 1 пробел между ними. Создаем рамку которая содержит также пробелы между изображениями
            //coordinates = CGPointMake(x, y);
            Cell *cellImageView = [[Cell alloc] initWithImage:cellImage]; //создаем саму ячейку
            
            
            cellImageView.frame = frameWithSpace; //задаем рамку с пробелом чтобы была визуальная белая граница между ячейками
            cellImageView.coordinates = CGPointMake(x, y);
            cellImageView.cellType = 0;//по умолчанию все ячейки сначало закрытые
            index = index + 1;
            //NSLog(@"index %d",index);
            cellImageView.indexOfCell = index;
            cellImageView.used = NO;//по умолчанию все ячейки не отработанные
            cellImageView.image = [UIImage imageNamed:@"closeCell"];//по умолчанию все ячейки скрываем
            [_Cells addObject:cellImageView];//массив указателей на ячейки
            [_gameArea addSubview:cellImageView]; //добавляем ячейку на игровое поле
        }}
}
//функция инициализирует мины
- (void) initialMines {
    //выбираем 10 ячеек рэндомно
    NSInteger ourMines = 0;//начальное количество мин на игровом поле
    NSMutableArray *mines = [[NSMutableArray alloc] init];//инийиализируем массив с ячейками-минами
    while (ourMines < numberOfMines) { //цикл пока мин на поле меньше чем numberOfMines
        //int r = arc4random_uniform([_Cells count]-1);//генерируем рэндомное число от 0 до к примеру до 63 при размере поля 8 на 8
        int r = 2;
        NSNumber *n = [NSNumber numberWithInt:r]; //переводим инт в NSNumber
        Cell *currentCell = [_Cells objectAtIndex:r];//получаем ячейку по рэндомному индексу
        //[mines addObject:currentCell];
        if (currentCell.cellType != 9) { //если рэндомная ячейка еще не мина
            currentCell.cellType = 9; //то делаем ее миной
            ourMines = ourMines+1; //увеличиваем счетчик мин на поле
            [mines addObject:n]; //добавляем в массив мин индекс мины
        }}
    
    [self initialNumbers4:mines];//формируем числа на ячейках которые будут соседствоавать с минами
}

//функция формирует массив индексов тех ячеек, которые будут рядом
- (void) initialNumbers4:(NSMutableArray *) mines { //входной параметр - массив с индексами мин
    for (NSNumber *mineIndex in mines) { //для каждого индекса ячейки с миной
        int mineIndexInt = [mineIndex intValue]; //переводим тип индекса в Инт
        //NSLog(@"mine %d",mineIndexInt);
        Cell *mine = [_Cells objectAtIndex:mineIndexInt];//получаем мину
        int x = mine.coordinates.x; //столбец с миной
        int y = mine.coordinates.y; //строка с миной
        if (x==0) { //формируем массив массив, который будет содержать изменения (дельта) на которую надо будет изменить индекс мины, чтобы получить соседние ячейки т.е. -+8 -+7 -+1 например
            if (y==0) { //если мина сверху слева, то чтобы получить соседние ячейки нужно изменить индекс на 1 ,8, 9 (к примеру)
                [self ArrayOfIndex:1];
                [self ArrayOfIndex:numberOfGorizontalCells];
                [self ArrayOfIndex:(numberOfGorizontalCells+1)];
            } else if ((y!=0) && (y!= (numberOfVerticalCells-1))) { //если мина слева в центре
                [self ArrayOfIndex:(numberOfGorizontalCells*-1)];
                [self ArrayOfIndex:(numberOfGorizontalCells*-1)+1];
                [self ArrayOfIndex:1];
                [self ArrayOfIndex:numberOfGorizontalCells];
                [self ArrayOfIndex:(numberOfGorizontalCells+1)];
            } else if (y==(numberOfVerticalCells-1)) { //если ячейка слева снизу
                [self ArrayOfIndex:(numberOfGorizontalCells*-1)];
                [self ArrayOfIndex:(numberOfGorizontalCells*-1)+1];
                [self ArrayOfIndex:1];}
        } else if ((x!=0) && (x!=(numberOfGorizontalCells-1))) { //если ячейка в центре сверху
            if (y==0) {
                [self ArrayOfIndex:-1];
                [self ArrayOfIndex:1];
                [self ArrayOfIndex:(numberOfGorizontalCells-1)];
                [self ArrayOfIndex:numberOfGorizontalCells];
                [self ArrayOfIndex:(numberOfGorizontalCells+1)];
            } else if ((y!=0) && (y!=(numberOfVerticalCells-1))) { //если ячейка в самом центре поля (ну или просто окружена со всех допустимых сторон ячейками)
                [self ArrayOfIndex:(numberOfGorizontalCells*-1)-1];
                [self ArrayOfIndex:(numberOfGorizontalCells*-1)];
                [self ArrayOfIndex:(numberOfGorizontalCells*-1)+1];
                [self ArrayOfIndex:-1];
                [self ArrayOfIndex:1];
                [self ArrayOfIndex:(numberOfGorizontalCells-1)];
                [self ArrayOfIndex:numberOfGorizontalCells];
                [self ArrayOfIndex:(numberOfGorizontalCells+1)];
            } else if (y==(numberOfVerticalCells-1)) { //если ячейка снизу по центру
                [self ArrayOfIndex:(numberOfGorizontalCells*-1)-1];
                [self ArrayOfIndex:(numberOfGorizontalCells*-1)];
                [self ArrayOfIndex:(numberOfGorizontalCells*-1)+1];
                [self ArrayOfIndex:-1];
                [self ArrayOfIndex:1];}
        } else if (x==(numberOfGorizontalCells-1)) {
            if (y==0) { //если ячейка справа сверху
                [self ArrayOfIndex:-1];;
                [self ArrayOfIndex:(numberOfGorizontalCells-1)];
                [self ArrayOfIndex:numberOfGorizontalCells];
            } else if ((y!=0) && (y!=(numberOfVerticalCells-1))) { //если ячейка справа по центру
                [self ArrayOfIndex:(numberOfGorizontalCells*-1)-1];
                [self ArrayOfIndex:(numberOfGorizontalCells*-1)];
                [self ArrayOfIndex:-1];
                [self ArrayOfIndex:(numberOfGorizontalCells-1)];
                [self ArrayOfIndex:numberOfGorizontalCells];
            } else if (y==(numberOfVerticalCells-1)) { //если ячейка справа снизу
                [self ArrayOfIndex:(numberOfGorizontalCells*-1)-1];
                [self ArrayOfIndex:(numberOfGorizontalCells*-1)];
                [self ArrayOfIndex:-1];}
        };
        
        for (NSNumber *cellIndex in _indices) { //после того как массив дельта для индекса мины сформирован мы каждую дельту прибавляем к индексу мины тем самым получая все соседние ячейки и увеличивая их "счетчик"
            int index = [mineIndex intValue]+[cellIndex intValue];
            Cell *cell = [_Cells objectAtIndex:index];
            if (cell.cellType !=9) { //если соседняя ячейка мина то пропускаем ее
                cell.cellType = cell.cellType + 1; }}
        [_indices removeAllObjects]; //очищаем массив индексов чтобы обработать следующую мину так как для нее уже будет другая дельта
    }
    // отображаем ячейки
    for (Cell *c in _Cells)     {
        if (c.cellType != 0)  {
            [self drawСell:c];
        }
    }
}

//функция переводит инт в нснамбер и добавляет его в массив индексов
-(void) ArrayOfIndex:(NSInteger) i {
    NSNumber *m = [NSNumber numberWithInt:i];
    [_indices addObject:m]; //добавляем в массив параметры на которые нужно изменить индекс мины чтобы получить все соседние ячейки
}

//функция отображает ячейку согласно ее типу
- (void) drawСell: (Cell *) cell {
    if ((cell.cellType >0) && (cell.cellType < 9)) {
        NSString *type = [NSString stringWithFormat:@"%f",cell.cellType];
        //NSLog(type);
        cell.image = [UIImage imageNamed:type]; //1-8 ячейки с цифрами
    } else if (cell.cellType == 9) {
        cell.image = [UIImage imageNamed:@"mine"];} //9 - мина
    else if (cell.cellType == 10) {
        cell.image = [UIImage imageNamed:@"mine_exp"];} //10 - взрыв
    else if (cell.cellType == 11) {
        cell.image = [UIImage imageNamed:@"flag"];} //11 - флаг
    else if (cell.cellType == 12) {
        cell.image = [UIImage imageNamed:@"mine_ban"];} //12 - mine_ban
    else if (cell.cellType == 0) {
        cell.image = [UIImage imageNamed:@"openCell"];} //0 - пустая ячейка
}

//функция отрабатывает прикосновение на игровое поле
- (void) touchesEnded:(NSSet *)touches
            withEvent:(UIEvent *)event
{
    UITouch *tap = [touches anyObject];
    CGPoint tapPoint = [tap locationInView:_gameArea];
    CGRect tapRect = CGRectMake(tapPoint.x, tapPoint.y, 1, 1); //создаем точку прикосновения размером с один пиксель
    for (Cell *c in _Cells) {
        //[self drawСell:c];//раскрыть все ячейки по нажатию
        if (CGRectIntersectsRect(c.frame, tapRect)) { //если рамки пересекаются
            [self drawСell:c];//раскрыть текущую ячейку
            //[self recurs:c];
            //[self perebor2:c];
            
            //            [_emptyCellsGroup removeAllObjects];
            //            if (c.cellType == 0) {
            //                c.used = YES;
            //                [_emptyCellsGroup addObject:c];}
            //            _Flag = NO;
            //c.used = NO;
            //NSArray *ArrayOfProccedCell = [[NSMutableArray alloc] init];
            [_arrayOfProcessedCells addObject:c];
            [self markNearEmptyCellsAsOpen:_arrayOfProcessedCells];
            
            
            //[self perebor5:_emptyCellsGroup];
            //break;
            for (Cell *emptycell in _arrayOfProcessedCells) {
                [self drawСell:emptycell];
            }
        }
    }
    [_arrayOfProcessedCells removeAllObjects];
}



- (void) perebor2: (Cell *) cell {
    //по нажатию получаем ячейку
    //NSMutableArray *arrayOfT = [[NSMutableArray alloc] init];
    if (cell.cellType == 0) {
        [_emptyCellsGroup addObject:cell];
        //float y = cell.coordinates.y;
        int b = cell.coordinates.y;
        int a = cell.coordinates.x;
        NSInteger k  = b * numberOfGorizontalCells + a;//индекс нажатой пустой ячейки
        
        int l = k+numberOfGorizontalCells;
        while (l<[_Cells count]) { //перебор всех нижних от ячейки ячеек
            Cell *ProveryaemayaCell = [_Cells objectAtIndex:l];
            if (ProveryaemayaCell.cellType == 0) {
                [_emptyCellsGroup addObject:ProveryaemayaCell];
            } else {
                [self drawСell:ProveryaemayaCell];
                break;}
            l = l+numberOfGorizontalCells;
        }
        
        //перебор всех ячеек выше по столбцу
        //NSInteger h  = b * numberOfGorizontalCells + a;
        NSInteger h = k - numberOfGorizontalCells;
        while (h>=0) {
            Cell *ProveryaemayaCell = [_Cells objectAtIndex:h];
            if (ProveryaemayaCell.cellType == 0) {
                [_emptyCellsGroup addObject:ProveryaemayaCell];
            } else {
                [self drawСell:ProveryaemayaCell];
                break;}
            h = h-numberOfGorizontalCells;
        }
        
        //перебор ячеек слева от столбца с пустой ячейкой
        
        int x = cell.coordinates.x;
        int n = x-1;
        while (n>=0)  {
            for (Cell *c in _Cells) {
                if (c.cellType == 0) {
                    int r = c.coordinates.x;//номер столбца у самой первой нажатой ячейки
                    if (r == n) { //если ячейка с соседнем столбце
                        NSInteger j  = ((c.coordinates.y)*numberOfGorizontalCells + c.coordinates.x);//индекс каждой перебираемой ячейки *с
                        Cell *cell1 = [[Cell alloc] init];
                        //Cell *cell2 = [[Cell alloc] init];
                        Cell *cell2 = [_Cells objectAtIndex:j+1];
                        Cell *cell3 = [[Cell alloc] init];
                        
                        if ((j-numberOfGorizontalCells+1) >=0){//правая верхняя
                            cell1 = [_Cells objectAtIndex:j-numberOfGorizontalCells+1];}
                        //if (j<(numberOfGorizontalCells*numberOfVerticalCells)-1){
                        //    cell2 = [_Cells objectAtIndex:j+1];}//правая
                        if ((j+numberOfGorizontalCells+1) <numberOfGorizontalCells*numberOfVerticalCells){
                            cell3 = [_Cells objectAtIndex:j+numberOfGorizontalCells+1];}//правая нижняя
                        
                        if ((cell1.cellType == 0)|(cell2.cellType == 0)|(cell3.cellType == 0)){
                            //NSLog(@"%f,%f",c.coordinates.x,c.coordinates.y);
                            [_emptyCellsGroup addObject:c];};
                    }
                }
                
            }n=n-1;}
        //перебор ячеек справа от столбца с нажатой пустой ячейкой
        //NSInteger x = cell.coordinates.x +1;
        
        int m = x+1;//m номер столбца справа
        while (m<numberOfGorizontalCells){
            for (Cell *c in _Cells) {
                int t = c.coordinates.x;
                if (t == m){ //если ячейка с соседнем столбце
                    NSInteger j  = ((c.coordinates.y)*numberOfGorizontalCells + c.coordinates.x);//индекс перебираемой ячейки
                    Cell *cell1 = [[Cell alloc] init];
                    Cell *cell2 = [_Cells objectAtIndex:j-1]; //левая
                    Cell *cell3 = [[Cell alloc] init];
                    
                    if ((j-numberOfGorizontalCells-1) >0){
                        cell1 = [_Cells objectAtIndex:j-numberOfGorizontalCells-1];}//левая верхняя
                    
                    if ((j+numberOfGorizontalCells-1)<numberOfGorizontalCells*numberOfVerticalCells){
                        cell3 = [_Cells objectAtIndex:j+numberOfGorizontalCells-1];}//верхняя правая
                    
                    if ((cell1.cellType == 0)|(cell2.cellType == 0)|(cell3.cellType == 0)){
                        //NSLog(@"%f,%f",c.coordinates.x,c.coordinates.y);
                        [_emptyCellsGroup addObject:c];};
                }
                
            }
            m = m+1;
        }
    }
    
    
    //цикл для открытия всех пустых ячеек
    for (Cell *c in _emptyCellsGroup) {
        [self drawСell:c];
    }
}



- (void) perebor3: (NSMutableArray *) emptyCellsGroup {
    
    //пробуем рекурсию
    //цикл по всем клеткам проходит только 1 раз
    if (!_Flag) {
        
        for (Cell *emptycell in emptyCellsGroup) {
            for (Cell *c in _Cells) {
                if (c.cellType == 0) {
                    //проверка есть ли вокруг нажатой пустой ячейки другие пустые
                    //если ячейка справа пустая
                    if (((emptycell.coordinates.x == c.coordinates.x-1) && (emptycell.coordinates.y == c.coordinates.y)) ||
                        //если ячейка сверху слв пустая
                        ((emptycell.coordinates.x == c.coordinates.x+1) && (emptycell.coordinates.y == c.coordinates.y+1)) ||
                        //если ячейка сверху пустая
                        ((emptycell.coordinates.x == c.coordinates.x) && (emptycell.coordinates.y == c.coordinates.y+1)) ||
                        //если ячейка сверху спр пустая
                        ((emptycell.coordinates.x == c.coordinates.x-1) && (emptycell.coordinates.y == c.coordinates.y+1)) ||
                        //если ячейка слева пустая
                        ((emptycell.coordinates.x == c.coordinates.x+1) && (emptycell.coordinates.y == c.coordinates.y)) ||
                        //если ячейка снизу слева пустая
                        ((emptycell.coordinates.x == c.coordinates.x+1) && (emptycell.coordinates.y == c.coordinates.y-1)) ||
                        //если ячейка снизу пустая
                        ((emptycell.coordinates.x == c.coordinates.x) && (emptycell.coordinates.y == c.coordinates.y-1)) ||
                        //если ячейка снизу справа пустая
                        ((emptycell.coordinates.x == c.coordinates.x-1) && (emptycell.coordinates.y == c.coordinates.y-1))) {
                        [_emptyCellsGroup addObject:c];//добавляем проверяемую ячейку в массив пустых ячеек
                        [self perebor3:_emptyCellsGroup];//запускаем рекурсию
                    } else {
                        _Flag = YES; //флаг того что ячейки соседние пустые ячейки закончились
                    }}
            }
        }
    }
    //цикл для открытия всех пустых ячеек
    for (Cell *c in _emptyCellsGroup) {
        [self drawСell:c];}
}



- (void) perebor4: (NSMutableArray *) emptyCellsGroup {
    
    //пробуем рекурсию
    //цикл по всем клеткам проходит только 1 раз
    if (!_Flag) {
        
        for (Cell *emptycell in emptyCellsGroup) {
            for (Cell *c in _Cells) {
                if (c.cellType == 0) {
                    if ((emptycell.coordinates.x == c.coordinates.x-1) && (emptycell.coordinates.y == c.coordinates.y)) {//если ячейка справа пустая
                        [_emptyCellsGroup addObject:c];
                        [self perebor4:_emptyCellsGroup];
                    } else if ((emptycell.coordinates.x == c.coordinates.x+1) && (emptycell.coordinates.y == c.coordinates.y+1)) {//ячейка сверху слева пуст
                        [_emptyCellsGroup addObject:c];
                        [self perebor4:_emptyCellsGroup];
                    } else if ((emptycell.coordinates.x == c.coordinates.x) && (emptycell.coordinates.y == c.coordinates.y+1)) {//если ячейка сверху пуст
                        [_emptyCellsGroup addObject:c];
                        [self perebor4:_emptyCellsGroup];
                    } else if ((emptycell.coordinates.x == c.coordinates.x-1) && (emptycell.coordinates.y == c.coordinates.y+1)) {//ячейка сверху справ пуст
                        [_emptyCellsGroup addObject:c];
                        [self perebor4:_emptyCellsGroup];
                    } else if ((emptycell.coordinates.x == c.coordinates.x+1) && (emptycell.coordinates.y == c.coordinates.y)) {//если ячейка слева пустая
                        [_emptyCellsGroup addObject:c];
                        [self perebor4:_emptyCellsGroup];
                    } else if ((emptycell.coordinates.x == c.coordinates.x+1) && (emptycell.coordinates.y == c.coordinates.y-1)) {//ячейка снизу слева пуст
                        [_emptyCellsGroup addObject:c];
                        [self perebor4:_emptyCellsGroup];
                    } else if ((emptycell.coordinates.x == c.coordinates.x) && (emptycell.coordinates.y == c.coordinates.y-1)) { //ячейка снизу пустая
                        [_emptyCellsGroup addObject:c];
                        [self perebor4:_emptyCellsGroup];
                    } else if ((emptycell.coordinates.x == c.coordinates.x-1) && (emptycell.coordinates.y == c.coordinates.y-1)) {//ячейка снизу справа пуст
                        [_emptyCellsGroup addObject:c];
                        [self perebor4:_emptyCellsGroup];
                        //                    } else if ((emptycell.coordinates.x == c.coordinates.x) && (emptycell.coordinates.y == c.coordinates.y)) {//ячейка нажатия пуст
                        //                        //[_emptyCellsGroup addObject:c];
                        //                        //[self perebor4:_emptyCellsGroup];
                    } else {
                        if ((emptycell.coordinates.x != c.coordinates.x) && (emptycell.coordinates.y != c.coordinates.y)) {
                            _Flag = YES; }
                    }}
            }
        }
    }
    //цикл для открытия всех пустых ячеек
    for (Cell *c in _emptyCellsGroup) {
        [self drawСell:c];}
}

- (void) perebor5: (NSMutableArray *) _arrayOfProcessedCells {
    for (Cell *emptycell in _Cells) { //для всех пустых ячеек на поле
        for (Cell *c in _arrayOfProcessedCells) {
            if (c.cellType == 0) {
                //проверка есть ли вокруг нажатой пустой ячейки другие пустые
                //если ячейка справа пустая
                if (emptycell.cellType == 0) {
                    if (((emptycell.coordinates.x == c.coordinates.x-1) && (emptycell.coordinates.y == c.coordinates.y)) ||
                        //если ячейка сверху слв пустая
                        ((emptycell.coordinates.x == c.coordinates.x+1) && (emptycell.coordinates.y == c.coordinates.y+1)) ||
                        //если ячейка сверху пустая
                        ((emptycell.coordinates.x == c.coordinates.x) && (emptycell.coordinates.y == c.coordinates.y+1)) ||
                        //если ячейка сверху спр пустая
                        ((emptycell.coordinates.x == c.coordinates.x-1) && (emptycell.coordinates.y == c.coordinates.y+1)) ||
                        //если ячейка слева пустая
                        ((emptycell.coordinates.x == c.coordinates.x+1) && (emptycell.coordinates.y == c.coordinates.y)) ||
                        //если ячейка снизу слева пустая
                        ((emptycell.coordinates.x == c.coordinates.x+1) && (emptycell.coordinates.y == c.coordinates.y-1)) ||
                        //если ячейка снизу пустая
                        ((emptycell.coordinates.x == c.coordinates.x) && (emptycell.coordinates.y == c.coordinates.y-1)) ||
                        //если ячейка снизу справа пустая
                        ((emptycell.coordinates.x == c.coordinates.x-1) && (emptycell.coordinates.y == c.coordinates.y-1))) {
                        c.used = YES;
                        [_arrayOfProcessedCells addObject:emptycell];
                    }
                }
            }
        }
    }
}

- (void) perebor6: (NSMutableArray *) _arrayOfProcessedCells {
    
    for (Cell *c in _arrayOfProcessedCells)  {
        for (Cell *emptycell in _Cells) { //для всех пустых ячеек на поле
            if ((emptycell.cellType == 0) && (c.used == NO))  {
                //проверка есть ли вокруг нажатой пустой ячейки другие пустые
                //если ячейка справа пустая
                if (emptycell.cellType == 0) {
                    if (((emptycell.coordinates.x == c.coordinates.x-1) && (emptycell.coordinates.y == c.coordinates.y)) ||
                        //если ячейка сверху слв пустая
                        ((emptycell.coordinates.x == c.coordinates.x+1) && (emptycell.coordinates.y == c.coordinates.y+1)) ||
                        //если ячейка сверху пустая
                        ((emptycell.coordinates.x == c.coordinates.x) && (emptycell.coordinates.y == c.coordinates.y+1)) ||
                        //если ячейка сверху спр пустая
                        ((emptycell.coordinates.x == c.coordinates.x-1) && (emptycell.coordinates.y == c.coordinates.y+1)) ||
                        //если ячейка слева пустая
                        ((emptycell.coordinates.x == c.coordinates.x+1) && (emptycell.coordinates.y == c.coordinates.y)) ||
                        //если ячейка снизу слева пустая
                        ((emptycell.coordinates.x == c.coordinates.x+1) && (emptycell.coordinates.y == c.coordinates.y-1)) ||
                        //если ячейка снизу пустая
                        ((emptycell.coordinates.x == c.coordinates.x) && (emptycell.coordinates.y == c.coordinates.y-1)) ||
                        //если ячейка снизу справа пустая
                        ((emptycell.coordinates.x == c.coordinates.x-1) && (emptycell.coordinates.y == c.coordinates.y-1))) {
                        //получаем индекс обрабатываемой ячейки
                        //c.coordinates.x
                        
                        c.used == YES;
                        [_arrayOfProcessedCells addObject:emptycell];
                        //[self perebor6:_arrayOfProcessedCells];
                    }
                }
            }
        }
    }
}
//написать кусок кода который генерирует на поле 4 на 4 1 мину в определенном месте

- (void) markNearEmptyCellsAsOpen: (NSMutableArray *) _arrayOfProcessedCells {
    if (_arrayOfProcessedCells.count>0){
        for (Cell *c in _arrayOfProcessedCells) {
            for (Cell *emptycell in _Cells) {
                if ((emptycell.cellType == 0) &&
                    (c.used == NO) &&
                    ([self isCell:c aNeighborOfCell:emptycell]) &&
                    (emptycell.used == NO)) {
                    NSLog(@"Index %f",emptycell.indexOfCell);
                    [_arrayOfProcessedCells addObject:emptycell];
                }
            }
            
            c.used = YES;
            [_arrayOfProcessedCells removeObject:c];
            [self markNearEmptyCellsAsOpen:_arrayOfProcessedCells];
        }
    }
}

- (BOOL) isCell:(Cell *)originalCell aNeighborOfCell:(Cell *)anotherCell  {
    return ((ABS(originalCell.coordinates.x - anotherCell.coordinates.x) <= 1) &&
            (ABS(originalCell.coordinates.y - anotherCell.coordinates.y) <= 1));
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initGameField];
    [self initialMines];
}

@end
