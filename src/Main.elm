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


type alias BingGoCell =
    { number : FizzBuzzNumber
    , chosen : Bool
    , choosable : Bool
    }


type alias BingGoBoard =
    Array BingGoCell


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


clearCell : BingGoCell -> BingGoCell
clearCell cell =
    { cell | choosable = False }


clearChoosable : BingGoBoard -> BingGoBoard
clearChoosable board =
    Array.map clearCell board


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


randomListInt : Random.Generator (List Int)
randomListInt =
    Random.list 25 (Random.int 1 99)


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


randomFizzBuzzNumber : Random.Generator FizzBuzzNumber
randomFizzBuzzNumber =
    Random.int 1 99
        |> Random.map toFizzBuzzNumber



----------------------------------------------


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


cellView : List CellIndex -> CellIndex -> BingGoCell -> Html.Html Msg
cellView bingGoIndexes index cell =
    let
        color =
            cellColor bingGoIndexes index cell
    in
    if cell.choosable then
        td [ style "background-color" color ] [ button [ onClick (CellChosen index) ] [ text (fizzBuzzNumberToStr cell.number) ] ]

    else if cell.chosen then
        td [ style "background-color" color ] [ text (fizzBuzzNumberToStr cell.number) ]

    else
        td [] [ button [] [ text (fizzBuzzNumberToStr cell.number) ] ]


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


boardView : List CellIndex -> BingGoBoard -> Html.Html Msg
boardView bingGoIndexes board =
    table []
        [ boardRowView bingGoIndexes 0 (Array.slice 0 5 board)
        , boardRowView bingGoIndexes 1 (Array.slice 5 10 board)
        , boardRowView bingGoIndexes 2 (Array.slice 10 15 board)
        , boardRowView bingGoIndexes 3 (Array.slice 15 20 board)
        , boardRowView bingGoIndexes 4 (Array.slice 20 25 board)
        ]


randomButton : Bool -> Html.Html Msg
randomButton bingGo =
    if bingGo then
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


showBingGo : Bool -> Html.Html Msg
showBingGo bingGo =
    if bingGo then
        h1 [ style "color" "green" ] [ text "BINGO!!!" ]

    else
        div [] []


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


type alias Model =
    { board : BingGoBoard
    , currentNumber : Maybe FizzBuzzNumber
    , bingGoIndexes : List CellIndex
    }


initModel : Model
initModel =
    { board = Array.empty
    , currentNumber = Nothing
    , bingGoIndexes = []
    }


type alias CellIndex =
    Int


type Msg
    = GotRandomBoard (Maybe BingGoBoard)
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


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initModel, initCmd )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
