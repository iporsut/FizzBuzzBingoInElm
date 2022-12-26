# FizzBuzz Bing Go in Elm


![FizzBuzzBingGo](FizzBuzzBingGo.png)

```
1, B, F, 2, 6
B, 7, B, B, F
F, F, 4, B, F
B, B, 8, B, B
F, 25, B, B, 10
```

วันนี้เราจะมาหัดเขียน Elm ซึ่งเป็น Functional Programming language ที่มีไว้เพื่อพัฒนาเว็บแอพโดยเฉพาะกันครับ

โจย์เราวันนี้คือสร้าง Game เรียกกันว่า FizzBuzz Bing Go

หลายคนอาจจะคุ้ยเคยกับ FizzBuzz กันอยู่บ้าง มันคือโจทย์ง่ายๆว่า ถ้าเลขหารด้วย 3 ลงตัวให้พูดหรือแสดงคำว่า Fizz ถ้าหาร 5 ลงตัวให้แสดง Buzz และ ถ้าหารด้วย 5 และ 3 ลงตัวให้แสดง FizzBuzz

ส่วน FizzBuzz Bing Go คือเราจะมีตาราง 5x5 ที่ตัวอักษร F แทน Fizz และ B แทน Buzz และตัวเลขอื่นๆแต่ไม่เกิน 100

จากนั้นเราจะสุ่มตัวเลข 1 ถึง 100 ขึ้นมา ถ้าเลขหาร 3 ลงตัว ผู้เล่นจะเลือก F ตัวไหนก็ได้ 1 ช่อง ถ้าหาร 5 ลงตัวจะเลือก B ช่องไหนก็ได้ 1 ช่อง ถ้าหาร 5 และ 3 ลงตัว จะเลือก F หรือ B ช่องไหนก็ได้ 1 ช่อง

ใครเลือกจนได้ครบ 5 ช่อง แนวตั้ง, แนวนอน หรือแนวเฉียงๆก่อน คนนั้นชนะ

เรามาเริ่มจากสร้าง function เพื่อบอกเราได้ว่าตัวเลขเป็น Fizz, Buzz, FizzBuzz หรือเป็นตัวเลขธรรมดาอื่นๆกันก่อนเลย

เราออกแบบให้มี type ใหม่ขึ้นมาทำหน้าที่แทนตัวเลขที่มี Fizz, Buzz, FizzBuzz ร่วมอยู่ด้วย แบบนี้

```elm
type FizzBuzzNumber
    = Fizz
    | Buzz
    | FizzBuzz
    | Number Int
```

จากนั้นเราก็สร้างฟังก์ชันชื่อ toFizzBuzzNumber โดยให้รับค่าตัวเลข Int แล้วแปลงเป็น FizzBuzzNumber

```elm
toFizzBuzzNumber : Int -> FizzBuzzNumber
toFizzBuzzNumber n =
    if modBy 15 n == 0 then
        FizzBuzz
    else if modBy 3 n == 0 then
        Fizz
    else if modBy 5 n == 0 then
        Buzz
    else
        Number n
```

ต่อไปเรามาสร้าง type ใหม่เพื่อแทนช่อง 1 ช่องบนตารางบิงโกกัน

โดยเราจะใช้ record type เพื่อระบุ FizzBuzzNumber ของช่องนั้น และ สถานะ ว่าช่องนั้นถูกกาไปแล้วหรือยัง

```elm
type alias BingGoCell =
    { number : FizzBuzzNumber
    , chosen : Bool
    }
```

แต่ว่าเราอยากเทรกด้วยว่าช่องนั้นสามารถเลือกกาได้หรือเปล่าด้วย เลยจะเพิ่มอีก 1 field เข้าไปชื่อ choosable เวลาเลข random ขึ้นมาก็ค่อยเอามาเช็คว่าช่องนี้สามารถกาได้หรือไม่สำหรับเลขล่าสุดที่สุ่มขึ้นมา

```elm
type alias BingGoCell =
    { number : FizzBuzzNumber
    , chosen : Bool
    , choosable : Bool
    }
```



