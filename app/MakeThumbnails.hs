module Main where

import Control.Monad (forM_, when)
import Data.List (isSuffixOf, isPrefixOf, intercalate)
import System.Directory (doesFileExist, listDirectory)
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.FilePath (takeBaseName, takeExtension, (</>))
import System.Process (callProcess)

imgDir :: FilePath
imgDir = "assets/img"

defaultWidth :: String
defaultWidth = "300"

imageExts :: [String]
imageExts = [".jpg", ".jpeg", ".png", ".webp", ".gif", ".JPG"]

isThumbnail :: FilePath -> Bool
isThumbnail f = "_thumbnail" `isSuffixOf` takeBaseName f

isImage :: FilePath -> Bool
isImage f = takeExtension f `elem` imageExts

thumbnailPath :: FilePath -> FilePath -> FilePath
thumbnailPath dir f =
  let base = takeBaseName f
      ext  = takeExtension f
  in dir </> (base ++ "_thumbnail" ++ ext)

main :: IO ()
main = do
  args <- getArgs
  let (width, force, targets) = parseArgs args

  files <- case targets of
    [] -> do
      entries <- listDirectory imgDir
      let imgs = filter (\f -> isImage f && not (isThumbnail f)) entries
      pure (map (imgDir </>) imgs)
    fs -> pure fs

  when (null files) $ do
    putStrLn "No images found."

  forM_ files $ \src -> do
    let dir  = imgDir
        dest = thumbnailPath dir (takeBaseName src ++ takeExtension src)
    exists <- doesFileExist dest
    if exists && not force
      then putStrLn $ "Skipping " ++ src ++ " (thumbnail already exists, use --force to override)"
      else do
        putStrLn $ "Thumbnailing " ++ src ++ " -> " ++ dest
        callProcess "magick" [src, "-auto-orient", "-resize", width ++ "x>", "-strip", dest]

parseArgs :: [String] -> (String, Bool, [FilePath])
parseArgs = go defaultWidth False
  where
    go w f ("--width" : n : rest) = go n f rest
    go w f ("--force" : rest)     = go w True rest
    go w f args                   = (w, f, args)
