module Main exposing (..)

import Array exposing (Array)
import Browser
import Html exposing (button, div, table, td, text, tr)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Random
import Html exposing (h1)


type FizzBuzzNumber
    = Fizz
    | Buzz
    | FizzBuzz
    | Number Int


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


fizzBuzzNumberToStr : FizzBuzzNumber -> String
fizzBuzzNumberToStr number =
    case number of
        Fizz ->
            "F"

        Buzz ->
            "B"

        FizzBuzz ->
            "FB"

        Number n ->
            String.fromInt n


type alias BingoCell =
    { number : FizzBuzzNumber
    , chosen : Bool
    , choosable : Bool
    }


type alias BingoBoard =
    Array BingoCell


makeBingoBoard : List Int -> Maybe BingoBoard
makeBingoBoard nums =
    let
        makeCell num =
            { number = toFizzBuzzNumber num, chosen = False, choosable = False }
    in
    if List.length nums /= 25 then
        Nothing

    else
        Just (Array.fromList (List.map makeCell nums))


chooseCell : CellIndex -> BingoBoard -> BingoBoard
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


markCell : FizzBuzzNumber -> BingoCell -> BingoCell
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


markChoosable : FizzBuzzNumber -> BingoBoard -> BingoBoard
markChoosable number board =
    Array.map (markCell number) board


clearCell : BingoCell -> BingoCell
clearCell cell =
    { cell | choosable = False }


clearChoosable : BingoBoard -> BingoBoard
clearChoosable board =
    Array.map clearCell board


isBingoLine : List CellIndex -> BingoBoard -> Bool
isBingoLine indexes board =
    List.map (\index -> Array.get index board) indexes
        |> List.all
            (\maybeCell ->
                case maybeCell of
                    Nothing ->
                        False

                    Just cell ->
                        cell.chosen
            )


checkBingoIndexes : BingoBoard -> List CellIndex
checkBingoIndexes board =
    if isBingoLine [ 0, 1, 2, 3, 4 ] board then
        [ 0, 1, 2, 3, 4 ]

    else if isBingoLine [ 5, 6, 7, 8, 9 ] board then
        [ 5, 6, 7, 8, 9 ]

    else if isBingoLine [ 10, 11, 12, 13, 14 ] board then
        [ 10, 11, 12, 13, 14 ]

    else if isBingoLine [ 15, 16, 17, 18, 19 ] board then
        [ 15, 16, 17, 18, 19 ]

    else if isBingoLine [ 20, 21, 22, 23, 24 ] board then
        [ 20, 21, 22, 23, 24 ]

    else if isBingoLine [ 0, 5, 10, 15, 20 ] board then
        [ 0, 5, 10, 15, 20 ]

    else if isBingoLine [ 1, 6, 11, 16, 21 ] board then
        [ 1, 6, 11, 16, 21 ]

    else if isBingoLine [ 2, 7, 12, 17, 22 ] board then
        [ 2, 7, 12, 17, 22 ]

    else if isBingoLine [ 3, 8, 13, 18, 23 ] board then
        [ 3, 8, 13, 18, 23 ]

    else if isBingoLine [ 4, 9, 14, 19, 24 ] board then
        [ 4, 9, 14, 19, 24 ]

    else if isBingoLine [ 0, 6, 12, 18, 24 ] board then
        [ 0, 6, 12, 18, 24 ]

    else if isBingoLine [ 4, 8, 12, 16, 20 ] board then
        [ 4, 8, 12, 16, 20 ]

    else
        []


randomListInt : Random.Generator (List Int)
randomListInt =
    Random.list 25 (Random.int 1 99)


makeCellFizzOrBuzz : BingoCell -> Random.Generator BingoCell
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