ต่อไปเราสร้าง type เพื่อแทนบิงโกบอร์ด เป็น array 1 มิติ ที่เก็บแต่ละช่อง เก็บเลขในแต่ละช่องของตารางบิงโก้

```elm
type alias BingGoBoard =
    Array BingGoCell
```

เราใช้อาเรย์แค่ 1 มิติเพราะเรารู้อยู่แล้วว่าตารางคือ 5x5 เลยทำให้รู้ว่าแต่ละ index แทนช่องของ row และ column ไหนนั่นเอง

ต่อไปเราจะสร้างฟังก์ชันเพื่อสร้าง BingGoBoard จริงๆเราอยากไฟล์ board ที่ random ตัวเลข แต่ก่อนที่เราจะไปดูเรื่องการ Random ตัวเลขในวิธีแบบ Functional language อย่าง Elm เราทำให้ง่ายๆเข้าไว้ โดยสร้าง function ที่จะสร้าง BingGoBoard จากลิสต์ของตัวเลขแทน

```elm
makeBingGoBoard : List Int -> Maybe BingGoBoard
makeBingGoBoard nums =
    let
        makeCell num =
            { number = toFizzBuzzNumber num, chosen = False, choosable = False }
    in
    if List.length nums /= 25 then
        Nothing

    else
        Just (Array.fromList (List.map makeCell nums))
```

จะเห็นว่า return type คือ `Maybe BingGoBoard` เพราะเราต้องการตรวจสอบว่า List มีค่า 25 ตัวหรือไม่ ถ้าไม่เราจะ return Nothing ไปแทนได้

จากนั้นเราสร้าง makeCell เพื่อ map ค่าตัวเลข เอาไปสร้าง BingGoCell จากนั้นก็แค่แปลงกลับเป็น Array

หลังจากได้ BingGoBoard แล้ว ในเกมส์เมื่อผู้เล่นกดเลือกกาช่องที่ต้องการ เราต้องไป mark chosen ของ cell นั้นๆให้เป็น True
เราเลยสร้างอีกฟังก์ชัน เพื่อทำหน้าที่เปลี่ยน chosen ให้เป็น True ดังนี้

```elm
type alias CellIndex =
    Int

chooseCell : CellIndex -> BingGoBoard -> BingGoBoard
chooseCell index board =
    let
        getCell =
            Array.get index board
    in
    case getCell of
        Nothing ->
            board

        Just cell ->
            Array.set index { cell | chosen = True } board
```

ฟังก์ชันรับค่า index ซึ่งเราได้ประกาศ alias type ชื่อ CellIndex เป็น Int เพื่อให้โค้ดอ่านเข้าใจขึ้นว่า Int ตรงนี้แทนที่ Index ของช่องที่อยู่ใน Board

จากนั้นเราแค่ทำการ get cell นั้นออกมาจาก Array แล้วก็ set กลับไปใหม่โดยเปลี่ยน chosen เป็น True นั่นเอง

ข้อมูลใน Elm นั้นเป็น immutable ซึ่งการเปลี่ยนแปลง Array เราจะได้ Array ใหม่ออกมา ไม่ต้องกังวลเรื่องการแย่งกันแก้ไขค่าให้ยุ่งยาก

ฟังก์ชันต่อไปที่เราต้องการคือฟังก์ชันที่ทำการ mark choosable เป็น True โดยมี logic ว่า cell นั้นต้องไม่ถูก chosen ไปก่อนแล้ว และ ต้องมีค่าเท่ากับเลขที่สุ่มมา หรือถ้าเลขที่สุ่มคือ FizzBuzz เราก็ให้ cell ที่เป็น Fizz หรือ Buzz เปลี่ยน choosable เป็น True ทั้งคู่

```elm
markCell : FizzBuzzNumber -> BingGoCell -> BingGoCell
markCell num cell =
    if cell.chosen then
        cell

    else
        case ( num, cell.number ) of
            ( FizzBuzz, Fizz ) ->
                { cell | choosable = True }

            ( FizzBuzz, Buzz ) ->
                { cell | choosable = True }

            _ ->
                if num == cell.number then
                    { cell | choosable = True }

                else
                    cell

markChoosable : FizzBuzzNumber -> BingGoBoard -> BingGoBoard
markChoosable number board =
    Array.map (markCell number) board
```

