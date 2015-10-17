module Connect4.Model (Action, Player, Board, SpaceStatus, Space, newSpace, Model, initialModel) where

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
  , pos : {x : Int, y : Int}
  }


newSpace : Space
newSpace = 
  { status = Empty
  , id = 0
  , pos = { x=0, y=0 }
  }


type alias Model = 
  { board : Board
  , turn : Player
  , winner : Maybe Player
  , gameOver : Bool }


initialModel : Model
initialModel =
  let
    calcPos id =
      { x = (id-1) % 7
      , y = ((toFloat id)-1) / 7 |> floor }
  in
    { board = L.map2 (\spc nId -> { spc | id <- nId, pos <- calcPos nId  })
      (L.repeat 42 newSpace) [1..42]
    , turn = Player1
    , winner = Nothing
    , gameOver = False }
