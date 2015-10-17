module Connect4.Update (update) where

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

        toggleTurn : Player -> Player
        toggleTurn player = 
          case player of
            Player1 -> Player2
            Player2 -> Player1
    
      in case model.gameOver of
        False -> {model | board <- updatedBoard
                        , turn <- (toggleTurn model.turn)
                        , winner <- checkForWinner
                        , gameOver <- updatedGameOver }
        True -> model