ซึ่ง markChoosable จะรับค่าที่สุ่มได้เข้ามาเป็น parameter แรก แล้วรับ board จากนั้นก็ map แต่ละ cell เพื่อ markCell นั่นเอง

ต่อไปเราต้องมีฟังก์ชัน clearChoosable ซึ่งจะเปลี่ยน choosable กลับเป็น False ทั้งหมด ใช้ตอนที่ผู้เล่นกดเลือก cell เรียบร้อยแล้วในเทิร์นปัจจุบัน รอกดสุ่มเลขถัดไป เพื่อไม่ใช้เปลี่ยนตัวเลขได้นั่นเอง

```elm
clearCell : BingGoCell -> BingGoCell
clearCell cell =
    { cell | choosable = False }


clearChoosable : BingGoBoard -> BingGoBoard
clearChoosable board =
    Array.map clearCell board
```

ก่อนจะไปเรื่องสุ่มตัวเลข เราจะสร้างฟังก์ชันเพื่อเช็คก่อนว่าเกิด BinGo ขึ้นแล้วหรือยัง โดยเราจะเช็ค แนวนอน 5 แถว แนวตั้ง 5 และ แนวทะแยงอีก 2 ถ้าเจอว่าเป็น chosen หมดก็ถือว่า BingGo โดยเราจะ return list ของ index ของแนวนั้นๆออกมา เพื่อเอาไปใช้แสดงผล และ เพื่อเช็คว่า BinGo แล้วหรือยัง โดยถ้ายังไม่ BingGo จะได้ลิสต์ว่างๆ นั่นเอง

```elm
isBingGoLine : List CellIndex -> BingGoBoard -> Bool
isBingGoLine indexes board =
    List.map (\index -> Array.get index board) indexes
        |> List.all
            (\maybeCell ->
                case maybeCell of
                    Nothing ->
                        False

                    Just cell ->
                        cell.chosen
            )


checkBingGoIndexes : BingGoBoard -> List CellIndex
checkBingGoIndexes board =
    if isBingGoLine [ 0, 1, 2, 3, 4 ] board then
        [ 0, 1, 2, 3, 4 ]

    else if isBingGoLine [ 5, 6, 7, 8, 9 ] board then
        [ 5, 6, 7, 8, 9 ]

    else if isBingGoLine [ 10, 11, 12, 13, 14 ] board then
        [ 10, 11, 12, 13, 14 ]

    else if isBingGoLine [ 15, 16, 17, 18, 19 ] board then
        [ 15, 16, 17, 18, 19 ]

    else if isBingGoLine [ 20, 21, 22, 23, 24 ] board then
        [ 20, 21, 22, 23, 24 ]

    else if isBingGoLine [ 0, 5, 10, 15, 20 ] board then
        [ 0, 5, 10, 15, 20 ]

    else if isBingGoLine [ 1, 6, 11, 16, 21 ] board then
        [ 1, 6, 11, 16, 21 ]

    else if isBingGoLine [ 2, 7, 12, 17, 22 ] board then
        [ 2, 7, 12, 17, 22 ]

    else if isBingGoLine [ 3, 8, 13, 18, 23 ] board then
        [ 3, 8, 13, 18, 23 ]

    else if isBingGoLine [ 4, 9, 14, 19, 24 ] board then
        [ 4, 9, 14, 19, 24 ]

    else if isBingGoLine [ 0, 6, 12, 18, 24 ] board then
        [ 0, 6, 12, 18, 24 ]

    else if isBingGoLine [ 4, 8, 12, 16, 20 ] board then
        [ 4, 8, 12, 16, 20 ]

    else
        []
```

# Random Generator
เนื่องจาก Elm เป็น Functional ที่เรียกว่าพยายามให้เราเขียนโค้ดแบบ pure function ให้มากที่สุด แต่ว่าการ Random นั่นจะทำให้ฟังก์ชันเราไม่ pure แน่ๆ ทางออกที่ Elm มีไว้ให้เราก็คือ Random Generator type

