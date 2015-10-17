module Connect4 where


{-| A simple reimagination of the classic game, using the HTML module.

#Functions
@docs view, update

-}


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Array as A
import Signal as S
import List as L
import List.Extra as LE
import Maybe as M

import Connect4.Util exposing (..)

-- MODEL

type Action 
  = None 
  | MakeMove Int


type Player 
  = Player1
  | Player2


toggleTurn : Player -> Player
toggleTurn player = 
  case player of
    Player1 -> Player2
    Player2 -> Player1


type alias Board = List Space


convertTo2D : List a -> Int -> List (List a)
convertTo2D board size = 
  let 
    splitEvery n list = 
      case list of
        [] -> []
        list -> let (first, rest) = LE.splitAt n list
                in first :: (splitEvery n rest)
  in
    splitEvery size board

type SpaceStatus
  = Empty 
  | Red
  | Blue


type alias Space = 
  { status : SpaceStatus
  , id : Int
  , pos : {x : Int, y : Int}
  }


newSpace : Space
newSpace = 
  { status = Empty
  , id = 0
  , pos = { x=0, y=0 }
  }


calcPos id =
  { x = (id-1) % 7
  , y = ((toFloat id)-1) / 7 |> floor }


type alias Model = 
  { board : Board
  , turn : Player
  , winner : Maybe Player
  , gameOver : Bool }


initialModel : Model
initialModel =
  { board = L.map2 (\spc nId -> { spc | id <- nId, pos <- calcPos nId  })
    (L.repeat 42 newSpace) [1..42]
  , turn = Player1
  , winner = Nothing
  , gameOver = False }

{-| Takes an action and a model and delivers an updated model.
-}
update : Action -> Model -> Model
update action model =
  case action of
    None -> model
    
    MakeMove id ->
      let
        updateStatus space = 
          if space.id==id then 
            { space | status <- newStatus} 
          else 
            space

        newStatus = case model.turn of 
          Player1 -> Red
          Player2 -> Blue

        updatedBoard = L.map updateStatus model.board

        updatedBoardStatus = L.map .status updatedBoard

        convertedBoard = convertTo2D updatedBoardStatus 7

        isThereAWinner = checks
                         |> L.filter (\n->n>=3)
                         |> L.isEmpty
                         |> not

        checkForWinner = case isThereAWinner of
          True -> Just model.turn
          False -> Nothing           

                   
        checks =
          case move of
            Nothing -> []
            Just pos ->
              apply pos
                      [ checkVerticals
                      , checkHorizontals
                      , checkDiagonalsA
                      , checkDiagonalsB ]

        move : Maybe {x:Int, y:Int}
        move =
          case model.board !! id of
            Nothing -> Nothing
            Just space ->
              Just space.pos
      
        checkVerticals pos = 
          L.sum [ checkDir (pos.x, pos.y) (0, -1) 1
                , checkDir (pos.x, pos.y) (0, 1) 1 ] - 1

        checkHorizontals pos = 
          L.sum [ checkDir (pos.x, pos.y) (-1, 0) 1
                , checkDir (pos.x, pos.y) (1, 0) 1 ] - 1

        checkDiagonalsA pos = 
          L.sum [ checkDir (pos.x, pos.y) (-1, -1) 1
                , checkDir (pos.x, pos.y) (1, 1) 1 ] - 1
        
        checkDiagonalsB pos = 
          L.sum [ checkDir (pos.x, pos.y) (1, -1) 1
                , checkDir (pos.x, pos.y) (-1, 1) 1 ] - 1
        
        checkDir : (Int, Int) -> (Int, Int) -> Int -> Int
        checkDir (x, y) (dx, dy) total = 
          case (M.withDefault [] (convertedBoard !! (y+dy)) !! (x+dx)) of
            Nothing -> total
            Just sqr -> 
              if sqr==newStatus then
                checkDir (x+dx, y+dy) (dx,dy) (total+1)
              else
                total
        
        updatedGameOver = 
          (updatedBoardStatus |> LE.notMember Empty ) || checkForWinner /= Nothing

      in case model.gameOver of
        False -> {model | board <- updatedBoard
                        , turn <- (toggleTurn model.turn)
                        , winner <- checkForWinner
                        , gameOver <- updatedGameOver }
        True -> model

{-| This function converts a model into some Html and Styles.
-}
view : S.Address Action -> Model -> Html
view address model = 
  let
    makeSpace : Space -> Html
    makeSpace space =
      case space.status of
        Empty -> div [ class "empty",
                 onClick address (MakeMove space.id) ] []
        Red -> div [class "x"]
          [text "X"]
        Blue -> div [class "o"]
          [text "O"]
    
    winnerToString : Maybe Player -> String
    winnerToString winner =
      case winner of
        Nothing -> "Nobody won.. -.-"
        Just Player1 -> "Player 1 won! XD"
        Just Player2 -> "Player 2 won! XD"

  in
    div [] 
      [ div [id "board"] (L.map makeSpace model.board)
      , div [class "notice"] 
          (case model.gameOver of
            False -> [text "Connect 4"]
            True ->
              [ ul []
                [ li [] [text "game over"]
                , li [] [text <| winnerToString model.winner]
                , li [] [text "click refresh to try again"] ]
              ]
          )
        ]


inbox : Signal.Mailbox Action
inbox = Signal.mailbox None
        
            
--main : Signal Html
main =
  let
    model = S.foldp update initialModel inbox.signal
  in
    S.map (view inbox.address) model

       