randomNewBoard : Random.Generator (Maybe BingoBoard)
randomNewBoard =
    randomListInt
        |> Random.map
            (\numbers ->
                numbers |> makeBingoBoard
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


randomFizzBuzzNumber : Random.Generator FizzBuzzNumber
randomFizzBuzzNumber =
    Random.int 1 99
        |> Random.map toFizzBuzzNumber



----------------------------------------------


cellColor : List CellIndex -> CellIndex -> BingoCell -> String
cellColor bingoIndexes index cell =
    if cell.choosable then
        "red"

    else if cell.chosen && List.member index bingoIndexes then
        "green"

    else if cell.chosen then
        "yellow"

    else
        "white"


cellView : List CellIndex -> CellIndex -> BingoCell -> Html.Html Msg
cellView bingoIndexes index cell =
    let
        color =
            cellColor bingoIndexes index cell
    in
    if cell.choosable then
        td [ style "background-color" color ] [ button [ onClick (CellChosen index) ] [ text (fizzBuzzNumberToStr cell.number) ] ]

    else if cell.chosen then
        td [ style "background-color" color ] [ text (fizzBuzzNumberToStr cell.number) ]

    else
        td [] [ button [] [ text (fizzBuzzNumberToStr cell.number) ] ]


boardRowView : List CellIndex -> Int -> BingoBoard -> Html.Html Msg
boardRowView bingoIndexes rowIndex board =
    tr []
        (board
            |> Array.indexedMap
                (\index ->
                    cellView bingoIndexes (rowIndex * 5 + index)
                )
            |> Array.toList
        )


boardView : List CellIndex -> BingoBoard -> Html.Html Msg
boardView bingoIndexes board =
    table []
        [ boardRowView bingoIndexes 0 (Array.slice 0 5 board)
        , boardRowView bingoIndexes 1 (Array.slice 5 10 board)
        , boardRowView bingoIndexes 2 (Array.slice 10 15 board)
        , boardRowView bingoIndexes 3 (Array.slice 15 20 board)
        , boardRowView bingoIndexes 4 (Array.slice 20 25 board)
        ]


randomButton : Bool -> Html.Html Msg
randomButton bingo =
    if bingo then
        div [] []

    else
        button [ onClick GenerateNextNumber ] [ text "Next Number" ]


currentNumberView : Maybe FizzBuzzNumber -> Html.Html Msg
currentNumberView number =
    case number of
        Nothing ->
            div [] [ text "Random Number is " ]

        Just n ->
            div [] [ text "Random Number is ", text (fizzBuzzNumberToStr n) ]


showBingo : Bool -> Html.Html Msg
showBingo bingo =
    if bingo then
        h1 [ style "color" "green" ] [ text "BINGO!!!" ]

    else
        div [] []


view : Model -> Html.Html Msg
view model =
    if model.board == Array.empty then
        text ""

    else
        div []
            [ boardView model.bingoIndexes model.board
            , randomButton (model.bingoIndexes /= [])
            , currentNumberView model.currentNumber
            , showBingo (model.bingoIndexes /= [])
            ]


type alias Model =
    { board : BingoBoard
    , currentNumber : Maybe FizzBuzzNumber
    , bingoIndexes : List CellIndex
    }


initModel : Model
initModel =
    { board = Array.empty
    , currentNumber = Nothing
    , bingoIndexes = []
    }


type alias CellIndex =
    Int


type Msg
    = GotRandomBoard (Maybe BingoBoard)
    | CellChosen CellIndex
    | GenerateNextNumber
    | GotRandomFizzBuzzNumber FizzBuzzNumber


initCmd : Cmd Msg
initCmd =
    Random.generate GotRandomBoard randomNewBoard


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

                newBingoIndexes =
                    checkBingoIndexes newBoard
            in
            ( { model | board = newBoard, bingoIndexes = newBingoIndexes }, Cmd.none )

        GenerateNextNumber ->
            ( model, Random.generate GotRandomFizzBuzzNumber randomFizzBuzzNumber )

        GotRandomFizzBuzzNumber number ->
            let
                newBoard =
                    clearChoosable model.board
                        |> markChoosable number
            in
            ( { model | board = newBoard, currentNumber = Just number }, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initModel, initCmd )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