ซึ่งเป็น abstract type เมื่อให้เราสร้างฟังก์ชัน ที่จะทำงานเมื่อการการ random ขึ้นจริงๆ เมื่อเอา Random Generator ที่เราสร้างไปประกอบกับ Elm framework ซึ่งจะทำการสุ่มตัวเลขตามที่เรากำหนด spec เอาไว้ใน Generator แล้วสร้าง Cmd Msg type เพื่อเรียก udpate function ในการจัดการ state ของ application อีกทีนึง

ตัวอย่างฟักง์ชัน Generator ง่ายๆเช่น

```elm
randomNumberGenerator : Random.Generator Int
randomNumberGenerator = Random.int 1 99
```

ตัวฟังก์ชัน randomNumberGenerator เองยังคงเป็น pure function เพราะไม่ได้ทำการ random จริงๆตอนเรียกฟังก์ชันนี้ แต่แค่ return Random.Generator ซึ่งเป็น data type ที่เก็บข้อมูล spec ของการ random ในทีนี้เราเรียกฟังก์ชัน Random.int 1 99 ซึ่งจะสุ่มเลขระหว่าง 1 ถึง 99 เมื่อ Elm framework เอา spec นี้ไปใช้งาน นั่นเอง


การ Trigger ให้ Elm runtime สุ่มเลขจริงๆ เราจะเรียกใช้ฟังก์ชัน Random.generate ซึ่งจะรับ function ที่ generate message และ Random Generator จากนั้นจะสร้าง command type Cmd Msg เพื่อบอกให้ Elm runtime random แล้วเรียกฟังก์ชัน update ด้วย message ที่ห่อค่าที่ Random เอาไว้เช่น

```elm
type alias Msg =
    GotRandom Int

generateRandomCmd : Cmd Msg
generateRandomCmd =
    Random.generate GotRandom randomNumberGenerator
```

กลับไปที่ Game ของเรา ในการสร้าง random board เราต้องสุ่มเลขมา 25 ตัว ดังนั้นเลยสร้าง generator สำหรับสุ่มลิสต์ของตัวเลขได้แบบนี้

```elm
randomListInt : Random.Generator (List Int)
randomListInt =
    Random.list 25 (Random.int 1 99)
```

ต่อไปเป็น logic ที่ค่อนข้างซับซ้อน คือถ้าเราได้เลขที่เป็น FizzBuzz เราต้องสุ่มให้แสดงแค่ F หรือ B คือ Fizz หรือ Buzz เท่านั้น ดังนั้นเลยมี logic ที่ต้องสุ่มเลข 0 หรือ 1 ถ้าได้ 0 ให้เป็น Fizz ถ้าได้ 1 ให้เป็น Buzz เราแยกตรงนี้เป็นฟังก์ชันใหม่ชื่อ makeCellFizzOrBuzz ซึ่งมีโค้ดแบบนี้

```elm
makeCellFizzOrBuzz : BingGoCell -> Random.Generator BingGoCell
makeCellFizzOrBuzz cell =
    case cell.number of
        FizzBuzz ->
            Random.int 0 1
                |> Random.andThen
                    (\v ->
                        case v of
                            0 ->
                                Random.constant { cell | number = Fizz }

                            1 ->
                                Random.constant { cell | number = Buzz }

                            _ ->
                                Random.constant cell
                    )

        _ ->
            Random.constant cell
```

เราได้ใช้ฟังก์ชัน Random.andThen เพื่อช่วยร้อยเรียง logic ที่จะเกิดขึ้นหลังจากเลขถูก Random ขึ้นมาแล้ว จะเห็นว่าเป็นเทคนิคนึงที่ทำให้ Elm เป็น pure function เพราะ พอใช้ท่าแบบนี้ การ implements ไม่ต้องอาศัยค่าที่เกิดจากการ Random มาแล้วจริงๆเลย แค่เตรียมฟังก์ชัน ที่จะรับค่า random เป็น parameter แล้ว implements logic ที่ต้องการต่อได้เลย


ต่อไปเป็นส่วนในการ Random BingGoBoard

