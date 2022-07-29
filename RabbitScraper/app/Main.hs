{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad (forM_)
import Control.Concurrent.Async (concurrently)

-- for dl - this is normally modualrized out
import           Control.Monad.Trans.Resource (runResourceT)
import           Data.Conduit.Combinators     (sinkFile)
import           Network.HTTP.Conduit         (parseRequest, responseStatus, responseStatus)
import           Network.HTTP.Simple          (httpSink, getResponseStatusCode, httpLBS)



readLines :: FilePath -> IO [String]
readLines = fmap lines . readFile

-- ipfsUrlStart = "http://infura-ipfs.io/ipfs/" :: String
ipfsUrlStart = "http://image-optimizer.jpgstoreapis.com/" :: String


addStrings :: String  -> String
addStrings _x = ipfsUrlStart ++ _x

-- returns pair of lists
splitHalf :: [a] -> ([a], [a])
splitHalf _list = splitAt ((length _list + 1) `div` 2) _list

main :: IO ()
main = do
  ipfsEndings <- readLines "rabbits_ipfs_locs.txt"

  let ifpsPair = splitHalf ipfsEndings
  let batchPairOne = splitHalf $ fst ifpsPair
  let batchPairTwo = splitHalf $ snd ifpsPair

  let b1 = fst batchPairOne
  let b2 = snd batchPairOne
  let b3 = fst batchPairTwo
  let b4 = snd batchPairTwo

  
  print $ length ipfsEndings

  -- forM_ ipfsEndings $ \x ->   putStrLn $ show $ addStrings x

  concurrently (
    concurrently ( forM_ b1 $ \x ->   dlFile (addStrings x) "imgs" x) ( forM_ b2 $ \x ->   dlFile (addStrings x) "imgs" x))( 
    concurrently ( forM_ b4 $ \x ->   dlFile (addStrings x) "imgs" x) ( forM_ b3 $ \x ->   dlFile (addStrings x) "imgs" x))

  print $ "\n FINISHED FETCHING"

-- code below is from another project and needs to be modularized

dYlw  = "\ESC[2;1;33m"
bYlw  = "\ESC[1;33m"
bCyan = "\ESC[0;1;36m"
bRed     = "\ESC[0;1;31m"

alt    = "\ESC[38;5;65m"
alt2    = "\ESC[38;5;69m"

clr    = "\ESC[0m"

dlFile :: String -> String -> String  -> IO ()
dlFile _url _filePath _fileName  = do
  print _url
  request <- parseRequest _url
  resp2 <- httpLBS request

  let status = getResponseStatusCode resp2
  putStrLn $ "\nThe status code was: " ++ bYlw ++ show status ++ clr

  if status == 200 then do
    putStrLn (bCyan++"   DOWNLOADING: "++clr ++ _url ++ "\n      to: " ++  (_filePath++"/"++_fileName) ++ "\n")
    runResourceT $ httpSink request $ \_ -> sinkFile (_filePath++"/"++_fileName)
  else putStrLn (bRed++"   FAILED DOWNLOADING: "++clr ++ _url ++ "\n      FAILED to: " ++  (_filePath++"/"++_fileName) ++ "\n")