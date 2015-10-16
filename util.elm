module Connect4.Util (apply, (!!)) where

apply : a -> List (a -> b) -> List b
apply argument functions =
  case functions of
    [] -> []
    (f::fs) -> (f argument) :: (apply argument fs)


(!!) : List a -> Int -> M.Maybe a
xs !! n = 
  if | n < 0     -> Nothing
     | otherwise -> case (xs,n) of
         ([],_)    -> Nothing
         (x::xs,0) -> Just x
         (_::xs,n) -> xs !! (n-1)