```elm
randomNewBoard : Random.Generator (Maybe BingGoBoard)
randomNewBoard =
    randomListInt
        |> Random.map
            (\numbers ->
                numbers |> makeBingGoBoard
            )
        |> Random.andThen
            (\maybeBoard ->
                case maybeBoard of
                    Nothing ->
                        Random.constant Nothing

                    Just board ->
                        let
                            cellGenerators =
                                board
                                    |> Array.map makeCellFizzOrBuzz
                        in
                        Array.foldl
                            (\cellGen boardGen ->
                                cellGen
                                    |> Random.andThen
                                        (\cell ->
                                            boardGen
                                                |> Random.andThen
                                                    (\newBoard ->
                                                        Random.constant (Array.push cell newBoard)
                                                    )
                                        )
                            )
                            (Random.constant Array.empty)
                            cellGenerators
                            |> Random.map Just
            )
```

เราเริ่มจากเรียก randomListInt จากนั้นใช้ andThen เพื่อร้อยเรียง logic เหมือนเดิม เริ่มจากเอา list ที่ได้ไปสร้าง board ใหม่ด้วย makeBingGoBoard เสร็จแล้วเราเอา board ได้ที่ได้ ไปปรับค่าของ cell ด้วย makeCellFizzOrBuzz สุดท้ายเราใช้ Array.foldl เพื่อเปลี่ยนจาก type Array (Random.Generator BingGoCell) ให้กลายเป็น Random.Generator BingGoBoard แล้ว map ด้วย Just เข้าไปเพื่อให้เข้าไปอยู่ใน Maybe กลายเป็น Random.Generator (Maybe BingGoCell)

จะเห็นว่า Random.andThen เป็นฟังก์ชัน (combinator) ที่สำคัญมาก ที่ช่วยให้เราร้อยเรียง logic ของการ Random ตัวเลข โดยที่ยังไม่ต้อง Random ตัวเลขนั้นๆขึ้นมาเลยจริงๆด้วยซ้ำ

สุดท้ายอีกฟังก์ชันนึงก็คือ random ตัวเลขในแต่ละเทิร์น เขียน generator ได้แบบนี้

```elm
randomFizzBuzzNumber : Random.Generator FizzBuzzNumber
randomFizzBuzzNumber =
    Random.int 1 99
        |> Random.map toFizzBuzzNumber
```

เราก็ใช้ Random.map เพื่อเปลี่ยนจาก generator ของ Int ให้เป็น FizzBuzzNumber type นั่นเอง

# Application
หลังจากเขียน core ฟังก์ชันต่างๆไปแล้ว เรามาเขียนในส่วนของ Elm Application กัน ซึ่ง Elm Architecture หลักๆต้องการให้เราสร้างฟังก์ชัน 2 ส่วนนั่นคือ view และ update

หน้าที่หลักๆของ view คือเอา Model value ไปแสดงผล, ส่วนของ update นั้นจะรับ model value ล่าสุด พร้อมกับ message value ล่าสุดมา แล้วให้เราตอบกลับ model value ใหม่ที่ต้องการ update และ command ที่ต้องการสั่งให้ Elm runtime ทำงาน

- กลไกก็จะเป็นแบบบนี้ Elm จะเอา model ล่าสุดไปเรียก view ให้แสดงผล
- event ที่เกิดขึ้นจาก view จะทำให้เกิด message ใหม่
- Elm เรียก update พร้อมกับ message ที่เกิดขึ้น
- update เปลี่ยนค่า model ใหม่
- Elm เอา model ใหม่ไปเรียก view เพื่อเปลี่ยนการแสดงผล

หรืออีกสถานการณ์คือ update ตอบกลับ command ให้ Elm runtime ทำงาน flow ก็จะเป็นแบบนี้

