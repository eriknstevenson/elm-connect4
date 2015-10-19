module Connect4.Model ( Action(None, MakeMove)
                      , Player(Player1, Player2)
                      , Board
                      , SpaceStatus(Empty, Red, Blue)
                      , Space
                      , newSpace
                      , Model
                      , initialModel ) where

import List as L

-- MODEL

type Action 
  = None 
  | MakeMove Int


type Player 
  = Player1
  | Player2


type alias Board = List Space


type SpaceStatus
  = Empty 
  | Red
  | Blue


type alias Space = 
  { status : SpaceStatus
  , id : Int
  }


newSpace : Space
newSpace = 
  { status = Empty
  , id = -1
  }


type alias Model = 
  { board : Board
  , turn : Player
  , winner : Maybe Player
  , gameOver : Bool }


initialModel : Model
initialModel =
  { board = L.map2 (\spc nId -> { spc | id <- nId })
            (L.repeat 42 newSpace) [0..41]
  , turn = Player1
  , winner = Nothing
  , gameOver = False }
