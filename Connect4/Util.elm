module Connect4.Util (apply, (!!)) where

{-| random utility functions used by the Connect4 game.

# Helper functions
@docs apply, (!!)

-}

-- Native Imports
import Maybe as M


{-| Apply an argument to each function in a list.
-}
apply : a -> List (a -> b) -> List b
apply argument functions =
  case functions of
    [] -> []
    (f::fs) -> (f argument) :: (apply argument fs)


{-|  Implementation of Haskell's List index operator
-}
(!!) : List a -> Int -> M.Maybe a
xs !! n = 
  if | n < 0     -> Nothing
     | otherwise -> case (xs,n) of
         ([],_)    -> Nothing
         (x::xs,0) -> Just x
         (_::xs,n) -> xs !! (n-1)