- กลไกก็จะเป็นแบบบนี้ Elm จะเอา model ล่าสุดไปเรียก view ให้แสดงผล
- event ที่เกิดขึ้นจาก view จะทำให้เกิด message ใหม่
- Elm เรียก update พร้อมกับ message ที่เกิดขึ้น
- update เปลี่ยนค่า model ใหม่ และ สร้าง command ให้ Elm runtime เอาไปทำ
- Elm เอา command ไปทำงานเช่น command สำหรับ random
- Elm เรียก update อีกรอบหลังจากทำงานตาม command เสร็จพร้อมกับสร้าง Message ที่เป็นผลลัพธ์จากการทำงานของ command
- update ทำงานพร้อมกับเปลี่ยน model ใหม่
- Elm เอา model ใหม่ไปเรียก view ให้ทำการแสดงผล

# Model type
จากโฟล์ของ Elm Application ที่บอกไป เราต้องประกาศ Model type ซึ่งจะป็น type สำหรับเก็บ state ของ Application ของเรานั่นเอง
ในส่วนของเกม FizzBuzz Bing Go เราประกาศ Model type ไว้แบบนี้

```elm
type alias Model =
    { board : BingGoBoard
    , currentNumber : Maybe FizzBuzzNumber
    , bingGoIndexes : List CellIndex
    }
```

โดยเป็น Record ที่ประกอบไปด้วย field
- board เก็บสถานะของ BingGoBoard ปัจจุบัน
- currentNumber เก็บเลขที่ random ในเทิร์นปัจจุบัน
- bingGoIndexes เก็บ List ของ CellIndex ที่ทำให้เกิด Bing Go เอาไว้เช็คด้วยว่าเกิด BingGo แล้วหรือยัง


# Message type
ในส่วนของ Message type จะเป็น type ที่เป็นตัวแทน Event ต่างๆ หรือผลลัพธ์ของ Command ต่างๆ โดยเราสำมารถทำให้ Message ห่อหุ้มค้าของผลลัพธ์ หรือรายละเอียดอื่นๆของ Event ไว้ได้ด้วย

สำหรับเกมส์ของเรา ประกาศ​ Message type ไว้แบบนี้

```elm
type Msg
    = GotRandomBoard (Maybe BingGoBoard)
    | CellChosen CellIndex
    | GenerateNextNumber
    | GotRandomFizzBuzzNumber FizzBuzzNumber
```

โดยประกอบไปด้วย 4 messages ที่เป็นไปได้คือ
- GotRandomBoard (Maybe BingGoBoard), เกิดขึ้นเมื่อ random BingGoBoard เสร็จ
- CellChosen CellIndex, เกิดขึ้นเมื่อผู้เล่นกดเลือก Cell
- GenerateNextNumber, เกิดขึ้นเมื่อผู้เล่นกดปุ่มสุ่มเลขในเทิร์นถัดไป
- GotRandomFizzBuzzNumber FizzBuzzNumber, เกิดขึ้นเมื่อ Elm random เลขในเทิร์นถัดไปเสร็จแล้ว


# Main
ในส่วนของ main ฟังก์ชัน จะเป็นการประกอบร่างส่วนต่างๆเข้าด้วยกันให้ Elm runtime ทำงาน โดยเขียนไว้แบบนี้

```elm
main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initModel, initCmd )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
```

นั่นคือเราจะกำหนดค่า init ซึ่งเป็นฟังก์ชันที่ต้อง return ค่า tuple ออกมาโดยค่าแรกคือ ค่าเริ่มต้นของ Model
ค่าที่สองคือ command เริ่มต้นที่เราจะสั่งให้ Elm runtime ทำงาน

view คือกำหนด view function

update คือกำหนด update function

สุดท้าย subscriptions เราไม่ได้ใช้ตอนนี้เลยทำเป็นฟังก์ชันที่ return Sub.none ออกไปแทน


initModel ของเราเขียนไว้แบบนี้

```elm
initModel : Model
initModel =
    { board = Array.empty
    , currentNumber = Nothing
    , bingGoIndexes = []
    }
```

initCmd เราเขียนไว้ให้สร้าง command เพื่อให้ Elm สร้างบอร์ดใหม่ให้เรานั่นเอง แบบนี้

```elm
initCmd : Cmd Msg
initCmd =
    Random.generate GotRandomBoard randomNewBoard
```

จะเห็นว่า parameter ที่สองคือฟังก์ชัน GotRandomBoard ที่จะรับค่าจำนวนเต็ม เพื่อทำให้เกิด message นั่นเอง ซึ่ง Elm จะใช้สร้าง message เพื่อเรียก update เมื่อทำการ random board ใหม่เสร็จ


# View
ในส่วนของ View เราจะสร้างฟังก์ชันหลักคือ view ซึ่งเราแยกอีกหลายๆฟังก์ชันเมื่อทำหน้าที่แสดงผล HTML ส่วนต่างๆของเกมของเรา ดังนี้

```elm
-- ใช้เพื่อเลือกสี ในกรณีทั่วไปสีขาว, choosable สีแดง, chosen สีเหลือง และตอน Bing Go แล้วแถวที่ทำให้เกิดจะแสดงสี เขียว
cellColor : List CellIndex -> CellIndex -> BingGoCell -> String
cellColor bingGoIndexes index cell =
    if cell.choosable then
        "red"

    else if cell.chosen && List.member index bingGoIndexes then
        "green"

    else if cell.chosen then
        "yellow"

    else
        "white"

-- ใช้แสดง cell ด้วย tag td และใช้สี background ตามเงื่อนไขที่ต้องการโดยการเรียกฟังก์ชัน cellColor
cellView : List CellIndex -> CellIndex -> BingGoCell -> Html.Html Msg
cellView bingGoIndexes index cell =
    let
        color =
            cellColor bingGoIndexes index cell
    in
    if cell.choosable then
        -- เราใช้ onClick attribute และกำหนด message ที่จะถูกส่งไปให้ update เพื่อคลิกที่ปุ่มซึ่งกรณีนี้เราสร้าง CellChosen พร้อมส่ง index ไปด้วย
        td [ style "background-color" color ] [ button [ onClick (CellChosen index) ] [ text (fizzBuzzNumberToStr cell.number) ] ]

    else if cell.chosen then
        td [ style "background-color" color ] [ text (fizzBuzzNumberToStr cell.number) ]

    else
        td [] [ button [] [ text (fizzBuzzNumberToStr cell.number) ] ]


-- ใช้แสดง board 1 แถวใดๆ
boardRowView : List CellIndex -> Int -> BingGoBoard -> Html.Html Msg
boardRowView bingGoIndexes rowIndex board =
    tr []
        (board
            |> Array.indexedMap
                (\index ->
                    cellView bingGoIndexes (rowIndex * 5 + index)
                )
            |> Array.toList
        )


-- ใช้แสดง board โดยใช้ tag table แล้วเรียกฟังก์ชัน boardRowView เพื่อแสดงแต่ละแถวตามช่วย Index ที่ต้องการ
boardView : List CellIndex -> BingGoBoard -> Html.Html Msg
boardView bingGoIndexes board =
    table []
        [ boardRowView bingGoIndexes 0 (Array.slice 0 5 board)
        , boardRowView bingGoIndexes 1 (Array.slice 5 10 board)
        , boardRowView bingGoIndexes 2 (Array.slice 10 15 board)
        , boardRowView bingGoIndexes 3 (Array.slice 15 20 board)
        , boardRowView bingGoIndexes 4 (Array.slice 20 25 board)
        ]


-- ใช้สร้างปุ่มไว้กด random เลขในเทิร์นถัดไป โดยเมื่อกดปุ่มจะเรียก update พร้อม message GenerateNextNumber
randomButton : Bool -> Html.Html Msg
randomButton bingGo =
    if bingGo then
        div [] []

    else
        button [ onClick GenerateNextNumber ] [ text "Next Number" ]


-- ไว้แสดงตัวเลขสุ่มปัจจุบัน
currentNumberView : Maybe FizzBuzzNumber -> Html.Html Msg
currentNumberView number =
    case number of
        Nothing ->
            div [] [ text "Random Number is " ]

        Just n ->
            div [] [ text "Random Number is ", text (fizzBuzzNumberToStr n) ]


-- ไว้แสดงข้อความว่า BingGo เรียบร้อยแล้ว
showBingGo : Bool -> Html.Html Msg
showBingGo bingGo =
    if bingGo then
        h1 [ style "color" "green" ] [ text "BINGO!!!" ]

    else
        div [] []


-- สุดท้าย view เอา UI function ย่อยๆมาประกอบกัน
view : Model -> Html.Html Msg
view model =
    if model.board == Array.empty then
        text ""

    else
        div []
            [ boardView model.bingGoIndexes model.board
            , randomButton (model.bingGoIndexes /= [])
            , currentNumberView model.currentNumber
            , showBingGo (model.bingGoIndexes /= [])
            ]
```

# Update
ส่วนประกอบสุดท้ายแล้ว นั่นคือ update function ที่จะรับ message และ model state ล่าสุดเข้ามา

มีหน้าที่ตอนสนองต่อ message ว่าจะ update model state ใหม่เป็นยังไง หรือ เลือกที่จะส่ง command ไปให้ Elm runtime ทำงาน

สำหรับ Game ของเรา implements ไว้แบบนี้

```elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotRandomBoard maybeBoard ->
            case maybeBoard of
                Nothing ->
                    ( model, Cmd.none )

                Just board ->
                    ( { model | board = board }, Cmd.none )

        CellChosen index ->
            let
                newBoard =
                    chooseCell index model.board
                        |> clearChoosable

                newBingGoIndexes =
                    checkBingGoIndexes newBoard
            in
            ( { model | board = newBoard, bingGoIndexes = newBingGoIndexes }, Cmd.none )

        GenerateNextNumber ->
            ( model, Random.generate GotRandomFizzBuzzNumber randomFizzBuzzNumber )

        GotRandomFizzBuzzNumber number ->
            let
                newBoard =
                    clearChoosable model.board
                        |> markChoosable number
            in
            ( { model | board = newBoard, currentNumber = Just number }, Cmd.none )
```

ซึ่งก็เขียนไว้ตอบสนองกับ message แต่ละแบบ
- GotRandomBoard maybeBoard เมื่อ Elm random board เสร็จก็ update board ให้ model
- GenerateNextNumber เมื่อคนเล่นกดปุ่ม random number เราก็ส่ง command ไปให้ Elm เพื่อ random number
- GotRandomFizzBuzzNumber number เมื่อ Elm gen random number เสร็จ เราก็เอาไปอัพเดท currentNumber พร้อมกับ markChoosable ในแต่ละ cell
- CellChosen index เมื่อคนเล่นกดเลือก cell เราก็กำหนด chosen ให้ cell นั้นๆ แล้วก็ทำการ clear choosable พร้อมกับเช็คล่า bingGoIndexes ล่าสุด เพื่อดูว่า BingGo แล้วหรือยัง


# สรุป
จากการหัดเขียน Elm ซึ่งเป็นภาษา Pure Functional สำหรับสร้าง Web Application จะพบว่าเราถูกบังคับให้คิดแบบ Functional มากๆ คือแทนที่เราจะนึงถึง state ที่เก็บในตัวแปร แล้วเขียนโค้ดเพื่อจัดการค่าในตัวแปร เราต้องนึงถึง Flow ของข้อมูลที่เขามาเป็น parameter แล้วก็ output ที่ return ออกไปจากฟังก์ชันแทน

ส่วนการจัดการ side effect เช่นการสุ่มตัวเลข Elm runtime มีหน้าที่ทำให้เกิด side effect หรือเป็นคนรัน Cmd จริงๆ ส่วนโปรแกรมเมอร์ มีหน้าที่แค่เขียน function เพื่อบอกรายละเอียดว่าอยากให้ side effect ที่เกิดขึ้นนั้นเกิดแบบไหน เช่น Elm มี Random Generator เพื่อเขียนรายละเอียดของการสุ่ม และมี Random combinator function เช่น Random.map, Random.andThen ไว้ให้เราร้อยเรียงการทำงานที่เราต้องการทำกับค่า Random ที่เกิดขึ้น

Elm application architecture เองนั้นก็ให้เราเขียน web application ได้โดยเขียน pure function ของการแสดงผล คือเขียน view function และ เขียน logic การเปลี่ยนผ่านของ state model ด้วยการเขียนฟังก์ชัน update ที่จะต้องจัดการ message ที่เกิดขึ้นนั่นเอง
